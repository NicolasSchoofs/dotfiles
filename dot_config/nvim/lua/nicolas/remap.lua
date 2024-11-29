vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.api.nvim_set_option("clipboard","unnamed")

vim.keymap.set('n', '<leader>f', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], 
  { noremap = true, silent = false, desc = "Find and replace word under cursor" })

