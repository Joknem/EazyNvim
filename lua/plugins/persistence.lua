return {
  "folke/persistence.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
  config = function()
      require("persistence").setup({
          dir = vim.fn.expand(vim.fn.stdpath("config") .. "/session/"),
          options = {"buffers", "curdir", "tabpages", "winsize"},
          pre_save = nil,
      })
  end,
  opts = {
    -- add any custom options here
    },
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
    { "<leader>a", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  }
}
