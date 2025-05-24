if vim.g.vscode then
    return
end

local api = vim.api

-- 配置管理
local config = {
    enable = true,
    namespace_str = "tsplements",
    debounce_delay = 500,
    prefix = {
        interface = "implemented by: ",
        type_alias = "used by: ",
        abstract_class = "extended by: ",
    },
    display_module = vim.g.tsplements and vim.g.tsplements.display_module or true,
}

local namespace = api.nvim_create_namespace(config.namespace_str)
api.nvim_set_hl(0, "Tsplements", { default = true, link = "DiagnosticHint" })

-- 统一的查询配置
local QUERIES = {
    interface = {
        pattern = [[(interface_declaration name: (type_identifier) @name)]],
        lsp_method = vim.lsp.protocol.Methods.textDocument_implementation,
        fallback_patterns = {
            ".*interface%s+(%w+)",
            "export%s+.*interface%s+(%w+)",
            "export%s+default%s+interface%s+(%w+)",
        },
    },
    type_alias = {
        pattern = [[(type_alias_declaration name: (type_identifier) @name value: (object_type))]],
        lsp_method = vim.lsp.protocol.Methods.textDocument_references,
        fallback_patterns = {
            "type%s+(%w+)%s*=",
            "export%s+type%s+(%w+)%s*=",
        },
    },
    abstract_class = {
        pattern = [[(abstract_class_declaration name: (type_identifier) @name)]],
        lsp_method = vim.lsp.protocol.Methods.textDocument_implementation,
        fallback_patterns = {
            "abstract%s+class%s+(%w+)",
            "export%s+abstract%s+class%s+(%w+)",
        },
    },
}

-- 缓存管理
local cache = {
    parsers = {},
    queries = {},
    timers = {},
}

-- 工具函数
local function cleanup_timer(key)
    if cache.timers[key] then
        cache.timers[key]:stop()
        cache.timers[key] = nil
    end
end

local function debounce(func, delay)
    return function(...)
        local args = { ... }
        local key = tostring(func)

        cleanup_timer(key)
        cache.timers[key] = vim.defer_fn(function()
            func(unpack(args))
            cache.timers[key] = nil
        end, delay)
    end
end

local function is_valid_buffer(bufnr)
    if not bufnr or not api.nvim_buf_is_valid(bufnr) then
        return false
    end
    local ft = vim.bo[bufnr].filetype
    return ft == "typescript" or ft == "typescriptreact"
end

local function get_cached_parser(bufnr)
    local key = bufnr
    if not cache.parsers[key] then
        local ft = vim.bo[bufnr].filetype
        local ok, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
        if ok and parser then
            cache.parsers[key] = parser
        end
    end
    return cache.parsers[key]
end

local function get_cached_query(ft, query_str)
    local key = ft .. ":" .. query_str
    if not cache.queries[key] then
        local ok, query = pcall(vim.treesitter.query.parse, ft, query_str)
        if ok and query then
            cache.queries[key] = query
        end
    end
    return cache.queries[key]
end

-- 清理缓存
local function clear_cache(bufnr)
    if bufnr then
        cache.parsers[bufnr] = nil
    else
        cache.parsers = {}
        cache.queries = {}
        for key, timer in pairs(cache.timers) do
            timer:stop()
        end
        cache.timers = {}
    end
end

-- 统一的查询执行函数
local function execute_treesitter_query(bufnr, query_type)
    if not is_valid_buffer(bufnr) then
        return {}
    end

    local parser = get_cached_parser(bufnr)
    if not parser then
        return {}
    end

    local ft = vim.bo[bufnr].filetype
    local query_config = QUERIES[query_type]
    if not query_config then
        return {}
    end

    local query = get_cached_query(ft, query_config.pattern)
    if not query then
        return {}
    end

    local parse_results = parser:parse()
    if not parse_results or #parse_results == 0 then
        return {}
    end

    local root = parse_results[1]:root()
    local results = {}

    for _, node in query:iter_captures(root, 0) do
        local line, character = node:range()
        table.insert(results, {
            line = line,
            character = character,
            type = query_type,
            node = node,
        })
    end

    return results
end

-- 查找所有接口类型（优化版）
local function find_all_interfaces(bufnr)
    local all_interfaces = {}

    for query_type, _ in pairs(QUERIES) do
        local results = execute_treesitter_query(bufnr, query_type)
        for _, result in ipairs(results) do
            table.insert(all_interfaces, result)
        end
    end

    return all_interfaces
end

