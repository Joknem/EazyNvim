return {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensured_installed = { "lua", "vim", "c", "cpp", "make", "markdown", "python", "verilog", "json" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            node_incremental = "v",
            node_decremental = "<BS>",
          },
        },
      })
    end,
}
