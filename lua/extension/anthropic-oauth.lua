local uv = vim.uv or vim.loop
local Job = require("plenary.job")
local anthropic = require("codecompanion.adapters.http.anthropic")
local config = require("codecompanion.config")
local curl = require("plenary.curl")
local log = require("codecompanion.utils.log")

-- Module-level API key cache
local _api_key = nil
local _api_key_loaded = false

-- OAuth flow constant configuration
local OAUTH_CONFIG = {
    CLIENT_ID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e", -- OAuth client ID
    REDIRECT_URI = "https://console.anthropic.com/oauth/code/callback", -- Authorization callback URL
    AUTH_URL = "https://console.anthropic.com/oauth/authorize", -- Authorization request URL
    TOKEN_URL = "https://api.anthropic.com/v1/oauth/token", -- Token exchange URL
    API_KEY_URL = "https://api.anthropic.com/api/oauth/claude_cli/create_api_key", -- API key creation URL
    SCOPES = "org:create_api_key user:profile user:inference", -- Requested permission scopes
}

local DEFAULT_API_VERSION = (anthropic.headers and anthropic.headers["anthropic-version"]) or "2023-06-01"

local REQUIRED_BETA_FLAGS = {
    "oauth-2025-04-20",
}

local function trim(str)
    if type(str) ~= "string" then
        return ""
    end
    if vim.trim then
        return vim.trim(str)
    end
    return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

---@param headers table
---@param flag string
local function ensure_beta_flag(headers, flag)
    if not flag or flag == "" then
        return
    end
    headers["anthropic-beta"] = headers["anthropic-beta"] or ""
    local current = headers["anthropic-beta"]
    local pattern = string.format("(^|,)%s(,|$)", vim.pesc(flag))
    if current == "" then
        headers["anthropic-beta"] = flag
    elseif not current:match(pattern) then
        headers["anthropic-beta"] = current .. "," .. flag
    end
end

---@param path string
---@param length number
---@return string|nil
local function read_random_from_file(path, length)
    if not uv then
        return nil
    end
    -- Skip on Windows, use PowerShell instead
    if vim.fn.has("win32") == 1 then
        return nil
    end
    -- Use "r" flag (read mode) not "rb" for uv.fs_open
    local fd = uv.fs_open(path, "r", 438)
    if not fd then
        return nil
    end
    local data = uv.fs_read(fd, length, 0)
    uv.fs_close(fd)
    return data
end

---@param length number
---@return string|nil
local function read_random_from_windows(length)
    if vim.fn.has("win32") == 0 then
        return nil
    end

    local ps_exe = nil
    if vim.fn.executable("pwsh") == 1 then
        ps_exe = "pwsh"
    elseif vim.fn.executable("powershell") == 1 then
        ps_exe = "powershell"
    end
    if not ps_exe then
        return nil
    end

    local script = string.format(
        "$bytes = New-Object byte[] %d; "
            .. "[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes); "
            .. "[System.Convert]::ToBase64String($bytes)",
        length
    )
    local result = vim.fn.system({ ps_exe, "-NoProfile", "-Command", script })
    if vim.v.shell_error ~= 0 then
        return nil
    end

    local ok, decoded = pcall(vim.base64.decode, trim(result))
    if ok and decoded and #decoded >= length then
        return decoded:sub(1, length)
    end
    return nil
end

---@param length number
---@return string|nil
local function read_random_from_openssl(length)
    if vim.fn.executable("openssl") == 0 then
        return nil
    end
    local result = vim.fn.system({ "openssl", "rand", "-base64", tostring(length) })
    if vim.v.shell_error ~= 0 then
        return nil
    end
    local ok, decoded = pcall(vim.base64.decode, trim(result))
    if ok and decoded and #decoded >= length then
        return decoded:sub(1, length)
    end
    return nil
end

---@param length number
---@return string|nil
local function secure_random_bytes(length)
    local readers = {
        function()
            return read_random_from_file("/dev/urandom", length)
        end,
        function()
            return read_random_from_windows(length)
        end,
        function()
            return read_random_from_openssl(length)
        end,
    }

    for _, reader in ipairs(readers) do
        local ok, bytes = pcall(reader)
        if ok and bytes and #bytes >= length then
            return bytes:sub(1, length)
        end
    end

    return nil
end

