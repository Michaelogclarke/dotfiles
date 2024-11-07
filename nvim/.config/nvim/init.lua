-- Basic Neovim settings in Lua
vim.opt.number = true      -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.tabstop = 2        -- Number of spaces for a tab
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.shiftwidth = 2     -- Indent size



-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
-- Setup lazy.nvim
require("lazy").setup({
  spec = {
 { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },    -- Better syntax highlighting
  { "nvim-lualine/lualine.nvim" },                              -- Statusline

  -- telescope setup
  {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'jonarrien/telescope-cmdline.nvim',
  },
  keys = {
    { ':', '<cmd>Telescope cmdline<cr>', desc = 'Cmdline' }
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension('cmdline')
  end,
},

{
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
    }
  end,
  dependencies = { {'nvim-tree/nvim-web-devicons'}}
},

  -- LSP (Language Server Protocol)
  { "neovim/nvim-lspconfig" },                                  -- Basic LSP setup
  { "hrsh7th/nvim-cmp" },                                       -- Autocompletion plugin
  { "L3MON4D3/LuaSnip" },                                      -- Snippets
 
  {
    "neovim/nvim-lspconfig",
    config = function()
      require('laspconfig').setup()
    end
  },


  -- Add this to your Lazy.nvim setup
{
  'neoclide/coc.nvim',
  branch = 'release',
  config = function()
    -- Coc specific configuration
    vim.cmd([[
      " Use <Tab> for trigger completion and navigate to the next complete item
      inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
      inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

      " Use <CR> to confirm completion, `<C-g>u` means break undo chain at current position
      inoremap <silent><expr> <CR> coc#pum#visible() ? coc#_select_confirm()
                                        \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

      " Trigger completion automatically
      let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-python']

      " Configure popup behavior
      let g:coc_suggest_autoTrigger = 'always'
      let g:coc_suggest_triggerCompletionWait = 0
      let g:coc_suggest_minTriggerInputLength = 1
    ]])
  end
},
-- Add this to your Lazy.nvim setup
  -- Git integration
{
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "sindrets/diffview.nvim",        -- optional - Diff integration
  },
  config = true
},


-- File Explorer
  { "nvim-tree/nvim-tree.lua" },                                -- File explorer

 -- Catppuiccin
  {"catppuccin/nvim", name = "catppuccin", priority = 1000,
   config = function()
     vim.cmd.colorscheme "catppuccin-mocha"
   end,}
 }, 
 -- end of plugins
 
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  
  -- automatically check for plugin updates
  checker = { enabled = true },
})
-- Catppuccin specific config
require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
   })
-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  ensure_installed = "maintained", -- Auto-install maintained parsers
}

-- Lualine configuration
require('lualine').setup({
  options = { theme = 'catppuccin' }
})

-- Telescope configuration
local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
    },
  }
}

-- Nvim-Tree configuration
require("nvim-tree").setup()

-- Basic LSP setup
local lspconfig = require('lspconfig')
lspconfig.tsserver.setup{}   -- Example LSP setup for TypeScript/JavaScript

-- Autocompletion configuration
local cmp = require'cmp'
cmp.setup({
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  })
})


-- Telescope keybindings
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<CR>', { noremap = true })


-- Nvim-Tree keybinding
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Split window navigation
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader><leader>', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
-- Noice keybinds
vim.keymap.set("n", "<leader>nl", function()
  require("noice").cmd("last")
end)

vim.keymap.set("n", "<leader>nh", function()
  require("noice").cmd("history")
end)
