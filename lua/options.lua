option = vim.opt
option.clipboard = "unnamedplus"
option.completeopt = {"menu", "menuone", "noselect"}
option.mouse = 'a'

-- Tab
option.tabstop = 4 --number of visual spaces per TAB
option.softtabstop = 4 -- number of spacesin tab when editing
option.shiftwidth = 4 -- insert 4 spaces on a tab
option.expandtab = true -- tabs are spaces, mainly because of python

-- UI config
option.number = true
option.relativenumber = true
option.splitbelow = true
option.autochdir = true
option.undofile = true
option.termguicolors = true
option.cursorline = true
option.signcolumn = "yes"

-- Searching
option.incsearch = true
option.ignorecase=true
option.smartcase = true

-- Highlight yanked text for 500ms
vim.api.nvim_create_autocmd({"TextYankPost"},{
    pattern = {"*"},
    callback = function()
        vim.highlight.on_yank({
            timeout = 500,
        })
    end,
})
