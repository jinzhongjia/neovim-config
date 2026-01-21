return
--- @type LazySpec
{
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufNewFile", "BufWritePost" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                bash = { "shellcheck" },
                sh = { "shellcheck" },
                dockerfile = { "hadolint" },
                ["yaml.ghaction"] = { "actionlint" },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function()
                    local buftype = vim.bo.buftype
                    if buftype == "" or buftype == "acwrite" then
                        lint.try_lint()
                    end
                end,
            })
        end,
    },
}
