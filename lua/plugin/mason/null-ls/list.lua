local code_actions = "code_actions"
local completion = "completion"
local diagnostics = "diagnostics"
local formatting = "formatting"
local hover = "hover"

--- @type { name:string, auto_install:boolean, methods:("code_actions"|"completion"|"diagnostics"|"formatting"|"hover")[]}[]
local list = {
    {
        name = "actionlint",
        auto_install = true,
        methods = { diagnostics },
    },
    {
        name = "markdownlint",
        auto_install = true,
        methods = {
            diagnostics,
        },
    },
}

return list
