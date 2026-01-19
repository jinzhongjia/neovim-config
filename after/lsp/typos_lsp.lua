-- typos-lsp: 拼写检查 LSP
-- https://github.com/tekumara/typos-lsp
return {
    -- 初始化选项
    init_options = {
        -- 自定义配置文件路径 (可选)
        -- config = "~/.config/typos.toml",
        -- 诊断严重级别: Error, Warning, Information, Hint
        diagnosticSeverity = "Hint",
    },
}
