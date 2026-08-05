-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Auto pairs — blink.pairs (Rust matcher, syntax-aware)
-- download() is the documented vim.pack path: fetches the prebuilt
-- binary matching the pinned tag, no-op when already current.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("blink.pairs").download():pwait(60000)
require("blink.pairs").setup()
