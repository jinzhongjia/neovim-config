local uv = vim.uv or vim.loop
local Job = require("plenary.job")
local config = require("codecompanion.config")
local curl = require("plenary.curl")
local log = require("codecompanion.utils.log")

-- Module-level token cache
local _access_token = nil
local _refresh_token = nil
local _token_expires = nil
local _project_id = nil
local _token_loaded = false
local _current_endpoint_index = 1

-- OAuth flow constant configuration (from opencode-antigravity-auth)
local OAUTH_CONFIG = {
    CLIENT_ID = "1071006060591-tmhssin2h21lcre235vtolojh4g403ep.apps.googleusercontent.com",
    CLIENT_SECRET = "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",
    REDIRECT_URI = "http://localhost:51121/oauth-callback",
    AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth",
    TOKEN_URL = "https://oauth2.googleapis.com/token",
    SCOPES = {
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/cclog",
        "https://www.googleapis.com/auth/experimentsandconfigs",
    },
    CALLBACK_PORT = 51121,
    ACCESS_TOKEN_EXPIRY_BUFFER_MS = 60 * 1000, -- 1 minute buffer
}

-- Antigravity API configuration with fallback endpoints
local ANTIGRAVITY_CONFIG = {
    -- Endpoints in fallback order (daily → autopush → prod)
    ENDPOINTS = {
        "https://daily-cloudcode-pa.sandbox.googleapis.com",
        "https://autopush-cloudcode-pa.sandbox.googleapis.com",
        "https://cloudcode-pa.googleapis.com",
    },
    -- Endpoints for project discovery (prod first)
    LOAD_ENDPOINTS = {
        "https://cloudcode-pa.googleapis.com",
        "https://daily-cloudcode-pa.sandbox.googleapis.com",
        "https://autopush-cloudcode-pa.sandbox.googleapis.com",
    },
    DEFAULT_PROJECT_ID = "rising-fact-p41fc",
    HEADERS = {
        ["User-Agent"] = "antigravity/1.11.5 windows/amd64",
        ["X-Goog-Api-Client"] = "google-cloud-sdk vscode_cloudshelleditor/0.1",
        ["Client-Metadata"] = '{"ideType":"IDE_UNSPECIFIED","platform":"PLATFORM_UNSPECIFIED","pluginType":"GEMINI"}',
    },
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

---@param path string
---@param length number
---@return string|nil
local function read_random_from_file(path, length)
    if not uv then
        return nil
    end
    if vim.fn.has("win32") == 1 then
        return nil
    end
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
    local readers
    if vim.fn.has("win32") == 1 then
        -- Windows: prefer PowerShell, then openssl
        readers = {
            function()
                return read_random_from_windows(length)
            end,
            function()
                return read_random_from_openssl(length)
            end,
        }
    else
        -- Unix/Linux/macOS: prefer /dev/urandom, then openssl
        readers = {
            function()
                return read_random_from_file("/dev/urandom", length)
            end,
            function()
                return read_random_from_openssl(length)
            end,
        }
    end

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

-- URL encoding function
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

-- URL decode function
---@param str string
---@return string
local function url_decode(str)
    if not str then
        return ""
    end
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end)
    return str
end

-- Parse query string from URL
---@param query string
---@return table
local function parse_query_string(query)
    local params = {}
    if not query then
        return params
    end
    for pair in string.gmatch(query, "[^&]+") do
        local key, value = string.match(pair, "([^=]+)=?(.*)")
        if key then
            params[url_decode(key)] = url_decode(value or "")
        end
    end
    return params
end

