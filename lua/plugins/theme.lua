return {
  -- 'olivercederborg/poimandres.nvim',
  -- lazy = false,
  -- priority = 1000,
  -- config = function()
  --   require('poimandres').setup {
  --     -- leave this setup function empty for default config
  --     -- or refer to the configuration section
  --     -- for configuration options
  --   }
  -- end,
  --
  --
  -- -- optionally set the colorscheme within lazy config
  -- init = function()
  --   vim.cmd("colorscheme poimandres")
  -- end
  --
  -- 'ribru17/bamboo.nvim',
  -- lazy = false,
  -- priority = 1000,
  -- config = function()
  --   require('bamboo').setup {
  --     -- optional configuration here
  --   }
  --   require('bamboo').load()
  -- end,
  --
  --
  --
  --
  "rose-pine/neovim", 
  name = "rose-pine",
  init = function()
      vim.cmd('colorscheme rose-pine-dawn')
  end
  --
  --
}
