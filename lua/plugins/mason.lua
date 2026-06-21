local registry_refresh_marker = vim.fs.joinpath(vim.fn.stdpath("state"), "mason-registry-refresh")
local registry_refresh_interval = 24 * 60 * 60

local function registry_refresh_due()
    local stat = vim.uv.fs_stat(registry_refresh_marker)
    return not stat or os.time() - stat.mtime.sec > registry_refresh_interval
end

local function mark_registry_refreshed()
    vim.fn.mkdir(vim.fs.dirname(registry_refresh_marker), "p")
    vim.fn.writefile({ tostring(os.time()) }, registry_refresh_marker)
end

return {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
        require("mason").setup(opts)

        -- mason.nvim 本身不支持 ensure_installed，需要手动实现
        local ensure_installed = {
            "goimports",
            "goimports-reviser",
            "golangci-lint",
            "prettierd",
            "eslint-lsp",
            "shfmt",
            "clang-format",
            "ast-grep",
            "golines",
            "delve",
            "gofumpt",
            "stylua",
            "ruff",
            "debugpy",
            "fd",
            "yamlfmt",
            "sleek",
            "shellcheck",
            "hadolint",
            "actionlint",
        }

        if registry_refresh_due() then
            local registry = require("mason-registry")
            registry.refresh(function()
                mark_registry_refreshed()
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
        end
    end,
}
