-- goimpl.lua
-- Go interface implementation generator using vim.ui.select
-- 
-- Requirements: go install github.com/josharian/impl@latest
-- 
-- Usage in Go files:
--   1. Place cursor on type name (e.g., type MyService struct)
--   2. Press <leader>gi or run :GoImpl
--   3. Select interface from list
--   4. Implementation will be inserted below type declaration
--
-- Features:
--   - Zero dependencies (uses vim.ui.select)
--   - Auto-loaded for Go filetypes
--   - Full generics support
--   - LSP workspace symbol search
--
-- Customization:
--   - Change keymap: edit line ~445 (vim.keymap.set)
--   - Disable plugin: add 'return' at the top of this file

-- Skip if not needed
if vim.g.vscode then
	return
end

local M = {}

-- Logger helper
local function notify(msg, level)
	vim.schedule(function()
		vim.notify(msg, level or vim.log.levels.INFO, { title = "goimpl" })
	end)
end

-- Get treesitter node text
local function get_node_text(node, bufnr)
	bufnr = bufnr or 0
	if vim.treesitter.get_node_text then
		return vim.treesitter.get_node_text(node, bufnr)
	else
		-- Fallback for older Neovim versions
		return vim.treesitter.query.get_node_text(node, bufnr)
	end
end

-- Get LSP symbol kind name
local function get_symbol_kind_name(kind)
	return vim.lsp.protocol.SymbolKind[kind] or "Unknown"
end

