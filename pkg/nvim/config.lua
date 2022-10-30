if vim.fn.has "nvim-0.8" ~= 1 or vim.version().prerelease then
  vim.schedule(function()
    vim.api.nvim_err_writeln("Unsupported Neovim Version! Please check the requirements")
  end)
end

vim.cmd [[
let mapleader=' '

if has("user_commands")
  command! -bang -nargs=? -complete=file E e<bang> <args>
  command! -bang -nargs=? -complete=file W w<bang> <args>
  command! -bang -nargs=? -complete=file Wq wq<bang> <args>
  command! -bang -nargs=? -complete=file WQ wq<bang> <args>
  command! -bang Wa wa<bang>
  command! -bang WA wa<bang>
  command! -bang Q q<bang>
  command! -bang QA qa<bang>
  command! -bang Qa qa<bang>
endif

nnoremap <silent> <C-e> <CMD>NvimTreeToggle<CR>
]]

local cmp = require("cmp")
local fzf = require("fzf-lua")
local wk = require("which-key")
local alpha = require("alpha")
local impatient = require("impatient")
impatient.enable_profile()

-- Alpha Dashboard Setup
local dashboard = require'alpha.themes.startify'
dashboard.section.header.val = {
   [[  ___   __   __  ._     ___ ___    ]],
   [[ / _ `\/\ \ /\ \/\ \  / __` __`\   ]],
   [[/\ \/\ \ \ \_/ /\ \ \/\ \/\ \/\ \  ]],
   [[\ \_\ \_\ \___/  \ \_\ \_\ \_\ \_\ ]],
   [[ \/_/\/_/\/__/    \/_/\/_/\/_/\/_/ ]],
}
dashboard.nvim_web_devicons.enabled = true
dashboard.config.opts.noautocmd = false
dashboard.section.top_buttons.val = {
   dashboard.button( "e", "  Create New file" , ":ene <BAR> startinsert <CR>"),
   dashboard.button( "f", "   File tree" , ":NvimTreeOpen<CR>"),
   dashboard.button( "R", "   System REPL" , ":terminal system repl<BAR> startinsert<CR>"),
   dashboard.button( "S", "   System Switch" , ":terminal sudo system switch<CR>"),
   dashboard.button( "\\", "   Check Health" , ":checkhealth<CR>"),
   dashboard.button( "?", "   Find help " , ":FzfLua help_tags<CR>"),
}
alpha.setup(dashboard.config)

cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
    })
})

fzf.setup({
  fzf_colors = {
    ["fg"]          = { "fg", "CursorLine" },
    ["bg"]          = { "bg", "Normal" },
    ["hl"]          = { "fg", "Comment" },
    ["fg+"]         = { "fg", "Normal" },
    ["bg+"]         = { "bg", "CursorLine" },
    ["hl+"]         = { "fg", "Statement" },
    ["info"]        = { "fg", "PreProc" },
    ["prompt"]      = { "fg", "Conditional" },
    ["pointer"]     = { "fg", "Exception" },
    ["marker"]      = { "fg", "Keyword" },
    ["spinner"]     = { "fg", "Label" },
    ["header"]      = { "fg", "Comment" },
    ["gutter"]      = { "bg", "Normal" },
  },
})

-- WhichKey Keybinds Setup
wk.register({
  ["<leader>e"] = { "<cmd>NvimTreeToggle<cr>", "File Tree" },
  ["<leader>/"] = {
    name = "+find",
    f = { "<cmd>FzfLua files<cr>", "files" },
    b = { "<cmd>FzfLua buffers<cr>", "buffers" },
    j = { "<cmd>FzfLua jumps<cr>", "jumps" },
    T = { "<cmd>FzfLua filetypes<cr>", "filetype" },
    t = { "<cmd>FzfLua tabs<cr>", "tabs" },
    l = { "<cmd>FzfLua loclist<cr>", "loclist" },
    q = { "<cmd>FzfLua quickfix<cr>", "qf" },
    ["?"] = { "<cmd>FzfLua help_tags<cr>", "help tags" },
    R = { "<cmd>FzfLua registers<cr>", "registers" },
    m = { "<cmd>FzfLua marks<cr>", "marks" },
    M = { "<cmd>FzfLua man_pages<cr>", "man" },
    c = { "<cmd>FzfLua command_history<cr>", "command history" },
  },
})

wk.setup({
    plugins = {
      marks = true, -- shows a list of your marks on ' and `
      registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      spelling = {
        enabled = true, -- show WhichKey when pressing z= to select spelling suggestions
        suggestions = 20, -- how many suggestions should be shown in the list?
      },
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
        motions = true, -- adds help for motions
        text_objects = true, -- help for text objects triggered after entering an operator
        windows = true, -- default bindings on <c-w>
        nav = true, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = true, -- bindings for prefixed with g
      },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
      -- override the label used to display some keys. It doesn't effect WK
      -- in any other way.
      ["<space>"] = "SPC",
      ["<cr>"] = "RET",
      ["<tab>"] = "TAB",
    },
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "➜", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
    },
    popup_mappings = {
      scroll_down = '<c-d>', -- binding to scroll down inside the popup
      scroll_up = '<c-u>', -- binding to scroll up inside the popup
    },
    window = {
      border = "none", -- none, single, double, shadow
      position = "bottom", -- bottom, top
      margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      winblend = 0
    },
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
      align = "left", -- align columns left, center or right
    },
    ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
    hidden = {
       -- hide mapping boilerplate
      "<silent>",
      "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "},
    show_help = true, -- show help message on the command line when the popup is visible
    show_keys = true, -- show the currently pressed key and its label as a message in the command line
    triggers = "auto", -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_blacklist = {
      -- list of mode / prefixes that should never be hooked by WhichKey
      -- this is mostly relevant for key maps that start with a native binding
      -- most people should not need to change this
      i = { "j", "k" },
      v = { "j", "k" },
    },
    -- disable the WhichKey popup for certain buf types and file types.
    -- Disabled by deafult for Telescope
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  })

