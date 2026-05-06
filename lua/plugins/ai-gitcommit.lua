local languages = { "English", "Chinese" }
-- local work_opts = {
--     provider = "openai",
--     languages = languages,
--     providers = {
--         openai = {
--             api_key = vim.env.LLAMA_API_KEY,
--             model = vim.env.LLAMA_MODEL,
--             endpoint = vim.env.LLAMA_ENDPOINT,
--         },
--     },
-- }

local my_opts = {
    languages = languages,
}

-- local opts = {}
local opts = my_opts

-- if vim.env.IS_WORK_DEVICE then
--     opts = work_opts
-- else
--     opts = my_opts
-- end

return {
    "jinzhongjia/ai-gitcommit.nvim",
    dev = true,
    event = "VeryLazy",
    opts = opts,
}
