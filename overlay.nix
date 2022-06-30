{ self, ... } @ inputs: final: prev: with prev; {
  fnctl = self.inputs.fnctl.packages.${system};
  do-nixpkgs = self.inputs.do-nixpkgs.packages.${system};
  neovim = (neovim.override {
      vimAlias = true;
      viAlias = true;
      configure = {
        packages.default = with vimPlugins; {
          opt = [];
          start = [ 
            vim-lastplace 
            # nvim-tree-lua
            telescope-nvim
            nvim-lspconfig
            vim-nix 
            nvim-web-devicons 
            i3config-vim
            vim-easy-align 
            vim-gnupg
            vim-cue
            vim-go
            vim-hcl
            # which-key-nvim
            # toggleterm-nvim
            (nvim-treesitter.withPlugins (p: builtins.map (n: p."tree-sitter-${n}") [
              "bash" 
              "c"
              "comment"
              "cpp" 
              "css" 
              "go"
              "html" 
              "json" 
              "lua"
              "make"
              "markdown"
              "nix"
              "python"
              "ruby"
              "rust"
              "toml"
              "vim"
              "yaml"
            ]))
            onedarkpro-nvim
          ]; 
        };
        customRC = ''
          colorscheme onedarkpro
          set nocompatible autoread
          set backspace=indent,eol,start
          let mapleader=' '
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

        '';
      };
    }
  );
}
