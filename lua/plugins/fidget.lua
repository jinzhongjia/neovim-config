return {
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        init = function()
            local codecompanion_progress = nil

            vim.api.nvim_create_autocmd("User", {
                pattern = "CodeCompanionRequest*",
                group = vim.api.nvim_create_augroup("FidgetCodeCompanion", { clear = true }),
                callback = function(request)
                    local progress = require("fidget.progress")

                    if request.match == "CodeCompanionRequestStarted" then
                        codecompanion_progress = progress.handle.create({
                            title = "CodeCompanion",
                            message = "Thinking...",
                            lsp_client = { name = "CodeCompanion" },
                            percentage = 0,
                        })
                    elseif request.match == "CodeCompanionRequestFinished" and codecompanion_progress then
                        codecompanion_progress:report({ message = "Done", percentage = 100 })
                        codecompanion_progress:finish()
                        codecompanion_progress = nil
                    end
                end,
            })
        end,
        opts = {
            notification = {
                window = {
                    avoid = { "NvimTree" },
                },
            },
        },
    },
}
