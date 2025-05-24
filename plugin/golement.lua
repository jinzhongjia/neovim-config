if vim.g.vscode then
    return
end

local api = vim.api

-- 配置管理
local config = {
    enable = true,
    namespace_str = "goplements",
    debounce_delay = 500,
    prefix = {
        interface = "implemented by: ",
        struct = "implements: ",
    },
    display_package = vim.g.goplements and vim.g.goplements.display_package or true,
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
        if timer then
            timer:stop()
            timer = nil
        end
        timer = vim.defer_fn(function()
            func(unpack(args))
            timer = nil
        end, delay)
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
local function find_types(bufnr)
    local parser = safe_pcall(vim.treesitter.get_parser, bufnr, "go")
    if not parser then
        vim.notify("Go TreeSitter parser not found", vim.log.levels.DEBUG)
        return {}
    end

    local query = safe_pcall(vim.treesitter.query.parse, "go", query_str)
    if not query then
        vim.notify("Failed to parse treesitter query", vim.log.levels.DEBUG)
        return {}
    end

    local parse_results = parser:parse()
    if not parse_results or #parse_results == 0 then
        return {}
    end

    local root = parse_results[1]:root()
    local nodes = {}

    for id, node in query:iter_captures(root, 0) do
        local type = query.captures[id]
        local line, character = node:range()
        table.insert(nodes, { line = line, character = character, type = type })
    end
    return nodes
end

-- 文件处理
local function get_package_name(fdata)
    for _, line in ipairs(fdata) do
        local match = string.match(line, "^package (%a+)$")
        if match then
            return match
        end
    end
    return ""
end

local function read_file_data(uri, bufnr, fcache)
    if bufnr and vim.api.nvim_buf_is_loaded(bufnr) then
        return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    end

    local file = vim.uri_to_fname(uri)
    if not fcache[file] then
        fcache[file] = vim.fn.readfile(file)
    end
    return fcache[file]
end

-- 统一的实现回调处理
local function process_implementation(impl, fcache, is_vscode)
    local uri, impl_line, impl_start, impl_end

    if is_vscode then
        uri = "file://" .. impl.uri.path
        impl_line = impl.range[1].line
        impl_start = impl.range[1].character
        impl_end = impl.range[2].character
    else
        uri = impl.uri
        impl_line = impl.range.start.line
        impl_start = impl.range.start.character
        impl_end = impl.range["end"].character
    end

    local bufnr = vim.uri_to_bufnr(uri)
    local data = read_file_data(uri, bufnr, fcache)

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
    return package_name .. impl_text:sub(impl_start + 1, impl_end)
end

local function create_implementation_callback(is_vscode)
    return function(result)
        if not result then
            return {}
        end

        local fcache = {}
        local names = {}

        local function process_single(impl)
            local name = process_implementation(impl, fcache, is_vscode)
            if name then
                table.insert(names, name)
            end
        end

        if is_vscode then
            if result[1] and result[1].uri then
                process_single(result[1])
            else
                for _, impl in pairs(result) do
                    process_single(impl)
                end
            end
        else
            if result.uri then
                process_single(result)
            else
                for _, impl in pairs(result) do
                    process_single(impl)
                end
            end
        end

        return names
    end
end

local implementation_callback = create_implementation_callback(false)
local vscode_implementation_callback = create_implementation_callback(true)

-- LSP 交互
local function get_implementation_names(client, line, character, callback, bufnr)
    client:request(vim.lsp.protocol.Methods.textDocument_implementation, {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = { line = line, character = character },
    }, function(err, result, _, _)
        if err or not api.nvim_buf_is_valid(bufnr) then
            return
        end

        local names = implementation_callback(result)
        callback(names)
    end)
end

local function get_implementations_at_position(line, character)
    local vscode = require("vscode")
    return vscode.eval(
        [[
        const editor = vscode.window.activeTextEditor;
        if (!editor || editor.document.languageId !== 'go') return null;
        
        const position = new vscode.Position(args.line, args.character);
        return vscode.commands.executeCommand(
            'vscode.executeImplementationProvider', 
            editor.document.uri, 
            position
        );
    ]],
        {
            args = { line = line, character = character },
        }
    )
end

-- 渲染相关
local function clean_render(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr or 0, namespace, 0, -1)
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

    -- 避免在同一行创建多个 extmark
    local marks = safe_pcall(vim.api.nvim_buf_get_extmarks, bufnr, namespace, { line, 0 }, { line, -1 }, {})
    if marks and #marks > 0 then
        opts.id = marks[1][1]
    end

    pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, line, 0, opts)
end

-- 主要功能
local function annotate_structs_interfaces(bufnr)
    if not config.enable or not is_valid_buffer(bufnr) then
        return
    end

    clean_render(bufnr)
    local nodes = find_types(bufnr)

    if vim.g.vscode then
        for _, node in ipairs(nodes) do
            local result = get_implementations_at_position(node.line, node.character + 1)
            if result then
                local _prefix = config.prefix[node.type]
                set_virt_text(bufnr, node.line, _prefix, vscode_implementation_callback(result))
            end
        end
        return
    end

    local clients = vim.lsp.get_clients({ name = "gopls" })
    if not clients or #clients < 1 then
        return
    end

    local gopls = clients[1]
    for _, node in ipairs(nodes) do
        get_implementation_names(gopls, node.line, node.character + 1, function(names)
            if api.nvim_buf_is_valid(bufnr) then
                local _prefix = config.prefix[node.type]
                set_virt_text(bufnr, node.line, _prefix, names)
            end
        end, bufnr)
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
api.nvim_create_user_command("GoplementsEnable", enable, { desc = "Enable Goplements" })
api.nvim_create_user_command("GoplementsDisable", disable, { desc = "Disable Goplements" })
api.nvim_create_user_command("GoplementsToggle", toggle, { desc = "Toggle Goplements" })

local events = vim.g.vscode and { "TextChanged", "LspAttach", "BufEnter" } or { "TextChanged", "LspAttach" }
api.nvim_create_autocmd(events, {
    pattern = { "*.go" },
    callback = debounce(function(args)
        annotate_structs_interfaces(args.buf)
    end, config.debounce_delay),
})