-- Generate random string for PKCE (RFC 7636 compliant)
-- Code verifier: 43-128 characters from [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~"
---@param length number
---@return string
local function generate_random_string(length)
    -- Use openssl for reliable random generation
    if vim.fn.executable("openssl") == 1 then
        -- Generate base64 random and convert to URL-safe format
        local result = vim.fn.system({ "openssl", "rand", "-base64", tostring(math.ceil(length * 3 / 4)) })
        if vim.v.shell_error == 0 and result then
            -- Convert to URL-safe base64 and trim to desired length
            local safe = trim(result):gsub("+", "-"):gsub("/", "_"):gsub("=", "")
            if #safe >= length then
                return safe:sub(1, length)
            end
        end
    end

    -- Fallback: use /dev/urandom or other sources
    local bytes = secure_random_bytes(length)
    if not bytes then
        log:error("Antigravity OAuth: Unable to generate secure random bytes")
        return nil
    end

    -- Use only alphanumeric characters for simplicity (subset of allowed chars)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = {}
    for i = 1, length do
        local byte = bytes:byte(i)
        local rand_index = (byte % #chars) + 1
        result[i] = chars:sub(rand_index, rand_index)
    end
    return table.concat(result)
end

-- Get a temporary file path (cross-platform)
---@return string
local function get_temp_file()
    local tmp_file = os.tmpname()
    -- On Windows, os.tmpname() may return a path without directory
    -- Need to prepend TEMP directory
    if vim.fn.has("win32") == 1 then
        local temp_dir = os.getenv("TEMP") or os.getenv("TMP") or "."
        if not tmp_file:match("[\\/]") then
            tmp_file = temp_dir .. "\\" .. tmp_file
        end
    end
    return tmp_file
end

-- Generate SHA256 hash using openssl on Unix-like systems
---@param input string
---@return string|nil
local function sha256_base64url_unix(input)
    if vim.fn.has("win32") == 1 then
        return nil
    end
    if vim.fn.executable("openssl") == 0 then
        return nil
    end

    -- Write input to a temp file to avoid shell escaping issues
    local tmp_file = get_temp_file()
    local f = io.open(tmp_file, "wb")
    if not f then
        return nil
    end
    f:write(input)
    f:close()

    -- Use openssl to hash the file
    local result = vim.fn.system({ "openssl", "dgst", "-sha256", "-binary", tmp_file })
    os.remove(tmp_file)

    if vim.v.shell_error ~= 0 or not result or result == "" then
        return nil
    end

    -- Encode to base64url
    local base64 = vim.base64.encode(result)
    return base64:gsub("+", "-"):gsub("/", "_"):gsub("=", "")
end

-- Generate SHA256 hash using PowerShell on Windows
---@param input string
---@return string|nil
local function sha256_base64url_windows(input)
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

    -- Write input to a temp file to avoid escaping issues
    local tmp_file = get_temp_file()
    local f = io.open(tmp_file, "wb")
    if not f then
        return nil
    end
    f:write(input)
    f:close()

    -- Use PowerShell to compute SHA256 and convert to base64
    -- Use double quotes and escape properly for PowerShell
    local script = string.format(
        "$bytes = [System.IO.File]::ReadAllBytes('%s'); "
            .. "$hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes); "
            .. "[System.Convert]::ToBase64String($hash)",
        tmp_file:gsub("'", "''")
    )

    local result = vim.fn.system({ ps_exe, "-NoProfile", "-Command", script })
    os.remove(tmp_file)

    if vim.v.shell_error ~= 0 or not result or result == "" then
        return nil
    end

    -- Convert to base64url format
    local base64 = trim(result)
    return base64:gsub("+", "-"):gsub("/", "_"):gsub("=", "")
end

-- Generate SHA256 hash in base64url format for PKCE (cross-platform)
---@param input string
---@return string
local function sha256_base64url(input)
    -- Try platform-specific implementations first
    local result = sha256_base64url_unix(input) or sha256_base64url_windows(input)
    if result then
        return result
    end

    -- Fallback to vim's sha256 function (returns hex, need to convert)
    local hash_binary = sha256_binary_vimfn(input)
    if not hash_binary then
        log:error("Antigravity OAuth: Unable to generate PKCE hash")
        return nil
    end

    local base64 = vim.base64.encode(hash_binary)
    return base64:gsub("+", "-"):gsub("/", "_"):gsub("=", "")
end

-- Generate PKCE code verifier and challenge
---@return { verifier: string, challenge: string }
local function generate_pkce()
    -- Use 64 characters for verifier (within RFC 7636 range of 43-128)
    local verifier = generate_random_string(64)
    if not verifier then
        return nil
    end

    log:debug("Antigravity OAuth: Generated verifier length: %d", #verifier)

    local challenge = sha256_base64url(verifier)
    if not challenge then
        return nil
    end

    log:debug("Antigravity OAuth: Generated challenge length: %d", #challenge)

    return {
        verifier = verifier,
        challenge = challenge,
    }
end

-- Find data path for storing OAuth tokens
---@return string|nil
local function find_data_path()
    local env_path = os.getenv("CODECOMPANION_GEMINI_TOKEN_PATH")
    if env_path and vim.fn.isdirectory(vim.fs.dirname(env_path)) > 0 then
        return vim.fs.dirname(env_path)
    end

    local nvim_data = vim.fn.stdpath("data")
    if nvim_data and vim.fn.isdirectory(nvim_data) > 0 then
        return nvim_data
    end

    return nil
end

-- Get OAuth token file path
---@return string|nil
local function get_token_file_path()
    local data_path = find_data_path()
    if not data_path then
        log:error("Antigravity OAuth: Unable to determine data directory")
        return nil
    end

    local path_sep = package.config:sub(1, 1)
    return data_path .. path_sep .. "antigravity_oauth.json"
end

-- Load tokens from file
---@return boolean
local function load_tokens()
    if _token_loaded then
        return _access_token ~= nil and _refresh_token ~= nil
    end

    _token_loaded = true

    local token_file = get_token_file_path()
    if not token_file or vim.fn.filereadable(token_file) == 0 then
        return false
    end

    local success, content = pcall(vim.fn.readfile, token_file)
    if not success or not content or #content == 0 then
        log:debug("Antigravity OAuth: Unable to read token file or file is empty")
        return false
    end

    local decode_success, data = pcall(vim.json.decode, table.concat(content, "\n"))
    if decode_success and data then
        _access_token = data.access_token
        _refresh_token = data.refresh_token
        _token_expires = data.expires
        _project_id = data.project_id
        return _refresh_token ~= nil
    else
        log:warn("Antigravity OAuth: Invalid token file format")
        return false
    end
end

-- Save tokens to file
---@param access_token string
---@param refresh_token string
---@param expires number
---@param project_id string|nil
---@return boolean
local function save_tokens(access_token, refresh_token, expires, project_id)
    if not refresh_token or refresh_token == "" then
        log:error("Antigravity OAuth: Cannot save without refresh token")
        return false
    end

    local token_file = get_token_file_path()
    if not token_file then
        return false
    end

    local data = {
        access_token = access_token,
        refresh_token = refresh_token,
        expires = expires,
        project_id = project_id,
        created_at = os.time(),
        version = 1,
    }

    local success, json_data = pcall(vim.json.encode, data)
    if not success then
        log:error("Antigravity OAuth: Unable to encode token data")
        return false
    end

    ---@diagnostic disable-next-line: redefined-local
    local success, err = pcall(function()
        if vim.fn.has("win32") == 1 then
            vim.fn.writefile(vim.split(json_data, "\n", { plain = true }), token_file, "b")
        else
            vim.fn.writefile({ json_data }, token_file)
        end
    end)

    if success then
        _access_token = access_token
        _refresh_token = refresh_token
        _token_expires = expires
        _project_id = project_id
        _token_loaded = true
        log:info("Antigravity OAuth: Tokens saved successfully")
        return true
    else
        log:error("Antigravity OAuth: Failed to save tokens: %s", err or "unknown error")
        return false
    end
end

-- Check if access token is expired
---@return boolean
local function access_token_expired()
    if not _access_token or not _token_expires then
        return true
    end
    -- Current time in milliseconds
    local now_ms = os.time() * 1000
    return _token_expires <= now_ms + OAUTH_CONFIG.ACCESS_TOKEN_EXPIRY_BUFFER_MS
end

-- Load managed project from Antigravity API (tries multiple endpoints)
---@param access_token string
---@return string|nil
local function load_managed_project(access_token)
    log:debug("Antigravity OAuth: Loading managed project")

    local request_body = {
        metadata = {
            ideType = "IDE_UNSPECIFIED",
            platform = "PLATFORM_UNSPECIFIED",
            pluginType = "GEMINI",
        },
    }

    local success, body_json = pcall(vim.json.encode, request_body)
    if not success then
        log:error("Antigravity OAuth: Failed to encode request body")
        return nil
    end

    -- Try each endpoint in order
    for _, endpoint in ipairs(ANTIGRAVITY_CONFIG.LOAD_ENDPOINTS) do
        local response = curl.post(endpoint .. "/v1internal:loadCodeAssist", {
            headers = vim.tbl_extend("force", {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. access_token,
            }, ANTIGRAVITY_CONFIG.HEADERS),
            body = body_json,
            insecure = config.adapters
                and config.adapters.http
                and config.adapters.http.opts
                and config.adapters.http.opts.allow_insecure,
            proxy = config.adapters
                and config.adapters.http
                and config.adapters.http.opts
                and config.adapters.http.opts.proxy,
            timeout = 30000,
            on_error = function(err)
                log:debug("Antigravity OAuth: Load managed project error at %s: %s", endpoint, vim.inspect(err))
            end,
        })

        if response and response.status < 400 then
            local decode_success, data = pcall(vim.json.decode, response.body)
            if decode_success and data then
                local project_id = data.cloudaicompanionProject
                if type(project_id) == "table" and project_id.id then
                    project_id = project_id.id
                end
                if project_id and project_id ~= "" then
                    log:debug("Antigravity OAuth: Found managed project: %s (from %s)", project_id, endpoint)
                    return project_id
                end
            end
        end
        log:debug("Antigravity OAuth: No project found at %s, trying next endpoint", endpoint)
    end

    log:debug("Antigravity OAuth: No existing managed project found, will use default")
    return nil
end

-- Onboard user to get managed project (Antigravity may not support this, use default)
---@param access_token string
---@return string|nil
local function onboard_managed_project(access_token)
    log:debug("Antigravity OAuth: Attempting to onboard user")

    local request_body = {
        tierId = "FREE",
        metadata = {
            ideType = "IDE_UNSPECIFIED",
            platform = "PLATFORM_UNSPECIFIED",
            pluginType = "GEMINI",
        },
    }

    local success, body_json = pcall(vim.json.encode, request_body)
    if not success then
        log:error("Antigravity OAuth: Failed to encode onboard request body")
        return nil
    end

    -- Try prod endpoint for onboarding
    local endpoint = ANTIGRAVITY_CONFIG.LOAD_ENDPOINTS[1]
    local response = curl.post(endpoint .. "/v1internal:onboardUser", {
        headers = vim.tbl_extend("force", {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. access_token,
        }, ANTIGRAVITY_CONFIG.HEADERS),
        body = body_json,
        insecure = config.adapters
            and config.adapters.http
            and config.adapters.http.opts
            and config.adapters.http.opts.allow_insecure,
        proxy = config.adapters
            and config.adapters.http
            and config.adapters.http.opts
            and config.adapters.http.opts.proxy,
        timeout = 30000,
        on_error = function(err)
            log:debug("Antigravity OAuth: Onboard error: %s", vim.inspect(err))
        end,
    })

    if response and response.status < 400 then
        local decode_success, data = pcall(vim.json.decode, response.body)
        if decode_success and data then
            local project_id = data.response
                and data.response.cloudaicompanionProject
                and data.response.cloudaicompanionProject.id
            if data.done and project_id then
                log:debug("Antigravity OAuth: Onboarded with managed project: %s", project_id)
                return project_id
            end
        end
    end

    log:debug("Antigravity OAuth: Onboard not available, will use default project")
    return nil
end

-- Ensure we have a valid project ID
---@param access_token string
---@return string|nil
local function ensure_project_id(access_token)
    -- First try to load existing managed project
    local project_id = load_managed_project(access_token)
    if project_id then
        return project_id
    end

    -- Try to onboard
    project_id = onboard_managed_project(access_token)
    if project_id then
        return project_id
    end

    -- Use default project ID as fallback
    log:debug("Antigravity OAuth: Using default project ID: %s", ANTIGRAVITY_CONFIG.DEFAULT_PROJECT_ID)
    return ANTIGRAVITY_CONFIG.DEFAULT_PROJECT_ID
end

-- Refresh access token using refresh token
---@return string|nil
local function refresh_access_token()
    if not _refresh_token or _refresh_token == "" then
        log:error("Antigravity OAuth: No refresh token available")
        return nil
    end

    log:debug("Antigravity OAuth: Refreshing access token")

    local response = curl.post(OAUTH_CONFIG.TOKEN_URL, {
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        },
        body = "grant_type=refresh_token"
            .. "&refresh_token="
            .. url_encode(_refresh_token)
            .. "&client_id="
            .. url_encode(OAUTH_CONFIG.CLIENT_ID)
            .. "&client_secret="
            .. url_encode(OAUTH_CONFIG.CLIENT_SECRET),
        insecure = config.adapters
            and config.adapters.http
            and config.adapters.http.opts
            and config.adapters.http.opts.allow_insecure,
        proxy = config.adapters
            and config.adapters.http
            and config.adapters.http.opts
            and config.adapters.http.opts.proxy,
        timeout = 30000,
        on_error = function(err)
            log:error("Antigravity OAuth: Token refresh error: %s", vim.inspect(err))
        end,
    })

    if not response then
        log:error("Antigravity OAuth: No response from token refresh request")
        return nil
    end

    if response.status >= 400 then
        log:error("Antigravity OAuth: Token refresh failed, status %d: %s", response.status, response.body or "no body")
        -- Check if refresh token is revoked
        local decode_ok, error_data = pcall(vim.json.decode, response.body)
        if decode_ok and error_data and error_data.error == "invalid_grant" then
            log:warn("Antigravity OAuth: Refresh token revoked. Please run :AntigravityOAuthSetup to reauthenticate")
            _access_token = nil
            _refresh_token = nil
            _token_expires = nil
            _project_id = nil
        end
        return nil
    end

    local decode_success, token_data = pcall(vim.json.decode, response.body)
    if not decode_success or not token_data or not token_data.access_token then
        log:error("Antigravity OAuth: Invalid token refresh response")
        return nil
    end

    local expires = os.time() * 1000 + (token_data.expires_in or 3600) * 1000
    local new_refresh = token_data.refresh_token or _refresh_token

    -- Ensure we have a project ID
    local project_id = _project_id or ensure_project_id(token_data.access_token)

    if save_tokens(token_data.access_token, new_refresh, expires, project_id) then
        log:debug("Antigravity OAuth: Access token refreshed successfully")
        return token_data.access_token
    end

    return nil
end

-- Exchange authorization code for tokens
---@param code string
---@param verifier string
---@return boolean
local function exchange_code_for_tokens(code, verifier)
    if not code or code == "" or not verifier or verifier == "" then
        log:error("Antigravity OAuth: Authorization code and verifier required")
        return false
    end

    log:debug("Antigravity OAuth: Exchanging authorization code for tokens")
    log:debug("Antigravity OAuth: Code length: %d, Verifier length: %d", #code, #verifier)

    local response = curl.post(OAUTH_CONFIG.TOKEN_URL, {
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        },
        body = "client_id=" .. url_encode(OAUTH_CONFIG.CLIENT_ID) .. "&client_secret=" .. url_encode(
            OAUTH_CONFIG.CLIENT_SECRET
        ) .. "&code=" .. url_encode(code) .. "&grant_type=authorization_code" .. "&redirect_uri=" .. url_encode(
            OAUTH_CONFIG.REDIRECT_URI
        ) .. "&code_verifier=" .. url_encode(verifier),
        insecure = config.adapters
            and config.adapters.http
            and config.adapters.http.opts
            and config.adapters.http.opts.allow_insecure,
        proxy = config.adapters
            and config.adapters.http
            and config.adapters.http.opts
            and config.adapters.http.opts.proxy,
        timeout = 30000,
        on_error = function(err)
            log:error("Antigravity OAuth: Token exchange error: %s", vim.inspect(err))
        end,
    })

    if not response then
        log:error("Antigravity OAuth: No response from token exchange request")
        return false
    end

    if response.status >= 400 then
        log:error(
            "Antigravity OAuth: Token exchange failed, status %d: %s",
            response.status,
            response.body or "no body"
        )
        return false
    end

    local decode_success, token_data = pcall(vim.json.decode, response.body)
    if not decode_success or not token_data then
        log:error("Antigravity OAuth: Invalid token exchange response")
        return false
    end

    if not token_data.access_token then
        log:error("Antigravity OAuth: Missing access_token in response")
        return false
    end

    if not token_data.refresh_token then
        log:error("Antigravity OAuth: Missing refresh_token in response")
        return false
    end

    local expires = os.time() * 1000 + (token_data.expires_in or 3600) * 1000

    -- Get managed project ID
    log:debug("Antigravity OAuth: Getting managed project ID")
    local project_id = ensure_project_id(token_data.access_token)
    if not project_id then
        log:error("Antigravity OAuth: Failed to get managed project ID")
        return false
    end

    return save_tokens(token_data.access_token, token_data.refresh_token, expires, project_id)
end

-- Encode state for OAuth (base64url)
---@param verifier string
---@return string
local function encode_state(verifier)
    local state_data = vim.json.encode({ verifier = verifier, projectId = "" })
    local base64 = vim.base64.encode(state_data)
    return base64:gsub("[+/=]", { ["+"] = "-", ["/"] = "_", ["="] = "" })
end

-- Generate OAuth authorization URL
---@return { url: string, verifier: string }|nil
local function generate_auth_url()
    local pkce = generate_pkce()
    if not pkce then
        return nil
    end

    log:debug("Antigravity OAuth: PKCE verifier: %s", pkce.verifier:sub(1, 20) .. "...")
    log:debug("Antigravity OAuth: PKCE challenge: %s", pkce.challenge)

    local state = encode_state(pkce.verifier)

    local query_params = {
        "client_id=" .. url_encode(OAUTH_CONFIG.CLIENT_ID),
        "response_type=code",
        "redirect_uri=" .. url_encode(OAUTH_CONFIG.REDIRECT_URI),
        "scope=" .. url_encode(table.concat(OAUTH_CONFIG.SCOPES, " ")),
        "code_challenge=" .. url_encode(pkce.challenge),
        "code_challenge_method=S256",
        "state=" .. url_encode(state),
        "access_type=offline",
        "prompt=consent",
    }

    local auth_url = OAUTH_CONFIG.AUTH_URL .. "?" .. table.concat(query_params, "&")
    log:debug("Antigravity OAuth: Authorization URL generated")

    return {
        url = auth_url,
        verifier = pkce.verifier,
    }
end

-- Get access token (from cache, file, or refresh)
---@return string|nil, string|nil
local function get_access_token()
    -- Load from file if not loaded
    if not _token_loaded then
        load_tokens()
    end

    -- If we have a valid access token, return it
    if _access_token and not access_token_expired() then
        return _access_token, _project_id
    end

    -- Try to refresh the access token
    if _refresh_token then
        local new_token = refresh_access_token()
        if new_token then
            return new_token, _project_id
        end
    end

    log:error("Antigravity OAuth: Access token not available. Please run :AntigravityOAuthSetup to authenticate")
    return nil, nil
end

-- HTTP success response HTML
local SUCCESS_HTML = [[<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Antigravity OAuth - CodeCompanion</title>
    <style>
        :root { color-scheme: light dark; }
        body {
            margin: 0; min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            font-family: "Roboto", "Google Sans", arial, sans-serif;
            background: #f1f3f4; color: #202124;
        }
        main {
            width: min(448px, calc(100% - 3rem));
            background: #ffffff; border-radius: 28px;
            padding: 2.5rem 2.75rem;
            box-shadow: 0 1px 2px rgba(60,64,67,.3), 0 2px 6px rgba(60,64,67,.15);
        }
        h1 { margin: 0 0 0.75rem; font-size: 1.75rem; font-weight: 500; }
        p { margin: 0 0 1.75rem; font-size: 1.05rem; line-height: 1.6; color: #3c4043; }
        .action {
            display: inline-flex; padding: 0.65rem 1.85rem;
            border-radius: 999px; background: #1a73e8; color: #fff;
            font-weight: 500; text-decoration: none;
        }
        @media (prefers-color-scheme: dark) {
            body { background: #131314; color: #e8eaed; }
            main { background: #202124; }
            p { color: #e8eaed; }
            .action { background: #8ab4f8; color: #202124; }
        }
    </style>
</head>
<body>
    <main>
        <h1>Authentication Successful!</h1>
        <p>Your Google account is now linked to CodeCompanion. You can close this window and return to Neovim.</p>
        <a class="action" href="javascript:window.close()">Close window</a>
    </main>
</body>
</html>]]

-- Start local HTTP server for OAuth callback
---@param verifier string
---@param callback function
local function start_oauth_server(verifier, callback)
    local server = uv.new_tcp()
    if not server then
        log:error("Antigravity OAuth: Failed to create TCP server")
        callback(nil, "Failed to create TCP server")
        return
    end

    local bind_ok, bind_err = server:bind("127.0.0.1", OAUTH_CONFIG.CALLBACK_PORT)
    if not bind_ok then
        log:error("Antigravity OAuth: Failed to bind to port %d: %s", OAUTH_CONFIG.CALLBACK_PORT, bind_err or "unknown")
        server:close()
        callback(nil, "Failed to bind to port " .. OAUTH_CONFIG.CALLBACK_PORT)
        return
    end

    local listen_ok, listen_err = server:listen(128, function(err)
        if err then
            log:error("Antigravity OAuth: Server listen error: %s", err)
            return
        end

        local client = uv.new_tcp()
        server:accept(client)

        local request_data = ""

        client:read_start(function(read_err, chunk)
            if read_err then
                log:error("Antigravity OAuth: Read error: %s", read_err)
                client:close()
                return
            end

            if chunk then
                request_data = request_data .. chunk
                log:debug("Antigravity OAuth: Received chunk, total size: %d", #request_data)

                if string.find(request_data, "\r\n\r\n") then
                    local request_line = string.match(request_data, "^([^\r\n]+)")
                    log:debug("Antigravity OAuth: Request line: %s", (request_line or ""):sub(1, 100))
                    local path = string.match(request_line or "", "GET ([^ ]+)")
                    log:debug("Antigravity OAuth: Parsed path: %s", (path or "nil"):sub(1, 50))

                    if path and string.find(path, "/oauth%-callback") then
                        local query = string.match(path, "%?(.+)$")
                        local params = parse_query_string(query)

                        local response = "HTTP/1.1 200 OK\r\n"
                            .. "Content-Type: text/html; charset=utf-8\r\n"
                            .. "Content-Length: "
                            .. #SUCCESS_HTML
                            .. "\r\n"
                            .. "Connection: close\r\n"
                            .. "\r\n"
                            .. SUCCESS_HTML

                        client:write(response, function()
                            client:shutdown()
                            client:close()
                            server:close()

                            vim.schedule(function()
                                if params.error then
                                    callback(nil, "OAuth error: " .. (params.error_description or params.error))
                                elseif params.code then
                                    callback(params.code, nil)
                                else
                                    callback(nil, "No authorization code received")
                                end
                            end)
                        end)
                    else
                        local not_found = "HTTP/1.1 404 Not Found\r\n"
                            .. "Content-Type: text/plain\r\n"
                            .. "Content-Length: 9\r\n"
                            .. "Connection: close\r\n"
                            .. "\r\n"
                            .. "Not found"
                        client:write(not_found, function()
                            client:shutdown()
                            client:close()
                        end)
                    end
                end
            else
                client:close()
            end
        end)
    end)

    if not listen_ok then
        log:error("Antigravity OAuth: Failed to listen: %s", listen_err or "unknown")
        server:close()
        callback(nil, "Failed to start server")
        return
    end

    log:debug("Antigravity OAuth: Server listening on port %d", OAUTH_CONFIG.CALLBACK_PORT)

    local timeout = uv.new_timer()
    timeout:start(5 * 60 * 1000, 0, function()
        if not server:is_closing() then
            server:close()
            vim.schedule(function()
                callback(nil, "OAuth timeout - no callback received within 5 minutes")
            end)
        end
        timeout:close()
    end)
end

-- Setup OAuth authentication (interactive)
---@return boolean
local function setup_oauth()
    local auth_data = generate_auth_url()
    if not auth_data then
        vim.notify("Unable to generate Antigravity OAuth authorization URL, please check logs.", vim.log.levels.ERROR)
        return false
    end

    vim.notify("Starting Antigravity OAuth authentication...", vim.log.levels.INFO)

    start_oauth_server(auth_data.verifier, function(code, err)
        if err then
            vim.notify("Antigravity OAuth failed: " .. err, vim.log.levels.ERROR)
            return
        end

        if code then
            vim.notify("Authorization code received, exchanging for tokens...", vim.log.levels.INFO)
            if exchange_code_for_tokens(code, auth_data.verifier) then
                vim.notify("Antigravity OAuth authentication successful!", vim.log.levels.INFO)
            else
                vim.notify("Antigravity OAuth: Failed to exchange code for tokens", vim.log.levels.ERROR)
            end
        end
    end)

    -- Open URL in default browser (cross-platform)
    local function open_url(url)
        local success = false

        if vim.fn.has("mac") == 1 then
            -- macOS: use 'open' command with array syntax to avoid shell escaping
            vim.fn.system({ "open", url })
            success = vim.v.shell_error == 0
        elseif vim.fn.has("win32") == 1 then
            -- Windows: use rundll32 which is more reliable than 'start'
            vim.fn.system({ "rundll32", "url.dll,FileProtocolHandler", url })
            success = vim.v.shell_error == 0
            if not success then
                -- Fallback to PowerShell
                local ps_exe = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
                vim.fn.system({ ps_exe, "-NoProfile", "-Command", "Start-Process", url })
                success = vim.v.shell_error == 0
            end
        elseif vim.fn.has("unix") == 1 then
            -- Linux: try xdg-open first, then other alternatives
            local openers = { "xdg-open", "gnome-open", "kde-open", "wslview" }
            for _, opener in ipairs(openers) do
                if vim.fn.executable(opener) == 1 then
                    vim.fn.system({ opener, url })
                    success = vim.v.shell_error == 0
                    if success then
                        break
                    end
                end
            end
        end

        return success
    end

    local success = open_url(auth_data.url)
    if not success then
        vim.notify(
            "Unable to automatically open browser. Please manually open this URL:\n" .. auth_data.url,
            vim.log.levels.WARN
        )
    end

    return true
end

-- Create user commands
vim.api.nvim_create_user_command("AntigravityOAuthSetup", function()
    setup_oauth()
end, {
    desc = "Setup Antigravity OAuth authentication",
})

vim.api.nvim_create_user_command("AntigravityOAuthStatus", function()
    load_tokens()
    if not _refresh_token then
        vim.notify(
            "Antigravity OAuth: Not authenticated. Run :AntigravityOAuthSetup to authenticate.",
            vim.log.levels.WARN
        )
        return
    end

    local status = "Antigravity OAuth: Authenticated"
    if _project_id then
        status = status .. " (Project: " .. _project_id .. ")"
    end
    if _access_token and not access_token_expired() then
        status = status .. " - Token is valid"
    else
        status = status .. " - Token needs refresh"
    end
    vim.notify(status, vim.log.levels.INFO)
end, {
    desc = "Check Antigravity OAuth status",
})

vim.api.nvim_create_user_command("AntigravityOAuthClear", function()
    local token_file = get_token_file_path()
    if token_file and vim.fn.filereadable(token_file) == 1 then
        local success = pcall(vim.fn.delete, token_file)
        if success then
            _access_token = nil
            _refresh_token = nil
            _token_expires = nil
            _project_id = nil
            _token_loaded = false
            vim.notify("Antigravity OAuth: Tokens cleared.", vim.log.levels.INFO)
        else
            vim.notify("Antigravity OAuth: Failed to clear token file.", vim.log.levels.ERROR)
        end
    else
        vim.notify("Antigravity OAuth: No tokens to clear.", vim.log.levels.WARN)
    end
end, {
    desc = "Clear stored Antigravity OAuth tokens",
})

-- Generate a unique request ID
local function generate_request_id()
    local chars = "0123456789abcdef"
    local parts = {}
    local lengths = { 8, 4, 4, 4, 12 }
    for _, len in ipairs(lengths) do
        local part = {}
        for _ = 1, len do
            local idx = math.random(1, #chars)
            table.insert(part, chars:sub(idx, idx))
        end
        table.insert(parts, table.concat(part))
    end
    return "agent-" .. table.concat(parts, "-")
end

-- Generate a session ID
local function generate_session_id()
    return "-" .. tostring(math.random(1000000000000000000, 9999999999999999999))
end

-- Get current endpoint (with fallback support)
local function get_current_endpoint()
    return ANTIGRAVITY_CONFIG.ENDPOINTS[_current_endpoint_index] or ANTIGRAVITY_CONFIG.ENDPOINTS[1]
end

-- Create adapter using Antigravity API
local adapter = {
    name = "antigravity_oauth",
    formatted_name = "Antigravity (OAuth)",
    roles = {
        llm = "model",
        user = "user",
    },
    opts = {
        stream = true,
        tools = true,
        vision = true,
    },
    features = {
        text = true,
        tokens = true,
    },
    -- Use Antigravity API endpoint (daily sandbox first)
    url = ANTIGRAVITY_CONFIG.ENDPOINTS[1] .. "/v1internal:streamGenerateContent?alt=sse",
    env = {
        api_key = function()
            local token, _ = get_access_token()
            return token
        end,
    },
    headers = {
        ["Authorization"] = "Bearer ${api_key}",
        ["Content-Type"] = "application/json",
        ["User-Agent"] = ANTIGRAVITY_CONFIG.HEADERS["User-Agent"],
        ["X-Goog-Api-Client"] = ANTIGRAVITY_CONFIG.HEADERS["X-Goog-Api-Client"],
        ["Client-Metadata"] = ANTIGRAVITY_CONFIG.HEADERS["Client-Metadata"],
    },
    handlers = {
        setup = function(self)
            local access_token, project_id = get_access_token()
            if not access_token then
                vim.notify(
                    "Antigravity OAuth: Not authenticated. Run :AntigravityOAuthSetup to authenticate.",
                    vim.log.levels.ERROR
                )
                return false
            end
            if not project_id then
                vim.notify(
                    "Antigravity OAuth: No project ID. Run :AntigravityOAuthSetup to reauthenticate.",
                    vim.log.levels.ERROR
                )
                return false
            end

            -- Store project_id for form_messages
            self._project_id = project_id

            -- Set model-specific options
            local model = self.schema.model.default
            local model_opts = self.schema.model.choices[model]
            if model_opts and model_opts.opts then
                self.opts = vim.tbl_deep_extend("force", self.opts, model_opts.opts)
            end

            return true
        end,

        tokens = function(self, data)
            if not data or data == "" then
                return nil
            end

            -- Parse SSE data
            local data_str = type(data) == "table" and data.body or data
            if type(data_str) ~= "string" then
                return nil
            end

            -- Extract JSON from SSE format
            local json_str = data_str:match("^data:%s*(.+)$") or data_str
            local ok, json = pcall(vim.json.decode, json_str, { luanil = { object = true } })

            if ok then
                -- Handle wrapped response format
                local response = json.response or json
                if response and response.usageMetadata then
                    return response.usageMetadata.totalTokenCount
                end
            end
            return nil
        end,

        -- Return empty to prevent default parameters from being added
        form_parameters = function(self, params, messages)
            return {}
        end,

        -- Return empty - we use set_body instead
        form_messages = function(self, messages)
            return {}
        end,

        -- Use set_body to completely control the request body format
        set_body = function(self, payload)
            local contents = {}
            local system_instruction = nil
            local messages = payload.messages or {}

            for _, msg in ipairs(messages) do
                if msg.role == "system" then
                    -- Collect system messages
                    if not system_instruction then
                        system_instruction = { parts = {} }
                    end
                    table.insert(system_instruction.parts, { text = msg.content })
                elseif msg.role == "user" or msg.role == "assistant" then
                    local role = msg.role == "assistant" and "model" or "user"
                    local parts = {}

                    if type(msg.content) == "string" then
                        table.insert(parts, { text = msg.content })
                    elseif type(msg.content) == "table" then
                        for _, part in ipairs(msg.content) do
                            if part.type == "text" then
                                table.insert(parts, { text = part.text })
                            elseif part.type == "image_url" then
                                -- Handle image
                                local url = part.image_url and part.image_url.url
                                if url then
                                    if string.match(url, "^data:") then
                                        local mime, img_data = string.match(url, "^data:([^;]+);base64,(.+)$")
                                        if mime and img_data then
                                            table.insert(parts, {
                                                inlineData = {
                                                    mimeType = mime,
                                                    data = img_data,
                                                },
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if #parts > 0 then
                        table.insert(contents, { role = role, parts = parts })
                    end
                end
            end

            -- Build the inner request
            local request = {
                contents = contents,
            }

            if system_instruction then
                request.systemInstruction = system_instruction
            end

            -- Add generation config for reasoning models
            local model = self.schema.model.default
            local model_opts = self.schema.model.choices[model]
            if model_opts and model_opts.opts and model_opts.opts.can_reason then
                request.generationConfig = {
                    thinkingConfig = {
                        thinkingBudget = 8192,
                    },
                }
            end

            -- Add session ID to request (Antigravity-specific)
            request.sessionId = generate_session_id()

            -- Return the full Antigravity API format with userAgent and requestId
            return {
                project = self._project_id or _project_id,
                model = model,
                request = request,
                userAgent = "antigravity",
                requestId = generate_request_id(),
            }
        end,

        ---Output the data from the API ready for insertion into the chat buffer
        ---@param self CodeCompanion.HTTPAdapter
        ---@param data string|table The streamed SSE data from the API
        ---@param tools? table The table to write any tool output to
        ---@return table|nil {status: string, output: table}
        chat_output = function(self, data, tools)
            if not data or data == "" then
                return nil
            end

            -- Parse SSE data format: "data: {...}"
            local data_str = type(data) == "table" and data.body or data
            if type(data_str) ~= "string" then
                return nil
            end

            -- Extract JSON from SSE format (handle "data: " prefix)
            local json_str = data_str:match("^data:%s*(.+)$") or data_str
            if not json_str or json_str == "" or json_str == "[DONE]" then
                return nil
            end

            local ok, json = pcall(vim.json.decode, json_str, { luanil = { object = true } })
            if not ok then
                log:debug("Antigravity OAuth: Failed to parse JSON: %s", json_str:sub(1, 200))
                return nil
            end

            -- Handle wrapped response format from Code Assist API
            -- Response format: { response: { candidates: [...] } }
            local response = json.response or json

            if not response or not response.candidates or #response.candidates == 0 then
                return nil
            end

            local candidate = response.candidates[1]
            if not candidate or not candidate.content then
                return nil
            end

            -- Extract text content from parts
            local content = ""
            local role = candidate.content.role == "model" and "assistant" or candidate.content.role

            if candidate.content.parts then
                for _, part in ipairs(candidate.content.parts) do
                    if part.text then
                        content = content .. part.text
                    end
                end
            end

            if content == "" and not role then
                return nil
            end

            return {
                status = "success",
                output = {
                    role = role,
                    content = content,
                },
            }
        end,

        ---Output the data from the API ready for inlining into the current buffer
        ---@param self CodeCompanion.HTTPAdapter
        ---@param data string|table The streamed data from the API
        ---@param context? table Useful context about the buffer to inline to
        ---@return {status: string, output: string}|nil
        inline_output = function(self, data, context)
            local result = self.handlers.chat_output(self, data, nil)
            if result and result.output and result.output.content then
                return {
                    status = result.status,
                    output = result.output.content,
                }
            end
            return nil
        end,

        on_exit = function(self, data)
            return nil
        end,
    },
    schema = {
        model = {
            order = 1,
            mapping = "parameters",
            type = "enum",
            desc = "The model that will complete your prompt.",
            default = "gemini-2.5-flash",
            choices = {
                -- Gemini 3 models
                ["gemini-3-pro-high"] = {
                    formatted_name = "Gemini 3 Pro High",
                    opts = { can_reason = true, has_vision = true },
                },
                ["gemini-3-pro-low"] = {
                    formatted_name = "Gemini 3 Pro Low",
                    opts = { can_reason = true, has_vision = true },
                },
                -- Gemini 2.x models
                ["gemini-2.5-pro"] = {
                    formatted_name = "Gemini 2.5 Pro",
                    opts = { can_reason = true, has_vision = true },
                },
                ["gemini-2.5-flash"] = {
                    formatted_name = "Gemini 2.5 Flash",
                    opts = { can_reason = true, has_vision = true },
                },
                ["gemini-2.0-flash"] = { formatted_name = "Gemini 2.0 Flash", opts = { has_vision = true } },
                ["gemini-2.0-flash-lite"] = { formatted_name = "Gemini 2.0 Flash Lite", opts = { has_vision = true } },
                -- Gemini 1.x models
                ["gemini-1.5-pro"] = { formatted_name = "Gemini 1.5 Pro", opts = { has_vision = true } },
                ["gemini-1.5-flash"] = { formatted_name = "Gemini 1.5 Flash", opts = { has_vision = true } },
                -- Claude models (via Antigravity)
                ["claude-sonnet-4-5"] = { formatted_name = "Claude Sonnet 4.5", opts = { has_vision = true } },
                ["claude-sonnet-4-5-thinking"] = {
                    formatted_name = "Claude Sonnet 4.5 Thinking",
                    opts = { can_reason = true, has_vision = true },
                },
                ["claude-opus-4-5-thinking"] = {
                    formatted_name = "Claude Opus 4.5 Thinking",
                    opts = { can_reason = true, has_vision = true },
                },
                -- GPT models (via Antigravity)
                ["gpt-oss-120b-medium"] = { formatted_name = "GPT-OSS 120B Medium", opts = { has_vision = false } },
            },
        },
        max_tokens = {
            order = 2,
            mapping = "parameters",
            type = "integer",
            optional = true,
            default = nil,
            desc = "The maximum number of tokens to include in a response candidate.",
            validate = function(n)
                return n > 0, "Must be greater than 0"
            end,
        },
        temperature = {
            order = 3,
            mapping = "parameters",
            type = "number",
            optional = true,
            default = nil,
            desc = "Controls the randomness of the output.",
            validate = function(n)
                return n >= 0 and n <= 2, "Must be between 0 and 2"
            end,
        },
    },
}

adapter.get_access_token = get_access_token

return adapter
