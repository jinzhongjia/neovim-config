--- @param name string
--- @param is_fmt boolean
local function get_efm_config(name, is_fmt)
    local status, config =
        pcall(require, string.format("efmls-configs.%s.%s", is_fmt and "formatters" or "linters", name))
    if not status then
        vim.notify(string.format("not found %s", name))
        return {}
    end
    return config
end

local eslint_d = get_efm_config("eslint_d", false)
local stylelint = get_efm_config("stylelint", false)

local languages = {
    javascript = {
        eslint_d,
        get_efm_config("js_standard", false),
    },
    typescript = { eslint_d },
    javascriptreact = { eslint_d },
    typescriptreact = { eslint_d },
    vue = { eslint_d },
    lua = {
        get_efm_config("stylua", true),
        get_efm_config("luacheck", false),
    },
    css = {
        stylelint,
    },
    dockerfile = {
        get_efm_config("hadolint", false),
    },
    go = {
        get_efm_config("golangci_lint", false),
    },
    python = {
        get_efm_config("pylint", false),
    },
    markdown = {
        get_efm_config("markdownlint", false),
        get_efm_config("alex", false),
    },
    yaml = {
        get_efm_config("actionlint", false),
    },
    less = {
        stylelint,
    },
    sass = {
        stylelint,
    },
    scss = {
        stylelint,
    },

    vim = {
        get_efm_config("vint", false),
    },
}

local opt = {
    filetypes = vim.tbl_keys(languages),
    settings = {
        rootMarkers = { ".git" },
        languages = languages,
    },
    init_options = {
        documentFormatting = false,
        documentRangeFormatting = false,
    },
    single_file_support = true,
}

return opt

