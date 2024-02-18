local status, lint = pcall(require, "lint")
if not status then
    vim.notify("not found nvim-lint")
    return
end

lint.linters_by_ft = {
    javascript = { "eslint_d", "standardjs" },
    typescript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    svelte = { "eslint_d" },
    python = { "pylint" },
    yaml = { "actionlint" },
    markdown = { "alex", "markdownlint" },
    go = { "golangcilint" },
    json = { "jsonlint" },
    dockerfile = { "hadolint" },
    lua = { "luacheck" },
    css = { "stylelint" },
    vim = { "vint" },
}

local all_run = {
    "codespell",
    "typos",
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

local run_lint = function()
    lint.try_lint()
    for _, val in pairs(all_run) do
        lint.try_lint(val)
    end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = run_lint,
    desc = "autocmd for nvim-lint",
})

vim.api.nvim_create_user_command("Lint", run_lint, {
    desc = "command for nvim-lint",
})
