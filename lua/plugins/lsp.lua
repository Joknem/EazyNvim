return {
  {
    'neovim/nvim-lspconfig',
    ft = vim.g.fts,
    dependencies = {
      'folke/neodev.nvim',
      'nvimdev/lspsaga.nvim',
    },
    config = function()
      local servers = {
        clangd = {},
        pyright = {},
      }
      local on_attach = function(_, bufnr)
        local nmap = function(keys, func, desc)
          if desc then
            desc = 'LSP: ' .. desc
          end
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end
        nmap("<leader>mm", "<cmd>Lspsaga term_toggle<CR>", "Open terminal")
        nmap('gpd', '<cmd>Lspsaga peek_definition<CR>', 'Peek Definition')
        nmap('gpr', '<cmd>Telescope lsp_references<CR>', 'Peek References')
        nmap('<s-k>', '<cmd>Lspsaga hover_doc<CR>', 'Hover Documentation')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, 'Workspace Add Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Workspace Remove Folder')
        nmap('<leader>wl', function()
          vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, 'Workspace List Folders')
        nmap('<leader>rn', '<cmd>Lspsaga rename ++project<cr>', 'Rename')
        nmap('<leader>ca', '<cmd>Lspsaga code_action<CR>', 'Code Action')
        nmap('<leader>ot', '<cmd>Lspsaga outline<CR>', 'OutLine')
        nmap('d[', vim.diagnostic.goto_prev, 'Diangostics Prev')
        nmap('d]', vim.diagnostic.goto_next, 'Diangostics Next')
      end

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require('neodev').setup({
        lspconfig = true,
        override = function(_, library)
          library.enabled = true
          library.plugins = true
          library.types = true
        end,
      })

      require('lspsaga').setup({
        outline = {
          keys = {
            quit = 'Q',
          }
        },
        finder = {
          keys = {
            quit = 'Q',
            edit = '<C-o>',
            toggle_or_open = '<CR>',
          },
        },
        definition = {
          keys = {
            edit = '<C-o>',
            vsplit = '<c-v>',
          }
        },
        code_action = {
          keys = {
            quit = 'Q',
          }
        },
        hover_doc = {
          keys = 'K',
        },
      })

      for server, config in pairs(servers) do
        require('lspconfig')[server].setup(vim.tbl_deep_extend('keep', {
          on_attach = on_attach,
          capabilities = capabilities,
        }, config))
      end

      vim.diagnostic.config({
        virtual_text = {
          prefix = '❯',
        }
      })

      vim.api.nvim_create_autocmd('CursorHold', {
        callback = function()
          local opts = {
            focusable = false,
            close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
          }
          vim.diagnostic.open_float(nil, opts)
        end
      })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    lazy = true,
    event = 'LspAttach',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      {
        'saadparwaiz1/cmp_luasnip',
        dependencies = {
          'L3MON4D3/LuaSnip',
        },
      },
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'onsails/lspkind.nvim',
      "zbirenbaum/copilot.lua",
      "zbirenbaum/copilot-cmp",
    },
    config = function()
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
            and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end
      require('luasnip.loaders.from_snipmate').lazy_load()
      local luasnip = require('luasnip')
      local cmp = require('cmp')
      cmp.setup({
        window = {
          completion = {
            col_offset = -3,
            side_padding = 0,
            border = 'rounded',
            winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:MyCmpSel",
            scrollbar = true,
          },
          documentation = {
            winhighlight = 'normal:pmenu,floatborder:pmenu,search:none',
            border = 'rounded',
            scrollbar = true,
          },
        },
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          expandable_indicator = false,
          format = function(entry, vim_item)
            local kind = require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, '%s', { trimempty = true })
            kind.kind = ' ' .. (strings[1] or '') .. ' '
            kind.menu = ' ' .. (strings[2] or '')
            return kind
          end,
        },
        sources = cmp.config.sources({
          { name = 'copilot',  priority = 100 },
          { name = 'nvim_lsp', priority = 100 },
          { name = 'nvim_lua', priority = 100 },
          { name = 'path',     priority = 100 },
          { name = 'buffer',   priority = 100 },
        }),
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        experimental = {
          ghost_text = true,
        },
      })
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    config = function()
        require('lsp_signature').setup{
            bind = true,
            doc_lines = 0,
            floating_window = true,
            hint_enable = true,
            hint_prefix = "🐼  ",
            hi_parameter = "LspSignatureActiveParameter",
            max_height = 12,
            max_width = 80,
            handler_opts = {
                border = "single",
            },
            zindex = 200,
            padding = "",
            debug = false,
            log_path = "debug_log_file",
            timer_interval = 200,
            transparency = nil
        }
    end
  }
}
