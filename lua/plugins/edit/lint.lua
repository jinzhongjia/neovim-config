return
--- @type LazySpec
{
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },

        config = function()
            require("lint").linters_by_ft = {
                bash = { "bash" },
                -- typescript = { "ts-standard" },
            }
            vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged" }, {
                callback = function(meta)
                    local bufnr = meta.buf
                    if vim.fn.buflisted(bufnr) then
                        require("lint").try_lint()
                    end
                end,
                desc = "auto cmd for neovim-lint",
            })
        end,
    },
}