-- 获取接口名称（优化版）
local function get_interface_name(bufnr, interface_data)
    -- 优先使用已有的node
    if interface_data.node then
        local ok, name = pcall(vim.treesitter.get_node_text, interface_data.node, bufnr)
        if ok and name then
            return name
        end
    end

    -- 回退到正则表达式
    local lines = api.nvim_buf_get_lines(bufnr, interface_data.line, interface_data.line + 1, false)
    if #lines == 0 then
        return nil
    end

    local line_text = lines[1]
    local query_config = QUERIES[interface_data.type]
    if not query_config then
        return nil
    end

    for _, pattern in ipairs(query_config.fallback_patterns) do
        local match = string.match(line_text, pattern)
        if match then
            return match
        end
    end

    return nil
end

-- 提取类名（简化版）
local function extract_class_name_from_location(bufnr, location)
    local target_bufnr = bufnr
    local uri = location.uri

    if uri ~= vim.uri_from_bufnr(bufnr) then
        local fname = vim.uri_to_fname(uri)
        target_bufnr = vim.fn.bufnr(fname)
        if target_bufnr == -1 then
            return vim.fn.fnamemodify(fname, ":t:r")
        end
    end

    local parser = get_cached_parser(target_bufnr)
    if not parser then
        return nil
    end

    local ft = vim.bo[target_bufnr].filetype
    local class_query_str = [[(class_declaration name: (type_identifier) @name)]]
    local query = get_cached_query(ft, class_query_str)
    if not query then
        return nil
    end

    local parse_results = parser:parse()
    if not parse_results or #parse_results == 0 then
        return nil
    end

    local root = parse_results[1]:root()
    local target_line = location.range.start.line
    local target_character = location.range.start.character

    for _, node in query:iter_captures(root, 0) do
        local start_line, start_col, end_line, end_col = node:range()
        if start_line == target_line and start_col <= target_character and target_character <= end_col then
            local ok, name = pcall(vim.treesitter.get_node_text, node, target_bufnr)
            if ok then
                return name
            end
        end
    end

    return nil
end

-- 查找接口实现（优化版）
local function find_interface_implementations(bufnr, client, interface_data, interface_name)
    local query_config = QUERIES[interface_data.type]
    if not query_config then
        return
    end

    client:request(query_config.lsp_method, {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = { line = interface_data.line, character = interface_data.character },
    }, function(err, result, _, _)
        if err or not api.nvim_buf_is_valid(bufnr) then
            return
        end

        if not result or #result == 0 then
            return
        end

        local impl_names = {}
        for _, impl in ipairs(result) do
            local impl_name = extract_class_name_from_location(bufnr, impl)
            if impl_name and impl_name ~= interface_name then
                table.insert(impl_names, impl_name)
            end
        end

        if #impl_names > 0 then
            local prefix = config.prefix[interface_data.type] or config.prefix.interface
            local impl_text = prefix .. table.concat(impl_names, ", ")
            pcall(api.nvim_buf_set_extmark, bufnr, namespace, interface_data.line, 0, {
                virt_text = { { impl_text, "Tsplements" } },
                virt_text_pos = "eol",
            })
        end
    end)
end

-- 主要功能（优化版）
local function annotate_interfaces(bufnr)
    if not config.enable or not is_valid_buffer(bufnr) then
        return
    end

    api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local capable_client = nil

    for _, client in ipairs(clients) do
        if client.server_capabilities.implementationProvider then
            capable_client = client
            break
        end
    end

    if not capable_client then
        return
    end

    local interfaces = find_all_interfaces(bufnr)

    for _, interface_data in ipairs(interfaces) do
        local interface_name = get_interface_name(bufnr, interface_data)
        if interface_name then
            find_interface_implementations(bufnr, capable_client, interface_data, interface_name)
        end
    end
end

-- 命令和自动命令
api.nvim_create_user_command("TsplementsToggle", function()
    config.enable = not config.enable
    local bufnr = api.nvim_get_current_buf()
    if config.enable then
        annotate_interfaces(bufnr)
    else
        api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    end
end, { desc = "Toggle Tsplements" })

local annotate_debounced = debounce(annotate_interfaces, config.debounce_delay)

api.nvim_create_autocmd({ "TextChanged", "LspAttach" }, {
    pattern = { "*.ts", "*.tsx" },
    callback = function(args)
        annotate_debounced(args.buf)
    end,
})

-- 清理缓存的自动命令
api.nvim_create_autocmd("BufDelete", {
    pattern = { "*.ts", "*.tsx" },
    callback = function(args)
        clear_cache(args.buf)
    end,
})
