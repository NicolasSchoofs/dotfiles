require('neo-tree').setup {
  close_if_last_window = true,  
  open_on_setup = false,        
  open_on_setup_file = false,   
  auto_open = false,            
  filesystem = {
    hijack_netrw_behavior = "disabled", 
  },
}

vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true, desc = "Toggle Neo-tree" })
vim.keymap.set('n', '<leader>o', ':Neotree focus<CR>', { noremap = true, silent = true, desc = "Focus Neo-tree" })
vim.keymap.set('n', '<leader>r', ':Neotree reveal<CR>', { noremap = true, silent = true, desc = "Reveal current file in Neo-tree" })
