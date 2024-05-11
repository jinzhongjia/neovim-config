if vim.g.neovide then
    vim.o.pumblend = 45
    local home = vim.fn.expand("~")
    vim.fn.chdir(home)

    vim.o.guifont = "Maple Mono SC NF:h15"

    vim.g.neovide_input_ime = false
    local function set_ime(args)
        if args.event:match("Enter$") then
            vim.g.neovide_input_ime = true
        else
            vim.g.neovide_input_ime = false
        end
    end

    local ime_input = vim.api.nvim_create_augroup("ime_input", { clear = true })

    vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
        group = ime_input,
        pattern = "*",
        callback = set_ime,
    })

    vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
        group = ime_input,
        pattern = "[/\\?]",
        callback = set_ime,
    })

    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0

    vim.g.neovide_floating_blur_amount_x = 2.0
    vim.g.neovide_floating_blur_amount_y = 2.0

    vim.g.neovide_transparency = 0.9

    vim.g.neovide_hide_mouse_when_typing = true

    vim.g.neovide_refresh_rate = 144

    vim.g.neovide_refresh_rate_idle = 5
    vim.g.neovide_no_idle = true

    vim.g.neovide_fullscreen = false

    vim.g.neovide_remember_window_size = true

    vim.g.neovide_cursor_antialiasing = true

    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_floating_shadow = false
end
