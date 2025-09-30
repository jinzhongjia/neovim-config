-- Anthropic OAuth 认证模块
--
-- 依赖要求：
-- - Linux/macOS: 需要安装 OpenSSL
-- - Windows: 需要以下任一工具：
--   * OpenSSL (推荐)
--   * PowerShell 7+ (pwsh, 跨平台版本)
--   * Windows PowerShell 5.x (powershell, Windows 内置)
--
-- PKCE (Proof Key for Code Exchange) 流程需要 SHA256 哈希生成器
-- 本模块会按以下优先级尝试：
-- 1. OpenSSL (跨平台，推荐)
-- 2. PowerShell 7/pwsh (Windows 优先，如果安装了的话)
-- 3. Windows PowerShell 5.x (Windows 内置备选)

local uv = vim.uv
local Job = require("plenary.job")
local anthropic = require("codecompanion.adapters.http.anthropic")
local config = require("codecompanion.config")
local curl = require("plenary.curl")
local log = require("codecompanion.utils.log")

-- 模块级别的 API 密钥缓存
local _api_key = nil
local _api_key_loaded = false

-- OAuth 流程的常量配置
local OAUTH_CONFIG = {
    CLIENT_ID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e", -- OAuth 客户端 ID
    REDIRECT_URI = "https://console.anthropic.com/oauth/code/callback", -- 授权回调地址
    AUTH_URL = "https://console.anthropic.com/oauth/authorize", -- 授权请求地址
    TOKEN_URL = "https://api.anthropic.com/v1/oauth/token", -- 令牌交换地址
    API_KEY_URL = "https://api.anthropic.com/api/oauth/claude_cli/create_api_key", -- API 密钥创建地址
    SCOPES = "org:create_api_key user:profile user:inference", -- 请求的权限范围
}

-- URL 编码函数，用于构建 OAuth URL 参数
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

