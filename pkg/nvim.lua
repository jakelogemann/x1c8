local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then impatient.enable_profile() end

if vim.fn.has "nvim-0.8" ~= 1 or vim.version().prerelease then
  vim.schedule(function() 
    vim.api.nvim_err_writeln("Unsupported Neovim Version! Please check the requirements") 
  end)
end

-- Alpha Dashboard Setup
local ok, alpha = pcall(require, "alpha")
if ok then 
  local dashboard = require'alpha.themes.startify'
   dashboard.section.header.val = {
       [[                               __                ]],
       [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
       [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
       [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
       [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
       [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
   }
   dashboard.nvim_web_devicons.enabled = true
   dashboard.config.opts.noautocmd = false
   dashboard.section.top_buttons.val = {
       dashboard.button( "e", "  New file" , ":ene <BAR> startinsert <CR>"),
       dashboard.button( "E", "  File tree" , ":NvimTreeOpen<CR>"),
       dashboard.button( "q", "  Quit NVIM" , ":qa<CR>"),
   }
   alpha.setup(dashboard.config)
end

local ts = require("telescope")
ts.setup()

-- WhichKey Keybinds Setup
local wk = require("which-key")
wk.register({
  ["<leader>e"] = { "<cmd>NvimTreeToggle<cr>", "File Tree" },
  ["<leader>f"] = {
    name = "+file",
    f = { "<cmd>Telescope find_files<cr>", "Find File" },
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    n = { "<cmd>enew<cr>", "New File" },
  },
  ["<leader>/"] = {
    name = "+search",
    f = { "<cmd>Telescope find_files<cr>", "files" },
    r = { "<cmd>Telescope oldfiles<cr>", "recent files" },
    s = { "<cmd>Telescope symbols<cr>", "symbols" },
    R = { "<cmd>Telescope registers<cr>", "registers" },
    m = { "<cmd>Telescope marks<cr>", "marks" },
    M = { "<cmd>Telescope man_pages<cr>", "man pages" },
    c = { "<cmd>Telescope commands<cr>", "commands" },
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

-- _G.which_key.register({
--       f = {
--         name = "file", -- optional group name
--         f = { "<cmd>Telescope find_files<cr>", "Find File" }, -- create a binding with label
--         r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File", noremap=false, buffer = 123 }, -- additional options for creating the keymap
--         n = { "New File" }, -- just a label. don't create any mapping
--         e = "Edit File", -- same as above
--         ["1"] = "which_key_ignore",  -- special label to hide it in the popup
--         b = { function() print("bar") end, "Foobar" } -- you can also pass functions!
--       },
--     }, { prefix = "<leader>" })



vim.cmd [[
colorscheme nord
set number nobackup noswapfile tabstop=2 shiftwidth=2 softtabstop=2 nocompatible autoread
set expandtab smartcase autoindent nostartofline hlsearch incsearch mouse=a
set cmdheight=2 wildmenu showcmd cursorline ruler spell foldmethod=syntax nowrap
set backspace=indent,eol,start background=dark
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

command! -nargs=* System tab terminal system <q-args><cr>
command! -nargs=* Alejandra !alejandra -q <q-args><cr>
command! -nargs=0 SystemRepl silent tab terminal system repl<cr>
command! -nargs=0 SystemSwitch tab terminal sudo system switch<cr>
]]
