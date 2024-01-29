if vim.g.neovide then
    local home = vim.fn.expand("~")
    vim.fn.chdir(home)

    if vim.fn.has("win32") == 1 then
        vim.o.guifont = "Maple Mono SC NF:h15"
    elseif vim.fn.has("linux") == 1 then
        local xdg_session = os.getenv("XDG_SESSION_TYPE")
        if xdg_session == "x11" then
            vim.o.guifont = "Maple Mono NF:h11"
        else
            vim.o.guifont = "Maple Mono NF:h15"
        end
    end

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

    vim.g.neovide_fullscreen = false

    vim.g.neovide_remember_window_size = true

    vim.g.neovide_cursor_antialiasing = true

    vim.g.neovide_input_ime = true

    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_floating_shadow = false
end