vim.opt.number = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.cmdheight = 2
vim.opt.wildmenu = true
vim.opt.showcmd = true
vim.opt.cursorline = true
vim.opt.ruler = true
vim.opt.spell = true
vim.opt.wrap = false
vim.opt.foldmethod = "syntax"
vim.opt.autoread = true
vim.opt.autoindent = true
vim.opt.startofline = false
vim.opt.completeopt= {"menu","menuone","noselect"}
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.mouse = "a"
vim.opt.background = "dark"
vim.opt.backspace = {"indent", "eol", "start"}
vim.opt.expandtab = true
vim.opt.smartcase = true

vim.cmd "colorscheme onedarkpro"

--[[
   ___       __                                         __
  / _ |__ __/ /____  _______  __ _  __ _  ___ ____  ___/ /__
 / __ / // / __/ _ \/ __/ _ \/  ' \/  ' \/ _ `/ _ \/ _  (_-<
/_/ |_\_,_/\__/\___/\__/\___/_/_/_/_/_/_/\_,_/_//_/\_,_/___/
--]]
vim.api.nvim_create_autocmd('TextYankPost',
{
	callback = function() vim.highlight.on_yank() end,
	group = vim.api.nvim_create_augroup('config', {clear = false}),
})

--- Reset my indent guide settings
vim.api.nvim_create_autocmd({'BufWinEnter', 'BufWritePost', 'InsertLeave'},
{
	callback = function()
		vim.opt.cpo:append 'n'
		vim.opt.list = true
		vim.opt.listchars = {nbsp = '␣', tab = '│ ', trail = '•'}
		vim.opt.showbreak = '└ '
	end,
	group = 'config',
})

--- Strip whitespaces that procedes lines
vim.api.nvim_create_autocmd('BufWritePre',
{
	callback = function()
		if not (vim.bo.binary or vim.bo.filetype == 'diff') then
			local winview = vim.fn.winsaveview()
			vim.api.nvim_command [[silent! %s/\s\+$//e]]
			vim.fn.winrestview(winview)
		end
	end,
	group = 'config',
})

--[[
  _____                              __
 / ___/__  __ _  __ _  ___ ____  ___/ /__
/ /__/ _ \/  ' \/  ' \/ _ `/ _ \/ _  (_-<
\___/\___/_/_/_/_/_/_/\_,_/_//_/\_,_/___/
--]]

-- Space-Tab Conversion
vim.api.nvim_create_user_command(
	'SpacesToTabs',
	function(tbl)
		vim.opt.expandtab = false
		local previous_tabstop = vim.bo.tabstop
		vim.opt.tabstop = tonumber(tbl.args)
		vim.api.nvim_command 'retab!'
		vim.opt.tabstop = previous_tabstop
	end,
	{force = true, nargs = 1}
)

vim.api.nvim_create_user_command(
	'TabsToSpaces',
	function(tbl)
		vim.opt.expandtab = true
		local previous_tabstop = vim.bo.tabstop
		vim.opt.tabstop = tonumber(tbl.args)
		vim.api.nvim_command 'retab'
		vim.opt.tabstop = previous_tabstop
	end,
	{force = true, nargs = 1}
)
