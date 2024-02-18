--- @param name string
local function get_efm_config(name)
    local status, config = pcall(require, string.format("efmls-configs.linters.%s", name))
    if not status then
        vim.notify(string.format("not found %s", name))
        return {}
    end
    return config
end

local xo = get_efm_config("xo")
local stylelint = get_efm_config("stylelint")

local languages = {
    javascript = {
        xo,
        get_efm_config("js_standard"),
    },
    typescript = { xo,  },
    javascriptreact = { xo,  },
    typescriptreact = { xo,  },
    vue = { xo,  },
    css = {
        stylelint,
        
    },
    dockerfile = {
        get_efm_config("hadolint"),
    },
    go = {
        get_efm_config("golangci_lint"),
    },
    python = {
        get_efm_config("pylint"),
    },
    markdown = {
        get_efm_config("markdownlint"),
        get_efm_config("alex"),
    },
    yaml = {
        get_efm_config("actionlint"),
        get_efm_config("yamllint"),
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
        get_efm_config("vint"),
    },
    sh = {
        get_efm_config("shellcheck"),
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
