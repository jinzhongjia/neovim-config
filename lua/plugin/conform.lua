local status, conform = pcall(require, "conform")
if not status then
    vim.notify("not found conform")
    return
end

--- @param list {name:string,cmd:string}[]
--- @return string[]
local check = function(list)
    local res = {}
    for _, ele in pairs(list) do
        local cmd = ele.cmd or ele.name
        if not isNixos() or check_exec(cmd) then
            table.insert(res, ele.name)
        end
    end
    return res
end

conform.setup({
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
        nix = check({
            { name = "nixpkgs_fmt", cmd = "nixpkgs-fmt" },
        }),
    },
})
