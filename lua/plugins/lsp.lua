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
        bashls = {},
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

        nmap("gd", vim.lsp.buf.definition, "Open definition")
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
            winhighlight = 'normal:pmenu,floatborder:pmenu,search:none',
            col_offset = -3,
            side_padding = 0,
            border = 'rounded',
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
          format = function(entry, vim_item)
            local kind = require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, '%s', { trimempty = true })
            kind.kind = ' ' .. (strings[1] or '') .. ' '
            kind.menu = ' ' .. (strings[2] or '')
            return kind
          end
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        sources = cmp.config.sources({
          { name = "jupynium", priority = 1000 },
          { name = 'copilot',  priority = 100 },
          { name = 'luasnip',  priority = 100 },
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
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
        }),
        experimental = {
          ghost_text = true,
        },
      })
    end,
  },
  -- function argments display --
  {
    "ray-x/lsp_signature.nvim",
    opts = {},
    config = function(_, opts)
      local cfg = {
        debug = false,                                              -- set to true to enable debug logging
        log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
        -- default is  ~/.cache/nvim/lsp_signature.log
        verbose = false,                                            -- show debug line number

        bind = true,                                                -- This is mandatory, otherwise border config won't get registered.
        -- If you want to hook lspsaga or other signature handler, pls set to false
        doc_lines = 10,                                             -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
        -- set to 0 if you DO NOT want any API comments be shown
        -- This setting only take effect in insert mode, it does not affect signature help in normal
        -- mode, 10 by default

        max_height = 12,                       -- max height of signature floating_window
        max_width = 80,                        -- max_width of signature floating_window, line will be wrapped if exceed max_width
        -- the value need >= 40
        wrap = true,                           -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
        floating_window = true,                -- show hint in a floating window, set to false for virtual text only mode

        floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
        -- will set to true when fully tested, set to false will use whichever side has more space
        -- this setting will be helpful if you do not want the PUM and floating win overlap

        floating_window_off_x = 1,                   -- adjust float windows x position.
        -- can be either a number or function
        floating_window_off_y = function()           -- adjust float windows y position. e.g. set to -2 can make floating window move up 2 lines
          local linenr = vim.api.nvim_win_get_cursor(0)[1] -- buf line number
          local pumheight = vim.o.pumheight
          local winline = vim.fn.winline()           -- line number in the window
          local winheight = vim.fn.winheight(0)

          -- window top
          if winline - 1 < pumheight then
            return pumheight
          end

          -- window bottom
          if winheight - winline < pumheight then
            return -pumheight
          end
          return 0
        end, 
        close_timeout = 200, -- close floating window after ms when laster parameter is entered
        fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
        hint_enable = true, -- virtual hint enable
        hint_prefix = "🐼  ", -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
        hint_scheme = "String",
        hint_inline = function() return false end, -- should the hint be inline(nvim 0.10 only)?  default false
        -- return true | 'inline' to show hint inline, return 'eol' to show hint at end of line, return false to disable
        -- return 'right_align' to display hint right aligned in the current line
        hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
        handler_opts = {
          border = "rounded"                          -- double, rounded, single, shadow, none, or a table of borders
        },

        always_trigger = false,                   -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

        auto_close_after = nil,                   -- autoclose signature float win after x sec, disabled if nil.
        extra_trigger_chars = {},                 -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
        zindex = 200,                             -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

        padding = '',                             -- character to pad on left and right of signature can be ' ', or '|'  etc

        transparency = nil,                       -- disabled by default, allow floating win transparent value 1~100
        shadow_blend = 36,                        -- if you using shadow as border use this set the opacity
        shadow_guibg = 'Black',                   -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
        timer_interval = 10,                      -- default timer check interval set to lower value if you want to reduce latency
        toggle_key = nil,                         -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
        toggle_key_flip_floatwin_setting = false, -- true: toggle floating_windows: true|false setting after toggle key pressed
        -- false: floating_windows setup will not change, toggle_key will pop up signature helper, but signature
        -- may not popup when typing depends on floating_window setting

        select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
        move_cursor_key = nil,      -- imap, use nvim_set_current_win to move cursor between current win and floating
      }

      -- recommended:
      require 'lsp_signature'.setup(cfg) -- no need to specify bufnr if you don't use toggle_key
    end
  },
}
