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
    local parser = vim.treesitter.get_parser(bufnr, "go")

    local query = vim.treesitter.query.parse("go", query_str)

    local root = parser:parse()[1]:root()

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

--- Add virtual text to the struct/interface at the given line and character position
--- @param client vim.lsp.Client The LSP client
--- @param line integer The line number of the struct/interface
--- @param character integer The character position of the struct/interface name
--- @param callback fun(names: string[])
local function get_implementation_names(client, line, character, callback)
    client.request(vim.lsp.protocol.Methods.textDocument_implementation, {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = { line = line, character = character },
    }, function(err, result, _, _)
        -- This can happen if the Go file structure is ruined (e.g. the "package" is deleted)
        -- stylua: ignore
        if err then return end

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
    -- stylua: ignore
    -- Avoid the bufnr not exist due to asynchronous
    if not api.nvim_buf_is_valid(bufnr) then return end
    local impl_text = _prefix .. table.concat(names, ", ")
    local opts = {
        virt_text = { { impl_text, "Goplements" } },
        virt_text_pos = "eol",
    }

    -- insurance that we don't create multiple extmarks on the same line
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, namespace, { line, 0 }, { line, -1 }, {})
    if #marks > 0 then
        opts.id = marks[1][1]
    end

    vim.api.nvim_buf_set_extmark(bufnr, namespace, line, 0, opts)
end

--- Searches for structs and interfaces in the current buffer
--- and adds virtual text with implementations details next to them
--- Called from autocmd
--- @param bufnr integer
local function annotate_structs_interfaces(bufnr)
    if not is_enable then
        return
    end

    clean_render(bufnr)

    local clients = vim.lsp.get_clients({ name = "gopls" })
    -- stylua: ignore
    if not clients or #clients < 1 then return end

    local gopls = clients[1]

    local nodes = find_types(bufnr)
    for _, node in ipairs(nodes) do
        get_implementation_names(gopls, node.line, node.character + 1, function(names)
            local _prefix = prefix[node.type]
            set_virt_text(bufnr, node.line, _prefix, names)
        end)
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

api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "LspAttach" }, {
    pattern = { "*.go" },
    callback = debounce(function(args)
        annotate_structs_interfaces(args.buf)
    end, 500),
})
