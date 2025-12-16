local uv = vim.uv or vim.loop
local curl = require("plenary.curl")
local Job = require("plenary.job")
local config = require("codecompanion.config")
local log = require("codecompanion.utils.log")

-- Module-level token cache
local _access_token = nil
local _refresh_token = nil
local _token_expires = nil
local _account_id = nil
local _token_loaded = false

-- Load hardcoded instructions from local file
local codex_instructions = require("extension.codex-instructions")

-- OAuth flow constant configuration (from openai/codex)
local OAUTH_CONFIG = {
    CLIENT_ID = "app_EMoamEEZ73f0CkXaXp7hrann",
    -- No CLIENT_SECRET (public client with PKCE)
    REDIRECT_URI = "http://localhost:1455/auth/callback",
    AUTH_URL = "https://auth.openai.com/oauth/authorize",
    TOKEN_URL = "https://auth.openai.com/oauth/token",
    SCOPES = "openid profile email offline_access",
    CALLBACK_PORT = 1455,
    ACCESS_TOKEN_EXPIRY_BUFFER_MS = 60 * 1000, -- 1 minute buffer
}

-- Codex API configuration
local CODEX_CONFIG = {
    BASE_URL = "https://chatgpt.com/backend-api",
    ENDPOINT = "https://chatgpt.com/backend-api/codex/responses",
    HEADERS = {
        ["OpenAI-Beta"] = "responses=experimental",
        ["originator"] = "codex_cli_rs",
    },
    JWT_CLAIM_PATH = "https://api.openai.com/auth",
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

-- Base64 URL decode (for JWT)
---@param input string
---@return string|nil
local function base64url_decode(input)
    if not input then
        return nil
    end
    -- Convert base64url to base64
    local base64 = input:gsub("-", "+"):gsub("_", "/")
    -- Add padding if necessary
    local padding = 4 - (#base64 % 4)
    if padding ~= 4 then
        base64 = base64 .. string.rep("=", padding)
    end
    local ok, decoded = pcall(vim.base64.decode, base64)
    if ok then
        return decoded
    end
    return nil
end

-- Decode JWT token to extract payload
---@param token string
---@return table|nil
local function decode_jwt(token)
    if not token or token == "" then
        return nil
    end
    local parts = vim.split(token, ".", { plain = true })
    if #parts ~= 3 then
        return nil
    end
    local payload = base64url_decode(parts[2])
    if not payload then
        return nil
    end
    local ok, data = pcall(vim.json.decode, payload)
    if ok and data then
        return data
    end
    return nil
end

-- Extract ChatGPT account ID from JWT token
---@param token string
---@return string|nil
local function extract_account_id(token)
    local payload = decode_jwt(token)
    if not payload then
        return nil
    end
    local auth_claim = payload[CODEX_CONFIG.JWT_CLAIM_PATH]
    if auth_claim and auth_claim.chatgpt_account_id then
        return auth_claim.chatgpt_account_id
    end
    return nil
end

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
        readers = {
            function()
                return read_random_from_windows(length)
            end,
            function()
                return read_random_from_openssl(length)
            end,
        }
    else
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

-- Get a temporary file path (cross-platform)
---@return string
local function get_temp_file()
    local tmp_file = os.tmpname()
    if vim.fn.has("win32") == 1 then
        local temp_dir = os.getenv("TEMP") or os.getenv("TMP") or "."
        if not tmp_file:match("[\\/]") then
            tmp_file = temp_dir .. "\\" .. tmp_file
        end
    end
    return tmp_file
end

-- Generate random string for PKCE
---@param length number
---@return string
local function generate_random_string(length)
    if vim.fn.executable("openssl") == 1 then
        local result = vim.fn.system({ "openssl", "rand", "-base64", tostring(math.ceil(length * 3 / 4)) })
        if vim.v.shell_error == 0 and result then
            local safe = trim(result):gsub("+", "-"):gsub("/", "_"):gsub("=", "")
            if #safe >= length then
                return safe:sub(1, length)
            end
        end
    end

    local bytes = secure_random_bytes(length)
    if not bytes then
        log:error("Codex OAuth: Unable to generate secure random bytes")
        return nil
    end

    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = {}
    for i = 1, length do
        local byte = bytes:byte(i)
        local rand_index = (byte % #chars) + 1
        result[i] = chars:sub(rand_index, rand_index)
    end
    return table.concat(result)
end

-- Generate SHA256 hash in base64url format for PKCE (cross-platform)
---@param input string
---@return string|nil
local function sha256_base64url(input)
    local tmp_file = get_temp_file()
    local f = io.open(tmp_file, "wb")
    if not f then
        return nil
    end
    f:write(input)
    f:close()

    local result
    if vim.fn.has("win32") == 1 then
        local ps_exe = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
        local script = string.format(
            "$bytes = [System.IO.File]::ReadAllBytes('%s'); "
                .. "$hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes); "
                .. "[System.Convert]::ToBase64String($hash)",
            tmp_file:gsub("'", "''")
        )
        result = vim.fn.system({ ps_exe, "-NoProfile", "-Command", script })
    else
        result = vim.fn.system({ "openssl", "dgst", "-sha256", "-binary", tmp_file })
        if vim.v.shell_error == 0 and result then
            result = vim.base64.encode(result)
        end
    end

    os.remove(tmp_file)

    if vim.v.shell_error ~= 0 or not result or result == "" then
        return nil
    end

    local base64 = trim(result)
    return base64:gsub("+", "-"):gsub("/", "_"):gsub("=", "")
end

-- Generate PKCE code verifier and challenge
---@return { verifier: string, challenge: string }|nil
local function generate_pkce()
    local verifier = generate_random_string(64)
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

-- Generate random state for OAuth
---@return string
local function generate_state()
    local bytes = secure_random_bytes(16)
    if bytes then
        local hex = {}
        for i = 1, #bytes do
            hex[i] = string.format("%02x", bytes:byte(i))
        end
        return table.concat(hex)
    end
    return generate_random_string(32)
end

-- Find data path for storing OAuth tokens
---@return string|nil
local function find_data_path()
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
        log:error("Codex OAuth: Unable to determine data directory")
        return nil
    end

    local path_sep = package.config:sub(1, 1)
    return data_path .. path_sep .. "codex_oauth.json"
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
        return false
    end

    local decode_success, data = pcall(vim.json.decode, table.concat(content, "\n"))
    if decode_success and data then
        _access_token = data.access_token
        _refresh_token = data.refresh_token
        _token_expires = data.expires
        _account_id = data.account_id
        return _refresh_token ~= nil
    end

    return false
end

-- Save tokens to file
---@param access_token string
---@param refresh_token string
---@param expires number
---@param account_id string|nil
---@return boolean
local function save_tokens(access_token, refresh_token, expires, account_id)
    if not refresh_token or refresh_token == "" then
        log:error("Codex OAuth: Cannot save without refresh token")
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
        account_id = account_id,
        created_at = os.time(),
        version = 1,
    }

    local success, json_data = pcall(vim.json.encode, data)
    if not success then
        log:error("Codex OAuth: Unable to encode token data")
        return false
    end

    local write_success, err = pcall(function()
        if vim.fn.has("win32") == 1 then
            vim.fn.writefile(vim.split(json_data, "\n", { plain = true }), token_file, "b")
        else
            vim.fn.writefile({ json_data }, token_file)
        end
    end)

    if write_success then
        _access_token = access_token
        _refresh_token = refresh_token
        _token_expires = expires
        _account_id = account_id
        _token_loaded = true
        log:info("Codex OAuth: Tokens saved successfully")
        return true
    else
        log:error("Codex OAuth: Failed to save tokens: %s", err or "unknown error")
        return false
    end
end

-- Check if access token is expired
---@return boolean
local function access_token_expired()
    if not _access_token or not _token_expires then
        return true
    end
    local now_ms = os.time() * 1000
    return _token_expires <= now_ms + OAUTH_CONFIG.ACCESS_TOKEN_EXPIRY_BUFFER_MS
end

-- Refresh access token using refresh token
---@return string|nil
local function refresh_access_token()
    if not _refresh_token or _refresh_token == "" then
        log:error("Codex OAuth: No refresh token available")
        return nil
    end

    log:debug("Codex OAuth: Refreshing access token")

    local response = curl.post(OAUTH_CONFIG.TOKEN_URL, {
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        },
        body = "grant_type=refresh_token"
            .. "&refresh_token="
            .. url_encode(_refresh_token)
            .. "&client_id="
            .. url_encode(OAUTH_CONFIG.CLIENT_ID),
        timeout = 30000,
        on_error = function(err)
            log:error("Codex OAuth: Token refresh error: %s", vim.inspect(err))
        end,
    })

    if not response then
        log:error("Codex OAuth: No response from token refresh request")
        return nil
    end

    if response.status >= 400 then
        log:error("Codex OAuth: Token refresh failed, status %d: %s", response.status, response.body or "no body")
        return nil
    end

    local decode_success, token_data = pcall(vim.json.decode, response.body)
    if not decode_success or not token_data or not token_data.access_token then
        log:error("Codex OAuth: Invalid token refresh response")
        return nil
    end

    local expires = os.time() * 1000 + (token_data.expires_in or 3600) * 1000
    local new_refresh = token_data.refresh_token or _refresh_token
    local account_id = extract_account_id(token_data.access_token) or _account_id

    if save_tokens(token_data.access_token, new_refresh, expires, account_id) then
        log:debug("Codex OAuth: Access token refreshed successfully")
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
        log:error("Codex OAuth: Authorization code and verifier required")
        return false
    end

    log:debug("Codex OAuth: Exchanging authorization code for tokens")

    local response = curl.post(OAUTH_CONFIG.TOKEN_URL, {
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        },
        body = "grant_type=authorization_code"
            .. "&client_id="
            .. url_encode(OAUTH_CONFIG.CLIENT_ID)
            .. "&code="
            .. url_encode(code)
            .. "&code_verifier="
            .. url_encode(verifier)
            .. "&redirect_uri="
            .. url_encode(OAUTH_CONFIG.REDIRECT_URI),
        timeout = 30000,
        on_error = function(err)
            log:error("Codex OAuth: Token exchange error: %s", vim.inspect(err))
        end,
    })

    if not response then
        log:error("Codex OAuth: No response from token exchange request")
        return false
    end

    if response.status >= 400 then
        log:error("Codex OAuth: Token exchange failed, status %d: %s", response.status, response.body or "no body")
        return false
    end

    local decode_success, token_data = pcall(vim.json.decode, response.body)
    if not decode_success or not token_data then
        log:error("Codex OAuth: Invalid token exchange response")
        return false
    end

    if not token_data.access_token or not token_data.refresh_token then
        log:error("Codex OAuth: Missing tokens in response")
        return false
    end

    local expires = os.time() * 1000 + (token_data.expires_in or 3600) * 1000
    local account_id = extract_account_id(token_data.access_token)

    if not account_id then
        log:warn("Codex OAuth: Could not extract account ID from token")
    end

    return save_tokens(token_data.access_token, token_data.refresh_token, expires, account_id)
