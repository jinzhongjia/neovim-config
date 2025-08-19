local Job = require("plenary.job")
local anthropic = require("codecompanion.adapters.anthropic")
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
    if vim.loop then
        -- 获取高精度时间戳（微秒）
        local hrtime = vim.loop.hrtime()
        if hrtime then
            -- 取低32位作为额外的熵
            seed = seed + (hrtime % 2147483647)
        end
        
        -- 获取进程ID作为额外的熵
        local pid = vim.loop.os_getpid()
        if pid then
            seed = seed + pid
        end
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
    -- 尝试使用 OpenSSL 生成正确的 SHA256 哈希
    -- 注意：Windows 系统可能需要单独安装 OpenSSL
    if vim.fn.executable("openssl") == 1 then
        local job = Job:new({
            command = "openssl",
            args = { "dgst", "-sha256", "-binary" },
            writer = input,
            enable_recording = true,
        })

        local success, _ = pcall(function()
            job:sync(3000) -- 3 second timeout
        end)

        if success and job.code == 0 then
            local hash_binary = table.concat(job:result(), "")
            if hash_binary ~= "" then
                local base64 = vim.base64.encode(hash_binary)
                return base64:gsub("[+/=]", { ["+"] = "-", ["/"] = "_", ["="] = "" })
            end
        else
            log:warn("OpenSSL 命令执行失败，错误代码: %s", job.code)
        end
    else
        log:warn("OpenSSL 不可用，将使用不安全的哈希方法（仅用于开发环境）")
    end

    -- 后备方案：非加密安全但功能可用（仅用于开发/测试）
    log:warn("使用后备哈希方法（非加密安全）")
    local simple_hash = vim.base64.encode(input)
    return simple_hash:gsub("[+/=]", { ["+"] = "-", ["/"] = "_", ["="] = "" })
end

-- 生成 PKCE 代码验证器和挑战码
---@return { verifier: string, challenge: string }
local function generate_pkce()
    local verifier = generate_random_string(128) -- 使用最大长度以提高安全性
    local challenge = sha256_base64url(verifier)
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

    local success, err = pcall(function()
        vim.fn.writefile({ vim.json.encode(data) }, token_file)
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

    local response = curl.post(OAUTH_CONFIG.API_KEY_URL, {
        headers = {
            ["Content-Type"] = "application/json",
            ["authorization"] = "Bearer " .. access_token,
        },
        body = vim.json.encode({}),
        insecure = config.adapters.opts.allow_insecure,
        proxy = config.adapters.opts.proxy,
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
        log:error("Anthropic OAuth: API 密钥响应格式无效")
        return nil
    end

    log:debug("Anthropic OAuth: API 密钥创建成功")
    return api_key_data.raw_key
end

-- 用授权码交换访问令牌并创建 API 密钥
---@param code string
---@param verifier string
---@return string|nil
local function exchange_code_for_api_key(code, verifier)
    if not code or code == "" or not verifier or verifier == "" then
        log:error("Anthropic OAuth: 需要授权码和验证器")
        return nil
    end

    log:debug("Anthropic OAuth: 正在用授权码交换访问令牌")

    -- 从回调 URL 片段解析授权码和状态
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

    log:debug("Anthropic OAuth: 令牌交换请求已发起")

    local response = curl.post(OAUTH_CONFIG.TOKEN_URL, {
        headers = {
            ["Content-Type"] = "application/json",
        },
        body = vim.json.encode(request_data),
        insecure = config.adapters.opts.allow_insecure,
        proxy = config.adapters.opts.proxy,
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
        log:error(
            "Anthropic OAuth: 令牌交换失败，状态码 %d: %s",
            response.status,
            response.body or "no body"
        )
        return nil
    end

    local decode_success, token_data = pcall(vim.json.decode, response.body)
    if not decode_success or not token_data or not token_data.access_token then
        log:error("Anthropic OAuth: 令牌响应格式无效")
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
---@return { url: string, verifier: string }
local function generate_auth_url()
    local pkce = generate_pkce()

    -- 构建正确编码和顺序的查询字符串
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
    log:debug("Anthropic OAuth: 已生成授权 URL")

    return {
        url = auth_url,
        verifier = pkce.verifier,
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
        -- Windows 需要特殊处理，使用 cmd /c start
        open_cmd = "cmd /c start \"\""
    end

    if open_cmd then
        local cmd
        if vim.fn.has("win32") == 1 then
            -- Windows: 使用双引号，并转义特殊字符
            cmd = open_cmd .. " \"" .. auth_data.url:gsub("&", "^&") .. "\""
        else
            -- Unix/Mac: 使用单引号
            cmd = open_cmd .. " '" .. auth_data.url .. "'"
        end
        
        local success = pcall(vim.fn.system, cmd)
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
        prompt = "请输入回调 URL 中的授权码（'code=' 后面的部分）：",
    }, function(code)
        if not code or code == "" then
            vim.notify("OAuth 设置已取消", vim.log.levels.WARN)
            return
        end

        -- 显示进度
        vim.notify("正在用授权码交换 API 密钥...", vim.log.levels.INFO)

        local api_key = exchange_code_for_api_key(code, auth_data.verifier)
        if api_key then
            vim.notify("Anthropic OAuth 认证成功！API 密钥已创建并保存。", vim.log.levels.INFO)
        else
            vim.notify(
                "Anthropic OAuth 认证失败。请检查日志并重试。",
                vim.log.levels.ERROR
            )
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
        ["anthropic-beta"] = "claude-code-20250219,oauth-2025-04-20,interleaved-thinking-2025-05-14,fine-grained-tool-streaming-2025-05-14",
    },

    -- 使用最新模型覆盖模型架构
    schema = vim.tbl_deep_extend("force", anthropic.schema or {}, {
        model = {
            order = 1,
            mapping = "parameters",
            type = "enum",
            desc = "The model that will complete your prompt. See https://docs.anthropic.com/claude/docs/models-overview for additional details and options.",
            default = "claude-opus-4-1-20250805",
            choices = {
                ["claude-opus-4-1-20250805"] = { opts = { can_reason = true, has_vision = true } },
                ["claude-opus-4-20250514"] = { opts = { can_reason = true, has_vision = true } },
                ["claude-sonnet-4-20250514"] = { opts = { can_reason = true, has_vision = true } },
                ["claude-3-7-sonnet-20250219"] = {
                    opts = { can_reason = true, has_vision = true, has_token_efficient_tools = true },
                },
                ["claude-3-5-haiku-20241022"] = { opts = { has_vision = true } },
            },
        },
    }),
})

-- 覆盖处理器以添加 OAuth 特定功能和 Claude Code 系统消息
adapter.handlers = vim.tbl_extend("force", anthropic.handlers, {
    -- 在开始请求前检查有效的 API 密钥
    ---@param self CodeCompanion.Adapter
    ---@return boolean
    setup = function(self)
        -- 获取并验证 API 密钥
        local api_key = get_api_key()
        if not api_key then
            vim.notify("未找到 Anthropic API 密钥。运行 :AnthropicOAuthSetup 进行认证。", vim.log.levels.ERROR)
            return false
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

return adapter
