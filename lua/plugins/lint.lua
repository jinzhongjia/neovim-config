return
--- @type LazySpec
{
    {
        "mfussenegger/nvim-lint",
        event = "BufWritePost",
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                go = { "golangcilint" },
                bash = { "shellcheck" },
                sh = { "shellcheck" },
                dockerfile = { "hadolint" },
                ["yaml.ghaction"] = { "actionlint" },
            }

            vim.api.nvim_create_autocmd("BufWritePost", {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function()
                    local buftype = vim.bo.buftype
                    if buftype ~= "" and buftype ~= "acwrite" then
                        return
                    end

                    lint.try_lint()
                end,
            })
        end,
    },
}
