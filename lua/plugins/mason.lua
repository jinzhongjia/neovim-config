return {
    "mason-org/mason.nvim",
    opts = {},
    config = function(_, opts)
        require("mason").setup(opts)

        -- mason.nvim 本身不支持 ensure_installed，需要手动实现
        local ensure_installed = {
            "goimports",
            "goimports-reviser",
            "golangci-lint",
            "prettierd",
            "shfmt",
            "clang-format",
            "ast-grep",
            "golines",
            "delve",
            "gofumpt",
            "stylua",
            "yapf",
            "yamlfmt",
            "sleek",
            "shellcheck",
            "hadolint",
            "actionlint",
        }

        local registry = require("mason-registry")
        registry.refresh(function()
            for _, pkg_name in ipairs(ensure_installed) do
                local ok, pkg = pcall(registry.get_package, pkg_name)
                if ok and not pkg:is_installed() then
                    vim.schedule(function()
                        vim.notify("Mason: installing " .. pkg_name, vim.log.levels.INFO)
                    end)
                    pkg:install()
                end
            end
        end)
    end,
}
