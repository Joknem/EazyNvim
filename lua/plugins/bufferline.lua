  return {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      { "<S-h>", ":BufferLineCyclePrev<CR>", opt },
      { "<S-l>", ":BufferLineCycleNext<CR>", opt },
      { "<C-w>", ":bdelete %<CR>",           opt },
    },
    config = function()
      require("bufferline").setup()
    end,
  }
