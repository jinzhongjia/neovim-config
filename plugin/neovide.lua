if not vim.g.neovide then
    return
end
local o, g, fn, api = vim.o, vim.g, vim.fn, vim.api

-- cd home
fn.chdir(fn.expand("~"))

o.pumblend = 45
o.guifont = "Maple Mono NF:h12"

-- disable input ime
g.neovide_input_ime = false

local function set_ime(args)
    if args.event:match("Enter$") then
        g.neovide_input_ime = true
        return
    end
    g.neovide_input_ime = false
end

local ime_input = api.nvim_create_augroup("ime_input", { clear = true })

api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    group = ime_input,
    pattern = "*",
    callback = set_ime,
})

api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    group = ime_input,
    pattern = "[/\\?]",
    callback = set_ime,
})

g.neovide_padding_top = 0
g.neovide_padding_bottom = 0
g.neovide_padding_right = 0
g.neovide_padding_left = 0

g.neovide_floating_blur_amount_x = 2.0
g.neovide_floating_blur_amount_y = 2.0

g.neovide_opacity = 0.9
g.transparency = 0.9

g.neovide_hide_mouse_when_typing = true

g.neovide_refresh_rate = 144

g.neovide_refresh_rate_idle = 5
g.neovide_no_idle = true

g.neovide_fullscreen = false

g.neovide_remember_window_size = true

g.neovide_cursor_antialiasing = true

g.neovide_cursor_animation_length = 0
g.neovide_floating_shadow = false
