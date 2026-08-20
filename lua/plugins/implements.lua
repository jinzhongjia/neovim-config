-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- goplements / tsplements — 仓库自带的两个脚本（plugin/golement.lua、
-- plugin/tslement.lua），给 interface / struct 打上行尾虚拟文本：
--   Go：implements: / implemented by:     TS：同名的实现列表
-- 纯 treesitter + LSP，零外部依赖。
--
-- 两个脚本开头都有 vim.g.__load_* 守卫，所以 Neovim 对 plugin/ 目录的
-- 自动 source 只是空转；真正加载放到首次打开对应 filetype 时 dofile，
-- 启动路径上一分钱不花。FileType 先于 LspAttach，脚本自己的 LspAttach
-- 回调仍能赶上第一个 buffer 的首次标注。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local group = vim.api.nvim_create_augroup("ImplementsLazy", { clear = true })

local function lazy_load(flag, script, filetypes)
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = filetypes,
        once = true,
        callback = function()
            vim.g[flag] = true
            dofile(vim.fn.stdpath("config") .. "/plugin/" .. script)
            vim.g[flag] = nil
        end,
    })
end

lazy_load("__load_goplements", "golement.lua", "go")
lazy_load("__load_tsplements", "tslement.lua", { "typescript", "typescriptreact" })
