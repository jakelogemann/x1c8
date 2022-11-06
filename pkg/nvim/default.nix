{
  /* non-dependent arguments */
  lib,
  prefs,
  self,
  stdenv,
  symlinkJoin,
  vimPlugins,
  /* dependencies to include in editor env. */
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
  sumneko-lua-language-server,
  neovim,
  nodejs,
  ripgrep,
  shellcheck,
  shellharden,
  stylua,
} @ args: let
  inherit (prefs.user) firstName lastName email;
  extraTools = symlinkJoin {
    name = "extra-tools";
    paths = (builtins.attrValues (builtins.removeAttrs args ["stdenv" "vimPlugins" "self" "lib" "prefs" "symlinkJoin" "neovim"]));
  };
in
  neovim.override {
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

    configure.customRC = ''
      lua vim.env.PATH = vim.env.PATH .. ":${extraTools}/bin"
      lua vim.env.XDG_CACHE_HOME = vim.fn.expand("$HOME/.cache")
      let $GIT_COMMITTER_EMAIL = "${email}"
      let $GIT_COMMITTER_NAME = "${firstName} ${lastName}"
      let $CGO_ENABLED = "0"
      let $PAGER = "bat"
      set grepprg=rg\ --vimgrep
      command! -nargs=* DOCC !docc <args>
      luafile ${./config.lua}
    '';

    configure.packages.default = with vimPlugins; {
      opt = [
      ];
      start = [
        aerial-nvim
        alpha-nvim
        better-escape-nvim
        bufferline-nvim
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
        dracula-nvim
        dressing-nvim
        editorconfig-nvim
        fzf-lua
        fzf-vim
        gitsigns-nvim
        impatient-nvim
        lspkind-nvim
        lualine-nvim
        luasnip
        neorg
        formatter-nvim
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
        nvim-web-devicons
        plenary-nvim
        toggleterm-nvim
        trouble-nvim
        vim-automkdir
        vim-caddyfile
        vim-cue
        vim-easy-align
        vim-gnupg
        vim-go
        vim-hcl
        vim-lastplace
        vim-nftables
        vim-nickel
        vim-nix
        vim-nixhash
        vim-pager
        vim-protobuf
        which-key-nvim
        windows-nvim

        (nvim-treesitter.withPlugins (p:
          builtins.map (n: p."tree-sitter-${n}") [
            "bash"
            "c"
            "comment"
            "cpp"
            "css"
            "go"
            "gomod"
            "elm"
            "zig"
            "dockerfile"
            "scss"
            "fish"
            "regex"
            "html"
            "json"
            "lua"
            "commonlisp"
            "haskell"
            "c-sharp"
            "graphql"
            "hcl"
            "make"
            "markdown"
            "typescript"
            "javascript"
            "json5"
            "hjson"
            "jsdoc"
            "nix"
            "python"
            "ruby"
            "rust"
            "toml"
            "vim"
            "yaml"
          ]))
      ];
    };
  }
