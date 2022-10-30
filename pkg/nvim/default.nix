{
  self,
  lib,
  bat,
  alejandra,
  prefs,
  stdenv,
  ripgrep,
  gnumake,
  neovim,
  vimPlugins,
} @ args: let
  inherit (prefs.user) firstName lastName email;
  inherit (lib) getExe;
  nonDependencies = ["stdenv" "vimPlugins" "self" "lib" "prefs"];
  dependencies = (with builtins; attrValues (removeAttrs nonDependencies args));
in
  neovim.override {
    extraName = "-jlogemann";
    viAlias = true;
    vimAlias = true;
    extraLuaPackages = p: [
      p.luarocks-nix
    ];

    configure.customRC = ''
      let $CGO_ENABLED = "0"
      let $GIT_COMMITTER_EMAIL = "${email}"
      let $GIT_COMMITTER_NAME = "${firstName} ${lastName}"
      let $GO111MODULE = "on"
      let $GOFLAGS = "-mod=vendor"
      let $GONOPROXY = "*.internal.digitalocean.com,github.com/digitalocean"
      let $GONOSUMDB = "*.internal.digitalocean.com,github.com/digitalocean"
      let $GOPRIVATE = "${email}"
      let $GOPRIVATE = "*.internal.digitalocean.com,github.com/digitalocean"
      let $GOPROXY = "direct"
      let $GOSUMDB = "sum.golang.org"
      let $PAGER = "${getExe bat}"
      set grepprg=${getExe ripgrep}\ --vimgrep
      set makeprg=${getExe gnumake}
      command! -nargs=* Alejandra !${getExe alejandra} -q <args>
      command! -nargs=* DOCC !docc <args>
      luafile ${./config.lua}
    '';

    configure.packages.default = with vimPlugins; {
      opt = [
        i3config-vim
        vim-concourse
        vim-nftables
        vim-nickel
      ];
      start = [
        alpha-nvim
        cmp-buffer
        cmp-calc
        cmp-nvim-lua
        luasnip
        cmp-git
        cmp-rg
        cmp-dictionary
        cmp-digraphs
        cmp-copilot
        cmp-emoji
        cmp-nvim-lsp
        cmp-omni
        cmp-path
        cmp-spell
        cmp-treesitter
        copilot-vim
        editorconfig-nvim
        fzf-lua
        fzf-vim
        galaxyline-nvim
        gitsigns-nvim
        impatient-nvim
        neorg
        nvim-cmp
        nvim-config-local
        nvim-cursorline
        nvim-dap
        nvim-dap-ui
        nvim-lspconfig
        nvim-terminal-lua
        nvim-web-devicons
        nvim-surround
        nvim-autopairs
        onedarkpro-nvim
        plenary-nvim
        trouble-nvim
        vim-automkdir
        vim-caddyfile
        vim-cue
        vim-easy-align
        vim-gnupg
        vim-go
        vim-hcl
        vim-lastplace
        vim-nix
        vim-nixhash
        vim-pager
        vim-protobuf
        which-key-nvim

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
