return
--- @type LangSpec
{
    lsp = "phpactor",
    opt = {},
    others = {
        "php-cs-fixer", -- PHP 代码格式化工具
        "phpstan", -- PHP 静态分析工具
        "psalm", -- PHP 静态分析工具（可选）
    },
    before_set = nil,
    after_set = nil,
    lint = {},
}
