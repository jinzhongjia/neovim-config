return
--- @type LangSpec
{
    lsp = "rust_analyzer",
    opt = nil,
    others = nil,
    before_set = nil,
    after_set = nil,
    plugins = {
        {
            "mrcjkb/rustaceanvim",
            version = "^5", -- Recommended
            lazy = false, -- This plugin is already lazy
            inif = function()
                vim.g.rustaceanvim = {
                    -- Plugin configuration
                    tools = {},
                    -- LSP configuration
                    server = {
                        default_settings = {
                            ["rust-analyzer"] = {
                                settings = {
                                    ["rust-analyzer"] = {
                                        imports = {
                                            granularity = {
                                                group = "module",
                                            },
                                            prefix = "self",
                                        },
                                        cargo = {
                                            buildScripts = {
                                                enable = true,
                                            },
                                        },
                                        procMacro = {
                                            enable = true,
                                        },
                                    },
                                },
                            },
                        },
                    },
                    -- DAP configuration
                    dap = {},
                }
            end,
        },
    },
}
