if not vim.g.__load_goplements then
    return
end

local api = vim.api
local uv = vim.loop

-- 配置管理
local user_config = vim.g.goplements or {}
local display_package = true
if user_config.display_package ~= nil then
    display_package = user_config.display_package
end

local config = {
    enable = true,
    namespace_str = "goplements",
    debounce_delay = 500,
    prefix = {
        interface = "implemented by: ",
        struct = "implements: ",
    },
    display_package = display_package,
}

local namespace = api.nvim_create_namespace(config.namespace_str)
api.nvim_set_hl(0, "Goplements", { default = true, link = "DiagnosticHint" })

-- 查询字符串
local query_str = [[
    (type_spec
        name: (type_identifier) @interface
        type: (interface_type))
    (type_spec
        name: (type_identifier) @struct
        type: (struct_type))
]]

-- 工具函数
local function debounce(func, delay)
    local timer = nil
    return function(...)
        local args = { ... }

        if timer and not timer:is_closing() then
            timer:stop()
            timer:close()
        end

        timer = uv.new_timer()
        if not timer then
            vim.schedule(function()
                func(unpack(args))
            end)
            return
        end

        timer:start(delay, 0, function()
            if timer and not timer:is_closing() then
                timer:stop()
                timer:close()
            end
            timer = nil
            vim.schedule(function()
                func(unpack(args))
            end)
        end)
    end
end

local function is_valid_buffer(bufnr)
    return bufnr and api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "go"
end

local function safe_pcall(func, ...)
    local ok, result = pcall(func, ...)
    return ok and result or nil
end

-- TreeSitter 相关
local parsed_query
local query_parse_failed = false

local function find_types(bufnr)
    local parser = safe_pcall(vim.treesitter.get_parser, bufnr, "go")
    if not parser then
        return {}
    end

    if not parsed_query and not query_parse_failed then
        parsed_query = safe_pcall(vim.treesitter.query.parse, "go", query_str)
        if not parsed_query then
            query_parse_failed = true
            vim.notify("Failed to parse treesitter query", vim.log.levels.WARN)
            return {}
        end
    end

    if query_parse_failed then
        return {}
    end

    local parse_results = parser:parse()
    if not parse_results or #parse_results == 0 then
        return {}
    end

    local root = parse_results[1]:root()
    local nodes = {}

    for id, node in parsed_query:iter_captures(root, bufnr) do
        local type = parsed_query.captures[id]
        local line, character = node:range()
        table.insert(nodes, { line = line, character = character, type = type })
    end
    return nodes
end

-- 渲染代数:每轮标注 +1,在途的旧回调发现代数不匹配就直接放弃
local generation = 0

-- 文件处理:缓存随每轮标注整体重置,一轮内同一文件只读一次,
-- 跨轮自然失效,不会读到过期内容也不会无限增长
local file_cache = {} -- [fname] = lines

local function get_package_name(fdata)
    for _, line in ipairs(fdata) do
        local match = string.match(line, "^package%s+([%a_][%w_]*)%s*$")
        if match then
            return match
        end
    end
    return ""
end

local function read_file_data(uri)
    local fname = vim.uri_to_fname(uri)
    local cached = file_cache[fname]
    if cached then
        return cached
    end

    local lines
    -- 只复用已经加载的 buffer;不要用 uri_to_bufnr,
    -- 它会为每个实现所在的文件凭空创建 buffer
    local bufnr = vim.fn.bufnr(fname)
    if bufnr ~= -1 and api.nvim_buf_is_loaded(bufnr) then
        lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    else
        local ok, content = pcall(vim.fn.readfile, fname)
        lines = ok and content or nil
    end

    if lines then
        file_cache[fname] = lines
    end
    return lines
end

