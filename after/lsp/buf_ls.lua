-- Buf LSP 配置 (Protocol Buffers)
return {
    -- 不复用 client，每个 buffer 启动独立的 LSP 实例
    reuse_client = false,
}

