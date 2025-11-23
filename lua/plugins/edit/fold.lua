-- this is not equal to offical handler!!!
local function handler(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local totalLines = vim.api.nvim_buf_line_count(0)
    local foldedLines = endLnum - lnum
    local suffix = (" 󰁂 %d / %d%%"):format(foldedLines, foldedLines / totalLines * 100)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    local rAlignAppndx = math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
    suffix = (" "):rep(rAlignAppndx) .. suffix
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
end

return
--- @type LazySpec
{
    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async",
            {
                "luukvbaal/statuscol.nvim",
                config = function()
                    local builtin = require("statuscol.builtin")
                    require("statuscol").setup({
                        relculright = true,
                        segments = {
                            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                            { text = { "%s" }, click = "v:lua.ScSa" },
                            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                        },
                    })
                end,
            },
        },
        event = { "BufReadPost", "BufNewFile" }, -- 打开文件时加载
        opts = function()
            -- LSP folding capability 已在 plugins/lsp/init.lua 中配置
            return {
                fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate, ctx)
                    -- 获取当前 buffer 的信息
                    local bufnr = ctx.bufnr or vim.api.nvim_get_current_buf()
                    local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
                    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
                    
                    -- 禁用特殊文件类型和 buftype 的自定义折叠文本
                    local disable_filetypes = {
                        "codecompanion",
                        "gitcommit",
                        "gitrebase",
                        "help",
                        "dashboard",
                        "NvimTree",
                        "neo-tree",
                        "Outline",
                        "lazy",
                        "mason",
                        "TelescopePrompt",
                        "TelescopeResults",
                        "terminal",
                        "toggleterm",
                        "floaterm",
                        "qf",
                        "diff",
                        "fugitive",
                        "log",
                    }
                    
                    -- 如果是特殊类型，返回默认行为
                    if buftype ~= "" then
                        return virtText
                    end
                    
                    for _, ft in ipairs(disable_filetypes) do
                        if filetype == ft then
                            return virtText
                        end
                    end
                    
                    -- 使用自定义 handler
                    return handler(virtText, lnum, endLnum, width, truncate)
                end,
                -- 提供者选择器: LSP > Treesitter > indent
                provider_selector = function(bufnr, filetype, buftype)
                    -- 禁用特殊文件类型的折叠
                    local disable_filetypes = {
                        "codecompanion",
                        "gitcommit",
                        "gitrebase",
                        "help",
                        "dashboard",
                        "NvimTree",
                        "neo-tree",
                        "Outline",
                        "lazy",
                        "mason",
                        "TelescopePrompt",
                        "TelescopeResults",
                        "terminal",
                        "toggleterm",
                        "floaterm",
                        "qf", -- quickfix
                        "diff",
                        "fugitive",
                        "log",
                    }

                    -- 禁用特殊 buffer 类型的折叠
                    if buftype ~= "" then
                        return ""
                    end

                    -- 检查文件类型
                    for _, ft in ipairs(disable_filetypes) do
                        if filetype == ft then
                            return ""
                        end
                    end
                    
                    -- 优先使用 LSP，fallback 使用 treesitter
                    -- 注意：provider_selector 只支持最多两个 provider (main + fallback)
                    return { "lsp", "treesitter" }
                end,
                -- 首次打开时关闭特定类型的折叠（仅对 LSP provider 有效）
                close_fold_kinds_for_ft = {
                    default = { "imports", "comment" },
                    -- 可以为特定语言添加额外的 fold kinds
                    go = { "imports", "comment" },
                    python = { "imports", "comment" },
                    typescript = { "imports", "comment" },
                    typescriptreact = { "imports", "comment" },
                    javascript = { "imports", "comment" },
                    javascriptreact = { "imports", "comment" },
                },
                -- 预览窗口配置
                preview = {
                    win_config = {
                        border = "rounded",
                        winblend = 0,
                        winhighlight = "Normal:Normal",
                    },
                    mappings = {
                        scrollU = "<C-u>",
                        scrollD = "<C-d>",
                        jumpTop = "[",
                        jumpBot = "]",
                    },
                },
            }
        end,
        -- stylua: ignore
        keys = {
            { "zR", function() require("ufo").openAllFolds() end, desc = "open all folds" },
            { "zM", function() require("ufo").closeAllFolds() end, desc = "close all folds" },
            { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "open folds except kinds" },
            { "zm", function() require("ufo").closeFoldsWith() end, desc = "close folds with" },
            -- K 键已在 LspUI 配置中定义，包含了 ufo 折叠预览 + LspUI hover 的逻辑
        },
    },
}