-- Check if LSP client is attached and supports workspace/symbol
local function has_workspace_symbol_support(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, client in ipairs(clients) do
		if client.server_capabilities.workspaceSymbolProvider then
			return true
		end
	end
	return false
end

-- Convert LSP symbols to interface items
local function interfaces_to_items(symbols, bufnr)
	if not symbols or not bufnr then
		return {}
	end

	local items = {}

	local function process_symbols(syms)
		for _, symbol in ipairs(syms) do
			local kind = get_symbol_kind_name(symbol.kind)

			if kind == "Interface" then
				local item = {
					symbol_name = symbol.name,
					containerName = symbol.containerName,
					kind = kind,
				}

				if symbol.location then
					-- SymbolInformation type
					local ok, uri = pcall(vim.uri_to_fname, symbol.location.uri)
					if ok and uri then
						item.filename = uri
						item.lnum = symbol.location.range.start.line + 1
						item.col = symbol.location.range.start.character + 1
					end
				elseif symbol.selectionRange then
					-- DocumentSymbol type
					item.filename = vim.api.nvim_buf_get_name(bufnr)
					item.lnum = symbol.selectionRange.start.line + 1
					item.col = symbol.selectionRange.start.character + 1
				end

				table.insert(items, item)
			end

			-- Process children recursively
			if symbol.children then
				process_symbols(symbol.children)
			end
		end
	end

	process_symbols(symbols)
	return items
end

-- Get workspace symbols (interfaces)
local function get_workspace_interfaces(bufnr, query, callback)
	local params = { query = query or "" }

	vim.lsp.buf_request(bufnr, "workspace/symbol", params, function(err, result)
		if err then
			notify("LSP request failed: " .. tostring(err), vim.log.levels.ERROR)
			callback({})
			return
		end

		local interfaces = interfaces_to_items(result or {}, bufnr)
		callback(interfaces)
	end)
end

-- Parse type parameters from treesitter
local function get_type_parameter_query()
	local ok, query = pcall(vim.treesitter.query.parse, "go", [[(type_parameter_declaration
  name: (identifier) @param_name)]])
	return ok and query or nil
end

local function get_type_parameters(node, bufnr)
	if not node then
		return {}
	end

	local query = get_type_parameter_query()
	if not query then
		return {}
	end

	local params = {}
	for _, pnode in query:iter_captures(node, bufnr) do
		table.insert(params, get_node_text(pnode, bufnr))
	end
	return params
end

local function format_type_parameters(params)
	if not params or #params == 0 then
		return ""
	end
	return "[" .. table.concat(params, ", ") .. "]"
end

-- Get interface type parameters from file
local function get_interface_type_params(filepath, interface_name, callback)
	-- Validate filepath
	if not filepath or filepath == "" then
		callback("")
		return
	end

	-- Create temporary buffer for parsing
	local buf = vim.api.nvim_create_buf(false, true)
	if not buf or buf == 0 then
		callback("")
		return
	end

	-- Read file content
	local ok, lines = pcall(vim.fn.readfile, filepath)
	if not ok or not lines or #lines == 0 then
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
		callback("")
		return
	end

	-- Set buffer content and filetype
	local set_ok = pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
	if not set_ok then
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
		callback("")
		return
	end

	vim.bo[buf].filetype = "go"

	-- Wait for treesitter to parse
	vim.schedule(function()
		-- Check if buffer still exists
		if not vim.api.nvim_buf_is_valid(buf) then
			callback("")
			return
		end

		local parser_ok, parser = pcall(vim.treesitter.get_parser, buf, "go")
		if not parser_ok or not parser then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
			callback("")
			return
		end

		local trees_ok, trees = pcall(parser.parse, parser)
		if not trees_ok or not trees or #trees == 0 then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
			callback("")
			return
		end

		-- Query for interface declarations
		local query_ok, query = pcall(
			vim.treesitter.query.parse,
			"go",
			[[
(type_declaration
  (type_spec
    name: (type_identifier) @interface_name
    type_parameters: (type_parameter_list) @type_params
    type: (interface_type)
  )
)]]
		)

		if not query_ok or not query then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
			callback("")
			return
		end

		local root = trees[1]:root()
		for id, node in query:iter_captures(root, buf) do
			local capture_name = query.captures[id]
			if capture_name == "interface_name" then
				local name = get_node_text(node, buf)
				if name == interface_name then
					-- Found the interface, now get its type parameters
					for pid, pnode in query:iter_captures(node:parent(), buf) do
						local pcapture = query.captures[pid]
						if pcapture == "type_params" then
							local params = get_type_parameters(pnode, buf)
							pcall(vim.api.nvim_buf_delete, buf, { force = true })
							callback(format_type_parameters(params))
							return
						end
					end
				end
			end
		end

		pcall(vim.api.nvim_buf_delete, buf, { force = true })
		callback("")
	end)
end

-- Run impl command
local function run_impl(receiver, interface_name, cwd, callback)
	local cmd = { "impl", "-dir", cwd, receiver, interface_name }

	notify("Generating implementation for: " .. interface_name)

	local stdout_data = {}
	local stderr_data = {}

	local job = vim.fn.jobstart(cmd, {
		cwd = cwd,
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.list_extend(stdout_data, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.list_extend(stderr_data, data)
			end
		end,
		on_exit = function(_, code)
			callback({
				code = code,
				stdout = stdout_data,
				stderr = stderr_data,
			})
		end,
	})

	if job <= 0 then
		callback({
			code = -1,
			stdout = {},
			stderr = { "Failed to start impl command" },
		})
	end
end

-- Insert implementation into buffer
local function insert_implementation(tsnode, output)
	-- Clean up output
	local data = {}
	for _, line in ipairs(output) do
		if line and line ~= "" then
			table.insert(data, line)
		end
	end

	if #data == 0 then
		notify("No implementation generated", vim.log.levels.WARN)
		return false
	end

	-- Check for errors
	local first_line = data[1] or ""
	if first_line:match("unrecognized interface:") or first_line:match("couldn't find") then
		notify("Interface not found: " .. first_line, vim.log.levels.ERROR)
		return false
	end

	-- Find insertion position (after the type declaration)
	local parent = tsnode:parent()
	if not parent then
		notify("Invalid node parent", vim.log.levels.ERROR)
		return false
	end

	local grandparent = parent:parent()
	if not grandparent then
		notify("Invalid node grandparent", vim.log.levels.ERROR)
		return false
	end

	local _, _, end_line, _ = grandparent:range()
	local insert_line = end_line + 1

	-- Insert implementation
	vim.schedule(function()
		vim.fn.append(insert_line, "")
		vim.fn.append(insert_line + 1, data)
		notify("Implementation generated successfully!")
	end)

	return true
end

-- Main implementation function
function M.goimpl()
	local bufnr = vim.api.nvim_get_current_buf()

	-- Check if we're in a Go file
	if vim.bo[bufnr].filetype ~= "go" then
		notify("Not a Go file", vim.log.levels.WARN)
		return
	end

	-- Check if impl is available (lazy check)
	if vim.fn.executable("impl") ~= 1 then
		notify("impl command not found. Install it with: go install github.com/josharian/impl@latest", vim.log.levels.ERROR)
		return
	end

	-- Check if LSP is attached and supports workspace/symbol
	if not has_workspace_symbol_support(bufnr) then
		notify("No LSP client with workspace symbol support attached. Make sure gopls is running.", vim.log.levels.ERROR)
		return
	end

	-- Check if treesitter Go parser is available
	local has_parser = pcall(vim.treesitter.get_parser, bufnr, "go")
	if not has_parser then
		notify("Go treesitter parser not installed. Run :TSInstall go", vim.log.levels.ERROR)
		return
	end

	-- Get treesitter node at cursor
	local tsnode = vim.treesitter.get_node()
	if not tsnode then
		notify("No node found under cursor", vim.log.levels.WARN)
		return
	end

	-- Check if cursor is on a type identifier in a type declaration
	if
		tsnode:type() ~= "type_identifier"
		or not tsnode:parent()
		or tsnode:parent():type() ~= "type_spec"
		or not tsnode:parent():parent()
		or tsnode:parent():parent():type() ~= "type_declaration"
	then
		notify("Cursor must be on a type name in a type declaration", vim.log.levels.WARN)
		return
	end

	-- Get the type name
	local type_name = get_node_text(tsnode, bufnr)
	if not type_name or type_name == "" then
		notify("Failed to get type name", vim.log.levels.ERROR)
		return
	end

	-- Get type parameters if any
	local type_params = {}
	if tsnode:parent() then
		type_params = get_type_parameters(tsnode:parent(), bufnr)
	end
	local type_params_str = format_type_parameters(type_params)
	local receiver_type = type_name .. type_params_str

	-- Create receiver variable name (first 1-2 chars lowercase)
	local receiver_var = string.lower(string.sub(type_name, 1, math.min(2, #type_name)))
	if receiver_var == "" then
		receiver_var = "r"
	end
	local receiver = receiver_var .. " *" .. receiver_type

	-- Get current directory
	local cwd = vim.fn.expand("%:p:h")
	if not cwd or cwd == "" then
		notify("Failed to get current directory", vim.log.levels.ERROR)
		return
	end

	-- Store node range for later validation
	local node_start_line, node_start_col, node_end_line, node_end_col = tsnode:range()

	-- Get workspace interfaces
	notify("Searching for interfaces...")

	get_workspace_interfaces(bufnr, "", function(interfaces)
		-- Check if buffer is still valid
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		if #interfaces == 0 then
			notify("No interfaces found in workspace", vim.log.levels.WARN)
			return
		end

		-- Format items for vim.ui.select
		local items = {}
		local items_map = {}

		for _, iface in ipairs(interfaces) do
			local display = iface.symbol_name
			if iface.containerName and iface.containerName ~= "" then
				display = iface.containerName .. "." .. display
			end

			table.insert(items, display)
			items_map[display] = iface
		end

		-- Show selection UI
		vim.ui.select(items, {
			prompt = "Select interface to implement:",
			format_item = function(item)
				return item
			end,
		}, function(choice)
			-- Check if buffer is still valid
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			if not choice then
				return
			end

			local selected = items_map[choice]
			if not selected then
				return
			end

			-- Re-get the treesitter node at the original position
			-- (it may have changed if buffer was edited)
			local current_node = vim.treesitter.get_node({
				bufnr = bufnr,
				pos = { node_start_line, node_start_col },
			})

			if not current_node or current_node:type() ~= "type_identifier" then
				notify("Original type position has changed. Please try again.", vim.log.levels.WARN)
				return
			end

			-- Get simple interface name
			local interface_name = selected.symbol_name
			local parts = vim.split(interface_name, ".", { plain = true })
			interface_name = parts[#parts]

			-- Get interface type parameters if it has a file location
			if selected.filename then
				get_interface_type_params(selected.filename, interface_name, function(type_params_str)
					-- Build full interface name
					local full_interface = choice .. type_params_str

					-- Try to generate implementation
					run_impl(receiver, full_interface, cwd, function(result)
						if not vim.api.nvim_buf_is_valid(bufnr) then
							return
						end

						if result.code == 0 then
							insert_implementation(current_node, result.stdout)
						else
							-- Try without package prefix as fallback
							local fallback_interface = interface_name .. type_params_str
							run_impl(receiver, fallback_interface, cwd, function(fallback_result)
								if not vim.api.nvim_buf_is_valid(bufnr) then
									return
								end

								if fallback_result.code == 0 then
									insert_implementation(current_node, fallback_result.stdout)
								else
									local err_msg = table.concat(fallback_result.stderr, "\n")
									if err_msg == "" or err_msg == "\n" then
										err_msg = table.concat(fallback_result.stdout, "\n")
									end
									if err_msg ~= "" and err_msg ~= "\n" then
										notify("Failed to generate implementation: " .. err_msg, vim.log.levels.ERROR)
									else
										notify("Failed to generate implementation", vim.log.levels.ERROR)
									end
								end
							end)
						end
					end)
				end)
			else
				-- No file location, try directly
				run_impl(receiver, choice, cwd, function(result)
					if not vim.api.nvim_buf_is_valid(bufnr) then
						return
					end

					if result.code == 0 then
						insert_implementation(current_node, result.stdout)
					else
						local err_msg = table.concat(result.stderr, "\n")
						if err_msg == "" or err_msg == "\n" then
							err_msg = table.concat(result.stdout, "\n")
						end
						if err_msg ~= "" and err_msg ~= "\n" then
							notify("Failed to generate implementation: " .. err_msg, vim.log.levels.ERROR)
						else
							notify("Failed to generate implementation", vim.log.levels.ERROR)
						end
					end
				end)
			end
		end)
	end)
end

-- Auto-setup for Go files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function(args)
		local bufnr = args.buf

		-- Create buffer-local command
		vim.api.nvim_buf_create_user_command(bufnr, "GoImpl", function()
			M.goimpl()
		end, {
			desc = "Generate Go interface implementation",
		})

		-- Create buffer-local keymap
		vim.keymap.set("n", "<leader>gi", M.goimpl, {
			desc = "Generate Go interface implementation",
			buffer = bufnr,
		})
	end,
})

return M
