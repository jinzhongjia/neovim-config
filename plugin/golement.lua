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

        -- Stop and close existing timer
        if timer and not timer:is_closing() then
            timer:stop()
            timer:close()
        end

        -- Create new timer
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

    for id, node in parsed_query:iter_captures(root, 0) do
        local type = parsed_query.captures[id]
        local line, character = node:range()
        table.insert(nodes, { line = line, character = character, type = type })
    end
    return nodes
end

-- 文件处理
local file_cache = {}

local function get_package_name(fdata)
    for _, line in ipairs(fdata) do
        local match = string.match(line, "^package%s+([%a_][%w_]*)%s*$")
        if match then
            return match
        end
    end
    return ""
end

local function read_file_data(uri, bufnr)
    if bufnr and vim.api.nvim_buf_is_loaded(bufnr) then
        return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    end

    local file = vim.uri_to_fname(uri)
    if not file_cache[file] then
        local ok, content = pcall(vim.fn.readfile, file)
        if ok and content then
            file_cache[file] = content
        else
            return nil
        end
    end
    return file_cache[file]
end

-- Clear file cache periodically to prevent memory leak
local function clear_file_cache()
    file_cache = {}
end

-- 统一的实现回调处理
local function process_implementation(impl)
    local uri = impl.uri
    local impl_line = impl.range.start.line
    local impl_start = impl.range.start.character
    local impl_end = impl.range["end"].character

    local bufnr = vim.uri_to_bufnr(uri)
    local data = read_file_data(uri, bufnr)

    if not data or not data[impl_line + 1] then
        return nil
    end

    local package_name = ""
    if config.display_package then
        package_name = get_package_name(data)
        if package_name ~= "" then
            package_name = package_name .. "."
        end
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

    return package_name .. impl_text:sub(start_col, end_col)
end

local function create_implementation_callback()
    return function(result)
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
end

local implementation_callback = create_implementation_callback()

local gopls_client
local active_requests = {}

-- LSP 交互
local function get_gopls_client()
    -- Check if cached client is still valid
    if gopls_client then
        local client = vim.lsp.get_client_by_id(gopls_client.id)
        if client and client.name == "gopls" then
            return gopls_client
        end
    end

    -- Get fresh client
    local clients = vim.lsp.get_clients({ name = "gopls" })
    gopls_client = clients and clients[1] or nil
    return gopls_client
end

local function get_implementation_names(bufnr, line, character, callback)
    local client = get_gopls_client()
    if not client then
        return
    end

    -- Create unique request key
    local request_key = string.format("%d:%d:%d", bufnr, line, character)

    -- Cancel duplicate requests
    if active_requests[request_key] then
        return
    end

    active_requests[request_key] = true

    -- Build request params manually to ensure correct buffer
    local params = {
        textDocument = vim.lsp.util.make_text_document_params(bufnr),
        position = { line = line, character = character },
    }

    client:request(vim.lsp.protocol.Methods.textDocument_implementation, params, function(err, result, _, _)
        active_requests[request_key] = nil

        if err or not api.nvim_buf_is_valid(bufnr) then
            return
        end

        -- Verify buffer hasn't changed
        if vim.bo[bufnr].filetype ~= "go" then
            return
        end

        local names = implementation_callback(result)
        callback(names)
    end, bufnr)
end

-- 渲染相关
local extmark_cache = {}

local function clean_render(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    extmark_cache[bufnr] = {}
end

local function set_virt_text(bufnr, line, _prefix, names)
    if #names < 1 or not is_valid_buffer(bufnr) then
        return
    end

    local line_count = api.nvim_buf_line_count(bufnr)
    if line >= line_count then
        return
    end

    local impl_text = _prefix .. table.concat(names, ", ")
    local opts = {
        virt_text = { { impl_text, "Goplements" } },
        virt_text_pos = "eol",
    }

    -- Use cached extmark ID if available
    if not extmark_cache[bufnr] then
        extmark_cache[bufnr] = {}
    end

    if extmark_cache[bufnr][line] then
        opts.id = extmark_cache[bufnr][line]
    end

    local ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, line, 0, opts)
    if ok and mark_id then
        extmark_cache[bufnr][line] = mark_id
    end
end

-- 主要功能
local function annotate_structs_interfaces(bufnr)
    if not config.enable or not is_valid_buffer(bufnr) then
        return
    end

    clean_render(bufnr)
    local nodes = find_types(bufnr)

    if #nodes == 0 then
        return
    end

    local client = get_gopls_client()
    if not client then
        return
    end

    for _, node in ipairs(nodes) do
        get_implementation_names(bufnr, node.line, node.character + 1, function(names)
            if api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "go" then
                local _prefix = config.prefix[node.type]
                set_virt_text(bufnr, node.line, _prefix, names)
            end
        end)
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

api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "LspAttach" }, {
    group = augroup,
    pattern = { "*.go" },
    callback = debounce(function(args)
        annotate_structs_interfaces(args.buf)
    end, config.debounce_delay),
})

-- Clear file cache on BufDelete to prevent memory leaks
api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    pattern = { "*.go" },
    callback = function(args)
        -- Clear extmark cache for this buffer
        if extmark_cache[args.buf] then
            extmark_cache[args.buf] = nil
        end
        -- Periodic file cache cleanup
        if math.random() < 0.1 then -- 10% chance
            clear_file_cache()
        end
    end,
})
