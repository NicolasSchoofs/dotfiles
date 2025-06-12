return {
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup({
                use_diagnostic_signs = false,
            })

            vim.keymap.set("n", "<leader>tt", function()
                require("trouble").toggle("diagnostics")
            end)

            -- Helper function to jump to next diagnostic of specific severity
            local function goto_diagnostic(severity, direction)
                local opts = { severity = severity }
                if direction == "next" then
                    vim.diagnostic.goto_next(opts)
                else
                    vim.diagnostic.goto_prev(opts)
                end
            end

            -- Wrapped logic: try to jump to error first, fallback to warning
            local function goto_prioritized_diag(direction)
                local count_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                if count_errors > 0 then
                    goto_diagnostic(vim.diagnostic.severity.ERROR, direction)
                else
                    goto_diagnostic(vim.diagnostic.severity.WARN, direction)
                end
            end

            vim.keymap.set("n", "<leader>nn", function()
                goto_prioritized_diag("next")
            end, { desc = "Next prioritized diagnostic" })

            vim.keymap.set("n", "<leader>bb", function()
                goto_prioritized_diag("prev")
            end, { desc = "Previous prioritized diagnostic" })
        end
    },
}

