{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-templates.url = "github:nixos/templates";

    fnctl = {
      url = "github:jakelogemann/fnctl";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hardware.follows = "nixos-hardware";
      inputs.templates.follows = "nixos-templates";
      inputs.utils.follows = "flake-utils";
      inputs.nix-filter.follows = "nix-filter";
    };

    dotfiles = {
      url = "github:jakelogemann/.config";
      flake = false;
    };

    AstroNvim = {
      type = "github";
      owner = "astronvim";
      repo = "astronvim";
      flake = false;
    };

    cthulhu = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "cthulhu";
      flake = false;
    };

    dao = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "dao";
      flake = false;
    };

    cicd = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "cicd";
      flake = false;
    };

    do-nixpkgs = {
      url = "git+https://github.internal.digitalocean.com/digitalocean/do-nixpkgs?ref=master";
      inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
      inputs.cthulhu.follows = "cthulhu";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    /*
    preferences are loaded from a TOML file located in this directory. the data
    in here is free-form and should be kept as minimalist as possible.
    */
    prefs = builtins.fromTOML (builtins.readFile ./prefs.toml);
  in {
    # a few values are inherited directly from another project i maintain.
    inherit (self.inputs.fnctl) lib formatter devShells;

    /*
    while its possible to have several overlays, i tend to keep only a single one like this..
    i think its a bit stylistic.
    */
    overlays.default = final: prev:
      with prev; rec {
        do-nixpkgs =
          self.inputs.do-nixpkgs.packages.${system}
          // {
            dao = callPackage ./pkg/dao.nix {};
            ghe = pkgs.writeShellApplication {
              name = "ghe";
              runtimeInputs = with pkgs; [gh];
              text = lib.concatStringsSep " " ["exec" "env" "GH_HOST='github.internal.digitalocean.com'" "gh" "\"$@\""];
            };
            vault = pkgs.writeShellApplication {
              name = "vault";
              runtimeInputs = with pkgs; [vault];
              text = lib.concatStringsSep " " ["exec" "env" "VAULT_CACERT=${pkgs.do-nixpkgs.sammyca}" "VAULT_ADDR=https://vault-api.internal.digitalocean.com:8200" "vault" "\"$@\""];
            };
          };
      };

    /*
    do-internal represents "internal" digitalocean configuration.
    beyond that... I haven't decided what this module does yet..
    */
    nixosModules.do-internal = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [
        self.inputs.do-nixpkgs.nixosModules.kolide-launcher
        self.inputs.do-nixpkgs.nixosModules.sentinelone
      ];
      services.sentinelone.enable = true;
      services.kolide-launcher.enable = true;
      services.kolide-launcher.secretFilepath = "/home/${prefs.user.login}/.do/kolide.secret";
      system.nixos.tags = ["digitalocean"];
      environment.systemPackages = with pkgs; [
        (pkgs.symlinkJoin {
          name = "do-nixpkgs-bundle";
          paths =
            (builtins.map (p: pkgs.do-nixpkgs."${p}") prefs.packages.internal)
            ++ [
              (pkgs.writeShellScriptBin "do-nixpkgs-bundle" "dirname $(dirname $(readlink $(which docc)))")
              (pkgs.writeShellScriptBin "do-nixpkgs-bundle-tree" "tree $\{@:--lnQhx} $(do-nixpkgs-bundle)")
              (pkgs.writeShellScriptBin "do-nixpkgs-bundle-pager" "tree $\{@:--lnQhx} $(do-nixpkgs-bundle) | ${lib.getExe pkgs.bat} --file-name=$0 --plain")
              (pkgs.writeShellScriptBin "jf" "exec docker run --rm -it --mount type=bind,source=\"$HOME/.jfrog\",target=/root/.jfrog 'releases-docker.jfrog.io/jfrog/jfrog-cli-v2-jf' jf \"$@\"")
              (pkgs.writeShellApplication {
                name = "vpn";
                runtimeInputs = with pkgs; [openconnect];
                text = ''
                  set -x; exec ${lib.getExe pkgs.openconnect} \
                    --passwd-on-stdin --background --protocol=gp -F _challenge:passwd=1 \
                    --csd-wrapper=${pkgs.openconnect}/libexec/openconnect/hipreport.sh \
                    -F _login:user="$1" \
                    "https://vpn-$2.digitalocean.com/ssl-vpn"
                '';
              })
              (pkgs.writeShellApplication {
                name = "ghe";
                runtimeInputs = with pkgs; [gh];
                text = lib.concatStringsSep " " ["exec" "env" "GH_HOST='github.internal.digitalocean.com'" "gh" "\"$@\""];
              })
              (pkgs.writeShellApplication {
                name = "vault";
                runtimeInputs = with pkgs; [vault];
                text = lib.concatStringsSep " " ["exec" "env" "VAULT_CACERT=${pkgs.do-nixpkgs.sammyca}" "VAULT_ADDR=https://vault-api.internal.digitalocean.com:8200" "vault" "\"$@\""];
              })
            ];
        })
      ];
    };

    /*
    lenovo-x1c8 contains the configuration that is specific to my Lenovo
    X1 Carbon (8th gen), but generic enough to perhaps reuse.
    */
    nixosModules.lenovo-x1c8 = {
      config,
      lib,
      pkgs,
      ...
    }: {
      system.nixos.tags = ["x1c8"];
      boot.initrd.availableKernelModules = ["nvme" "usb_storage" "sd_mod"];
      imports = [
        self.inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
      ];
    };

    /*
    this contains ... well.. me. or ... "you"... perhaps, "us"?
    */
    nixosModules.${prefs.user.login} = {
      config,
      lib,
      pkgs,
      ...
    }: {
      users.users.${prefs.user.login} = {
        extraGroups = ["users" prefs.user.login];
        group = prefs.user.login;
        initialPassword = "";
        home = "/home/${prefs.user.login}";
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
      };
      users.groups.${prefs.user.login}.gid = 990;
      system.nixos.tags = [prefs.user.login];
    };

    /*
    shellz wraps ZSH with my current configuration.
    */
    nixosModules.shellz = {
      config,
      lib,
      pkgs,
      ...
    }: {
      programs.zsh = {
        autosuggestions.enable = true;
        autosuggestions.extraConfig.ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
        autosuggestions.highlightStyle = "fg=cyan";
        autosuggestions.strategy = ["completion"];
        enable = true;
        # enableBashCompletion = true;
        enableCompletion = true;
        # enableGlobalCompInit = true;
        histFile = "$HOME/.zsh_history";
        histSize = 100000;
        syntaxHighlighting.enable = true;
        syntaxHighlighting.highlighters = ["main" "brackets" "pattern" "root" "line"];
        syntaxHighlighting.styles.alias = "fg=magenta,bold";
        # vteIntegration = true;
        setOptions = [
          "AUTO_CD"
          "AUTO_PUSHD"
          "HIST_IGNORE_DUPS"
          "SHARE_HISTORY"
          "HIST_FCNTL_LOCK"
          "EXTENDED_HISTORY"
          "RM_STAR_WAIT"
          "CD_SILENT"
          "CHASE_DOTS"
          "CHASE_LINKS"
          "PUSHD_IGNORE_DUPS"
          "PUSHD_MINUS"
          "PUSHD_SILENT"
          "PUSHD_TO_HOME"
          "COMPLETE_ALIASES"
          "EXTENDED_HISTORY"
          "BASH_AUTO_LIST"
          "INC_APPEND_HISTORY"
          "INTERACTIVE_COMMENTS"
          "MENU_COMPLETE"
          "HIST_SAVE_NO_DUPS"
          "HIST_IGNORE_SPACE"
          "HIST_EXPIRE_DUPS_FIRST"
        ];
        interactiveShellInit = ''
          eval "$(${lib.getExe pkgs.direnv} hook zsh)"
          source "${pkgs.skim}/share/skim/completion.zsh"
          source "${pkgs.skim}/share/skim/key-bindings.zsh"
          eval "$(${lib.getExe pkgs.navi} widget zsh)"
          eval "$(${lib.getExe pkgs.starship} init zsh)"
          eval "$(${lib.getExe pkgs.zoxide} init zsh)"
          eval "$(${lib.getExe pkgs.do-nixpkgs.docc} completion zsh)"
          zstyle ':vcs_info:*' enable git cvs svn hg
          hash -d current-sw=/run/current-system/sw
          hash -d booted-sw=/run/booted-system/sw
          autoload -U edit-command-line && zle -N edit-command-line && bindkey '\C-x\C-e' edit-command-line
          bindkey '\C-k' up-line-or-history
          bindkey '\C-j' down-line-or-history
          bindkey '\C-h' backward-word
          bindkey '\C-l' forward-word

        '';
      };
    };

    /*
    nvim wraps neovim with my current configuration.
    */
    nixosModules.nvim = {
      config,
      lib,
      pkgs,
      ...
    }: {
      programs.neovim = {
        enable = true;
        vimAlias = true;
        defaultEditor = true;
        viAlias = true;
        configure.packages.default.start = with pkgs.vimPlugins; [
          vim-lastplace
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
          (nvim-treesitter.withPlugins (p:
            builtins.map (n: p."tree-sitter-${n}") [
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

        configure.customRC = ''
          colorscheme onedarkpro
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

          function! NumberToggle()
          if(&relativenumber == 1) set nu nornu
          else set nonu rnu
          endif
          endfunc

          nnoremap <leader>r :call NumberToggle()<cr>
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
    };

    /*
    this is a specific host's configuration (my laptop, to be specific).
    you probably don't actually want to use this... but feel free to have a
    bowl of copy+pasta :)
    */
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {inherit self nixpkgs prefs system;};
      modules =
        (builtins.attrValues self.nixosModules)
        ++ [
          ({
            config,
            lib,
            pkgs,
            ...
          }: {
            boot.binfmt.emulatedSystems = ["aarch64-linux"];
            boot.enableContainers = true;
            boot.extraModprobeConfig = "options kvm_intel nested=1";
            #boot.kernel.sysctl."kernel.modules_disabled" = 1;
            boot.initrd.kernelModules = ["dm-snapshot" "br_netfilter"];
            boot.initrd.luks.devices.root.allowDiscards = true;
            boot.initrd.luks.devices.root.device = "/dev/disk/by-uuid/c680bcae-9d30-4845-825c-225666887138";
            boot.initrd.luks.devices.root.preLVM = true;
            boot.loader.grub.configurationLimit = 10;
            boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
            boot.kernel.sysctl."kernel.kptr_restrict" = 2;
            boot.kernel.sysctl."kernel.perf_event_paranoid" = 3;
            boot.kernel.sysctl."kernel.randomize_va_space" = 2;
            boot.kernel.sysctl."kernel.sysrq" = 0;
            boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;
            boot.kernel.sysctl."net.core.bpf_jit_harden" = 2;
            boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = 1;
            boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = 1;
            boot.kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 0;
            boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = 1;
            boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = 0;
            boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = 0;
            boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = 0;
            boot.kernel.sysctl."vm.swappiness" = 1;
            boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = 0;
            boot.kernelParams = ["acpi_osi=\"Linux\"" "i8042.reset=1" "i8042.nomux=1"];
            boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
            boot.loader.systemd-boot.enable = true;
            boot.supportedFilesystems = lib.mkForce ["btrfs" "vfat"];
            boot.kernelModules = [
              "acpi_call"
              "br_netfilter"
              "btusb"
              "drm"
              "ext2"
              "i915"
              "iwlmvm"
              "kvm-intel"
              "mei_me"
              "sd_mod"
              "snd_hda_intel"
              "tpm_tis"
              "xhci_pci"
            ];

            # programs.ssh.ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
            # programs.ssh.kexAlgorithms = ["curve25519-sha256@libssh.org" "diffie-hellman-group-exchange-sha256"];
            # programs.ssh.macs = ["hmac-sha2-512-etm@openssh.com" "hmac-sha1"];
            # virtualisation.docker.rootless.daemon.settings.fixed-cidr-v6 = "fd00::/80";
            # virtualisation.docker.rootless.daemon.settings.ipv6 = true;
            # security.pki.certificateFiles = [ pkgs.do-nixpkgs.sammyca ];
            console.earlySetup = true;
            console.font = "Lat2-Terminus16";
            console.useXkbConfig = true;
            documentation.dev.enable = false;
            documentation.doc.enable = true;
            documentation.enable = true;
            documentation.man.enable = true;
            documentation.man.generateCaches = false;
            documentation.man.man-db.enable = true;
            documentation.nixos.includeAllModules = true;
            documentation.nixos.options.warningsAreErrors = false;
            environment.pathsToLink = ["/share/zsh"];
            environment.shellAliases.git-vars = "${lib.getExe pkgs.bat} -l=ini --file-name 'git var -l' <(git var -l)";
            environment.shellAliases.l = "ls -alh";
            environment.shellAliases.la = "${lib.getExe pkgs.lsd} -a";
            environment.shellAliases.ll = "${lib.getExe pkgs.lsd} -l";
            environment.shellAliases.lla = "${lib.getExe pkgs.lsd} -la";
            environment.shellAliases.ls = lib.getExe pkgs.lsd;
            environment.shellAliases.lt = "${lib.getExe pkgs.lsd} --tree";
            environment.variables.EDITOR = "nvim";
            fileSystems."/".device = "/dev/disk/by-uuid/45264d57-59a7-428b-a85a-35fa35c1ddeb";
            fileSystems."/".fsType = "btrfs";
            fileSystems."/boot".device = "/dev/disk/by-uuid/6696-7F45";
            fileSystems."/boot".fsType = "vfat";
            fonts.enableDefaultFonts = true;
            fonts.fontconfig.antialias = true;
            fonts.fontconfig.defaultFonts.emoji = ["Noto Color Emoji"];
            fonts.fontconfig.defaultFonts.monospace = ["TerminessTTF Nerd Font Mono" "DejaVu Sans Mono"];
            fonts.fontconfig.defaultFonts.sansSerif = ["DejaVu Sans"];
            fonts.fontconfig.defaultFonts.serif = ["DejaVu Serif"];
            fonts.fontconfig.enable = true;
            fonts.fontconfig.hinting.autohint = true;
            fonts.fontconfig.hinting.style = "hintslight";
            fonts.fonts = builtins.map (p: pkgs.${p}) prefs.packages.fonts;
            hardware.cpu.intel.updateMicrocode = true;
            hardware.gpgSmartcards.enable = true;
            hardware.ksm.enable = true;
            hardware.mcelog.enable = true;
            hardware.opengl.enable = true;
            hardware.opengl.extraPackages = with pkgs; [intel-compute-runtime];
            hardware.pulseaudio.enable = true;
            networking.dhcpcd.extraConfig = lib.mkForce "nohook resolv.conf";
            networking.domain = "local";
            networking.enableIPv6 = true;
            networking.firewall.allowPing = true;
            networking.firewall.allowedTCPPorts = [];
            networking.firewall.allowedUDPPorts = [];
            networking.firewall.autoLoadConntrackHelpers = true;
            networking.firewall.checkReversePath = true;
            networking.firewall.enable = true;
            networking.firewall.logRefusedConnections = true;
            networking.firewall.logRefusedPackets = true;
            networking.firewall.logReversePathDrops = true;
            networking.firewall.pingLimit = "--limit 1/minute --limit-burst 5";
            networking.firewall.rejectPackets = true;
            networking.hostName = prefs.host.name;
            networking.interfaces.enp45s0u1u3u2c2.useDHCP = true;
            networking.interfaces.enp45s0u2u3.useDHCP = true;
            networking.nameservers = lib.mkForce ["127.0.0.1" "::1"];
            networking.networkmanager.dns = lib.mkForce "none";
            networking.networkmanager.enable = true;
            networking.networkmanager.plugins = with pkgs; [networkmanager-openconnect];
            networking.networkmanager.wifi.powersave = true;
            networking.resolvconf.enable = lib.mkForce false;
            networking.useDHCP = false;
            networking.useHostResolvConf = true;
            networking.wireless.enable = false;
            networking.wireless.iwd.enable = false;
            networking.wireless.userControlled.enable = true;
            nix.daemonCPUSchedPolicy = "idle";
            nix.daemonIOSchedPriority = 3;
            nix.gc.automatic = true;
            nix.gc.dates = "daily";
            nix.optimise.automatic = true;
            nix.optimise.dates = ["daily"];
            nix.registry.do-nixpkgs.flake = self.inputs.do-nixpkgs;
            nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
            nix.settings.allow-dirty = true;
            nix.settings.allowed-users = ["root" prefs.user.login];
            nix.settings.auto-optimise-store = true;
            nix.settings.experimental-features = ["nix-command" "flakes"];
            nix.settings.log-lines = 50;
            nix.settings.max-free = 64 * 1024 * 1024 * 1024;
            nix.settings.trusted-users = ["root" prefs.user.login];
            nix.settings.warn-dirty = false;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = lib.mkForce [self.overlays.default];
            powerManagement.cpuFreqGovernor = "powersave";
            programs.git.config.alias.aliases = "config --show-scope --get-regexp alias";
            programs.git.config.alias.amend = "commit --amend";
            programs.git.config.alias.amendall = "commit --amend --all";
            programs.git.config.alias.amendit = "commit --amend --no-edit";
            programs.git.config.alias.branches = "branch --all";
            programs.git.config.alias.l = "log --pretty=oneline --graph --abbrev-commit";
            programs.git.config.alias.quick-rebase = "rebase --interactive --root --autosquash --autostash";
            programs.git.config.alias.remotes = "remote --verbose";
            programs.git.config.alias.list-vars = "!${lib.getExe pkgs.bat} -l=ini --file-name 'git var -l (sorted)' <(git var -l | sort)";
            programs.git.config.alias.user = "config --show-scope --get-regexp user";
            programs.git.config.alias.wtf-config = "config --show-scope --show-origin --list --includes";
            programs.git.config.apply.whitespace = "fix";
            programs.git.config.branch.sort = "-committerdate";
            programs.git.config.core.excludesfile = pkgs.writeText "git-excludes" (lib.concatStringsSep "\n" ["*~" "tags" ".nvimlog" "*.swp" "*.swo" "*.log" ".DS_Store"]);
            programs.git.config.core.ignorecase = true;
            programs.git.config.core.pager = lib.getExe pkgs.delta;
            programs.git.config.core.untrackedcache = true;
            programs.git.config.credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
            programs.git.config.diff.bin.textconv = "hexdump -v -C";
            programs.git.config.diff.renames = "copies";
            programs.git.config.help.autocorrect = 1;
            programs.git.config.init.defaultbranch = "main";
            programs.git.config.interactive.difffilter = "${lib.getExe pkgs.delta} --color-only";
            programs.git.config.pull.ff = true;
            programs.git.config.pull.rebase = true;
            programs.git.config.push.default = "simple";
            programs.git.config.push.followtags = true;
            programs.git.enable = true;
            programs.git.lfs.enable = lib.mkDefault true;
            programs.gnupg.agent.enable = true;
            programs.gnupg.agent.enableBrowserSocket = true;
            programs.gnupg.agent.enableSSHSupport = true;
            programs.ssh.extraConfig = builtins.readFile ./pkg/ssh_config;
            programs.ssh.forwardX11 = false;
            programs.ssh.hostKeyAlgorithms = ["ecdsa-sha2-nistp256" "ssh-ed25519" "ssh-rsa"];
            programs.ssh.setXAuthLocation = false;
            programs.ssh.startAgent = false;
            programs.starship.enable = true;
            programs.starship.settings.add_newline = false;
            # programs.starship.settings.character.continuation_prompt = "[▶▶](dim cyan)";
            programs.starship.settings.character.error_symbol = "[➜](bold red)";
            programs.starship.settings.character.success_symbol = "[➜](bold green)";
            programs.starship.settings.character.vicmd_symbol = "[](bold magenta)";
            programs.starship.settings.format = "$character";
            programs.starship.settings.right_format = "$all";
            programs.starship.settings.scan_timeout = 10;
            programs.tmux.aggressiveResize = true;
            programs.tmux.baseIndex = 1;
            programs.tmux.enable = true;
            programs.tmux.newSession = true;
            programs.tmux.plugins = with pkgs.tmuxPlugins; [pain-control onedark-theme sensible];
            programs.tmux.reverseSplit = true;
            programs.tmux.secureSocket = true;
            programs.tmux.shortcut = "a";
            programs.tmux.terminal = "tmux-256color";
            security.allowUserNamespaces = true;
            security.forcePageTableIsolation = true;
            security.polkit.adminIdentities = ["unix-user:${prefs.user.login}"];
            security.protectKernelImage = true;
            security.rtkit.enable = true;
            security.tpm2.enable = true;
            security.virtualisation.flushL1DataCache = "always";
            services.acpid.enable = true;
            services.earlyoom.enable = true;
            services.earlyoom.freeMemThreshold = 10;
            services.earlyoom.freeSwapThreshold = 10;
            services.fwupd.enable = true;
            services.journald.extraConfig = lib.concatStringsSep "\n" ["SystemMaxUse=1G"];
            services.journald.forwardToSyslog = false;
            hardware.uinput.enable = true;
            services.tlp.enable = true;
            services.upower.enable = true;
            services.emacs.enable = false;
            services.emacs.install = false;
            services.xserver.autorun = true;
            services.xserver.displayManager.autoLogin.enable = true;
            services.xserver.displayManager.autoLogin.user = prefs.user.login;
            services.xserver.displayManager.defaultSession = "none+i3";
            services.xserver.enable = true;
            services.xserver.enableCtrlAltBackspace = true;
            services.xserver.layout = "us";
            services.xserver.libinput.touchpad.disableWhileTyping = true;
            services.xserver.videoDrivers = ["modesetting"];
            services.xserver.windowManager.i3.enable = true;
            services.xserver.windowManager.i3.package = pkgs.i3-gaps;
            services.xserver.xkbOptions = "altwin:swap_lalt_lwin,ctrl:nocaps,terminate:ctrl_alt_bksp";
            sound.enable = true;
            sound.mediaKeys.enable = true;
            swapDevices = [{device = "/dev/disk/by-uuid/e3b45cba-578e-46b9-8633-c6b67f9a556d";}];
            users.groups.users = {};
            users.groups.wheel = {};
            virtualisation.oci-containers.backend = "podman";
            virtualisation.podman.dockerCompat = true;
            virtualisation.podman.dockerSocket.enable = true;
            virtualisation.podman.enable = true;

            systemd = {
              services.dnscrypt-proxy2.serviceConfig.StateDirectory = lib.mkForce "dnscrypt-proxy2";
            };

            security.pam.u2f = {
              enable = true;
              control = "sufficient";
              authFile = pkgs.writeText "u2f-authFile" (lib.concatStringsSep "\n" [
                "${prefs.user.login}:PbfYUgHNUk54RUZu7mOz9DjZ1cYajfXJMQqpVH+jOgoBEyfDmH6JGoJy+zrixAkAjfJxJHdoI7AOhX3rvUfWyQ==,JzU6nKSnlWdd8kpjfIkihYV9AXxTAyNfzdF83haYD9fCsHoBfqKj/pw4xbkl+dl3nOGoOvvgUQcaFHgjVtwYVA==,es256,+presence"
              ]);
            };

            security.sudo = {
              enable = true;
              extraRules = [
                {
                  users = [prefs.user.login];
                  runAs = "root";
                  commands = let
                    mostlySafe = command: {
                      inherit command;
                      options = ["SETENV" "NOPASSWD"];
                    };
                  in [
                    "ALL"
                    (mostlySafe "/run/current-system/sw/bin/journalctl")
                    (mostlySafe "/run/current-system/sw/bin/nix-collect-garbage")
                    (mostlySafe "/run/current-system/sw/bin/nixos-rebuild")
                    (mostlySafe "/run/current-system/sw/bin/poweroff")
                    (mostlySafe "/run/current-system/sw/bin/reboot")
                    (mostlySafe "/run/current-system/sw/bin/shutdown")
                    (mostlySafe "/run/current-system/sw/bin/systemd-cgls")
                    (mostlySafe "/run/current-system/sw/bin/system-rebuild")
                    (mostlySafe "/run/current-system/sw/bin/system-repl")
                    (mostlySafe "/run/current-system/sw/bin/systemd-cgtop")
                    (mostlySafe "/run/current-system/sw/bin/vpn")
                    (mostlySafe "/run/current-system/sw/bin/dmesg")
                    (mostlySafe "/run/current-system/sw/bin/systemctl")
                  ];
                }
              ];
            };

            services.dnscrypt-proxy2 = {
              enable = lib.mkForce true;
              settings = {
                # Immediately respond to A and AAAA queries for host names without a
                # domain name.
                block_unqualified = true;
                # Immediately respond to queries for local zones instead
                # of leaking them to upstream resolvers (always causing errors or
                # timeouts).
                block_undelegated = true;
                # ------------------------
                server_names = ["cloudflare" "cloudflare-ipv6" "cloudflare-security" "cloudflare-security-ipv6"];
                ipv6_servers = true;
                ipv4_servers = true;
                use_syslog = true;
                require_nolog = true;
                require_nofilter = false;
                edns_client_subnet = ["0.0.0.0/0" "2001:db8::/32"];
                require_dnssec = true;
                blocked_query_response = "refused";
                block_ipv6 = false;

                allowed_ips.allowed_ips_file =
                  /*
                  Allowed IP lists support the same patterns as IP blocklists
                  If an IP response matches an allow ip entry, the corresponding session
                  will bypass IP filters.

                  Time-based rules are also supported to make some websites only accessible at specific times of the day.
                  */
                  pkgs.writeText "allowed_ips" ''
                  '';

                cloaking_rules =
                  /*
                  Cloaking returns a predefined address for a specific name.
                  In addition to acting as a HOSTS file, it can also return the IP address
                  of a different name. It will also do CNAME flattening.
                  */
                  pkgs.writeText "cloaking_rules" ''
                    # The following rules force "safe" (without adult content) search
                    # results from Google, Bing and YouTube.
                      www.google.*             forcesafesearch.google.com
                      www.bing.com             strict.bing.com
                      =duckduckgo.com          safe.duckduckgo.com
                      www.youtube.com          restrictmoderate.youtube.com
                      m.youtube.com            restrictmoderate.youtube.com
                      youtubei.googleapis.com  restrictmoderate.youtube.com
                      youtube.googleapis.com   restrictmoderate.youtube.com
                      www.youtube-nocookie.com restrictmoderate.youtube.com
                  '';

                forwarding_rules = let
                  iDNS = nixpkgs.lib.concatStringsSep "," prefs.dns.v4.ns;
                in
                  pkgs.writeText "forwarding_rules" ''
                    do.co ${iDNS}
                    *.do.co ${iDNS}
                    internal.digitalocean.com ${iDNS}
                    *.internal.digitalocean.com ${iDNS}
                    10.in.arpa ${iDNS}
                  '';
                cloak_ttl = 600;
                allowed_names.allowed_names_file = pkgs.writeText "allowed_names" "";
                blocked_names.blocked_names_file = pkgs.writeText "blocked_names" "";
                blocked_ips.blocked_ips_file = pkgs.writeText "blocked_ips" "";
                query_log.file = "/dev/stdout";
                query_log.ignored_qtypes = ["DNSKEY"];
                blocked_names.log_file = "/dev/stdout";
                allowed_ips.log_file = "/dev/stdout";
                blocked_ips.log_file = "/dev/stdout";
                allowed_names.log_file = "/dev/stdout";
                sources = {
                  public-resolvers = {
                    urls = [
                      "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                      "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
                    ];
                    cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
                    minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                    refresh_delay = 72;
                    prefix = "";
                  };
                  relays = {
                    urls = [
                      "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
                      "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
                      "https://ipv6.download.dnscrypt.info/resolvers-list/v3/relays.md"
                      "https://download.dnscrypt.net/resolvers-list/v3/relays.md"
                    ];
                    cache_file = "/var/lib/dnscrypt-proxy2/relays.md";
                    minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                    refresh_delay = 72;
                    prefix = "";
                  };
                  odoh-servers = {
                    urls = [
                      "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-servers.md"
                      "https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
                      "https://ipv6.download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
                      "https://download.dnscrypt.net/resolvers-list/v3/odoh-servers.md"
                    ];
                    cache_file = "/var/lib/dnscrypt-proxy2/odoh-servers.md";
                    minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                    refresh_delay = 24;
                    prefix = "";
                  };
                  odoh-relays = {
                    urls = [
                      "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-relays.md"
                      "https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
                      "https://ipv6.download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
                      "https://download.dnscrypt.net/resolvers-list/v3/odoh-relays.md"
                    ];
                    cache_file = "/var/lib/dnscrypt-proxy2/odoh-relays.md";
                    minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                    refresh_delay = 24;
                    prefix = "";
                  };
                };
              };
            };

            boot.extraModulePackages = with pkgs; [
              linuxPackages_latest.acpi_call
              linuxPackages_latest.cpupower
              tpm2-tools
              tpm2-tss
              i2c-tools
            ];

            environment.systemPackages =
              (builtins.map (p: pkgs."${p}") prefs.packages.global)
              ++ (with pkgs; [
                xorg.xev
                xorg.xprop
                (pkgs.writeShellScriptBin "list-git-vars" "${lib.getExe pkgs.bat} -l=ini --file-name 'git var -l (sorted)' <(${lib.getExe pkgs.git} var -l | sort)")
                (pkgs.writeShellScriptBin "system-rebuild" "nixos-rebuild --flake '${prefs.repo.path}#${prefs.host.name}' $@")
                (pkgs.writeShellApplication {
                  name = "system-repl";
                  runtimeInputs = with pkgs; [gum nix];
                  text = let
                    hostName = prefs.host.name;
                    entrypoint = pkgs.writeText "entrypoint.nix" ''
                      rec {
                      inherit (flake.outputs.nixosConfigurations."${hostName}") pkgs lib options config;
                      inherit (flake.inputs) nixpkgs do-nixpkgs nixos-hardware;
                      flake = builtins.getFlake "${prefs.repo.path}";
                      # flake = builtins.getFlake "${self}";
                      hostName = "${hostName}";
                      system = "${system}";
                      }
                    '';
                  in ''
                    exec nix repl ${entrypoint}
                  '';
                })

                (pkgs.writeShellApplication {
                  name = "alacritty";
                  runtimeInputs = [alacritty terminus-nerdfont xcwd];
                  text = lib.concatStringsSep " " [
                    "exec alacritty"
                    "--working-directory=\"$(xcwd)\""
                    "--config-file='${writeText "alacritty.yml" (builtins.toJSON rec {
                      cursor.style.blinking = "On";
                      cursor.style.shape = "block";
                      env.TERM = "xterm-new";
                      font.builtin_box_drawing = false;
                      font.glyph_offset.x = -1;
                      font.glyph_offset.y = -1;
                      font.normal.family = "TerminessTTF Nerd Font Mono";
                      font.offset.x = 0;
                      font.offset.y = 1;
                      font.size = 9.5;
                      live_config_reload = false;
                      mouse.hide_when_typing = true;
                      selection.save_to_clipboard = true;
                      window.dynamic_padding = true;
                      window.padding.x = 5;
                      window.padding.y = 5;
                    })}'"
                    "\"$@\""
                  ];
                })
                (pkgs.writeShellApplication {
                  name = "rofi";
                  runtimeInputs = [rofi terminus-nerdfont];
                  text = lib.concatStringsSep " " [
                    "exec rofi"
                    "-markup"
                    "-modi drun,ssh,window,run"
                    "-font 'TerminessTTF Nerd Font Mono 12'"
                    "\"$@\""
                  ];
                })
              ]);

            # This value determines the NixOS release from which the default
            # settings for stateful data, like file locations and database versions
            # on your system were taken. It‘s perfectly fine and recommended to leave
            # this value at the release version of the first install of this system.
            # Before changing this value read the documentation for this option
            # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
            system.stateVersion = lib.mkForce "22.05";
          })
        ];
    };
  };
}
