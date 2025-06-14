return {
  "ThePrimeagen/harpoon",
  commit = "4f9c65e",  -- Known stable Harpoon v1 commit
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon_mark = require("harpoon.mark")
    local harpoon_ui = require("harpoon.ui")

    vim.keymap.set("n", "<leader>a", harpoon_mark.add_file)
    vim.keymap.set("n", "<C-e>", harpoon_ui.toggle_quick_menu)

    vim.keymap.set("n", "<C-h>", function() harpoon_ui.nav_file(1) end)
    vim.keymap.set("n", "<C-t>", function() harpoon_ui.nav_file(2) end)
    vim.keymap.set("n", "<C-n>", function() harpoon_ui.nav_file(3) end)
    vim.keymap.set("n", "<C-s>", function() harpoon_ui.nav_file(4) end)
  end
}

