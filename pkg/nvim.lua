local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then impatient.enable_profile() end

-- for _, source in ipairs {
--   "core.utils",
--   "core.options",
--   "core.bootstrap",
--   "core.plugins",
--   "core.diagnostics",
--   "core.autocmds",
--   "core.mappings",
--   "configs.which-key-register",
-- } do
--   local status_ok, fault = pcall(require, source)
--   if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
-- end
-- 
local ok, alpha = pcall(require, "alpha")
if ok then 
  local dashboard = require'alpha.themes.dashboard'
   dashboard.section.header.val = {
       [[                               __                ]],
       [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
       [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
       [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
       [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
       [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
   }
   dashboard.section.buttons.val = {
       dashboard.button( "e", "  New file" , ":ene <BAR> startinsert <CR>"),
       dashboard.button( "q", "  Quit NVIM" , ":qa<CR>"),
   }
   dashboard.config.opts.noautocmd = true
   vim.cmd[[autocmd User AlphaReady echo 'ready']]
   alpha.setup(dashboard.config)
end

if vim.fn.has "nvim-0.8" ~= 1 or vim.version().prerelease then
  vim.schedule(function() 
    vim.api.nvim_err_writeln("Unsupported Neovim Version! Please check the requirements") 
  end)
end

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
nnoremap <silent> <leader>e <CMD>NvimTreeToggle<CR>
nnoremap <silent> <leader><leader>f <CMD>Telescope find_files<CR>
nnoremap <silent> <leader><leader>r <CMD>Telescope symbols<CR>
nnoremap <silent> <leader><leader>R <CMD>Telescope registers<CR>
nnoremap <silent> <leader><leader>z <CMD>Telescope current_buffer_fuzzy_find<CR>
nnoremap <silent> <leader><leader>m <CMD>Telescope marks<CR>
nnoremap <silent> <leader><leader>H <CMD>Telescope help_tags<CR>
nnoremap <silent> <leader><leader>M <CMD>Telescope man_pages<CR>
nnoremap <silent> <leader><leader>c <CMD>Telescope commands<CR>

command! -nargs=* SystemSwitch silent !sudo system switch<cr>
command! -nargs=* System silent! !system <q-args><cr>
command! -nargs=0 NixFmt silent! !nix run nixpkgs\#alejandra -- -q %:p<cr>
]]
