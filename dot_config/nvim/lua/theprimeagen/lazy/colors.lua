function ColorMyPencils(color)
    color = color or "gruvbox"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {

    -- TOKYONIGHT
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "moon",
                transparent = true,
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    sidebars = "dark",
                    floats = "dark",
                },
            })
        end,
    },

    -- EVERFOREST
    {
        "sainnhe/everforest",
        config = function()
            vim.g.everforest_enable_italic = false
            vim.g.everforest_background = "medium"
            vim.g.everforest_transparent_background = 1
        end,
    },

    -- GRUVBOX
    {
        "ellisonleao/gruvbox.nvim",
        config = function()
            require("gruvbox").setup({
                transparent_mode = true,
            })
            ColorMyPencils("gruvbox")
        end,
    },

    -- KANAGAWA
    {
        "rebelot/kanagawa.nvim",
        config = function()
            require("kanagawa").setup({
                transparent = true,
            })
        end,
    },

    -- ROSE PINE
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                disable_background = true,
            })
        end,
    },
}
