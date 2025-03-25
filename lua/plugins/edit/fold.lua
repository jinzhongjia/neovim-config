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
    -- 很不错的插件，但是不应该继续用这个了
    {
        "chrisgrieser/nvim-origami",
        event = "VeryLazy",
        enabled = false,
        opts = {}, -- needed even when using default config
    },
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
                        provider_selector = function(bufnr, filetype, buftype)
                            return { "lsp", "treesitter", "indent" }
                        end,
                    })
                end,
            },
        },
        event = "VeryLazy",
        opts = {
            fold_virt_text_handler = handler,
        },
        -- stylua: ignore
        keys = {
            { "zR", function() require("ufo").openAllFolds() end, desc = "open all folds" },
            { "zM", function() require("ufo").closeAllFolds() end, desc = "close all folds" },
            { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "open folds except kinds" },
            { "zm", function() require("ufo").closeFoldsWith() end, desc = "close folds with" },
        },
    },
}
