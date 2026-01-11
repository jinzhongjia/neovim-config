-- zls: Zig Language Server
return {
    settings = {
        zls = {
            -- 启用 inlay hints
            enable_inlay_hints = true,
            inlay_hints_show_builtin = true,
            inlay_hints_exclude_single_argument = true,
            inlay_hints_hide_redundant_param_names = true,
            inlay_hints_hide_redundant_param_names_last_token = true,
            -- 启用语义令牌
            semantic_tokens = "full",
            -- 警告风格（用于编译器诊断）
            warn_style = true,
            -- 高亮全局变量
            highlight_global_var_declarations = true,
        },
    },
}
