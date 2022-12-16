{
  /*
  non-dependent arguments
  */
  stdenv,
  symlinkJoin,
  vimPlugins,
  /*
  dependencies to include in editor env.
  */
  alejandra,
  bat,
  commitlint,
  deadnix,
  gitlint,
  gnumake,
  gnupg,
  gnused,
  gnutar,
  nix-linter,
  jq,
  yamllint,
  yaml-language-server,
  rnix-lsp,
  sumneko-lua-language-server,
  rust-analyzer,
  neovim,
  nodejs,
  ripgrep,
  shellcheck,
  shellharden,
  stylua,
} @ args: neovim.override {
    extraName = "-jlogemann";
    viAlias = true;
    vimAlias = true;
    extraLuaPackages = p: [
      p.luacheck
      p.lua-lsp
      p.nvim-client
      p.nvim-cmp
      p.serpent
      p.vicious
      p.luarocks
      p.luarocks-nix
    ];

    configure.customRC = builtins.concatStringsSep "\n" [
      "lua vim.env.PATH = vim.env.PATH .. \":${symlinkJoin {
        name = "extra-tools";
        paths = builtins.attrValues (builtins.removeAttrs args [
          "stdenv"
          "symlinkJoin"
          "neovim"
          "vimPlugins"
        ]);
      }}/bin\""
      "luafile ${./config.lua}"
    ];

    configure.packages.default = with vimPlugins; {
      start = [
        SchemaStore-nvim
        aerial-nvim
        rust-tools-nvim
        alpha-nvim
        better-escape-nvim
        bufferline-nvim
        catppuccin-nvim
        cmp-buffer
        cmp-calc
        cmp-copilot
        cmp-dictionary
        cmp-digraphs
        cmp-emoji
        cmp-git
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-omni
        cmp-path
        cmp-rg
        cmp-spell
        cmp-treesitter
        colorizer
        copilot-vim
        crates-nvim
        dressing-nvim
        editorconfig-nvim
        formatter-nvim
        fzf-lua
        fzf-vim
        neodev-nvim
        gitsigns-nvim
        impatient-nvim
        lspkind-nvim
        lualine-nvim
        luasnip
        mini-nvim
        neorg
        neoscroll-nvim
        nightfox-nvim
        null-ls-nvim
        nvim-autopairs
        nvim-cmp
        nvim-config-local
        nvim-cursorline
        nvim-dap
        nvim-dap-ui
        nvim-lspconfig
        nvim-notify
        nvim-spectre
        nvim-surround
        nvim-terminal-lua
        nvim-treesitter-context
        nvim-treesitter-refactor
        nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars
        nvim-web-devicons
        plenary-nvim
        toggleterm-nvim
        trouble-nvim
        vim-automkdir
        vim-caddyfile
        vim-easy-align
        vim-gnupg
        vim-go
        vim-lastplace
        vim-nftables
        vim-nix
        vim-nixhash
        vim-pager
        vim-protobuf
        which-key-nvim
        # wilder-nvim
        windows-nvim
      ];
    };
  }
