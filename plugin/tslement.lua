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

local CAPABILITY_BY_METHOD = {
    [vim.lsp.protocol.Methods.textDocument_implementation] = "implementationProvider",
    [vim.lsp.protocol.Methods.textDocument_references] = "referencesProvider",
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

local function build_timer_key(func, args)
    local key = tostring(func)
    local identifier = args and args[1]

    if identifier == nil then
        return key
    end

    local id_type = type(identifier)
    if id_type == "number" or id_type == "string" then
        key = key .. ":" .. tostring(identifier)
    elseif id_type == "table" then
        local bufnr = identifier.bufnr or identifier.buf or identifier[1]
        if bufnr then
            key = key .. ":" .. tostring(bufnr)
        end
    end

    return key
end

local function debounce(func, delay)
    return function(...)
        local args = { ... }
        local key = build_timer_key(func, args)

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

local function safe_get_node_text(node, source)
    if not node then
        return nil
    end

    local ok, text = pcall(vim.treesitter.get_node_text, node, source)
    if ok and text and text ~= "" then
        return vim.trim(text)
    end

    local sr, sc, er, ec = node:range()

    if type(source) == "number" and api.nvim_buf_is_valid(source) then
        local sr, sc, er, ec = node:range()
        local lines = api.nvim_buf_get_text(source, sr, sc, er, ec, {})
        if lines and #lines > 0 then
            return vim.trim(table.concat(lines, "\n"))
        end
    elseif type(source) == "string" then
        local segments = {}
        for line in source:gmatch("[^\n]*") do
            table.insert(segments, line)
        end
        if #segments == 0 then
            return nil
        end

        local start_line = sr + 1
        local end_line = er + 1

        if start_line > #segments then
            return nil
        end

        end_line = math.min(end_line, #segments)

        if start_line == end_line then
            return vim.trim(segments[start_line]:sub(sc + 1, ec))
        end

        local collected = {}
        collected[#collected + 1] = segments[start_line]:sub(sc + 1)
        for line_nr = start_line + 1, end_line - 1 do
            collected[#collected + 1] = segments[line_nr]
        end
        collected[#collected + 1] = segments[end_line]:sub(1, ec)

        return vim.trim(table.concat(collected, "\n"))
    end

    return nil
end

-- 清理缓存
local function clear_cache(bufnr)
    if bufnr then
        cache.parsers[bufnr] = nil
        local suffix = ":" .. tostring(bufnr)
        for key, timer in pairs(cache.timers) do
            if type(key) == "string" and key:sub(-#suffix) == suffix then
                timer:stop()
                cache.timers[key] = nil
            end
        end
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
local function execute_treesitter_query(bufnr, query_type, opts)
    opts = opts or {}
    if not is_valid_buffer(bufnr) then
        return {}
    end

    local parser = opts.parser or get_cached_parser(bufnr)
    if not parser then
        return {}
    end

    local ft = opts.ft or vim.bo[bufnr].filetype
    local query_config = QUERIES[query_type]
    if not query_config then
        return {}
    end

    local query = get_cached_query(ft, query_config.pattern)
    if not query then
        return {}
    end

    local root = opts.root
    if not root then
        local parse_results = parser:parse()
        if not parse_results or #parse_results == 0 then
            return {}
        end
        root = parse_results[1]:root()
    end

    local source = opts.source or bufnr
    local results = {}

    for _, node in query:iter_captures(root, source) do
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
    if not is_valid_buffer(bufnr) then
        return {}
    end

    local parser = get_cached_parser(bufnr)
    if not parser then
        return {}
    end

    local parse_results = parser:parse()
    if not parse_results or #parse_results == 0 then
        return {}
    end

    local root = parse_results[1]:root()
    local ft = vim.bo[bufnr].filetype
    local all_interfaces = {}

    for query_type, _ in pairs(QUERIES) do
        local results = execute_treesitter_query(bufnr, query_type, {
            parser = parser,
            root = root,
            ft = ft,
        })
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
        local name = safe_get_node_text(interface_data.node, bufnr)
        if name then
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
    local uri = location.uri
    local target_bufnr = bufnr
    local parser
    local root
    local source
    local ft
    local fname

    if uri ~= vim.uri_from_bufnr(bufnr) then
        fname = vim.uri_to_fname(uri)
        local existing_bufnr = vim.fn.bufnr(fname)
        if existing_bufnr ~= -1 then
            target_bufnr = existing_bufnr
            if not api.nvim_buf_is_loaded(target_bufnr) then
                vim.fn.bufload(target_bufnr)
            end
        else
            target_bufnr = nil
            local ok, lines = pcall(vim.fn.readfile, fname)
            if not ok or not lines or #lines == 0 then
                return vim.fn.fnamemodify(fname, ":t:r")
            end
            local text = table.concat(lines, "\n")
            ft = vim.filetype.match({ filename = fname, contents = text }) or "typescript"
            local lang = vim.treesitter.language.get_lang(ft) or ft
            local parser_ok, string_parser = pcall(vim.treesitter.get_string_parser, text, lang)
            if not parser_ok then
                return vim.fn.fnamemodify(fname, ":t:r")
            end
            local trees = string_parser:parse()
            if not trees or #trees == 0 then
                return vim.fn.fnamemodify(fname, ":t:r")
            end
            root = trees[1]:root()
            root = trees[1]:root()
            source = text
        end
    end

    if not parser then
        parser = get_cached_parser(target_bufnr or bufnr)
        if not parser then
            return nil
        end
        ft = ft or vim.bo[target_bufnr or bufnr].filetype
        local parse_results = parser:parse()
        if not parse_results or #parse_results == 0 then
            return nil
        end
        root = parse_results[1]:root()
        source = target_bufnr or bufnr
    end

    ft = ft or vim.bo[target_bufnr or bufnr].filetype
    local class_query_str = [[(class_declaration name: (type_identifier) @name)]]
    local query = get_cached_query(ft, class_query_str)
    if not query then
        return nil
    end

    local target_line = location.range.start.line
    local target_character = location.range.start.character

    for _, node in query:iter_captures(root, source) do
        local start_line, start_col, end_line, end_col = node:range()
        if start_line == target_line and start_col <= target_character and target_character <= end_col then
            local name
            if target_bufnr then
                name = safe_get_node_text(node, target_bufnr)
            else
                name = safe_get_node_text(node, source)
            end
            if name then
                return name
            end
        end
    end

    if fname then
        return vim.fn.fnamemodify(fname, ":t:r")
    end

    return nil
end

-- 查找接口实现（优化版）
local function find_interface_implementations(bufnr, clients, interface_data, interface_name, state, index)
    local query_config = QUERIES[interface_data.type]
    if not query_config then
        return
    end

    index = index or 1
    local client = clients and clients[index]
    if not client then
        return
    end

    local method = query_config.lsp_method
    if not method then
        find_interface_implementations(bufnr, clients, interface_data, interface_name, state, index + 1)
        return
    end

    if not client then
        find_interface_implementations(bufnr, clients, interface_data, interface_name, state, index + 1)
        return
    end

    local capability_field = CAPABILITY_BY_METHOD[method]
    local supports_method = true
    if client.supports_method then
        supports_method = client:supports_method(method, { bufnr = bufnr })
    elseif capability_field then
        supports_method = client.server_capabilities and client.server_capabilities[capability_field]
    end

    if not supports_method then
        find_interface_implementations(bufnr, clients, interface_data, interface_name, state, index + 1)
        return
    end

    state = state or {}
    state.impl_set = state.impl_set or {}

    local changedtick = state.changedtick or api.nvim_buf_get_changedtick(bufnr)

    client:request(method, {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = { line = interface_data.line, character = interface_data.character },
     }, function(err, result, ctx, lsp_config)
        if err or not api.nvim_buf_is_valid(bufnr) then
            find_interface_implementations(bufnr, clients, interface_data, interface_name, state, index + 1)
            return
        end

        if api.nvim_buf_get_changedtick(bufnr) ~= changedtick then
            return
        end

        if not result or #result == 0 then
            find_interface_implementations(bufnr, clients, interface_data, interface_name, state, index + 1)
            return
        end

        local added_new = false
        for _, impl in ipairs(result) do
            local impl_name = extract_class_name_from_location(bufnr, impl)
            if impl_name and impl_name ~= interface_name then
                if not state.impl_set[impl_name] then
                    added_new = true
                    state.impl_set[impl_name] = true
                end
            end
        end

        local impl_names = vim.tbl_keys(state.impl_set)
        if #impl_names > 0 then
            table.sort(impl_names)
            local prefix = config.prefix[interface_data.type] or config.prefix.interface
            local impl_text = prefix .. table.concat(impl_names, ", ")
            local ok, mark_id = pcall(api.nvim_buf_set_extmark, bufnr, namespace, interface_data.line, 0, {
                virt_text = { { impl_text, "Tsplements" } },
                virt_text_pos = "eol",
                id = state.extmark_id,
            })
            if ok and type(mark_id) == "number" then
                state.extmark_id = mark_id
            end
        end

        if not added_new then
            find_interface_implementations(bufnr, clients, interface_data, interface_name, state, index + 1)
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
    local clients_by_method = {}
    for _, client in ipairs(clients) do
        if client.supports_method then
            for method, _ in pairs(CAPABILITY_BY_METHOD) do
                if client:supports_method(method, { bufnr = bufnr }) then
                    clients_by_method[method] = clients_by_method[method] or {}
                    table.insert(clients_by_method[method], client)
                end
            end
        else
            for method, capability_field in pairs(CAPABILITY_BY_METHOD) do
                if client.server_capabilities and client.server_capabilities[capability_field] then
                    clients_by_method[method] = clients_by_method[method] or {}
                    table.insert(clients_by_method[method], client)
                end
            end
        end
    end

    local interfaces = find_all_interfaces(bufnr)

    local current_tick = api.nvim_buf_get_changedtick(bufnr)

    for _, interface_data in ipairs(interfaces) do
        local interface_name = get_interface_name(bufnr, interface_data)
        if interface_name then
            local query_config = QUERIES[interface_data.type]
            local method = query_config and query_config.lsp_method
            if method then
                local method_clients = clients_by_method[method]
                if method_clients then
                    local state = { changedtick = current_tick }
                    find_interface_implementations(bufnr, method_clients, interface_data, interface_name, state)
                end
            end
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