---@param hex string
---@return string|nil
local function hex_to_binary(hex)
    if not hex or hex == "" then
        return nil
    end
    local ok, binary = pcall(function()
        return hex:gsub("..", function(cc)
            local byte = tonumber(cc, 16)
            return byte and string.char(byte) or ""
        end)
    end)
    if ok and binary and binary ~= "" then
        return binary
    end
    return nil
end

---@return string|nil
local function sha256_binary_openssl(input)
    if vim.fn.executable("openssl") == 0 then
        return nil
    end

    local job = Job:new({
        command = "openssl",
        args = { "dgst", "-sha256", "-binary" },
        writer = input,
        enable_recording = true,
        env = vim.fn.has("win32") == 1 and {
            PATH = vim.env.PATH,
            SYSTEMROOT = vim.env.SYSTEMROOT,
        } or nil,
    })

    local success = pcall(function()
        job:sync(3000)
    end)

    if not success or job.code ~= 0 then
        log:warn(
            "OpenSSL command execution failed, error code: %s, stderr: %s",
            job.code or "unknown",
            table.concat(job:stderr_result() or {}, "\n")
        )
        return nil
    end

    local result = job:result()
    if not result then
        return nil
    end

    local hash_binary
    if vim.fn.has("win32") == 1 then
        hash_binary = ""
        for _, line in ipairs(result) do
            if line and line ~= "" then
                hash_binary = hash_binary .. line
            end
        end
    else
        hash_binary = table.concat(result or {}, "")
    end

    if not hash_binary or hash_binary == "" then
        return nil
    end
    return hash_binary
end

---@return string|nil
local function sha256_binary_vimfn(input)
    if vim.fn.exists("*sha256") ~= 1 then
        return nil
    end
    local ok, hash_hex = pcall(vim.fn.sha256, input)
    if not ok or not hash_hex or hash_hex == "" then
        return nil
    end
    return hex_to_binary(hash_hex)
end

-- URL encoding function for building OAuth URL parameters
---@param str string
---@return string
local function url_encode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

