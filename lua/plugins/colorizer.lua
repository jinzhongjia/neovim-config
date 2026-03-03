return
--- @type LazySpec
{
    {
        "catgoose/nvim-colorizer.lua",
        ft = { "html", "css" },
        opts = {
            filetypes = {
                "html", -- 仅在 html/css 文件中启用
                "css",
                "!vim", -- 排除 vim 文件类型
            },
            options = {
                parsers = {
                    css = false,
                    css_fn = true,
                    names = {
                        enable = true,
                        lowercase = true,
                        camelcase = true,
                        uppercase = false,
                    },
                    hex = {
                        rgb = true,
                        rgba = true,
                        rrggbb = true,
                        rrggbbaa = false,
                        aarrggbb = false,
                    },
                    rgb = { enable = true },
                    hsl = { enable = true },
                    oklch = { enable = true },
                    tailwind = { enable = true, lsp = false },
                    sass = { enable = false, parsers = { css = true } },
                    xterm = { enable = false },
                },
                display = {
                    mode = "background",
                    virtualtext = {
                        char = "■",
                        position = "eol",
                    },
                },
                always_update = true,
            },

            -- 用户命令配置
            user_commands = false, -- 启用全部命令

            -- 懒加载配置
            lazy_load = true,
        },
    },
}
