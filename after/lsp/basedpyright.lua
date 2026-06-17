local python = require("core.python")

local function apply_python_settings(config, root)
    python.apply_lsp_settings(config, root)
end

return {
    root_markers = python.root_markers,
    before_init = function(_, config)
        apply_python_settings(config, config.root_dir)
    end,
    on_new_config = apply_python_settings,
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "standard",
            },
        },
    },
}