-- Generate cryptographically secure random string for PKCE
-- PKCE (Proof Key for Code Exchange) is a security extension for OAuth 2.0
---@param length number
---@return string
local function generate_random_string(length)
    local bytes = secure_random_bytes(length)
    if not bytes then
        log:error(
            "Anthropic OAuth: Unable to generate secure random bytes, please ensure system provides secure random source (e.g. /dev/urandom, PowerShell, or OpenSSL)"
        )
        return nil
    end

    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    local result = {}
    for i = 1, length do
        local byte = bytes:byte(i)
        local rand_index = (byte % #chars) + 1
        result[i] = chars:sub(rand_index, rand_index)
    end
    return table.concat(result)
end

-- Generate SHA256 hash required for PKCE challenge (base64url format)
---@param input string
---@return string
local function sha256_base64url(input)
    local hash_binary = sha256_binary_openssl(input) or sha256_binary_vimfn(input)
    if not hash_binary then
        log:error("Anthropic OAuth: Unable to generate PKCE hash, please ensure system supports OpenSSL or built-in sha256")
        return nil
    end

    local base64 = vim.base64.encode(hash_binary)
    return base64:gsub("[+/=]", { ["+"] = "-", ["/"] = "_", ["="] = "" })
end

-- Generate PKCE code verifier and challenge
---@return { verifier: string, challenge: string }
local function generate_pkce()
    local verifier = generate_random_string(128) -- Use maximum length for better security
    if not verifier then
        return nil
    end
    local challenge = sha256_base64url(verifier)
    if not challenge then
        return nil
    end
    return {
        verifier = verifier,
        challenge = challenge,
    }
end

-- Find data path for storing OAuth tokens
-- Supports custom path via environment variable
---@return string|nil
local function find_data_path()
    -- First check environment variable
    local env_path = os.getenv("CODECOMPANION_ANTHROPIC_TOKEN_PATH")
    if env_path and vim.fn.isdirectory(vim.fs.dirname(env_path)) > 0 then
        return vim.fs.dirname(env_path)
    end

    -- Use Neovim data directory (cross-platform compatible)
    local nvim_data = vim.fn.stdpath("data")
    if nvim_data and vim.fn.isdirectory(nvim_data) > 0 then
        return nvim_data
    end

    return nil
end

-- Get OAuth token file path
-- Use cross-platform path separator
---@return string|nil
local function get_token_file_path()
    local data_path = find_data_path()
    if not data_path then
        log:error("Anthropic OAuth: Unable to determine data directory")
        return nil
    end

    -- Use vim.fs.joinpath to ensure cross-platform path compatibility
    local path_sep = package.config:sub(1, 1) -- Get system path separator
    return data_path .. path_sep .. "anthropic_oauth.json"
end

-- Load API key from file
---@return string|nil
local function load_api_key()
    if _api_key_loaded then
        return _api_key
    end

    _api_key_loaded = true

    local token_file = get_token_file_path()
    if not token_file or vim.fn.filereadable(token_file) == 0 then
        return nil
    end

    local success, content = pcall(vim.fn.readfile, token_file)
    if not success or not content or #content == 0 then
        log:debug("Anthropic OAuth: Unable to read token file or file is empty")
        return nil
    end

    local decode_success, data = pcall(vim.json.decode, table.concat(content, "\n"))
    if decode_success and data and data.api_key then
        _api_key = data.api_key
        return data.api_key
    else
        log:warn("Anthropic OAuth: Invalid token file format")
        return nil
    end
end

-- Save API key to file
---@param api_key string
---@return boolean
local function save_api_key(api_key)
    if not api_key or api_key == "" then
        log:error("Anthropic OAuth: Cannot save empty API key")
        return false
    end

    local token_file = get_token_file_path()
    if not token_file then
        return false
    end

    local data = {
        api_key = api_key,
        created_at = os.time(),
        version = 1, -- Version number for potential future data migration
    }

    local success, json_data = pcall(vim.json.encode, data)
    if not success then
        log:error("Anthropic OAuth: Unable to encode API key data")
        return false
    end

    ---@diagnostic disable-next-line: redefined-local
    local success, err = pcall(function()
        -- Use binary mode for Windows platform when writing file
        if vim.fn.has("win32") == 1 then
            vim.fn.writefile(vim.split(json_data, "\n", { plain = true }), token_file, "b")
        else
            vim.fn.writefile({ json_data }, token_file)
        end
    end)

    if success then
        _api_key = api_key
        _api_key_loaded = true
        log:info("Anthropic OAuth: API key saved successfully")
        return true
    else
        log:error("Anthropic OAuth: Failed to save API key: %s", err or "unknown error")
        return false
    end
end

-- Create API key using OAuth access token
---@param access_token string
---@return string|nil
local function create_api_key(access_token)
    if not access_token or access_token == "" then
        log:error("Anthropic OAuth: Access token required")
        return nil
    end

    log:debug("Anthropic OAuth: Creating API key")

    local success, body_json = pcall(vim.json.encode, {})
    if not success then
        log:error("Anthropic OAuth: Unable to encode request body")
        return nil
    end

    local response = curl.post(OAUTH_CONFIG.API_KEY_URL, {
        headers = {
            ["Content-Type"] = "application/json",
            ["authorization"] = "Bearer " .. access_token,
            ["anthropic-version"] = DEFAULT_API_VERSION,
        },
        body = body_json,
        insecure = config.adapters.http.opts.allow_insecure,
        proxy = config.adapters.http.opts.proxy,
        timeout = 30000, -- 30 second timeout
        on_error = function(err)
            log:error("Anthropic OAuth: API key creation request error: %s", vim.inspect(err))
        end,
    })

    if not response then
        log:error("Anthropic OAuth: No response from API key creation request")
        return nil
    end

    if response.status >= 400 then
        log:error(
            "Anthropic OAuth: Failed to create API key, status code %d: %s",
            response.status,
            response.body or "no body"
        )
        return nil
    end

    local decode_success, api_key_data = pcall(vim.json.decode, response.body)

    if not decode_success or not api_key_data or not api_key_data.raw_key then
        log:error(
            "Anthropic OAuth: Invalid API key response format: %s",
            decode_success and "missing raw_key" or api_key_data
        )
        return nil
    end

    log:debug("Anthropic OAuth: API key created successfully")
    return api_key_data.raw_key
end

-- Exchange authorization code for access token and create API key
---@param code string
---@param verifier string
---@return string|nil
local function exchange_code_for_api_key(code, verifier)
    if not code or code == "" or not verifier or verifier == "" then
        log:error("Anthropic OAuth: Authorization code and verifier required")
        return nil
    end

    log:debug("Anthropic OAuth: Exchanging authorization code for access token")

    -- Parse authorization code and state from callback URL fragment
    local code_parts = vim.split(code, "#")
    local auth_code = code_parts[1]
    local state = code_parts[2] or verifier

    local request_data = {
        code = auth_code,
        state = state,
        grant_type = "authorization_code",
        client_id = OAUTH_CONFIG.CLIENT_ID,
        redirect_uri = OAUTH_CONFIG.REDIRECT_URI,
        code_verifier = verifier,
        scope = OAUTH_CONFIG.SCOPES,
    }

    local encode_success, body_json = pcall(vim.json.encode, request_data)
    if not encode_success then
        log:error("Anthropic OAuth: Unable to encode token exchange request")
        return nil
    end

    log:debug("Anthropic OAuth: Token exchange request initiated")

    local response = curl.post(OAUTH_CONFIG.TOKEN_URL, {
        headers = {
            ["Content-Type"] = "application/json",
            ["anthropic-version"] = DEFAULT_API_VERSION,
        },
        body = body_json,
        insecure = config.adapters.http.opts.allow_insecure,
        proxy = config.adapters.http.opts.proxy,
        timeout = 30000, -- 30 second timeout
        on_error = function(err)
            log:error("Anthropic OAuth: Token exchange request error: %s", vim.inspect(err))
        end,
    })

    if not response then
        log:error("Anthropic OAuth: No response from token exchange request")
        return nil
    end

    if response.status >= 400 then
        log:error("Anthropic OAuth: Token exchange failed, status code %d: %s", response.status, response.body or "no body")
        return nil
    end

    local decode_success, token_data = pcall(vim.json.decode, response.body)

    if not decode_success or not token_data or not token_data.access_token then
        log:error(
            "Anthropic OAuth: Invalid token response format: %s",
            decode_success and "missing access_token" or token_data
        )
        return nil
    end

    log:debug("Anthropic OAuth: Successfully obtained access token")

    -- Create API key using access token
    local api_key = create_api_key(token_data.access_token)
    if api_key and save_api_key(api_key) then
        return api_key
    end

    return nil
end

-- Generate OAuth authorization URL with PKCE
---@return { url: string, verifier: string }
local function generate_auth_url()
    local pkce = generate_pkce()
    if not pkce then
        return nil
    end

    -- Build properly encoded and ordered query string
    local query_params = {
        "code=true",
        "client_id=" .. url_encode(OAUTH_CONFIG.CLIENT_ID),
        "response_type=code",
        "redirect_uri=" .. url_encode(OAUTH_CONFIG.REDIRECT_URI),
        "scope=" .. url_encode(OAUTH_CONFIG.SCOPES),
        "code_challenge=" .. url_encode(pkce.challenge),
        "code_challenge_method=S256",
        "state=" .. url_encode(pkce.verifier),
    }

    local auth_url = OAUTH_CONFIG.AUTH_URL .. "?" .. table.concat(query_params, "&")
    log:debug("Anthropic OAuth: Authorization URL generated")

    return {
        url = auth_url,
        verifier = pkce.verifier,
    }
end

-- Get API key from cache or file
---@return string|nil
local function get_api_key()
    -- Try loading from cache or file
    local api_key = load_api_key()
    if api_key then
        return api_key
    end

    -- New OAuth flow required
    log:error("Anthropic OAuth: API key not found. Please run :AnthropicOAuthSetup to authenticate")
    return nil
end

-- Setup OAuth authentication (interactive)
---@return boolean
local function setup_oauth()
    local auth_data = generate_auth_url()
    if not auth_data then
        vim.notify("Unable to generate Anthropic OAuth authorization URL, please check logs.", vim.log.levels.ERROR)
        return false
    end

    vim.notify("Opening Anthropic OAuth authentication in browser...", vim.log.levels.INFO)

    -- Open URL in default browser (cross-platform handling)
    local open_cmd
    if vim.fn.has("mac") == 1 then
        open_cmd = "open"
    elseif vim.fn.has("unix") == 1 then
        -- Linux system, try xdg-open first
        open_cmd = "xdg-open"
        -- If xdg-open doesn't exist, try other common commands
        if vim.fn.executable("xdg-open") == 0 then
            if vim.fn.executable("gnome-open") == 1 then
                open_cmd = "gnome-open"
            elseif vim.fn.executable("kde-open") == 1 then
                open_cmd = "kde-open"
            end
        end
    elseif vim.fn.has("win32") == 1 then
        -- Windows requires special handling
        open_cmd = "start"
    end

    if open_cmd then
        local cmd
        if vim.fn.has("win32") == 1 then
            -- Windows: Use cmd /c start and properly handle URL
            -- Use empty title and escaped URL
            cmd = string.format('cmd /c start "" "%s"', auth_data.url:gsub("&", "^&"))
        else
            -- Unix/Mac: Use single quotes
            cmd = open_cmd .. " '" .. auth_data.url .. "'"
        end

        local success = pcall(function()
            if vim.fn.has("win32") == 1 then
                -- Windows platform uses system execution but hides output
                -- jobstart may not correctly open browser in some Windows environments
                vim.fn.system(cmd)
            else
                vim.fn.system(cmd)
            end
        end)

        if not success then
            vim.notify(
                "Unable to automatically open browser. Please manually open this URL:\n" .. auth_data.url,
                vim.log.levels.WARN
            )
        end
    else
        vim.notify("Please open this URL in your browser:\n" .. auth_data.url, vim.log.levels.INFO)
    end

    -- Prompt user to enter authorization code
    vim.ui.input({
        prompt = "Please enter the authorization code from callback URL (the part after 'code='):",
    }, function(code)
        if not code or code == "" then
            vim.notify("OAuth setup cancelled", vim.log.levels.WARN)
            return
        end

        -- Show progress
        vim.notify("Exchanging authorization code for API key...", vim.log.levels.INFO)

        local api_key = exchange_code_for_api_key(code, auth_data.verifier)
        if api_key then
            vim.notify("Anthropic OAuth authentication successful! API key created and saved.", vim.log.levels.INFO)
        else
            vim.notify("Anthropic OAuth authentication failed. Please check logs and retry.", vim.log.levels.ERROR)
        end
    end)

    return true
end

-- Create user commands for OAuth management
vim.api.nvim_create_user_command("AnthropicOAuthSetup", function()
    setup_oauth()
end, {
    desc = "Setup Anthropic OAuth authentication",
})

vim.api.nvim_create_user_command("AnthropicOAuthStatus", function()
    local api_key = load_api_key()
    if not api_key then
        vim.notify("Anthropic API key not found. Run :AnthropicOAuthSetup to authenticate.", vim.log.levels.WARN)
        return
    end

    vim.notify("Anthropic API key is configured and ready to use.", vim.log.levels.INFO)
end, {
    desc = "Check Anthropic OAuth API key status",
})

vim.api.nvim_create_user_command("AnthropicOAuthClear", function()
    local token_file = get_token_file_path()
    if token_file and vim.fn.filereadable(token_file) == 1 then
        local success = pcall(vim.fn.delete, token_file)
        if success then
            _api_key = nil
            _api_key_loaded = false
            vim.notify("Anthropic API key cleared.", vim.log.levels.INFO)
        else
            vim.notify("Failed to clear API key file.", vim.log.levels.ERROR)
        end
    else
        vim.notify("No Anthropic API key to clear.", vim.log.levels.WARN)
    end
end, {
    desc = "Clear stored Anthropic OAuth API key",
})

-- Create adapter by extending base anthropic adapter
local headers = vim.deepcopy(anthropic.headers or {})
headers["x-api-key"] = "${api_key}"
headers["anthropic-version"] = headers["anthropic-version"] or DEFAULT_API_VERSION
headers["anthropic-beta"] = headers["anthropic-beta"] or ""
for _, flag in ipairs(REQUIRED_BETA_FLAGS) do
    ensure_beta_flag(headers, flag)
end

local adapter = vim.tbl_deep_extend("force", vim.deepcopy(anthropic), {
    name = "anthropic_oauth",
    formatted_name = "Anthropic (OAuth)",

    env = {
        -- Get API key from OAuth flow
        ---@return string|nil
        api_key = function()
            return get_api_key()
        end,
    },

    headers = headers,

    -- Override model schema with latest models
    schema = vim.tbl_deep_extend("force", anthropic.schema or {}, {
        -- Override max_tokens to support longer outputs while ensuring it's greater than thinking_budget
        max_tokens = vim.tbl_deep_extend("force", anthropic.schema.max_tokens or {}, {
            default = function(self)
                local model = self.parameters and self.parameters.model or self.schema.model.default
                local model_opts = self.schema.model.choices[model]

                -- If model supports reasoning (extended thinking), ensure max_tokens > thinking_budget
                if model_opts and model_opts.opts and model_opts.opts.can_reason then
                    local thinking_budget = self.schema.thinking_budget and self.schema.thinking_budget.default or 16000
                    -- Ensure max_tokens is at least 1000 more than thinking_budget
                    local min_tokens = thinking_budget + 1000

                    if model_opts.opts.max_output then
                        -- Use model's max output capability, but consider thinking_budget
                        -- If min_tokens exceeds model's max output, use model's max output
                        return math.min(min_tokens, model_opts.opts.max_output)
                    end
                    return min_tokens
                elseif model_opts and model_opts.opts and model_opts.opts.max_output then
                    -- Use model's max output capability
                    return model_opts.opts.max_output
                end
                return 8192
            end,
            validate = function(n)
                return n > 0 and n <= 128000, "Must be between 0 and 128000"
            end,
        }),
    }),
})

-- Override existing default models with latest models from official website
adapter.schema.model = {
    order = 1,
    mapping = "parameters",
    type = "enum",
    desc = "The model that will complete your prompt. See https://docs.anthropic.com/claude/docs/models-overview for additional details and options.",
    default = "claude-sonnet-4-5",
    choices = {
        -- Claude Opus 4.5 - High performance model
        ["claude-opus-4-5"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                max_output = 64000,
                context_window = 200000,
                description = "High-performance model - Balanced performance and capability",
            },
        },
        -- Claude Opus 4.1 - Most powerful model
        ["claude-opus-4-1"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                max_output = 32000,
                context_window = 200000,
                description = "Our most capable model - Highest level of intelligence and capability",
            },
        },
        -- Claude Opus 4 - Previous flagship model
        ["claude-opus-4-0"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                max_output = 32000,
                context_window = 200000,
                description = "Our previous flagship model - Very high intelligence and capability",
            },
        },
        ["claude-sonnet-4-5"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                max_output = 64000,
                context_window = 200000,
                description = "High-performance model - Balanced performance and capability",
            },
        },
        -- Claude Sonnet 4 - High performance model
        ["claude-sonnet-4-0"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                max_output = 64000,
                context_window = 200000,
                description = "High-performance model - High intelligence and balanced performance",
            },
        },
        -- Claude Sonnet 3.7 - High performance model with early extended thinking
        ["claude-3-7-sonnet-latest"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                has_token_efficient_tools = true,
                max_output = 64000,
                context_window = 200000,
                description = "High-performance model with early extended thinking",
            },
        },
        -- Claude Haiku 4.5
        ["claude-haiku-4-5"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                max_output = 64000,
                context_window = 200000,
                description = "Our latest Claude Haiku model - Balanced performance and capability",
            },
        },
        -- Claude Haiku 3.5 - Fastest model
        ["claude-3-5-haiku-latest"] = {
            opts = {
                can_reason = false,
                has_vision = true,
                max_output = 8192,
                context_window = 200000,
                description = "Our fastest model - Intelligence at blazing speeds",
            },
        },
    },
}

