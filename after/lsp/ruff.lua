local python = require("core.python")

local function apply_ruff_settings(config, root)
    python.apply_ruff_init_options(config, root or config.root_dir)
end

return {
    root_markers = python.root_markers,
    before_init = function(_, config)
        apply_ruff_settings(config, config.root_dir)
    end,
    on_new_config = apply_ruff_settings,
    on_attach = function(client)
        -- Hover 交给 basedpyright，避免两个 Python LSP 抢同一个能力。
        client.server_capabilities.hoverProvider = false
    end,
}
