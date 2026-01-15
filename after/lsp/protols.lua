-- Protols: Protocol Buffer Language Server
-- Handles .proto file syntax highlighting, completion, diagnostics, and navigation
return {
    -- Initialize with include_paths to help protols find imported proto files
    init_options = {
        include_paths = {
            -- Add your proto directories here
            -- Examples:
            -- "proto",
            -- "vendor/protos",
            -- "third_party/proto",
        },
    },
    settings = {
        protols = {
            -- Enable protols features
            enable = true,
        },
    },
}