-- 生成用于 PKCE 的加密安全随机字符串
-- PKCE (Proof Key for Code Exchange) 是 OAuth 2.0 的安全扩展
---@param length number
---@return string
local function generate_random_string(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    local result = {}

    -- 使用更好的跨平台随机种子生成方法
    -- 结合多个熵源以提高随机性
    local seed = os.time() -- 基础时间戳

    -- 使用 vim.loop (libuv) 获取高精度时间，跨平台兼容
    -- 获取高精度时间戳（微秒）
    local hrtime = uv.hrtime()
    if hrtime then
        -- 取低32位作为额外的熵
        seed = seed + (hrtime % 2147483647)
    end

    -- 获取进程ID作为额外的熵
    local pid = uv.os_getpid()
    if pid then
        seed = seed + pid
    end

    -- 添加一些运行时信息作为熵
    local runtime_entropy = tostring({}):match("0x(%x+)") -- 从新对象地址获取熵
    if runtime_entropy then
        seed = seed + (tonumber(runtime_entropy, 16) % 1000000)
    end

    math.randomseed(seed)
    -- 预热随机数生成器
    for _ = 1, 10 do
        math.random()
    end

    for i = 1, length do
        local rand_index = math.random(1, #chars)
        table.insert(result, chars:sub(rand_index, rand_index))
    end
    return table.concat(result)
end

-- 生成 PKCE challenge 所需的 SHA256 哈希（base64url 格式）
---@param input string
---@return string
local function sha256_base64url(input)
    local is_windows = vim.fn.has("win32") == 1

    -- 尝试使用 OpenSSL 生成正确的 SHA256 哈希
    if vim.fn.executable("openssl") == 1 then
        local job = Job:new({
            command = "openssl",
            args = { "dgst", "-sha256", "-binary" },
            writer = input,
            enable_recording = true,
            -- Windows 平台需要特殊的环境变量
            env = is_windows and {
                PATH = vim.env.PATH,
                SYSTEMROOT = vim.env.SYSTEMROOT,
            } or nil,
        })

        local success, _ = pcall(function()
            job:sync(3000) -- 3 second timeout
        end)

        if success and job.code == 0 then
            local result = job:result()
            local hash_binary = ""

            -- Windows 平台可能返回额外的输出
            if is_windows and result then
                -- 在 Windows 上，二进制输出可能被分割成多行
                for _, line in ipairs(result) do
                    if line and line ~= "" then
                        hash_binary = hash_binary .. line
                    end
                end
            else
                hash_binary = table.concat(result or {}, "")
            end

            if hash_binary ~= "" then
                local base64 = vim.base64.encode(hash_binary)
                return base64:gsub("[+/=]", { ["+"] = "-", ["/"] = "_", ["="] = "" })
            end
        else
            log:warn(
                "OpenSSL 命令执行失败，错误代码: %s, stderr: %s",
                job.code or "unknown",
                table.concat(job:stderr_result() or {}, "\n")
            )
        end
    elseif is_windows then
        -- Windows 平台使用 PowerShell 作为备选方案
        -- 优先使用 PowerShell 7 (pwsh)，其次使用 Windows PowerShell 5.x (powershell)
        local ps_executable = nil
        local ps_version = nil

        if vim.fn.executable("pwsh") == 1 then
            ps_executable = "pwsh"
            ps_version = "PowerShell 7+"
        elseif vim.fn.executable("powershell") == 1 then
            ps_executable = "powershell"
            ps_version = "Windows PowerShell 5.x"
        end

        if ps_executable then
            log:debug("OpenSSL 不可用，使用 %s 生成 SHA256 哈希", ps_version)

            -- 构建 PowerShell 命令
            -- 使用 .NET 的加密类来计算 SHA256
            -- 注意：PowerShell 5 和 7 都支持这个 API
            local ps_command = string.format(
                "[Convert]::ToBase64String([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes('%s')))",
                input:gsub("'", "''") -- 转义单引号
            )

            local job = Job:new({
                command = ps_executable,
                args = {
                    "-NoProfile",
                    "-NonInteractive",
                    "-ExecutionPolicy",
                    "Bypass",
                    "-Command",
                    ps_command,
                },
                enable_recording = true,
            })

            local success, _ = pcall(function()
                job:sync(3000) -- 3 second timeout
            end)

            if success and job.code == 0 then
                local result = job:result()
                if result and #result > 0 then
                    local base64 = vim.trim(table.concat(result, ""))
                    -- 转换为 base64url 格式
                    return base64:gsub("[+/=]", { ["+"] = "-", ["/"] = "_", ["="] = "" })
                end
            else
                log:warn(
                    "%s 命令执行失败，错误代码: %s, stderr: %s",
                    ps_version,
                    job.code or "unknown",
                    table.concat(job:stderr_result() or {}, "\n")
                )
            end
        else
            log:debug("PowerShell 不可用（未找到 pwsh 或 powershell）")
        end
    end

    -- 如果 OpenSSL 和 PowerShell 都不可用，不能继续 OAuth 流程
    -- PKCE 要求真正的 SHA256 哈希，不能使用不安全的替代方案
    local error_msg
    if is_windows then
        error_msg = "OAuth 认证失败：需要 OpenSSL 或 PowerShell 来生成安全的 PKCE challenge。\n"
            .. "请确保 PowerShell 可用或安装 OpenSSL 后重试。"
    else
        error_msg = "OAuth 认证失败：需要安装 OpenSSL 来生成安全的 PKCE challenge。\n"
            .. "请安装 OpenSSL 后重试。"
    end

    log:error("无法生成 PKCE challenge：需要 OpenSSL 或 PowerShell（Windows）来计算 SHA256 哈希")
    vim.notify(error_msg, vim.log.levels.ERROR)
    return nil
end

-- 生成 PKCE 代码验证器和挑战码
---@return { verifier: string, challenge: string }
local function generate_pkce()
    local verifier = generate_random_string(128) -- 使用最大长度以提高安全性
    local challenge = sha256_base64url(verifier)

    -- 如果无法生成 challenge（例如 OpenSSL 不可用），返回 nil
    if not challenge then
        return nil
    end

    return {
        verifier = verifier,
        challenge = challenge,
    }
end

-- 查找用于存储 OAuth 令牌的数据路径
-- 支持通过环境变量自定义路径
---@return string|nil
local function find_data_path()
    -- 首先检查环境变量
    local env_path = os.getenv("CODECOMPANION_ANTHROPIC_TOKEN_PATH")
    if env_path and vim.fn.isdirectory(vim.fs.dirname(env_path)) > 0 then
        return vim.fs.dirname(env_path)
    end

    -- 使用 Neovim 数据目录（跨平台兼容）
    local nvim_data = vim.fn.stdpath("data")
    if nvim_data and vim.fn.isdirectory(nvim_data) > 0 then
        return nvim_data
    end

    return nil
end

-- 获取 OAuth 令牌文件路径
-- 使用跨平台的路径分隔符
---@return string|nil
local function get_token_file_path()
    local data_path = find_data_path()
    if not data_path then
        log:error("Anthropic OAuth: 无法确定数据目录")
        return nil
    end

    -- 使用 vim.fs.joinpath 确保跨平台路径兼容性
    local path_sep = package.config:sub(1, 1) -- 获取系统路径分隔符
    return data_path .. path_sep .. "anthropic_oauth.json"
end

-- 从文件加载 API 密钥
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
        log:debug("Anthropic OAuth: 无法读取令牌文件或文件为空")
        return nil
    end

    local decode_success, data = pcall(vim.json.decode, table.concat(content, "\n"))
    if decode_success and data and data.api_key then
        _api_key = data.api_key
        return data.api_key
    else
        log:warn("Anthropic OAuth: 令牌文件格式无效")
        return nil
    end
end

-- 保存 API 密钥到文件
---@param api_key string
---@return boolean
local function save_api_key(api_key)
    if not api_key or api_key == "" then
        log:error("Anthropic OAuth: 无法保存空的 API 密钥")
        return false
    end

    local token_file = get_token_file_path()
    if not token_file then
        return false
    end

    local data = {
        api_key = api_key,
        created_at = os.time(),
        version = 1, -- 版本号，用于未来可能的数据迁移
    }

    local success, json_data = pcall(vim.json.encode, data)
    if not success then
        log:error("Anthropic OAuth: 无法编码 API 密钥数据")
        return false
    end

    ---@diagnostic disable-next-line: redefined-local
    local success, err = pcall(function()
        -- Windows 平台写入文件时使用二进制模式
        if vim.fn.has("win32") == 1 then
            vim.fn.writefile(vim.split(json_data, "\n", { plain = true }), token_file, "b")
        else
            vim.fn.writefile({ json_data }, token_file)
        end
    end)

    if success then
        _api_key = api_key
        _api_key_loaded = true
        log:info("Anthropic OAuth: API 密钥保存成功")
        return true
    else
        log:error("Anthropic OAuth: 保存 API 密钥失败: %s", err or "未知错误")
        return false
    end
end

-- 使用 OAuth 访问令牌创建 API 密钥
---@param access_token string
---@return string|nil
local function create_api_key(access_token)
    if not access_token or access_token == "" then
        log:error("Anthropic OAuth: 需要访问令牌")
        return nil
    end

    log:debug("Anthropic OAuth: 正在创建 API 密钥")

    local success, body_json = pcall(vim.json.encode, {})
    if not success then
        log:error("Anthropic OAuth: 无法编码请求体")
        return nil
    end

    local response = curl.post(OAUTH_CONFIG.API_KEY_URL, {
        headers = {
            ["Content-Type"] = "application/json",
            ["authorization"] = "Bearer " .. access_token,
        },
        body = body_json,
        insecure = config.adapters.http.opts.allow_insecure,
        proxy = config.adapters.http.opts.proxy,
        timeout = 30000, -- 30 second timeout
        on_error = function(err)
            log:error("Anthropic OAuth: 创建 API 密钥请求错误: %s", vim.inspect(err))
        end,
    })

    if not response then
        log:error("Anthropic OAuth: API 密钥创建请求无响应")
        return nil
    end

    if response.status >= 400 then
        log:error(
            "Anthropic OAuth: 创建 API 密钥失败，状态码 %d: %s",
            response.status,
            response.body or "no body"
        )
        return nil
    end

    local decode_success, api_key_data = pcall(vim.json.decode, response.body)

    if not decode_success or not api_key_data or not api_key_data.raw_key then
        log:error(
            "Anthropic OAuth: API 密钥响应格式无效: %s",
            decode_success and "缺少 raw_key" or api_key_data
        )
        return nil
    end

    log:debug("Anthropic OAuth: API 密钥创建成功")
    return api_key_data.raw_key
end

-- 用授权码交换访问令牌并创建 API 密钥
---@param code string
---@param verifier string
---@param state string|nil
---@return string|nil
local function exchange_code_for_api_key(code, verifier, state)
    if not code or code == "" or not verifier or verifier == "" then
        log:error("Anthropic OAuth: 需要授权码和验证器")
        return nil
    end

    log:debug("Anthropic OAuth: 正在用授权码交换访问令牌")
    log:debug("授权码: %s", code)
    log:debug("Verifier length: %d", #verifier)

    local request_data = {
        code = code,
        grant_type = "authorization_code",
        client_id = OAUTH_CONFIG.CLIENT_ID,
        redirect_uri = OAUTH_CONFIG.REDIRECT_URI,
        code_verifier = verifier,
        -- 令牌交换请求通常不需要 scope 和 state
    }

    local encode_success, body_json = pcall(vim.json.encode, request_data)
    if not encode_success then
        log:error("Anthropic OAuth: 无法编码令牌交换请求")
        return nil
    end

    log:debug("Anthropic OAuth: 令牌交换请求已发起")

    local response = curl.post(OAUTH_CONFIG.TOKEN_URL, {
        headers = {
            ["Content-Type"] = "application/json",
        },
        body = body_json,
        insecure = config.adapters.http.opts.allow_insecure,
        proxy = config.adapters.http.opts.proxy,
        timeout = 30000, -- 30 second timeout
        on_error = function(err)
            log:error("Anthropic OAuth: 令牌交换请求错误: %s", vim.inspect(err))
        end,
    })

    if not response then
        log:error("Anthropic OAuth: 令牌交换请求无响应")
        return nil
    end

    if response.status >= 400 then
        log:error("Anthropic OAuth: 令牌交换失败，状态码 %d: %s", response.status, response.body or "no body")
        return nil
    end

    local decode_success, token_data = pcall(vim.json.decode, response.body)

    if not decode_success or not token_data or not token_data.access_token then
        log:error(
            "Anthropic OAuth: 令牌响应格式无效: %s",
            decode_success and "缺少 access_token" or token_data
        )
        return nil
    end

    log:debug("Anthropic OAuth: 成功获取访问令牌")

    -- 使用访问令牌创建 API 密钥
    local api_key = create_api_key(token_data.access_token)
    if api_key and save_api_key(api_key) then
        return api_key
    end

    return nil
end

-- 生成带 PKCE 的 OAuth 授权 URL
---@return { url: string, verifier: string, state: string }|nil
local function generate_auth_url()
    local pkce = generate_pkce()

    -- 如果 PKCE 生成失败，无法继续
    if not pkce then
        return nil
    end

    -- 生成独立的 state 参数用于 CSRF 保护
    -- state 应该是一个随机值，用于验证授权回调的完整性
    local state = generate_random_string(32)

    -- 构建正确编码和顺序的查询字符串
    local query_params = {
        "code=true",
        "client_id=" .. url_encode(OAUTH_CONFIG.CLIENT_ID),
        "response_type=code",
        "redirect_uri=" .. url_encode(OAUTH_CONFIG.REDIRECT_URI),
        "scope=" .. url_encode(OAUTH_CONFIG.SCOPES),
        "code_challenge=" .. url_encode(pkce.challenge),
        "code_challenge_method=S256",
        "state=" .. url_encode(state),
    }

    local auth_url = OAUTH_CONFIG.AUTH_URL .. "?" .. table.concat(query_params, "&")
    log:debug("Anthropic OAuth: 已生成授权 URL")
    log:debug("State: %s", state)
    log:debug("Verifier length: %d", #pkce.verifier)

    return {
        url = auth_url,
        verifier = pkce.verifier,
        state = state,
    }
end

-- 获取 API 密钥，从缓存或文件中
---@return string|nil
local function get_api_key()
    -- 尝试从缓存或文件加载
    local api_key = load_api_key()
    if api_key then
        return api_key
    end

    -- 需要新的 OAuth 流程
    log:error("Anthropic OAuth: 未找到 API 密钥。请运行 :AnthropicOAuthSetup 进行认证")
    return nil
end

-- 设置 OAuth 认证（交互式）
---@return boolean
local function setup_oauth()
    local auth_data = generate_auth_url()

    -- 如果无法生成授权 URL（例如 OpenSSL/PowerShell 不可用），无法继续
    if not auth_data then
        local is_windows = vim.fn.has("win32") == 1
        local error_msg
        if is_windows then
            error_msg = "无法启动 OAuth 认证流程。\n"
                .. "Windows 系统需要 OpenSSL 或 PowerShell 来生成安全令牌。\n"
                .. "请确保 PowerShell 可用或安装 OpenSSL。"
        else
            error_msg = "无法启动 OAuth 认证流程。请确保 OpenSSL 已安装。"
        end
        vim.notify(error_msg, vim.log.levels.ERROR)
        return false
    end

    vim.notify("正在浏览器中打开 Anthropic OAuth 认证...", vim.log.levels.INFO)

    -- 在默认浏览器中打开 URL（跨平台处理）
    local open_cmd
    if vim.fn.has("mac") == 1 then
        open_cmd = "open"
    elseif vim.fn.has("unix") == 1 then
        -- Linux 系统，优先尝试 xdg-open
        open_cmd = "xdg-open"
        -- 如果 xdg-open 不存在，尝试其他常见命令
        if vim.fn.executable("xdg-open") == 0 then
            if vim.fn.executable("gnome-open") == 1 then
                open_cmd = "gnome-open"
            elseif vim.fn.executable("kde-open") == 1 then
                open_cmd = "kde-open"
            end
        end
    elseif vim.fn.has("win32") == 1 then
        -- Windows 需要特殊处理
        open_cmd = "start"
    end

    if open_cmd then
        local cmd
        if vim.fn.has("win32") == 1 then
            -- Windows: 使用 cmd /c start，并正确处理 URL
            -- 使用空标题和转义的 URL
            cmd = string.format('cmd /c start "" "%s"', auth_data.url:gsub("&", "^&"))
        else
            -- Unix/Mac: 使用单引号
            cmd = open_cmd .. " '" .. auth_data.url .. "'"
        end

        local success = pcall(function()
            if vim.fn.has("win32") == 1 then
                -- Windows 平台使用 system 执行，但隐藏输出
                -- jobstart 在某些 Windows 环境下可能无法正确打开浏览器
                vim.fn.system(cmd)
            else
                vim.fn.system(cmd)
            end
        end)

        if not success then
            vim.notify(
                "无法自动打开浏览器。请手动打开此 URL：\n" .. auth_data.url,
                vim.log.levels.WARN
            )
        end
    else
        vim.notify("请在浏览器中打开此 URL：\n" .. auth_data.url, vim.log.levels.INFO)
    end

    -- 提示用户输入授权码
    vim.ui.input({
        prompt = "请输入回调 URL 中的授权码（'code=' 后面、'&' 之前的部分）：",
    }, function(code)
        if not code or code == "" then
            vim.notify("OAuth 设置已取消", vim.log.levels.WARN)
            return
        end

        -- 显示进度
        vim.notify("正在用授权码交换 API 密钥...", vim.log.levels.INFO)

        -- 传递 verifier 和 state（虽然令牌交换不需要 state，但保留以备将来使用）
        local api_key = exchange_code_for_api_key(code, auth_data.verifier, auth_data.state)
        if api_key then
            vim.notify("Anthropic OAuth 认证成功！API 密钥已创建并保存。", vim.log.levels.INFO)
        else
            vim.notify("Anthropic OAuth 认证失败。请检查日志并重试。", vim.log.levels.ERROR)
        end
    end)

    return true
end

-- 创建用于 OAuth 管理的用户命令
vim.api.nvim_create_user_command("AnthropicOAuthSetup", function()
    setup_oauth()
end, {
    desc = "设置 Anthropic OAuth 认证",
})

vim.api.nvim_create_user_command("AnthropicOAuthStatus", function()
    local api_key = load_api_key()
    if not api_key then
        vim.notify("未找到 Anthropic API 密钥。运行 :AnthropicOAuthSetup 进行认证。", vim.log.levels.WARN)
        return
    end

    vim.notify("Anthropic API 密钥已配置并可以使用。", vim.log.levels.INFO)
end, {
    desc = "检查 Anthropic OAuth API 密钥状态",
})

vim.api.nvim_create_user_command("AnthropicOAuthClear", function()
    local token_file = get_token_file_path()
    if token_file and vim.fn.filereadable(token_file) == 1 then
        local success = pcall(vim.fn.delete, token_file)
        if success then
            _api_key = nil
            _api_key_loaded = false
            vim.notify("Anthropic API 密钥已清除。", vim.log.levels.INFO)
        else
            vim.notify("清除 API 密钥文件失败。", vim.log.levels.ERROR)
        end
    else
        vim.notify("没有可清除的 Anthropic API 密钥。", vim.log.levels.WARN)
    end
end, {
    desc = "清除存储的 Anthropic OAuth API 密钥",
})

-- 通过扩展基础 anthropic 适配器创建适配器
local adapter = vim.tbl_deep_extend("force", vim.deepcopy(anthropic), {
    name = "anthropic_oauth",
    formatted_name = "Anthropic (OAuth)",

    env = {
        -- 从 OAuth 流程获取 API 密钥
        ---@return string|nil
        api_key = function()
            return get_api_key()
        end,
    },

    headers = {
        ["content-type"] = "application/json",
        ["x-api-key"] = "${api_key}",
        ["anthropic-version"] = "2023-06-01",
        -- 基础 beta features，在 setup 中动态添加更多
        ["anthropic-beta"] = "claude-code-20250219,oauth-2025-04-20,prompt-caching-2024-07-31,fine-grained-tool-streaming-2025-05-14,token-efficient-tools-2025-02-19,output-128k-2025-02-19,context-1m-2025-08-07",
    },

    -- 使用最新模型覆盖模型架构
    schema = vim.tbl_deep_extend("force", anthropic.schema or {}, {
        -- 覆盖 max_tokens 以支持更长的输出，同时确保大于 thinking_budget
        max_tokens = vim.tbl_deep_extend("force", anthropic.schema.max_tokens or {}, {
            default = function(self)
                local model = self.parameters and self.parameters.model or self.schema.model.default
                local model_opts = self.schema.model.choices[model]

                -- 如果模型支持推理（extended thinking），确保 max_tokens > thinking_budget
                if model_opts and model_opts.opts and model_opts.opts.can_reason then
                    local thinking_budget = self.schema.thinking_budget and self.schema.thinking_budget.default or 16000
                    -- 确保 max_tokens 至少比 thinking_budget 多 1000
                    local min_tokens = thinking_budget + 1000

                    if model_opts.opts.max_output then
                        -- 使用模型的最大输出能力，但需要考虑 thinking_budget
                        -- 如果 min_tokens 超过了模型的最大输出，使用模型的最大输出
                        return math.min(min_tokens, model_opts.opts.max_output)
                    end
                    return min_tokens
                elseif model_opts and model_opts.opts and model_opts.opts.max_output then
                    -- 使用模型的最大输出能力
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

-- 覆盖默认已经有的模型，使用官网的最新模型
adapter.schema.model = {
    order = 1,
    mapping = "parameters",
    type = "enum",
    desc = "The model that will complete your prompt. See https://docs.anthropic.com/claude/docs/models-overview for additional details and options.",
    default = "claude-opus-4-1",
    choices = {
        -- Claude Opus 4.1 - 最强大的模型
        ["claude-opus-4-1"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                max_output = 32000,
                context_window = 200000,
                description = "Our most capable model - Highest level of intelligence and capability",
            },
        },
        -- Claude Opus 4 - 前旗舰模型
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
                context_window = 1000000,
                description = "High-performance model - Balanced performance and capability",
            },
        },
        -- Claude Sonnet 4 - 高性能模型
        ["claude-sonnet-4-0"] = {
            opts = {
                can_reason = true,
                has_vision = true,
                max_output = 64000,
                context_window = 1000000,
                description = "High-performance model - High intelligence and balanced performance",
            },
        },
        -- Claude Sonnet 3.7 - 带早期扩展思考的高性能模型
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
        -- Claude Haiku 3.5 - 最快的模型
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
    -- 格式化参数，处理 Opus 4.1 的限制和 thinking 支持
    ---@param self CodeCompanion.Adapter
    ---@param params table
    ---@param messages table
    ---@return table
    form_parameters = function(self, params, messages)
        -- 首先调用原始的 form_parameters
        params = anthropic.handlers.form_parameters(self, params, messages)

        -- 获取当前模型配置
        local model = params.model or self.schema.model.default
        local model_opts = self.schema.model.choices[model]

        -- 关键修复：根据模型限制调整 max_tokens
        if model_opts and model_opts.opts and model_opts.opts.max_output then
            -- 如果当前的 max_tokens 超过了模型的最大值，调整它
            if params.max_tokens and params.max_tokens > model_opts.opts.max_output then
                log:debug(
                    "模型 %s 的 max_tokens %d 超过最大值 %d，调整为最大值",
                    model,
                    params.max_tokens,
                    model_opts.opts.max_output
                )
                params.max_tokens = model_opts.opts.max_output
            end
        end

        -- 关键修复：如果模型不支持 thinking，移除 thinking 相关参数
        if model_opts and model_opts.opts and not model_opts.opts.can_reason then
            -- 移除 thinking 参数
            if params.thinking then
                log:debug("模型 %s 不支持 thinking，移除 thinking 参数", model)
                params.thinking = nil
            end

            -- 清空 temp 中的 extended_thinking 和 thinking_budget
            self.temp.extended_thinking = nil
            self.temp.thinking_budget = nil
        end

        -- Opus 4.1 特殊处理
        if model == "claude-opus-4-1" then
            -- Opus 4.1 不允许同时指定 temperature 和 top_p
            if params.temperature and params.top_p then
                log:debug("Opus 4.1 检测到同时设置了 temperature 和 top_p，移除 top_p")
                params.top_p = nil
            end
        end

        return params
    end,

    -- 在开始请求前检查有效的 API 密钥
    ---@param self CodeCompanion.Adapter
    ---@return boolean
    setup = function(self)
        -- 获取并验证 API 密钥
        local api_key = get_api_key()
        if not api_key then
            vim.notify(
                "未找到 Anthropic API 密钥。运行 :AnthropicOAuthSetup 进行认证。",
                vim.log.levels.ERROR
            )
            return false
        end

        -- 确保启用工具支持
        if self.opts then
            self.opts.tools = true
        end

        -- 根据选择的模型动态调整设置
        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        if model_opts and model_opts.opts then
            -- 应用模型特定的选项
            self.opts = vim.tbl_deep_extend("force", self.opts or {}, {
                has_vision = model_opts.opts.has_vision,
                can_reason = model_opts.opts.can_reason,
                has_token_efficient_tools = model_opts.opts.has_token_efficient_tools,
            })

            -- 动态设置 thinking 相关的 beta headers
            -- 只有支持 thinking 的模型才添加 interleaved-thinking beta feature
            if model_opts.opts.can_reason then
                -- 添加 thinking 支持
                if not string.find(self.headers["anthropic-beta"], "interleaved%-thinking") then
                    self.headers["anthropic-beta"] = self.headers["anthropic-beta"]
                        .. ",interleaved-thinking-2025-05-14"
                    log:debug("为模型 %s 启用 thinking 支持", model)
                end
            else
                -- 移除 thinking 支持（如果存在）
                if string.find(self.headers["anthropic-beta"], "interleaved%-thinking") then
                    self.headers["anthropic-beta"] =
                        self.headers["anthropic-beta"]:gsub(",?interleaved%-thinking%-[^,]*", "")
                    log:debug("为模型 %s 禁用 thinking 支持", model)
                end

                -- 清空 extended_thinking 相关设置
                self.temp.extended_thinking = nil
                self.temp.thinking_budget = nil
            end

            -- 动态设置最大输出令牌数
            if model_opts.opts.max_output and self.schema.max_tokens then
                if type(self.schema.max_tokens.default) == "function" then
                    -- 已经是函数，不需要覆盖
                else
                    self.schema.max_tokens.default = model_opts.opts.max_output
                end
            end

            -- 记录当前使用的模型信息
            log:debug("使用模型: %s - %s", model, model_opts.opts.description or "")
            log:debug("Beta features: %s", self.headers["anthropic-beta"])
        end

        -- 调用原始设置函数处理流式传输和模型选项
        return anthropic.handlers.setup(self)
    end,

    -- 在开头格式化包含 Claude Code 系统消息的消息（OAuth 必需）
    ---@param self CodeCompanion.Adapter
    ---@param messages table
    ---@return table
    form_messages = function(self, messages)
        -- 首先，调用原始 form_messages 获取标准格式
        local formatted = anthropic.handlers.form_messages(self, messages)

        -- 提取现有系统消息或初始化空数组
        local system = formatted.system or {}

        -- 在开头添加 Claude Code 系统消息（OAuth 正常工作所必需）
        table.insert(system, 1, {
            type = "text",
            text = "You are Claude Code, Anthropic's official CLI for Claude.",
        })

        -- 返回带有修改后系统消息的格式化消息
        return {
            system = system,
            messages = formatted.messages,
        }
    end,
})

-- 覆盖 extended_thinking 的默认值逻辑
adapter.schema.extended_thinking = vim.tbl_deep_extend("force", adapter.schema.extended_thinking or {}, {
    default = function(self)
        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        -- 只有明确支持 can_reason 的模型才默认启用
        if model_opts and model_opts.opts and model_opts.opts.can_reason == true then
            return true
        end
        return false
    end,
    condition = function(self)
        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        -- 只有支持 can_reason 的模型才显示这个选项
        if model_opts and model_opts.opts then
            return model_opts.opts.can_reason == true
        end
        return false
    end,
})

-- 覆盖 thinking_budget 的条件逻辑
adapter.schema.thinking_budget = vim.tbl_deep_extend("force", adapter.schema.thinking_budget or {}, {
    condition = function(self)
        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        -- 只有支持 can_reason 的模型才显示这个选项
        if model_opts and model_opts.opts then
            return model_opts.opts.can_reason == true
        end
        return false
    end,
})

adapter.get_api_key = get_api_key

return adapter
