vim.opt.tabstop = 4        -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4     -- Number of spaces for auto-indent
vim.opt.expandtab = true   -- Convert tabs to spaces

vim.wo.number = true  -- Enable absolute line numbers
vim.wo.relativenumber = true  -- Enable relative line numbers

-- suggetions for commands
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

-- Always open terminal in the bottom split
vim.cmd([[
  autocmd BufWinEnter,WinNew term://* wincmd J
]])

-- Open new splits at the bottom
vim.opt.splitbelow = true
-- Open new vertical splits at the right
vim.opt.splitright = true


-- Bootstrap packer (if not installed)
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      'git', 'clone', '--depth', '1',
      'https://github.com/wbthomason/packer.nvim',
      install_path
    })
    vim.cmd('packadd packer.nvim')
  end
end
ensure_packer()

-- Load plugins with packer
require('packer').startup(function()
 -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- File explorer (modern replacement for NERDTree)
  use 'kyazdani42/nvim-tree.lua'
  use 'nvim-lua/plenary.nvim'  -- dependency for nvim-tree and telescope

  -- Telescope for file searching
  use 'nvim-telescope/telescope.nvim'

  -- Themes and UI
  use 'morhetz/gruvbox'
  use 'shaunsingh/nord.nvim'
  use 'folke/tokyonight.nvim'
  use 'catppuccin/nvim'

  -- Commenting utility
  use 'preservim/nerdcommenter'

  -- LSP and Treesitter
  use 'neovim/nvim-lspconfig'
  use 'nvim-treesitter/nvim-treesitter'

  -- Autocompletion plugins
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'

  -- Auto-pairs integration
  use 'windwp/nvim-autopairs'

  -- Debugging support
  use 'mfussenegger/nvim-dap'

end)

-- nvim-tree setup
require("nvim-tree").setup({
    update_focused_file = {
        enable = true,
        update_root = true,
    },
    filesystem_watchers = {
        enable = true,
    }
})

vim.cmd([[
  autocmd BufEnter * if winnr("$") > 1 | NvimTreeRefresh | endif
]])


-- Enable LSP
require'lspconfig'.clangd.setup{}

-- Configure Treesitter for Better Syntax
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "cpp" }, -- Add more
  highlight = { enable = true },
  indent = { enable = false }, -- Enable auto-indentation
}

-- nvim-cmp and Auto-pairs Setup

local cmp = require'cmp'
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

cmp.setup({
  completion = {
    autocomplete = { cmp.TriggerEvent.TextChanged, cmp.TriggerEvent.InsertEnter },
  },
  mapping = {
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
  },
})

require('nvim-autopairs').setup({
  check_ts = true,
  ts_config = {
    lua = {'string'},
    javascript = {'template_string'},
  },
})


--  Add GDB Debugging Keybindings
local dap = require'dap'
dap.adapters.gdb = {
  type = 'executable',
  command = 'gdb',
  args = { '--interpreter=mi' }
}
dap.configurations.cpp = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopAtEntry = false,
  },
}

-- Automatically reload files when changed outside of Neovim
vim.cmd([[
  augroup auto_reload
    autocmd!
    autocmd FocusGained,BufEnter * checktime
  augroup END
]])

require("config.keymaps")  -- Load the keybindings

vim.cmd('colorscheme catppuccin')
-- Make neovim semi-transparent (Removes neovim background color, kitty is already semi-transparent)
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
]])
