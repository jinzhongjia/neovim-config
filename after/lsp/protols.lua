-- Protols: Protocol Buffer Language Server
-- Handles .proto file syntax highlighting, completion, diagnostics, and navigation
return {
    -- 检测项目根目录的标记
    root_markers = { "protols.toml", "buf.yaml", "proto", ".git" },
    -- 动态配置 include_paths，使 protols 能找到所有 proto 导入
    before_init = function(_, config)
        -- 优先级：protols.toml > init_options > CLI args
        config.init_options = {
            include_paths = {
                -- proto 是标准目录（项目根会自动检测）
                "proto",
                -- 也尝试当前工作目录
                ".",
            },
        }
    end,
    settings = {
        protols = {
            enable = true,
        },
    },
}
