return
--- @type LazySpec
{
    {
        "catgoose/nvim-colorizer.lua",
        event = "BufReadPre",
        opts = {
            filetypes = {
                "*", -- 为所有文件类型启用
                "!vim", -- 排除 vim 文件类型
            },
            user_default_options = {
                -- 基础颜色格式
                names = true, -- 支持 CSS 颜色名（Blue, red 等）
                RGB = true, -- #RGB 格式
                RGBA = true, -- #RGBA 格式
                RRGGBB = true, -- #RRGGBB 格式
                RRGGBBAA = false, -- #RRGGBBAA 格式
                AARRGGBB = false, -- 0xAARRGGBB 格式

                -- CSS 函数支持
                css = false, -- 不启用全部 CSS 特性（使用下面的细粒度控制）
                css_fn = true, -- 启用 CSS 函数（rgb, hsl, oklch 等）
                rgb_fn = true, -- CSS rgb() 和 rgba() 函数
                hsl_fn = true, -- CSS hsl() 和 hsla() 函数
                oklch_fn = true, -- CSS oklch() 函数

                -- Tailwind 支持
                tailwind = "normal", -- 使用标准 Tailwind 颜色

                -- Sass 支持
                sass = { enable = false, parsers = { "css" } },

                -- Xterm 256 色支持
                xterm = false,

                -- 名称选项
                names_opts = {
                    lowercase = true, -- 小写匹配（blue）
                    camelcase = true, -- 驼峰匹配（Blue）
                    uppercase = false, -- 不启用大写匹配
                },

                -- 显示模式：background（背景）| foreground（前景）| virtualtext（虚拟文本）
                mode = "background",

                -- 虚拟文本配置
                virtualtext = "■", -- 虚拟文本字符
                virtualtext_inline = false, -- 不内联显示虚拟文本

                -- 其他配置
                always_update = true, -- 仅在缓冲区获得焦点时更新
            },

            -- 用户命令配置
            user_commands = false, -- 启用全部命令

            -- 懒加载配置
            lazy_load = true,
        },
    },
}