adapter.handlers = vim.tbl_extend("force", anthropic.handlers, {
    -- Format parameters, handle Opus 4.1 limitations and thinking support
    ---@param self CodeCompanion.Adapter
    ---@param params table
    ---@param messages table
    ---@return table
    form_parameters = function(self, params, messages)
        -- First call original form_parameters
        params = anthropic.handlers.form_parameters(self, params, messages)

        -- Get current model configuration
        local model = params.model or self.schema.model.default
        local model_opts = self.schema.model.choices[model]

        -- Critical fix: Adjust max_tokens based on model limits
        if model_opts and model_opts.opts and model_opts.opts.max_output then
            -- If current max_tokens exceeds model's maximum, adjust it
            if params.max_tokens and params.max_tokens > model_opts.opts.max_output then
                log:debug(
                    "Model %s max_tokens %d exceeds maximum %d, adjusting to maximum",
                    model,
                    params.max_tokens,
                    model_opts.opts.max_output
                )
                params.max_tokens = model_opts.opts.max_output
            end
        end

        -- Critical fix: If model doesn't support thinking, remove thinking-related parameters
        if model_opts and model_opts.opts and not model_opts.opts.can_reason then
            -- Remove thinking parameter
            if params.thinking then
                log:debug("Model %s doesn't support thinking, removing thinking parameter", model)
                params.thinking = nil
            end

            -- Clear extended_thinking and thinking_budget in temp
            self.temp.extended_thinking = nil
            self.temp.thinking_budget = nil
        end

        -- Opus 4.1 special handling
        if model == "claude-opus-4-1" then
            -- Opus 4.1 doesn't allow both temperature and top_p
            if params.temperature and params.top_p then
                log:debug("Opus 4.1 detected with both temperature and top_p set, removing top_p")
                params.top_p = nil
            end
        end

        return params
    end,

    -- Check for valid API key before starting request
    ---@param self CodeCompanion.Adapter
    ---@return boolean
    setup = function(self)
        -- Get and validate API key
        local api_key = get_api_key()
        if not api_key then
            vim.notify(
                "Anthropic API key not found. Run :AnthropicOAuthSetup to authenticate.",
                vim.log.levels.ERROR
            )
            return false
        end

        -- Ensure tool support is enabled
        if self.opts then
            self.opts.tools = true
        end

        -- Dynamically adjust settings based on selected model
        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        if model_opts and model_opts.opts then
            -- Apply model-specific options
            self.opts = vim.tbl_deep_extend("force", self.opts or {}, {
                has_vision = model_opts.opts.has_vision,
                can_reason = model_opts.opts.can_reason,
                has_token_efficient_tools = model_opts.opts.has_token_efficient_tools,
            })

            -- Dynamically set thinking-related beta headers
            -- Only add interleaved-thinking beta feature for models that support thinking
            if model_opts.opts.can_reason then
                -- Add thinking support
                if not string.find(self.headers["anthropic-beta"], "interleaved%-thinking") then
                    self.headers["anthropic-beta"] = self.headers["anthropic-beta"]
                        .. ",interleaved-thinking-2025-05-14"
                    log:debug("Enabled thinking support for model %s", model)
                end
            else
                -- Remove thinking support (if exists)
                if string.find(self.headers["anthropic-beta"], "interleaved%-thinking") then
                    self.headers["anthropic-beta"] =
                        self.headers["anthropic-beta"]:gsub(",?interleaved%-thinking%-[^,]*", "")
                    log:debug("Disabled thinking support for model %s", model)
                end

                -- Clear extended_thinking related settings
                self.temp.extended_thinking = nil
                self.temp.thinking_budget = nil
            end

            -- Dynamically set maximum output tokens
            if model_opts.opts.max_output and self.schema.max_tokens then
                if type(self.schema.max_tokens.default) == "function" then
                    -- Already a function, no need to override
                else
                    self.schema.max_tokens.default = model_opts.opts.max_output
                end
            end

            -- Log current model information
            log:debug("Using model: %s - %s", model, model_opts.opts.description or "")
            log:debug("Beta features: %s", self.headers["anthropic-beta"])
        end

        -- Call original setup function to handle streaming and model options
        return anthropic.handlers.setup(self)
    end,

    -- Format messages with Claude Code system message at the beginning (required for OAuth)
    ---@param self CodeCompanion.Adapter
    ---@param messages table
    ---@return table
    form_messages = function(self, messages)
        -- First, call original form_messages to get standard format
        local formatted = anthropic.handlers.form_messages(self, messages)

        -- Extract existing system messages or initialize empty array
        local system = formatted.system or {}

        -- Add Claude Code system message at the beginning (required for OAuth to work properly)
        table.insert(system, 1, {
            type = "text",
            text = "You are Claude Code, Anthropic's official CLI for Claude.",
        })

        -- Return formatted messages with modified system messages
        return {
            system = system,
            messages = formatted.messages,
        }
    end,
})

-- Override extended_thinking default value logic
adapter.schema.extended_thinking = vim.tbl_deep_extend("force", adapter.schema.extended_thinking or {}, {
    default = function(self)
        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        -- Only enable by default for models that explicitly support can_reason
        if model_opts and model_opts.opts and model_opts.opts.can_reason == true then
            return true
        end
        return false
    end,
    enabled = function(self)
        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        -- Only show this option for models that support can_reason
        if model_opts and model_opts.opts then
            return model_opts.opts.can_reason == true
        end
        return false
    end,
})

-- Override thinking_budget condition logic
adapter.schema.thinking_budget = vim.tbl_deep_extend("force", adapter.schema.thinking_budget or {}, {
    enabled = function(self)
        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        -- Only show this option for models that support can_reason
        if model_opts and model_opts.opts then
            return model_opts.opts.can_reason == true
        end
        return false
    end,
})

adapter.get_api_key = get_api_key

return adapter
