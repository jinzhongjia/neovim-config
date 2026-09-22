-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Auto pairs — blink.pairs (Rust matcher, syntax-aware)
-- lazy.nvim 构建时 require 也会触发配置，必须先准备原生库再 setup。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local pairs = require("blink.pairs")
if not pairs.library_available() then
    pairs.build():wait(60000)
end
pairs.setup()
