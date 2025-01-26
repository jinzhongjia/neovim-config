--- @param list {name:string,cmd:string}[]
--- @return string[]
local function check(list)
    local res = {}
    for _, ele in pairs(list) do
        local cmd = ele.cmd or ele.name
        if __check_exec(cmd) then
            table.insert(res, ele.name)
        end
    end
    return res
end

return
--- @type LazySpec
{
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            default_format_opts = {
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                c = check({
                    { name = "clang_format" },
                }),
                cpp = check({
                    { name = "clang_format" },
                }),
                go = check({
                    { name = "gofumpt" },
                    { name = "goimports-reviser" },
                }),
                html = check({
                    { name = "prettierd" },
                }),
                json = check({
                    { name = "prettierd" },
                }),
                jsonc = check({
                    { name = "prettierd" },
                }),
                rust = check({
                    { name = "rustfmt" },
                }),
                bash = check({
                    { name = "shfmt" },
                }),
                lua = check({
                    { name = "stylua" },
                }),
                javascript = check({
                    { name = "prettierd" },
                }),
                typescript = check({
                    { name = "prettierd" },
                }),
                javascriptreact = check({
                    { name = "prettierd" },
                }),
                typescriptreact = check({
                    { name = "prettierd" },
                }),
                vue = check({
                    { name = "prettierd" },
                }),
                python = check({
                    { name = "isort" },
                    { name = "black" },
                }),
                zig = check({
                    { name = "zigfmt", cmd = "zig" },
                }),
                markdown = check({
                    { name = "prettierd" },
                    { name = "cbfmt" },
                }),
                yaml = check({
                    { name = "yamlfmt" },
                }),
                xml = check({
                    { name = "xmlformat" },
                }),
            },
        },
        keys = {
            {
                -- Customize or remove this keymap to your liking
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
        init = function()
            -- If you want the formatexpr, here is the place to set it
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
}
