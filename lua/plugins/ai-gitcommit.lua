local work_opts = {
    provider = "openai",
    languages = { "English", "Chinese" },
    providers = {
        openai = {
            api_key = vim.env.LLAMA_API_KEY,
            model = "Llama-3.3-70B-Instruct",
            endpoint = "https://api.llama.com/compat/v1/chat/completions",
        },
    },
}

local my_opts = {
    provider = "anthropic",
    languages = { "English", "Chinese" },
}

local opts = {}

if vim.env.IS_WORK_DEVICE then
    opts = work_opts
else
    opts = my_opts
end

print("is work device: ", vim.env.IS_WORK_DEVICE)

return {
    "jinzhongjia/ai-gitcommit.nvim",
    dev = true,
    event = "VeryLazy",
    opts = my_opts,
}
