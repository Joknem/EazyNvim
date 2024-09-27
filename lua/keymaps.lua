local opts = {
    noremap = true,
    silent = true
}
local keymaps = vim.keymap
-- Normal mode
vim.g.mapleader = " "
keymaps.set('n', "<leader>-", "<C-w>s")
keymaps.set('n', "<leader>\\", "<C-w>v")
keymaps.set('n', "<leader>x", "<C-w>q")
keymaps.set('n', '<leader>h', "<C-w>h")
keymaps.set('n', '<leader>l', "<C-w>l")
keymaps.set('n', '<leader>k', "<C-w>k")
keymaps.set('n', '<leader>j', "<C-w>j")
keymaps.set('n', '<leader>[', '<C-o>', opt)
keymaps.set('n', '<leader>]', '<C-i>', opt)
keymaps.set('n', '<leader>s', ':w<CR>', opt)
keymaps.set('n', '<leader>gun', ':q!<CR>', opt)
keymaps.set('n', '<leader>nh', ':nohlsearch<CR>', opt)

-- Insert mode
keymaps.set('i', "jk", "<Esc>")

