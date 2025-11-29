--- @type LazySpec
local M = {

    {
        "jinzhongjia/hlargs.nvim",
        enabled = true,
        event = "LspAttach", -- LSP 加载时触发
        config = function()
            require("hlargs").setup()
            vim.api.nvim_create_augroup("LspAttach_hlargs", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = "LspAttach_hlargs",
                callback = function(args)
                    if not (args.data and args.data.client_id) then
                        return
                    end

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    local caps = client.server_capabilities
                    if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
                        require("hlargs").disable_buf(args.buf)
                    end
                end,
            })
        end,
    },
    {
        "Wansmer/treesj",
        -- 按键触发即可
        keys = { "<space>m", "<space>j", "<space>s" },
        dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
        opts = {},
    },
    {
        "ckolkey/ts-node-action",
        dependencies = { "nvim-treesitter" },
        event = { "BufReadPost", "BufNewFile" }, -- 编辑文件时加载
        opts = function()
            local helpers = require("ts-node-action.helpers")

            -- Lua 自定义操作
            local lua_actions = {
                -- 切换 require 风格: local x = require("x") <-> require("x")
                ["assignment_statement"] = function(node)
                    local text = helpers.node_text(node)
                    if text:match("^local%s+%w+%s*=%s*require") then
                        local module = text:match("require%([\"'](.+)[\"']%)")
                        if module then
                            return string.format('require("%s")', module)
                        end
                    end
                end,

                -- 切换字符串拼接方式: "a" .. "b" <-> string.format("%s%s", "a", "b")
                ["binary_expression"] = function(node)
                    local text = helpers.node_text(node)
                    if text:match("%.%.") then
                        -- 简单的两个字符串拼接
                        local parts = {}
                        for part in text:gmatch("[^%.]+") do
                            local trimmed = part:match("^%s*(.-)%s*$")
                            table.insert(parts, trimmed)
                        end
                        if #parts == 2 then
                            return string.format('string.format("%%s%%s", %s, %s)', parts[1], parts[2])
                        end
                    end
                end,
            }

            -- Go 自定义操作
            local go_actions = {
                -- 切换错误处理风格
                ["if_statement"] = function(node)
                    local text = helpers.node_text(node)
                    -- err != nil <-> err == nil
                    if text:match("err%s*!=") then
                        return text:gsub("err%s*!=", "err ==")
                    elseif text:match("err%s*==") then
                        return text:gsub("err%s*==", "err !=")
                    end
                end,

                -- 切换指针接收者和值接收者
                ["method_declaration"] = function(node)
                    local text = helpers.node_text(node)
                    -- func (r *Receiver) <-> func (r Receiver)
                    local receiver, pointer, rest = text:match("^(%s*func%s+%((%*?)%w+%s+%w+%))(.*)")
                    if receiver then
                        if pointer == "*" then
                            return text:gsub("%((%*)(%w+)%s+(%w+)%)", "(%2 %3)")
                        else
                            return text:gsub("%((%w+)%s+(%w+)%)", "(*%1 %2)")
                        end
                    end
                end,

                -- 添加/移除 error 返回值
                ["function_declaration"] = function(node)
                    local text = helpers.node_text(node)
                    -- 检查是否已经返回 error
                    if text:match("%)%s*error%s*{") or text:match("%)%s*%(.-error.-%)%s*{") then
                        -- 已有 error，尝试移除（简单情况）
                        if text:match("%)%s*error%s*{") then
                            return text:gsub("%)%s*error%s*{", ") {")
                        end
                    else
                        -- 添加 error 返回值
                        local before_brace = text:match("(.*){")
                        if before_brace then
                            -- 检查是否已有返回值
                            if before_brace:match("%)%s*%w+%s*$") then
                                return text:gsub("%)%s*(%w+)%s*{", ") (%1, error) {")
                            else
                                return text:gsub("%)%s*{", ") error {")
                            end
                        end
                    end
                end,

                -- 切换短变量声明和标准声明: x := 1 <-> var x = 1
                ["short_var_declaration"] = function(node)
                    local text = helpers.node_text(node)
                    local var_name, value = text:match("(%w+)%s*:=%s*(.*)")
                    if var_name and value then
                        return string.format("var %s = %s", var_name, value)
                    end
                end,

                ["var_declaration"] = function(node)
                    local text = helpers.node_text(node)
                    -- var x = 1 -> x := 1 (简单情况)
                    local var_name, value = text:match("var%s+(%w+)%s*=%s*(.*)")
                    if var_name and value then
                        return string.format("%s := %s", var_name, value)
                    end
                end,

                -- 切换 make 的容量参数
                ["call_expression"] = {
                    -- errors.Is(err, SomeError) <-> err == SomeError
                    function(node)
                        local text = helpers.node_text(node)
                        if text:match("^errors%.Is%(") then
                            local err_var, err_type = text:match("errors%.Is%((%w+),%s*([%w%.]+)%)")
                            if err_var and err_type then
                                return string.format("%s == %s", err_var, err_type)
                            end
                        elseif text:match("^!errors%.Is%(") then
                            -- !errors.Is(err, SomeError) -> err != SomeError
                            local err_var, err_type = text:match("!errors%.Is%((%w+),%s*([%w%.]+)%)")
                            if err_var and err_type then
                                return string.format("%s != %s", err_var, err_type)
                            end
                        end
                    end,
                    -- make([]T, len) <-> make([]T, len, cap) <-> make([]T, 0, cap)
                    function(node)
                        local text = helpers.node_text(node)
                        if text:match("^make%s*%(") then
                            -- make([]T, len) -> make([]T, len, len*2)
                            if text:match("^make%s*%([^,]+,%s*%d+%s*%)") then
                                local type_part, len = text:match("^make%s*%(([^,]+),%s*(%d+)%s*%)")
                                if type_part and len then
                                    local cap = tonumber(len) * 2
                                    return string.format("make(%s, %s, %d)", type_part, len, cap)
                                end
                            -- make([]T, len, cap) -> make([]T, 0, cap)
                            elseif text:match("^make%s*%([^,]+,%s*%d+%s*,%s*%d+%s*%)") then
                                local type_part, len, cap = text:match("^make%s*%(([^,]+),%s*(%d+)%s*,%s*(%d+)%s*%)")
                                if type_part and cap and len ~= "0" then
                                    return string.format("make(%s, 0, %s)", type_part, cap)
                                else
                                    -- make([]T, 0, cap) -> make([]T, cap)
                                    return string.format("make(%s, %s)", type_part, cap)
                                end
                            end
                        end
                    end,
                    -- append 单个元素 <-> append 切片展开
                    function(node)
                        local text = helpers.node_text(node)
                        if text:match("^append%s*%(") then
                            -- append(s, elem) <-> append(s, elem...)
                            if text:match("%.%.%.%)$") then
                                return text:gsub("%.%.%.%)$", ")")
                            else
                                return text:gsub("%)$", "...)")
                            end
                        end
                    end,
                    name = "Toggle errors.Is/make/append",
                },

                -- 切换 struct 字段标签的 json tag 格式
                ["field_declaration"] = function(node)
                    local text = helpers.node_text(node)
                    -- Name string `json:"name"` <-> Name string `json:"name,omitempty"`
                    if text:match('`json:"[^"]+"`') then
                        if text:match("omitempty") then
                            return text:gsub(",omitempty", "")
                        else
                            return text:gsub('(json:"[^"]+)"', '%1,omitempty"')
                        end
                    end
                end,

                -- 切换循环类型: for range <-> for i := 0
                ["for_statement"] = function(node)
                    local text = helpers.node_text(node)
                    -- for range 转换为索引循环
                    if text:match("for%s+range%s+") then
                        local var_name = text:match("for%s+(%w+)%s+:=%s+range")
                        if var_name then
                            return text:gsub("for%s+%w+%s+:=%s+range%s+(%w+)", "for %s := 0; %s < len(%s); %s++")
                                :format(var_name, var_name, "%1", var_name)
                        end
                    elseif text:match("for%s+_%s*,%s*%w+%s+:=%s+range") then
                        -- for _, v := range slice -> for i := 0; i < len(slice); i++ { v := slice[i]
                        local val_name, slice = text:match("for%s+_%s*,%s*(%w+)%s+:=%s+range%s+(%w+)")
                        if val_name and slice then
                            return text:gsub(
                                "for%s+_%s*,%s*%w+%s+:=%s+range%s+%w+%s*{",
                                string.format("for i := 0; i < len(%s); i++ {\n\t%s := %s[i]", slice, val_name, slice)
                            )
                        end
                    end
                end,

                -- 切换接口类型断言: v.(Type) <-> v.(Type), ok
                ["type_assertion_expression"] = function(node)
                    local text = helpers.node_text(node)
                    -- 简单断言
                    if not text:match(",%s*ok") and not text:match(",%s*_") then
                        return text .. ", ok"
                    end
                end,

                -- 切换 nil 检查风格和错误比较
                ["binary_expression"] = function(node)
                    local text = helpers.node_text(node)
                    -- err == SpecificError -> errors.Is(err, SpecificError)
                    -- 匹配 err == context.Canceled, err == io.EOF 等
                    local err_var, err_type = text:match("(%w+)%s*==%s*([%w%.]+)")
                    if err_var and err_type and err_type ~= "nil" and not err_type:match("^%d") then
                        -- 确保不是数字比较，且右边不是 nil
                        return string.format("errors.Is(%s, %s)", err_var, err_type)
                    end

                    -- err != SpecificError -> !errors.Is(err, SpecificError)
                    err_var, err_type = text:match("(%w+)%s*!=%s*([%w%.]+)")
                    if err_var and err_type and err_type ~= "nil" and not err_type:match("^%d") then
                        return string.format("!errors.Is(%s, %s)", err_var, err_type)
                    end

                    -- x == nil <-> x != nil
                    if text:match("==%s*nil") then
                        return text:gsub("==%s*nil", "!= nil")
                    elseif text:match("!=%s*nil") then
                        return text:gsub("!=%s*nil", "== nil")
                    -- len(x) == 0 <-> len(x) > 0
                    elseif text:match("len%(.-%)%s*==%s*0") then
                        return text:gsub("==%s*0", "> 0")
                    elseif text:match("len%(.-%)%s*>%s*0") then
                        return text:gsub(">%s*0", "== 0")
                    end
                end,

                -- 切换 context 参数: ctx context.Context <-> _ context.Context
                ["parameter_declaration"] = function(node)
                    local text = helpers.node_text(node)
                    if text:match("ctx%s+context%.Context") then
                        return text:gsub("ctx%s+context%.Context", "_ context.Context")
                    elseif text:match("_%s+context%.Context") then
                        return text:gsub("_%s+context%.Context", "ctx context.Context")
                    end
                end,

                -- 切换 defer 语句位置（上移/下移优先级）
                ["defer_statement"] = function(node)
                    local text = helpers.node_text(node)
                    -- 为 defer 添加说明性注释
                    if not text:match("^%s*//%s*defer") then
                        return "// defer: cleanup\n" .. text
                    end
                end,

                -- 切换返回 nil 的方式: return nil <-> return nil, nil <-> return nil, fmt.Errorf()
                ["return_statement"] = function(node)
                    local text = helpers.node_text(node)
                    if text:match("^return%s+nil%s*$") then
                        return "return nil, nil"
                    elseif text:match("^return%s+nil,%s*nil%s*$") then
                        return 'return nil, fmt.Errorf("TODO: error message")'
                    elseif text:match("^return%s+nil,%s*fmt%.Errorf") then
                        return "return nil"
                    end
                end,
            }

            -- Rust 自定义操作
            local rust_actions = {
                -- 切换 Result 和 Option 的 unwrap 方法
                ["call_expression"] = function(node)
                    local text = helpers.node_text(node)
                    -- unwrap() <-> unwrap_or_default() <-> unwrap_or(...) <-> expect(...)
                    if text:match("%.unwrap%(%)") then
                        local base = text:match("(.*)%.unwrap%(%)")
                        return base .. ".unwrap_or_default()"
                    elseif text:match("%.unwrap_or_default%(%)") then
                        local base = text:match("(.*)%.unwrap_or_default%(%)")
                        return base .. '.expect("TODO: add message")'
                    elseif text:match("%.expect%(") then
                        local base = text:match("(.*)%.expect%(")
                        return base .. ".unwrap()"
                    end
                end,

                -- 切换可变性: let x <-> let mut x
                ["let_declaration"] = function(node)
                    local text = helpers.node_text(node)
                    if text:match("^let%s+mut%s+") then
                        return text:gsub("let%s+mut%s+", "let ")
                    elseif text:match("^let%s+") then
                        return text:gsub("let%s+", "let mut ")
                    end
                end,

                -- 切换引用类型: &T <-> &mut T <-> T
                ["reference_type"] = function(node)
                    local text = helpers.node_text(node)
                    if text:match("^&mut%s+") then
                        return text:gsub("&mut%s+", "")
                    elseif text:match("^&%s*") then
                        return text:gsub("&%s*", "&mut ")
                    else
                        return "&" .. text
                    end
                end,
            }

            -- TypeScript/JavaScript 自定义操作
            local ts_actions = {
                -- 切换 const/let/var
                ["lexical_declaration"] = function(node)
                    local text = helpers.node_text(node)
                    if text:match("^const%s+") then
                        return text:gsub("^const%s+", "let ")
                    elseif text:match("^let%s+") then
                        return text:gsub("^let%s+", "var ")
                    elseif text:match("^var%s+") then
                        return text:gsub("^var%s+", "const ")
                    end
                end,

                -- 切换箭头函数和普通函数
                ["arrow_function"] = function(node)
                    local text = helpers.node_text(node)
                    -- (args) => expr  转为  (args) => { return expr }
                    if not text:match("=>%s*{") then
                        local args, body = text:match("(.-)=>%s*(.*)")
                        if args and body then
                            return string.format("%s=> { return %s }", args, body)
                        end
                    else
                        -- { return expr } 转为 expr
                        local args, body = text:match("(.-)=>%s*{%s*return%s+(.-);?%s*}")
                        if args and body then
                            return string.format("%s=> %s", args, body)
                        end
                    end
                end,

                -- 切换 Promise 链式调用和 async/await
                ["call_expression"] = function(node)
                    local text = helpers.node_text(node)
                    -- .then() <-> await
                    if text:match("%.then%(") then
                        local base = text:match("(.*)%.then%(")
                        if base then
                            return "await " .. base
                        end
                    end
                end,

                -- 切换模板字符串和普通字符串
                ["template_string"] = function(node)
                    local text = helpers.node_text(node)
                    -- `text` -> "text" (如果没有插值)
                    if not text:match("%${") then
                        local content = text:match("`(.*)`")
                        if content then
                            return '"' .. content .. '"'
                        end
                    end
                end,

                ["string"] = function(node)
                    local text = helpers.node_text(node)
                    -- "text" -> `text`
                    if text:match('^".*"$') then
                        local content = text:match('^"(.*)"$')
                        return "`" .. content .. "`"
                    elseif text:match("^'.*'$") then
                        local content = text:match("^'(.*)'$")
                        return "`" .. content .. "`"
                    end
                end,
            }

            return {
                ["*"] = {
                    -- 全局操作：切换注释风格等
                },
                lua = lua_actions,
                go = go_actions,
                rust = rust_actions,
                typescript = ts_actions,
                tsx = ts_actions,
                javascript = ts_actions,
                jsx = ts_actions,
            }
        end,
        keys = {
            {
                "<leader>na",
                function()
                    require("ts-node-action").node_action()
                end,
                desc = "Trigger Node Action",
            },
        },
        config = function(_, opts)
            require("ts-node-action").setup(opts)
        end,
    },
    {
        "catgoose/nvim-colorizer.lua",
        event = { "BufReadPost", "BufNewFile" }, -- 打开文件时加载
        opts = {
            filetypes = {
                "css",
                "javascript",
                "html",
            },
        },
    },
    {
        "echasnovski/mini.move",
        version = "*",
        -- 按键触发时才需要,通过 keys 定义
        keys = {
            { "<M-h>", mode = { "n", "v" } },
            { "<M-j>", mode = { "n", "v" } },
            { "<M-k>", mode = { "n", "v" } },
            { "<M-l>", mode = { "n", "v" } },
        },
        opts = {},
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = { "BufReadPost", "BufNewFile" }, -- 编辑文件时加载
        opts = {},
    },
    {
        "mcauley-penney/visual-whitespace.nvim",
        event = "ModeChanged", -- 模式切换时加载(进入 visual 模式)
        config = true,
    },
    {
        "qwavies/smart-backspace.nvim",
        event = { "InsertEnter", "CmdlineEnter" }, -- 进入插入或命令行模式时加载
        opts = {
            enabled = true, -- 启用智能退格
            silent = true, -- 切换时不显示通知
            disabled_filetypes = { -- 禁用智能退格的文件类型
                "markdown",
                "text",
            },
        },
        keys = {
            {
                "<leader>bs",
                "<cmd>SmartBackspaceToggle<CR>",
                desc = "Toggle Smart Backspace",
                mode = "n",
            },
        },
    },
}

-- all plugins
__arr_concat(M, require("plugins.edit.comment"))
__arr_concat(M, require("plugins.edit.complete"))
__arr_concat(M, require("plugins.edit.fold"))
__arr_concat(M, require("plugins.edit.format"))
__arr_concat(M, require("plugins.edit.indent"))
__arr_concat(M, require("plugins.edit.lint"))
__arr_concat(M, require("plugins.edit.outline"))
__arr_concat(M, require("plugins.edit.search"))
__arr_concat(M, require("plugins.edit.snippet"))
__arr_concat(M, require("plugins.edit.debug"))

return M
