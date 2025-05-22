if vim.g.vscode then
    return
end
local api = vim.api

local is_enable = true
local namespace_str = "goplements"

local prefix = {
    interface = "implemented by: ",
    struct = "implements: ",
}

local query_str = [[
    (type_spec
        name: (type_identifier) @interface
        type: (interface_type))
    (type_spec
        name: (type_identifier) @struct
        type: (struct_type))
]]

local namespace = api.nvim_create_namespace(namespace_str)

api.nvim_set_hl(0, "Goplements", { default = true, link = "DiagnosticHint" })

-- debounce
--- @param func function
---@param delay integer
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

---@alias goplements.Typedef { line: integer, character: integer, type: `interface` | `struct` }

--- Find all structs and interfaces in the current buffer
--- @param bufnr integer The buffer number to parse
--- @return goplements.Typedef[]
local function find_types(bufnr)
    -- 保护TreeSitter解析，确保go解析器存在
    local ok, parser = pcall(function()
        return vim.treesitter.get_parser(bufnr, "go")
    end)

    if not ok or not parser then
        vim.notify("Go TreeSitter parser not found", vim.log.levels.DEBUG)
        return {}
    end

    local ok_query, query = pcall(vim.treesitter.query.parse, "go", query_str)
    if not ok_query or not query then
        vim.notify("Failed to parse treesitter query", vim.log.levels.DEBUG)
        return {}
    end

    local parse_results = parser:parse()
    if not parse_results or #parse_results == 0 then
        return {}
    end

    local root = parse_results[1]:root()
    local nodes = {} --- @type goplements.Typedef[]

    for id, node in query:iter_captures(root, 0) do
        local type = query.captures[id]
        local line, character = node:range()
        table.insert(nodes, { line = line, character = character, type = type })
    end
    return nodes
end

--- Clear all extmarks in the current buffer
--- @param bufnr? integer The buffer number to clear the extmarks from, defaults to the current buffer
local function clean_render(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr or 0, namespace, 0, -1)
end

--- Given the lines from a Go file - searches for the package name
--- @param fdata string[]
--- @return string the package name or an empty string if not found
local function get_package_name(fdata)
    for _, line in ipairs(fdata) do
        local match = string.match(line, "^package (%a+)$")
        if match then
            return match
        end
    end
    return ""
end

--- @alias goplements.LspImplementation { range: { start: { line: integer, character: integer }, ["end"]: { line: integer, character: integer } }, uri: string }

--- @param result lsp.Location|lsp.Location[]|lsp.LocationLink[]|nil The results from the LSP server
--- @return string[]
local function implementation_callback(result)
    --- @type {[string]: string[]}
    local fcache = {}
    local display_package = true
    if vim.g.goplements and vim.g.goplements.display_package ~= nil then
        display_package = vim.g.goplements.display_package
    end

    --- @type string[]
    local names = {}

    --- @param impl lsp.Location|lsp.LocationLink
    local function _tmp(impl)
        local uri = impl.uri
        local impl_line = impl.range.start.line
        local impl_start = impl.range.start.character
        local impl_end = impl.range["end"].character

        -- Read the line of the implementation to get the name
        local data = {}

        local buf = vim.uri_to_bufnr(uri)
        if vim.api.nvim_buf_is_loaded(buf) then
            data = vim.api.nvim_buf_get_lines(buf, 0, impl_line + 1, false)
        else
            local file = vim.uri_to_fname(uri)
            data = fcache[file]
            if not data then
                data = vim.fn.readfile(file)
                fcache[file] = data
            end
        end

        local package_name = ""
        if display_package then
            package_name = get_package_name(data)
            if package_name ~= "" then
                package_name = package_name .. "."
            end
        end
        local impl_text = data[impl_line + 1]
        local name = package_name .. impl_text:sub(impl_start + 1, impl_end)

        table.insert(names, name)
    end

    -- stylua: ignore
    if not result then return names end

    if result.uri then
        _tmp(result)
        return names
    end

    -- stylua: ignore
    for _, impl in pairs(result) do _tmp(impl) end

    return names
end

local function vscode_implementation_callback(result)
    --- @type {[string]: string[]}
    local fcache = {}
    local display_package = true
    if vim.g.goplements and vim.g.goplements.display_package ~= nil then
        display_package = vim.g.goplements.display_package
    end

    --- @type string[]
    local names = {}

    --- @param impl table
    local function _tmp(impl)
        local uri = impl.uri.path
        local impl_line = impl.range[1].line
        local impl_start = impl.range[1].character
        local impl_end = impl.range[2].character

        -- Read the line of the implementation to get the name
        local data = {}

        local buf = vim.uri_to_bufnr("file://" .. uri)
        if vim.api.nvim_buf_is_loaded(buf) then
            data = vim.api.nvim_buf_get_lines(buf, 0, impl_line + 1, false)
        else
            local file = vim.uri_to_fname("file://" .. uri)
            data = fcache[file]
            if not data then
                data = vim.fn.readfile(file)
                fcache[file] = data
            end
        end

        local package_name = ""
        if display_package then
            package_name = get_package_name(data)
            if package_name ~= "" then
                package_name = package_name .. "."
            end
        end
        local impl_text = data[impl_line + 1]
        local name = package_name .. impl_text:sub(impl_start + 1, impl_end)

        table.insert(names, name)
    end

    -- stylua: ignore
    if not result then return names end

    if result[1] and result[1].uri then
        _tmp(result[1])
        return names
    end

    -- stylua: ignore
    for _, impl in pairs(result) do _tmp(impl) end

    return names
