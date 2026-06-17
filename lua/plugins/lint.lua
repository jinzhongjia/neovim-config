return
--- @type LazySpec
{
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufNewFile", "BufWritePost" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                go = { "golangcilint" },
                bash = { "shellcheck" },
                sh = { "shellcheck" },
                dockerfile = { "hadolint" },
                ["yaml.ghaction"] = { "actionlint" },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function(args)
                    local buftype = vim.bo.buftype
                    if buftype ~= "" and buftype ~= "acwrite" then
                        return
                    end

                    -- golangci-lint is project-wide and slow; run it only after writes.
                    if vim.bo.filetype == "go" and args.event ~= "BufWritePost" then
                        return
                    end

                    lint.try_lint()
                end,
            })
        end,
    },
}
