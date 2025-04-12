if not vim.g.vscode then
    -- add Config command to chdir cwd to config path
    vim.api.nvim_create_user_command("Config", function()
        --- @type string
        ---@diagnostic disable-next-line: assign-type-mismatch
        local config_path = vim.fn.stdpath("config")
        vim.fn.chdir(config_path)
    end, { desc = "command for config" })
end