end

-- Generate OAuth authorization URL
---@return { url: string, verifier: string, state: string }|nil
local function generate_auth_url()
    local pkce = generate_pkce()
    if not pkce then
        return nil
    end

    local state = generate_state()

    local query_params = {
        "response_type=code",
        "client_id=" .. url_encode(OAUTH_CONFIG.CLIENT_ID),
        "redirect_uri=" .. url_encode(OAUTH_CONFIG.REDIRECT_URI),
        "scope=" .. url_encode(OAUTH_CONFIG.SCOPES),
        "code_challenge=" .. url_encode(pkce.challenge),
        "code_challenge_method=S256",
        "state=" .. url_encode(state),
        "id_token_add_organizations=true",
        "codex_cli_simplified_flow=true",
        "originator=codex_cli_rs",
    }

    local auth_url = OAUTH_CONFIG.AUTH_URL .. "?" .. table.concat(query_params, "&")

    return {
        url = auth_url,
        verifier = pkce.verifier,
        state = state,
    }
end

-- Get access token (from cache, file, or refresh)
---@return string|nil, string|nil
local function get_access_token()
    if not _token_loaded then
        load_tokens()
    end

    if _access_token and not access_token_expired() then
        return _access_token, _account_id
    end

    if _refresh_token then
        local new_token = refresh_access_token()
        if new_token then
            return new_token, _account_id
        end
    end

    log:error("Codex OAuth: Access token not available. Please run :CodexOAuthSetup to authenticate")
    return nil, nil
