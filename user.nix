{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  login = "jlogemann";
  email = "jlogemann@digitalocean.com";
  firstName = "Jake";
  lastName = "Logemann";
in {
  users.users."${login}" = rec {
    name = "${login}";
    group = name;
    description = "${firstName} ${lastName}";
    initialPassword = "";
    home = "/home/${name}";
    shell = pkgs.zsh;
    uid = 1000;
    isNormalUser = true;
    packages = with pkgs; [
      my-tools
      _1password
      aide
      dogdns
      glxinfo
      commitlint
      expect
      graphviz
      self.inputs.helix.packages.${pkgs.system}.helix
      self.inputs.gomod2nix.packages.${pkgs.system}.default
      self.inputs.nixpkgs-lint.packages.${pkgs.system}.default
      # (pkgs.callPackage ./nvim {})
      (writeShellApplication {
        name = "ldapsearch";
        runtimeInputs = [openldap];
        text = "ldapsearch -xLLLH ldaps://ldap-primary.internal.digitalocean.com -b ou=Groups,dc=internal,dc=digitalocean,dc=com";
      })

      (neovim.override {
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
            paths = [
              alejandra
              bat
              commitlint
              deadnix
              gitlint
              gnumake
              gnupg
              gnused
              gnutar
              nix-linter
              jq
              yamllint
              yaml-language-server
              rnix-lsp
              sumneko-lua-language-server
              rust-analyzer
              neovim
              nodejs
              ripgrep
              shellcheck
              shellharden
              stylua
            ];
          }}/bin\""
          "luafile ${./neovim.lua}"
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
      })
    ];
  };
  nix.settings.allowed-users = [login];
  nix.settings.trusted-users = [login];
  users.groups.kvm.members = [login];
  users.groups.users.members = [login];
  users.groups.video.members = [login];
  users.groups.wheel.members = [login];
  users.groups.podman.members = [login];
  users.groups."${login}".members = [login];
  users.groups.wireshark.members = [login];
  users.groups.systemd-journal.members = [login];
  security.sudo.extraRules = [
    {
      users = [login];
      runAs = "root";
      commands = lib.concatLists [
        ["ALL"]

        (builtins.map (name: {
            command = "/run/current-system/sw/bin/${name}";
            options = ["NOSETENV" "NOPASSWD"];
          }) [
            "nix-collect-garbage"
            "poweroff"
            "reboot"
            "shutdown"
            "system"
            "systemd-cgls"
            "systemd-cgtop"
            "dmesg"
            "systemctl"
            "openconnect"
            "kill"
            "killall"
          ])
      ];
    }
  ];
}
