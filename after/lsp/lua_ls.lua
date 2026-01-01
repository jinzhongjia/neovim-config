-- ~/.config/nvim/after/lsp/lua_ls.lua
-- lazydev.nvim 会自动处理工作区配置，无需手动设置 library 路径
return {
    settings = {
        Lua = {
            -- 运行时配置
            runtime = {
                version = "LuaJIT",
            },
            -- 诊断配置
            diagnostics = {
                -- 将 'vim' 识别为全局变量（避免未定义变量的警告）
                globals = { "vim" },
            },
            -- 工作区配置
            -- lazydev.nvim 会自动管理 workspace.library，无需手动配置
            workspace = {
                checkThirdParty = false,
            },
            -- 完成配置
            completion = {
                callSnippet = "Replace",
            },
            -- 遥测配置
            telemetry = {
                enable = false,
            },
        },
    },
}

