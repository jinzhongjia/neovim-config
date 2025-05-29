return
--- @type LangSpec
{
    lsp = "pylsp",
    opt = {
        settings = {
            pylsp = {
                configurationSources = { "flake8" },

                plugins = {
                    -- pyflakes配置（默认已启用）
                    pyflakes = {
                        enabled = true,
                    },

                    -- pydocstyle配置（默认禁用，需要手动启用）
                    pydocstyle = {
                        enabled = true,
                        convention = "numpy", -- 可选值: "pep257", "numpy", "google"
                    },

                    -- yapf配置（需要禁用autopep8）
                    autopep8 = {
                        enabled = false, -- 禁用autopep8以使用yapf
                    },
                    yapf = {
                        enabled = true,
                    },

                    -- flake8配置
                    flake8 = {
                        enabled = true,
                        maxLineLength = 100, -- 最大行长度
                        ignore = { "E203", "W503" }, -- 忽略的错误代码
                        select = { "E", "F", "W", "C" }, -- 启用的错误类别
                    },

                    -- pylint配置
                    pylint = {
                        enabled = true,
                    },

                    -- 其他常用插件配置
                    pycodestyle = {
                        enabled = true, -- 保持启用以获取基本的PEP 8检查
                        maxLineLength = 100,
                    },
                },
            },
        },
    },
    others = {
        -- "black",
        -- "isort",
        "pyflakes",
        "pydocstyle",
        "yapf",
        "flake8",
        "pylint",
    },
    before_set = nil,
    after_set = nil,
    lint = {},
}