end

-- HTTP success response HTML
local SUCCESS_HTML = [[<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Codex OAuth - CodeCompanion</title>
    <style>
        :root { color-scheme: light dark; }
        body {
            margin: 0; min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #f7f7f8; color: #202123;
        }
        main {
            width: min(448px, calc(100% - 3rem));
            background: #ffffff; border-radius: 16px;
            padding: 2.5rem 2.75rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { margin: 0 0 0.75rem; font-size: 1.75rem; font-weight: 600; }
        p { margin: 0 0 1.75rem; font-size: 1.05rem; line-height: 1.6; color: #6e6e80; }
        .action {
            display: inline-flex; padding: 0.65rem 1.85rem;
            border-radius: 8px; background: #10a37f; color: #fff;
            font-weight: 500; text-decoration: none;
        }
        @media (prefers-color-scheme: dark) {
            body { background: #202123; color: #ececf1; }
            main { background: #343541; }
            p { color: #c5c5d2; }
        }
    </style>
</head>
<body>
    <main>
        <h1>Authentication Successful!</h1>
        <p>Your ChatGPT account is now linked to CodeCompanion. You can close this window and return to Neovim.</p>
        <a class="action" href="javascript:window.close()">Close window</a>
    </main>
</body>
</html>]]

-- Start local HTTP server for OAuth callback
---@param verifier string
---@param expected_state string
---@param callback function
local function start_oauth_server(verifier, expected_state, callback)
    local server = uv.new_tcp()
    if not server then
        log:error("Codex OAuth: Failed to create TCP server")
        callback(nil, "Failed to create TCP server")
        return
    end

    local bind_ok, bind_err = server:bind("127.0.0.1", OAUTH_CONFIG.CALLBACK_PORT)
    if not bind_ok then
        log:error("Codex OAuth: Failed to bind to port %d: %s", OAUTH_CONFIG.CALLBACK_PORT, bind_err or "unknown")
        server:close()
        callback(nil, "Failed to bind to port " .. OAUTH_CONFIG.CALLBACK_PORT)
        return
    end

    local listen_ok, listen_err = server:listen(128, function(err)
        if err then
            log:error("Codex OAuth: Server listen error: %s", err)
            return
        end

        local client = uv.new_tcp()
        server:accept(client)

        local request_data = ""

        client:read_start(function(read_err, chunk)
            if read_err then
                log:error("Codex OAuth: Read error: %s", read_err)
                client:close()
                return
            end

            if chunk then
                request_data = request_data .. chunk

                if string.find(request_data, "\r\n\r\n") then
                    local request_line = string.match(request_data, "^([^\r\n]+)")
                    local path = string.match(request_line or "", "GET ([^ ]+)")

                    if path and string.find(path, "/auth/callback") then
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
                                    -- Verify state if provided
                                    if params.state and params.state ~= expected_state then
                                        callback(nil, "State mismatch - possible CSRF attack")
                                    else
                                        callback(params.code, nil)
                                    end
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
        log:error("Codex OAuth: Failed to listen: %s", listen_err or "unknown")
        server:close()
        callback(nil, "Failed to start server")
        return
    end

    log:debug("Codex OAuth: Server listening on port %d", OAUTH_CONFIG.CALLBACK_PORT)

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
        vim.notify("Unable to generate Codex OAuth authorization URL, please check logs.", vim.log.levels.ERROR)
        return false
    end

    vim.notify("Starting Codex OAuth authentication...", vim.log.levels.INFO)

    start_oauth_server(auth_data.verifier, auth_data.state, function(code, err)
        if err then
            vim.notify("Codex OAuth failed: " .. err, vim.log.levels.ERROR)
            return
        end

        if code then
            vim.notify("Authorization code received, exchanging for tokens...", vim.log.levels.INFO)
            if exchange_code_for_tokens(code, auth_data.verifier) then
                vim.notify("Codex OAuth authentication successful!", vim.log.levels.INFO)
            else
                vim.notify("Codex OAuth: Failed to exchange code for tokens", vim.log.levels.ERROR)
            end
        end
    end)

    -- Open URL in default browser (cross-platform)
    local function open_url(url)
        local success = false

        if vim.fn.has("mac") == 1 then
            vim.fn.system({ "open", url })
            success = vim.v.shell_error == 0
        elseif vim.fn.has("win32") == 1 then
            vim.fn.system({ "rundll32", "url.dll,FileProtocolHandler", url })
            success = vim.v.shell_error == 0
            if not success then
                local ps_exe = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
                vim.fn.system({ ps_exe, "-NoProfile", "-Command", "Start-Process", url })
                success = vim.v.shell_error == 0
            end
        elseif vim.fn.has("unix") == 1 then
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
vim.api.nvim_create_user_command("CodexOAuthSetup", function()
    setup_oauth()
end, {
    desc = "Setup Codex OAuth authentication",
})

vim.api.nvim_create_user_command("CodexOAuthStatus", function()
    load_tokens()
    if not _refresh_token then
        vim.notify("Codex OAuth: Not authenticated. Run :CodexOAuthSetup to authenticate.", vim.log.levels.WARN)
        return
    end

    local status = "Codex OAuth: Authenticated"
    if _account_id then
        status = status .. " (Account: " .. _account_id:sub(1, 8) .. "...)"
    end
    if _access_token and not access_token_expired() then
        status = status .. " - Token is valid"
    else
        status = status .. " - Token needs refresh"
    end
    vim.notify(status, vim.log.levels.INFO)
end, {
    desc = "Check Codex OAuth status",
})

vim.api.nvim_create_user_command("CodexOAuthClear", function()
    local token_file = get_token_file_path()
    if token_file and vim.fn.filereadable(token_file) == 1 then
        local success = pcall(vim.fn.delete, token_file)
        if success then
            _access_token = nil
            _refresh_token = nil
            _token_expires = nil
            _account_id = nil
            _token_loaded = false
            vim.notify("Codex OAuth: Tokens cleared.", vim.log.levels.INFO)
        else
            vim.notify("Codex OAuth: Failed to clear token file.", vim.log.levels.ERROR)
        end
    else
        vim.notify("Codex OAuth: No tokens to clear.", vim.log.levels.WARN)
    end
end, {
    desc = "Clear stored Codex OAuth tokens",
})

vim.api.nvim_create_user_command("CodexUpdateInstructions", function()
    vim.notify("Codex: Fetching latest instructions from GitHub...", vim.log.levels.INFO)

    local response = curl.get(codex_instructions.SOURCE_URL, {
        timeout = 15000,
        on_error = function(err)
            vim.notify("Codex: Failed to fetch instructions: " .. vim.inspect(err), vim.log.levels.ERROR)
        end,
    })

    if not response or response.status ~= 200 or not response.body or response.body == "" then
        vim.notify("Codex: Failed to fetch instructions from GitHub", vim.log.levels.ERROR)
        return
    end

    -- Get the instructions file path
    local config_path = vim.fn.stdpath("config")
    local instructions_file = config_path .. "/lua/extension/codex-instructions.lua"

    -- Generate the new file content
    local date = os.date("%Y-%m-%d")
    local new_content = string.format(
        [[-- Codex Instructions (fetched from https://github.com/openai/codex)
-- Last updated: %s
-- Run :CodexUpdateInstructions to update from GitHub

local M = {}

M.INSTRUCTIONS = %s

M.SOURCE_URL = %q

return M
]],
        date,
        vim.inspect(response.body),
        codex_instructions.SOURCE_URL
    )

    -- Write the file
    local success, err = pcall(function()
        vim.fn.writefile(vim.split(new_content, "\n", { plain = true }), instructions_file)
    end)

    if success then
        -- Reload the module
        package.loaded["extension.codex-instructions"] = nil
        codex_instructions = require("extension.codex-instructions")
        vim.notify("Codex: Instructions updated successfully! Restart Neovim to apply.", vim.log.levels.INFO)
    else
        vim.notify("Codex: Failed to write instructions file: " .. (err or "unknown"), vim.log.levels.ERROR)
    end
end, {
    desc = "Update Codex instructions from GitHub",
})

-- Create adapter using Codex API (OpenAI Responses API format)
local adapter = {
    name = "codex_oauth",
    formatted_name = "Codex (ChatGPT OAuth)",
    roles = {
        llm = "assistant",
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
    url = CODEX_CONFIG.ENDPOINT,
    env = {
        api_key = function()
            local token, _ = get_access_token()
            return token
        end,
    },
    headers = {
        ["Authorization"] = "Bearer ${api_key}",
        ["Content-Type"] = "application/json",
        ["Accept"] = "text/event-stream",
        ["OpenAI-Beta"] = CODEX_CONFIG.HEADERS["OpenAI-Beta"],
        ["originator"] = CODEX_CONFIG.HEADERS["originator"],
    },
    handlers = {
        setup = function(self)
            local access_token, account_id = get_access_token()
            if not access_token then
                vim.notify(
                    "Codex OAuth: Not authenticated. Run :CodexOAuthSetup to authenticate.",
                    vim.log.levels.ERROR
                )
                return false
            end

            -- Store account_id for headers
            self._account_id = account_id

            -- Add chatgpt-account-id header dynamically
            if account_id then
                self.headers["chatgpt-account-id"] = account_id
            end

            return true
        end,

        tokens = function(self, data)
            if not data or data == "" then
                return nil
            end

            local data_str = type(data) == "table" and data.body or data
            if type(data_str) ~= "string" then
                return nil
            end

            local json_str = data_str:match("^data:%s*(.+)$") or data_str
            local ok, json = pcall(vim.json.decode, json_str, { luanil = { object = true } })

            if ok and json then
                if json.usage then
                    return json.usage.total_tokens
                end
            end
            return nil
        end,

        form_parameters = function(self, params, messages)
            return {}
        end,

        form_messages = function(self, messages)
            return {}
        end,

        -- Use set_body to transform to Codex API format
        set_body = function(self, payload)
            local input = {}
            local messages = payload.messages or {}

            for _, msg in ipairs(messages) do
                local content = {}

                if type(msg.content) == "string" then
                    table.insert(content, { type = "input_text", text = msg.content })
                elseif type(msg.content) == "table" then
                    for _, part in ipairs(msg.content) do
                        if part.type == "text" then
                            table.insert(content, { type = "input_text", text = part.text })
                        elseif part.type == "image_url" then
                            local url = part.image_url and part.image_url.url
                            if url then
                                table.insert(content, { type = "input_image", image_url = url })
                            end
                        end
                    end
                end

                if #content > 0 then
                    local role = msg.role
                    -- Map system to developer role for Codex API
                    if role == "system" then
                        role = "developer"
                    end

                    table.insert(input, {
                        type = "message",
                        role = role,
                        content = content,
                    })
                end
            end

            local model = self.schema.model.default

            -- Build Codex API request body
            local body = {
                model = model,
                input = input,
                instructions = codex_instructions.INSTRUCTIONS,
                store = false,
                stream = true,
            }

            -- Add reasoning config for supported models
            local model_opts = self.schema.model.choices[model]
            if model_opts and model_opts.opts and model_opts.opts.can_reason then
                body.reasoning = {
                    effort = "medium",
                    summary = "auto",
                }
            end

            -- Add text verbosity
            body.text = {
                verbosity = "medium",
            }

            -- Include encrypted reasoning content for stateless operation
            body.include = { "reasoning.encrypted_content" }

            return body
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

            local data_str = type(data) == "table" and data.body or data
            if type(data_str) ~= "string" then
                return nil
            end

            -- Handle SSE format
            local json_str = data_str:match("^data:%s*(.+)$") or data_str
            if not json_str or json_str == "" or json_str == "[DONE]" then
                return nil
            end

            local ok, json = pcall(vim.json.decode, json_str, { luanil = { object = true } })
            if not ok then
                return nil
            end

            -- Handle Codex response format
            -- Response has output array with items
            local content = ""
            local role = "assistant"

            if json.output and type(json.output) == "table" then
                for _, item in ipairs(json.output) do
                    if item.type == "message" and item.content then
                        for _, part in ipairs(item.content) do
                            if part.type == "output_text" and part.text then
                                content = content .. part.text
                            end
                        end
                    end
                end
            end

            -- Also handle delta format for streaming
            if json.type == "response.output_text.delta" and json.delta then
                content = json.delta
            end

            if content == "" then
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
            default = "gpt-5.1-codex",
            choices = {
                -- GPT-5.2 (supports xhigh reasoning)
                ["gpt-5.2"] = { formatted_name = "GPT-5.2", opts = { can_reason = true, has_vision = true } },
                -- GPT-5.1 Codex family
                ["gpt-5.1-codex-max"] = { formatted_name = "GPT-5.1 Codex Max", opts = { can_reason = true, has_vision = true } },
                ["gpt-5.1-codex"] = { formatted_name = "GPT-5.1 Codex", opts = { can_reason = true, has_vision = true } },
                ["gpt-5.1-codex-mini"] = { formatted_name = "GPT-5.1 Codex Mini", opts = { can_reason = true, has_vision = true } },
                -- GPT-5.1 general
                ["gpt-5.1"] = { formatted_name = "GPT-5.1", opts = { can_reason = true, has_vision = true } },
                -- Legacy Codex Mini
                ["codex-mini-latest"] = { formatted_name = "Codex Mini Latest", opts = { can_reason = true, has_vision = true } },
            },
        },
    },
}

adapter.get_access_token = get_access_token

return adapter