end

--- Add virtual text to the struct/interface at the given line and character position
--- @param client vim.lsp.Client The LSP client
--- @param line integer The line number of the struct/interface
--- @param character integer The character position of the struct/interface name
--- @param callback fun(names: string[])
local function get_implementation_names(client, line, character, callback, bufnr)
    client:request(vim.lsp.protocol.Methods.textDocument_implementation, {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = { line = line, character = character },
    }, function(err, result, _, _)
        -- This can happen if the Go file structure is ruined (e.g. the "package" is deleted)
        -- stylua: ignore
        if err then return end

        -- 确保缓冲区仍然有效，避免异步回调时buffer已被关闭
        if not api.nvim_buf_is_valid(bufnr) then
            return
        end

        local names = implementation_callback(result)
        callback(names)
    end)
end

--- Set the virtual text for the given line
--- @param bufnr integer The buffer number
--- @param line integer The line number
--- @param _prefix string The prefix to display before the names
--- @param names string[] The names to display
local function set_virt_text(bufnr, line, _prefix, names)
    -- stylua: ignore
    if #names < 1 then return end

    -- 确保buffer仍然有效，避免在异步操作时buffer已经被关闭
    if not bufnr or not api.nvim_buf_is_valid(bufnr) then
        return
    end

    -- 确保buffer仍然存在该行
    local line_count = api.nvim_buf_line_count(bufnr)
    if line >= line_count then
        return
    end

    local impl_text = _prefix .. table.concat(names, ", ")
    local opts = {
        virt_text = { { impl_text, "Goplements" } },
        virt_text_pos = "eol",
    }

    -- insurance that we don't create multiple extmarks on the same line
    local ok, marks = pcall(vim.api.nvim_buf_get_extmarks, bufnr, namespace, { line, 0 }, { line, -1 }, {})
    if ok and marks and #marks > 0 then
        opts.id = marks[1][1]
    end

    pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, line, 0, opts)
end

-- 获取指定位置的实现
-- @param line 行号 (0-based)
-- @param character 字符位置 (0-based)
-- @return 原始 LSP 实现结果
local function get_implementations_at_position(line, character)
    local vscode = require("vscode")
    local result = vscode.eval(
        [[
    const editor = vscode.window.activeTextEditor;
    if (!editor) return null;
    
    const document = editor.document;
    
    // 检查是否为 Go 文件
    if (document.languageId !== 'go') return null;
    
    const position = new vscode.Position(args.line, args.character);
    
    // 直接返回原始响应
    return vscode.commands.executeCommand(
      'vscode.executeImplementationProvider', 
      document.uri, 
      position
    );
  ]],
        {
            args = {
                line = line,
                character = character,
            },
        }
    )

    return result
end

--- Searches for structs and interfaces in the current buffer
--- and adds virtual text with implementations details next to them
--- Called from autocmd
--- @param bufnr integer
local function annotate_structs_interfaces(bufnr)
    if not is_enable then
        return
    end

    -- 检查buffer是否有效
    if not bufnr or not api.nvim_buf_is_valid(bufnr) then
        return
    end

    -- 检查文件类型是否为Go
    local ft = vim.bo[bufnr].filetype
    if ft ~= "go" then
        return
    end

    clean_render(bufnr)

    -- in vsocde
    if vim.g.vscode then
        local nodes = find_types(bufnr)
        for _, node in ipairs(nodes) do
            local result = get_implementations_at_position(node.line, node.character + 1)
            if result == nil then
                return
            end
            local _prefix = prefix[node.type]
            set_virt_text(bufnr, node.line, _prefix, vscode_implementation_callback(result))
        end
        return
    end

    -- 使用方法：
    -- local implementations = get_implementations_raw()
    -- 然后您可以使用这个结果进行后续处理

    local clients = vim.lsp.get_clients({ name = "gopls" })
    -- stylua: ignore
    if not clients or #clients < 1 then return end

    local gopls = clients[1]

    local nodes = find_types(bufnr)
    for _, node in ipairs(nodes) do
        get_implementation_names(gopls, node.line, node.character + 1, function(names)
            local _prefix = prefix[node.type]
            -- 传递当前bufnr确保在回调时仍然使用正确的buffer
            if api.nvim_buf_is_valid(bufnr) then
                set_virt_text(bufnr, node.line, _prefix, names)
            end
        end, bufnr)
    end
end

local function enable()
    -- stylua: ignore
    if is_enable then return end
    is_enable = true

    local bufnr = vim.api.nvim_get_current_buf()

    annotate_structs_interfaces(bufnr)
end

local function disable()
    -- stylua: ignore
    if not is_enable then return end
    is_enable = false
    clean_render()
end

local function toggle()
    -- stylua: ignore
    if is_enable then disable() else enable() end
end

api.nvim_create_user_command("GoplementsEnable", enable, { desc = "Enable Goplements" })
api.nvim_create_user_command("GoplementsDisable", disable, { desc = "Disable Goplements" })
api.nvim_create_user_command("GoplementsToggle", toggle, { desc = "Toggle Goplements" })

local events = { "TextChanged", "LspAttach" }
if vim.g.vscode then
    table.insert(events, "BufEnter")
end
api.nvim_create_autocmd(events, {
    pattern = { "*.go" },
    callback = debounce(function(args)
        annotate_structs_interfaces(args.buf)
    end, 500),
})