-- 统一的实现回调处理
local function process_implementation(impl)
    local impl_line = impl.range.start.line
    local impl_start = impl.range.start.character
    local impl_end = impl.range["end"].character

    local data = read_file_data(impl.uri)
    if not data then
        return nil
    end

    local impl_text = data[impl_line + 1]
    if not impl_text then
        return nil
    end

    if impl_end <= impl_start then
        return nil
    end

    local line_len = #impl_text
    local start_col = math.min(impl_start + 1, line_len)
    local end_col = math.min(impl_end, line_len)

    if start_col > end_col then
        return nil
    end

    local package_name = ""
    if config.display_package then
        package_name = get_package_name(data)
        if package_name ~= "" then
            package_name = package_name .. "."
        end
    end

    return package_name .. impl_text:sub(start_col, end_col)
end

local function collect_implementation_names(result)
    if not result then
        return {}
    end

    local names = {}

    local function process_single(impl)
        local name = process_implementation(impl)
        if name then
            table.insert(names, name)
        end
    end

    if result.uri then
        process_single(result)
    else
        for _, impl in pairs(result) do
            process_single(impl)
        end
    end

    return names
end

local gopls_client

-- gopls 就绪状态跟踪:只有当 workspace 完全加载后才发 implementation 请求,
-- 避免在大型项目初始化阶段抢占 gopls 资源、拖慢首次加载。
local gopls_ready = {} -- [client_id] = true 表示该 gopls 实例的 workspace 已加载完成
local gopls_progress_seen = {} -- [client_id] = true 表示收到过任意进度事件

-- LSP 交互
local function get_gopls_client()
    if gopls_client then
        local client = vim.lsp.get_client_by_id(gopls_client.id)
        if client and client.name == "gopls" then
            return gopls_client
        end
    end

    local clients = vim.lsp.get_clients({ name = "gopls" })
    gopls_client = clients and clients[1] or nil
    return gopls_client
end

local function request_implementation_names(client, bufnr, line, character, callback)
    local params = {
        textDocument = vim.lsp.util.make_text_document_params(bufnr),
        position = { line = line, character = character },
    }

    local ok = client:request(vim.lsp.protocol.Methods.textDocument_implementation, params, function(err, result)
        if err then
            callback({})
            return
        end
        callback(collect_implementation_names(result))
    end, bufnr)

    -- 请求没发出去也要回调,否则这一轮的 pending 计数永远归不了零
    if not ok then
        callback({})
    end
end

-- 渲染相关
local function clean_render(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
end

local function set_virt_text(bufnr, line, prefix, names, old_marks, used_marks)
    if #names < 1 then
        return
    end
    if line >= api.nvim_buf_line_count(bufnr) then
        return
    end

    local ok, mark_id = pcall(api.nvim_buf_set_extmark, bufnr, namespace, line, 0, {
        virt_text = { { prefix .. table.concat(names, ", "), "Goplements" } },
        virt_text_pos = "eol",
        -- 复用同一行的旧 extmark 原位更新,避免先清屏后重画的闪烁
        id = old_marks[line],
    })
    if ok and mark_id then
        used_marks[mark_id] = true
    end
end

-- 主要功能
local function annotate_structs_interfaces(bufnr)
    if not config.enable or not is_valid_buffer(bufnr) then
        return
    end

    local nodes = find_types(bufnr)
    if #nodes == 0 then
        clean_render(bufnr)
        return
    end

    local client = get_gopls_client()
    -- gopls 未就绪(workspace 还在加载)时跳过,等就绪后由进度回调统一重渲染
    if not client or not gopls_ready[client.id] then
        return
    end

    generation = generation + 1
    file_cache = {}
    local gen = generation
    local tick = api.nvim_buf_get_changedtick(bufnr)

    -- 旧 extmark 按当前真实行号建索引:渲染时原位复用,
    -- 全部请求返回后再删掉没被复用的,而不是先清屏再等异步重画
    local old_marks = {} -- [line] = extmark_id
    for _, mark in ipairs(api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, {})) do
        old_marks[mark[2]] = mark[1]
    end
    local used_marks = {}
    local pending = #nodes

    local function on_request_done()
        pending = pending - 1
        if pending > 0 then
            return
        end
        if gen ~= generation or not api.nvim_buf_is_valid(bufnr) then
            return
        end
        for _, id in pairs(old_marks) do
            if not used_marks[id] then
                api.nvim_buf_del_extmark(bufnr, namespace, id)
            end
        end
    end

    for _, node in ipairs(nodes) do
        request_implementation_names(client, bufnr, node.line, node.character + 1, function(names)
            if
                config.enable
                and gen == generation
                and api.nvim_buf_is_valid(bufnr)
                and vim.bo[bufnr].filetype == "go"
                and api.nvim_buf_get_changedtick(bufnr) == tick
            then
                set_virt_text(bufnr, node.line, config.prefix[node.type], names, old_marks, used_marks)
            end
            on_request_done()
        end)
    end
end

-- gopls 就绪后,统一重渲染所有已加载的 Go buffer
-- (初始化阶段被跳过的渲染在这里补上)
local function annotate_all_go_buffers()
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "go" then
            annotate_structs_interfaces(bufnr)
        end
    end
end

-- 命令处理
local function enable()
    if config.enable then
        return
    end
    config.enable = true
    annotate_structs_interfaces(vim.api.nvim_get_current_buf())
end

local function disable()
    if not config.enable then
        return
    end
    config.enable = false
    -- 代数 +1 让在途回调全部作废
    generation = generation + 1
    clean_render()
end

local function toggle()
    if config.enable then
        disable()
    else
        enable()
    end
end

-- 注册命令和自动命令
pcall(api.nvim_del_user_command, "GoplementsEnable")
pcall(api.nvim_del_user_command, "GoplementsDisable")
pcall(api.nvim_del_user_command, "GoplementsToggle")

api.nvim_create_user_command("GoplementsEnable", enable, { desc = "Enable Goplements" })
api.nvim_create_user_command("GoplementsDisable", disable, { desc = "Disable Goplements" })
api.nvim_create_user_command("GoplementsToggle", toggle, { desc = "Toggle Goplements" })

local augroup = api.nvim_create_augroup("Goplements", { clear = true })

-- 插入模式内不触发(原来的 TextChangedI 会在打字停顿时反复发全量
-- implementation 请求),退出插入时用 InsertLeave 补一次即可
api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "LspAttach" }, {
    group = augroup,
    pattern = { "*.go" },
    callback = debounce(function(args)
        annotate_structs_interfaces(args.buf)
    end, config.debounce_delay),
})

-- 监听 gopls 的 workspace 加载进度:收到 "end" 表示初始化完成,
-- 此时才标记就绪并补渲染,确保 implementation 请求不会在加载期发出。
api.nvim_create_autocmd("LspProgress", {
    group = augroup,
    callback = function(args)
        local data = args.data
        if not data or not data.client_id then
            return
        end
        local client = vim.lsp.get_client_by_id(data.client_id)
        if not client or client.name ~= "gopls" then
            return
        end
        local id = client.id
        gopls_progress_seen[id] = true
        local value = data.params and data.params.value
        if value and value.kind == "end" and not gopls_ready[id] then
            gopls_ready[id] = true
            vim.schedule(annotate_all_go_buffers)
        end
    end,
})

-- 兜底:小项目/瞬时加载可能根本不发进度事件。gopls attach 后等待一小段时间,
-- 若期间没收到任何进度,就认为已就绪,避免永远不渲染。
api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    pattern = { "*.go" },
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "gopls" then
            return
        end
        local id = client.id
        if gopls_ready[id] then
            return
        end
        local timer = uv.new_timer()
        if not timer then
            return
        end
        timer:start(3000, 0, function()
            if not timer:is_closing() then
                timer:stop()
                timer:close()
            end
            vim.schedule(function()
                -- 只有在完全没收到进度事件时才兜底就绪;
                -- 若已收到进度(大项目仍在加载),交给 "end" 事件处理。
                if not gopls_ready[id] and not gopls_progress_seen[id] then
                    gopls_ready[id] = true
                    annotate_all_go_buffers()
                end
            end)
        end)
    end,
})

-- gopls 退出时清理就绪状态,避免重启后误用旧标记
api.nvim_create_autocmd("LspDetach", {
    group = augroup,
    callback = function(args)
        local id = args.data and args.data.client_id
        if id then
            gopls_ready[id] = nil
            gopls_progress_seen[id] = nil
        end
    end,
})
