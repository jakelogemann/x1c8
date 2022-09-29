{
  flakeDir ? builtins.getEnv "PWD",
  self ? (with builtins; getFlake (toString flakeDir)),
  nixpkgs ? self.inputs.nixpkgs,
  fnctl ? self.inputs.fnctl,
  do-nixpkgs ? self.inputs.do-nixpkgs,
  ...
}:
nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  specialArgs = {
    inherit flakeDir self nixpkgs do-nixpkgs system;
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
    stateVersion = "22.05";
    hostName = "laptop";
    userName = "jlogemann";
    userEmail = "jlogemann@digitalocean.com";
    userFullName = "Jake Logemann";
    dnsServers = nixpkgs.lib.concatStringsSep "," [
      "10.124.57.141"
      "10.124.57.160"
    ];
    enableDocs = false;
  };
  modules = [
    ({
      config,
      lib,
      pkgs,
      userName,
      hostName,
      stateVersion,
      ...
    }:
      with builtins;
      with lib;
      with specialArgs; {
        imports = [
          do-nixpkgs.nixosModules.kolide-launcher
          # do-nixpkgs.nixosModules.sentinelone
          self.inputs.fnctl.inputs.hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
        ];
        system.stateVersion = lib.mkForce specialArgs.stateVersion;
        boot = {
          binfmt.emulatedSystems = ["aarch64-linux"];
          enableContainers = true;
          extraModprobeConfig = "options kvm_intel nested=1";
          # kernel.sysctl."kernel.modules_disabled" = 1;
          initrd.availableKernelModules = ["nvme" "usb_storage" "sd_mod"];
          initrd.kernelModules = ["dm-snapshot" "br_netfilter"];
          initrd.luks.devices.root.allowDiscards = true;
          initrd.luks.devices.root.device = "/dev/disk/by-uuid/c680bcae-9d30-4845-825c-225666887138";
          initrd.luks.devices.root.preLVM = true;
          loader.grub.configurationLimit = 10;
          kernel.sysctl."kernel.dmesg_restrict" = 1;
          kernel.sysctl."kernel.kptr_restrict" = 2;
          kernel.sysctl."kernel.perf_event_paranoid" = 3;
          kernel.sysctl."kernel.randomize_va_space" = 2;
          kernel.sysctl."kernel.sysrq" = 0;
          kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;
          kernel.sysctl."net.core.bpf_jit_harden" = 2;
          kernel.sysctl."net.ipv4.conf.all.accept_redirects" = 1;
          kernel.sysctl."net.ipv4.conf.all.log_martians" = 1;
          kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 0;
          kernel.sysctl."net.ipv4.conf.all.rp_filter" = 1;
          kernel.sysctl."net.ipv4.conf.all.send_redirects" = 0;
          kernel.sysctl."net.ipv4.conf.default.accept_redirects" = 0;
          kernel.sysctl."net.ipv6.conf.all.accept_redirects" = 0;
          kernel.sysctl."vm.swappiness" = 1;
          kernel.sysctl."net.ipv6.conf.default.accept_redirects" = 0;
          kernelParams = ["acpi_osi=\"Linux\"" "i8042.reset=1" "i8042.nomux=1"];
          kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
          loader.systemd-boot.enable = true;
          supportedFilesystems = lib.mkForce ["btrfs" "vfat"];
          kernelModules = [
            "xhci_pci"
            "acpi_call"
            "btusb"
            "iwlmvm"
            "kvm-intel"
            "br_netfilter"
            "mei_me"
            "ext2"
            "sd_mod"
            "drm"
            "i915"
            "tpm_tis"
            "snd_hda_intel"
          ];
        };

        console = {
          earlySetup = true;
          font = "Lat2-Terminus16";
          useXkbConfig = true;
        };

        users.users.${userName} = {
          extraGroups = ["users" "wheel" "systemd-journal" "networkmanager" userName];
          group = userName;
          initialPassword = "";
          home = "/home/${userName}";
          shell = pkgs.zsh;
          uid = 1000;
          isNormalUser = true;
        };
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

        programs.gnupg.agent.enable = true;
        programs.gnupg.agent.enableSSHSupport = true;
        programs.gnupg.agent.enableBrowserSocket = true;
        programs.ssh.startAgent = false;
        programs.ssh.setXAuthLocation = false;
        programs.ssh.forwardX11 = false;
        # programs.ssh.ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
        # programs.ssh.macs = ["hmac-sha2-512-etm@openssh.com" "hmac-sha1"];
        programs.ssh.hostKeyAlgorithms = ["ecdsa-sha2-nistp256" "ssh-ed25519" "ssh-rsa"];
        # programs.ssh.kexAlgorithms = ["curve25519-sha256@libssh.org" "diffie-hellman-group-exchange-sha256"];
        documentation.enable = true;
        documentation.dev.enable = enableDocs;
        documentation.doc.enable = true;
        documentation.man.enable = true;
        documentation.man.generateCaches = enableDocs;
        documentation.man.man-db.enable = true;
        documentation.nixos.includeAllModules = true;
        documentation.nixos.options.warningsAreErrors = false;
        programs.git.config.alias.aliases = "config --show-scope --get-regexp alias";
        programs.git.config.alias.amend = "commit --amend";
        programs.git.config.alias.amendall = "commit --amend --all";
        programs.git.config.alias.amendit = "commit --amend --no-edit";
        programs.git.config.alias.branches = "branch --all";
        programs.git.config.alias.l = "log --pretty=oneline --graph --abbrev-commit";
        programs.git.config.alias.quick-rebase = "rebase --interactive --root --autosquash --autostash";
        programs.git.config.alias.remotes = "remote --verbose";
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
        programs.git.lfs.enable = mkDefault true;
        users.groups.${userName}.gid = 990;
        users.groups.users = {};
        users.groups.wheel = {};
        # virtualisation.docker.rootless.daemon.settings.fixed-cidr-v6 = "fd00::/80";
        # virtualisation.docker.rootless.daemon.settings.ipv6 = true;
        environment.pathsToLink = ["/share/zsh"];
        environment.shellAliases.git-vars = "${lib.getExe pkgs.bat} -l=ini --file-name 'git var -l' <(git var -l)";
        environment.shellAliases.l = "ls -alh";
        environment.variables.EDITOR = lib.getExe pkgs.neovim;
        environment.shellAliases.la = "${lib.getExe pkgs.lsd} -a";
        environment.shellAliases.ll = "${lib.getExe pkgs.lsd} -l";
        environment.shellAliases.lla = "${lib.getExe pkgs.lsd} -la";
        environment.shellAliases.ls = lib.getExe pkgs.lsd;
        environment.shellAliases.lt = "${lib.getExe pkgs.lsd} --tree";
        fileSystems."/".device = "/dev/disk/by-uuid/45264d57-59a7-428b-a85a-35fa35c1ddeb";
        fonts.fontconfig.enable = true;
        fonts.fontconfig.antialias = true;
        fonts.fontconfig.hinting.autohint = true;
        fonts.fontconfig.hinting.style = "hintslight";
        fonts.fonts = with pkgs; [dejavu_fonts terminus-nerdfont];
        fonts.fontconfig.defaultFonts.serif = ["DejaVu Serif"];
        fonts.fontconfig.defaultFonts.sansSerif = ["DejaVu Sans"];
        fonts.fontconfig.defaultFonts.monospace = ["TerminessTTF Nerd Font Mono" "DejaVu Sans Mono"];
        fonts.fontconfig.defaultFonts.emoji = ["Noto Color Emoji"];
        fonts.enableDefaultFonts = true;
        fileSystems."/".fsType = "btrfs";
        fileSystems."/boot".device = "/dev/disk/by-uuid/6696-7F45";
        fileSystems."/boot".fsType = "vfat";
        hardware.cpu.intel.updateMicrocode = true;
        hardware.gpgSmartcards.enable = true;
        hardware.ksm.enable = true;
        hardware.mcelog.enable = true;
        hardware.opengl.enable = true;
        hardware.opengl.extraPackages = with pkgs; [intel-compute-runtime];
        hardware.pulseaudio.enable = true;
        nix.daemonCPUSchedPolicy = "idle";
        nix.daemonIOSchedPriority = 3;
        nix.settings.experimental-features = ["nix-command" "flakes"];
        nix.settings.allow-dirty = true;
        nix.settings.log-lines = 50;
        nix.settings.warn-dirty = false;
        nix.settings.max-free = 64 * 1024 * 1024 * 1024;
        nix.optimise.automatic = true;
        nix.optimise.dates = ["daily"];
        nix.gc.automatic = true;
        nix.gc.dates = "daily";
        nix.settings.auto-optimise-store = true;
        nix.settings.allowed-users = ["root" userName];
        nix.settings.trusted-users = ["root" userName];
        nix.registry.fnctl.flake = self.inputs.fnctl;
        nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
        nix.registry.do-nixpkgs.flake = self.inputs.do-nixpkgs;
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = lib.mkForce [self.overlays.default];
        powerManagement.cpuFreqGovernor = "powersave";
        services.acpid.enable = true;
        services.earlyoom.enable = true;
        services.earlyoom.freeMemThreshold = 10;
        services.earlyoom.freeSwapThreshold = 10;
        services.fwupd.enable = true;
        services.journald.extraConfig = lib.concatStringsSep "\n" ["SystemMaxUse=1G"];
        services.journald.forwardToSyslog = false;
        services.kolide-launcher.enable = true;
        services.kolide-launcher.secretFilepath = "/home/${userName}/.do/kolide.secret";
        # services.sentinelone.enable = true;
        services.tlp.enable = true;
        services.upower.enable = true;
        services.xserver.autorun = true;
        services.xserver.displayManager.autoLogin.enable = true;
        services.xserver.displayManager.autoLogin.user = userName;
        services.xserver.displayManager.defaultSession = "none+i3";
        services.xserver.enable = true;
        services.xserver.enableCtrlAltBackspace = true;
        services.xserver.layout = "us";
        services.xserver.libinput.touchpad.disableWhileTyping = true;
        services.xserver.videoDrivers = ["modesetting"];
        services.xserver.windowManager.i3.enable = true;
        services.xserver.windowManager.i3.package = pkgs.i3-gaps;
        services.xserver.xkbOptions = "altwin:swap_lalt_lwin,ctrl:nocaps,terminate:ctrl_alt_bksp";
        services.autorandr = {
          enable = false;
          hooks.postswitch."notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
          hooks.postswitch."change-dpi" = ''
            case "$AUTORANDR_CURRENT_PROFILE" in
            default) DPI=160 ;;
            dual|left|right) DPI=90 ;;
            *) echo "Unknown profle: $AUTORANDR_CURRENT_PROFILE" && exit 1 ;;
            esac; echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
          '';

          profiles = let
            fingerprints = {
              builtin = "00ffffffffffff0009e5db0700000000011c0104a51f1178027d50a657529f27125054000000010101010101010101010101010101013a3880de703828403020360035ae1000001afb2c80de703828403020360035ae1000001a000000fe00424f452043510a202020202020000000fe004e4531343046484d2d4e36310a0043";
              left = "00ffffffffffff0010acb1414c534541341e0103803c2278eeee95a3544c99260f5054a54b00e1c0d100d1c0b300a94081808100714f08e80030f2705a80b0588a0055502100001e000000ff0037574e354332330a2020202020000000fc0044454c4c205532373230510a20000000fd00184b1e8c3c000a2020202020200173020343f15261605f5e5d101f051404131211030207060123097f07830100006d030c001000383c20006001020367d85dc401788003e20f03e305ff01e6060701605628565e00a0a0a029503020350055502100001a114400a0800025503020360055502100001a0000000000000000000000000000000000000000000000007d";
              right = "00ffffffffffff0010acb7414c4b4241341e0104b53c22783eee95a3544c99260f5054a54b00e1c0d100d1c0b300a94081808100714f4dd000a0f0703e803020350055502100001a000000ff00424e4e354332330a2020202020000000fd00184b1e8c36010a202020202020000000fc0044454c4c205532373230510a200187020324f14c101f2005140413121103020123097f0783010000e305ff01e6060701605628a36600a0f0703e803020350055502100001a565e00a0a0a029503020350055502100001a114400a0800025503020360055502100001a0000000000000000000000000000000000000000000000000000000000000000000000000014";
            };
          in {
            default.fingerprint.eDP-1 = fingerprints.builtin;
            default.config.eDP-1.enable = true;
            default.config.eDP-1.primary = true;
            default.config.eDP-1.rotate = "normal";
            default.config.eDP-1.dpi = 160;
            default.config.eDP-1.mode = "1920x1080";
            default.config.eDP-1.position = "0x0";

            left.fingerprint.HDMI-1 = fingerprints.left;
            left.config.HDMI-1.enable = true;
            left.config.HDMI-1.primary = true;
            left.config.HDMI-1.rotate = "90";
            left.config.HDMI-1.mode = "2048x1152";
            left.config.HDMI-1.position = "0x0";

            right.fingerprint.DP-2 = fingerprints.right;
            right.config.DP-2.enable = true;
            right.config.DP-2.primary = true;
            right.config.DP-2.rotate = "90";
            right.config.DP-2.mode = "2048x1152";
            right.config.DP-2.position = "0x0";

            dual.fingerprint.HDMI-1 = fingerprints.left;
            dual.config.HDMI-1.enable = true;
            dual.config.HDMI-1.primary = true;
            dual.config.HDMI-1.rotate = "90";
            dual.config.HDMI-1.mode = "2048x1152";
            dual.config.HDMI-1.position = "0x0";

            dual.fingerprint.DP-2 = fingerprints.right;
            dual.config.DP-2.enable = true;
            dual.config.DP-2.primary = true;
            dual.config.DP-2.rotate = "90";
            dual.config.DP-2.mode = "2048x1152";
            dual.config.DP-2.position = "1152x0";
          };
        };
        sound.enable = true;
        sound.mediaKeys.enable = true;
        swapDevices = [{device = "/dev/disk/by-uuid/e3b45cba-578e-46b9-8633-c6b67f9a556d";}];
        system.nixos.tags = ["digitalocean"];

        virtualisation.oci-containers = {
          backend = "podman";
        };

        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
        };
        programs.ssh.extraConfig = builtins.readFile ./files/ssh_config;

        programs.tmux = {
          enable = true;
          aggressiveResize = true;
          newSession = true;
          baseIndex = 1;
          reverseSplit = true;
          secureSocket = true;
          shortcut = "a";
          terminal = "tmux-256color";
          plugins = with pkgs.tmuxPlugins; [pain-control onedark-theme sensible];
        };

        programs.starship = {
          enable = true;
          settings.add_newline = false;
          settings.format = "$character";
          settings.right_format = "$all";
          settings.scan_timeout = 10;
          settings.character.success_symbol = "[➜](bold green)";
          settings.character.error_symbol = "[➜](bold red)";
          settings.character.vicmd_symbol = "[](bold magenta)";
          #settings.character.continuation_prompt = "[▶▶](dim cyan)";
        };

        programs.zsh = {
          enable = true;
          enableBashCompletion = true;
          enableCompletion = true;
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;
          syntaxHighlighting.highlighters = ["main" "brackets" "pattern" "root" "line"];
          syntaxHighlighting.styles.alias = "fg=magenta,bold";
          vteIntegration = true;
          autosuggestions.extraConfig.ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
          autosuggestions.highlightStyle = "fg=cyan";
          autosuggestions.strategy = ["completion"];
          histFile = "$HOME/.zsh_history";
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
          histSize = 100000;
          promptInit = ''
            autoload -Uz promptinit colors bashcompinit compinit && compinit && bashcompinit && promptinit && colors;
            eval "$(${getExe pkgs.starship} init zsh)"
          '';

          shellInit = with pkgs; ''
            zstyle ':vcs_info:*' enable git cvs svn hg
            eval "$(${lib.getExe direnv} hook zsh)"
            hash -d current-sw=/run/current-system/sw
            hash -d booted-sw=/run/booted-system/sw
            autoload -U edit-command-line; zle -N edit-command-line;
            bindkey '\\C-x\\C-e' edit-command-line
            bindkey '\\C-k' up-line-or-history
            bindkey '\\C-j' down-line-or-history
            bindkey '\\C-h' backward-word
            bindkey '\\C-l' forward-word
            source "${skim}/share/skim/completion.zsh"
            source "${skim}/share/skim/key-bindings.zsh"
            eval "$(${lib.getExe navi} widget zsh)"
            eval "$(${lib.getExe zoxide} init zsh)"
          '';
        };

        security = {
          # pki.certificateFiles = [ pkgs.do-nixpkgs.sammyca ];
          allowUserNamespaces = true;
          forcePageTableIsolation = true;
          rtkit.enable = true;
          tpm2.enable = true;
          virtualisation.flushL1DataCache = "always";
          protectKernelImage = true;
          polkit.adminIdentities = ["unix-user:${userName}"];

          pam.u2f.enable = true;
          pam.u2f.control = "sufficient";
          pam.u2f.authFile = pkgs.writeText "u2f-authFile" (lib.concatStringsSep "\n" [
            "${userName}:PbfYUgHNUk54RUZu7mOz9DjZ1cYajfXJMQqpVH+jOgoBEyfDmH6JGoJy+zrixAkAjfJxJHdoI7AOhX3rvUfWyQ==,JzU6nKSnlWdd8kpjfIkihYV9AXxTAyNfzdF83haYD9fCsHoBfqKj/pw4xbkl+dl3nOGoOvvgUQcaFHgjVtwYVA==,es256,+presence"
          ]);

          sudo = {
            enable = true;
            extraRules = [
              {
                users = [userName];
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
                  (mostlySafe "/run/current-system/sw/bin/systemd-cgtop")
                  (mostlySafe "/run/current-system/sw/bin/vpn")
                  (mostlySafe "/run/current-system/sw/bin/dmesg")
                  (mostlySafe "/run/current-system/sw/bin/systemctl")
                ];
              }
            ];
          };
        };

        networking = {
          enableIPv6 = true;
          firewall.allowPing = true;
          firewall.allowedTCPPorts = [];
          firewall.allowedUDPPorts = [];
          firewall.autoLoadConntrackHelpers = true;
          firewall.checkReversePath = true;
          firewall.enable = true;
          firewall.logRefusedConnections = true;
          firewall.logRefusedPackets = true;
          firewall.logReversePathDrops = true;
          firewall.pingLimit = "--limit 1/minute --limit-burst 5";
          firewall.rejectPackets = true;
          nameservers = mkForce ["127.0.0.1" "::1"];
          resolvconf.enable = mkForce false;
          dhcpcd.extraConfig = mkForce "nohook resolv.conf";
          networkmanager.dns = mkForce "none";
          hostName = hostName;
          domain = "local";

          interfaces.enp45s0u2u3 = {
            useDHCP = true;
            macAddress = "00:e0:4c:20:02:5e";

            # ipv4.addresses = [{ address = "192.168.8.77"; prefixLength = 24; }];
            # ipv4.routes = [{ address = "192.168.8.0"; prefixLength = 24; via = "192.168.8.1"; }];
          };

          interfaces.enp45s0u1u3u2c2 = {
            useDHCP = true;
            # ipv4.addresses = [{ address = "192.168.8.77"; prefixLength = 24; }];
            # ipv4.routes = [{ address = "192.168.8.0"; prefixLength = 24; via = "192.168.8.1"; }];
          };
          networkmanager.enable = true;
          useDHCP = false;
          useHostResolvConf = true;
          wireless.enable = false;
          wireless.iwd.enable = false;
          wireless.userControlled.enable = true;
          networkmanager.wifi.powersave = true;
          networkmanager.plugins = with pkgs; [networkmanager-openconnect];
        };

        services.dnscrypt-proxy2 = {
          enable = mkForce true;
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

            forwarding_rules = pkgs.writeText "forwarding_rules" ''
              internal.digitalocean.com ${dnsServers}
              *.internal.digitalocean.com ${dnsServers}
              10.in.arpa ${dnsServers}
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

        # systemd.network.links."10-mon0" = { matchConfig.PermanentMACAddress = "08:92:04:d4:a6:59"; linkConfig.Name = "mon0"; };

        systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = mkForce "dnscrypt-proxy2";
        boot.extraModulePackages = with pkgs; [
          linuxPackages_latest.acpi_call
          linuxPackages_latest.cpupower
          tpm2-tools
          tpm2-tss
          i2c-tools
        ];
        environment.systemPackages = with pkgs;
          [
            (pkgs.writeShellScriptBin "jf" "exec docker run --rm -it --mount type=bind,source=\"$HOME/.jfrog\",target=/root/.jfrog 'releases-docker.jfrog.io/jfrog/jfrog-cli-v2-jf' jf \"$@\"")
            (pkgs.writeShellScriptBin "list-git-vars" "${lib.getExe bat} -l=ini --file-name 'git var -l (sorted)' <(${lib.getExe git} var -l | sort)")
            (pkgs.writeShellScriptBin "system-repl" (let
              entrypoint = ''
                rec {
                  inherit (flake.outputs.nixosConfigurations."${hostName}") pkgs lib options;
                  currentConfig = flake.outputs.nixosConfigurations."${hostName}".config;
                  inherit (flake.inputs) nixpkgs;
                  flake = builtins.getFlake "${self}";
                  hostName = "${hostName}";
                  system = "${system}";
                }
              '';
            in "exec nix repl \"$@\" ${writeText "entrypoint.nix" entrypoint}"))

            commonUtils
            aide
            alejandra
            docker-credential-helpers
            expect
            jless
            lynis
            navi
            yubikey-manager
            ossec
            ranger
            dogdns
            shellcheck
            buildah
            skopeo
            nerdctl
            _1password
          ]
          ++ lib.optionals (config.services.xserver.enable) (with pkgs; [
            arandr
            scrot
            firefox
            flameshot
            xbindkeys
            xclip
            xdotool
            xorg.xev
            xorg.xprop
            _1password-gui

            (pkgs.writeShellApplication {
              name = "alacritty";
              runtimeInputs = [alacritty terminus-nerdfont xcwd];
              text = let
                config = rec {
                  cursor.style.blinking = "On";
                  cursor.style.shape = "block";
                  env.TERM = "alacritty";
                  font.builtin_box_drawing = false;
                  font.glyph_offset.x = -1;
                  font.glyph_offset.y = -1;
                  font.normal.family = "TerminessTTF Nerd Font Mono";
                  font.offset.x = 0;
                  font.offset.y = 1;
                  font.size = 9.5;
                  # font.use_thin_strokes = true;
                  live_config_reload = false;
                  mouse.hide_when_typing = true;
                  selection.save_to_clipboard = true;
                  window.dynamic_padding = true;
                  window.padding.x = 5;
                  window.padding.y = 5;
                };
              in
                lib.concatStringsSep " " [
                  "exec alacritty"
                  "--working-directory=\"$(xcwd)\""
                  "--config-file='${writeText "alacritty.yml" (builtins.toJSON config)}'"
                  "\"$@\""
                ];
            })

            (pkgs.writeShellApplication {
              name = "rofi";
              runtimeInputs = [rofi terminus-nerdfont];
              text = let
              in
                lib.concatStringsSep " " [
                  "exec rofi"
                  "-markup"
                  "-modi drun,ssh,window,run"
                  "-font 'TerminessTTF Nerd Font Mono 12'"
                  "\"$@\""
                ];
            })
          ])
          ++ lib.optionals (builtins.hasAttr "do-nixpkgs" pkgs) (with pkgs.do-nixpkgs; [
            (pkgs.writeShellScriptBin "data_bags" "cd ~/do/chef/data_bags && ${lib.getExe jless} $(find . -mindepth 1 -type f -name '*.json' | ${skim}/bin/sk)")
            dao
            do-xdg
            fly
            gh
            ghe
            staff-cert
            vault
            vpn
            (symlinkJoin {
              name = "cthulhu-bins";
              paths = [
                (pkgs.writeShellScriptBin "show-cthulhu-bins" "clear; dir=\"$(dirname $(readlink $(which docc)))\"; echo \"$dir contains: \" && ${lib.getExe lsd} --date=relative -lFLAh \"$dir\"; echo; jump --version; echo; docc --version;")
                artifactctl
                autoreview
                certdump
                deployer
                deptrackerd
                docc
                gitdash
                gtartifacts
                hvaddrctl
                hvannouncectl
                hvrouterctl
                ipamgetctl
                jump
                netsecpolctl
                northctl
                plinkoctl
                respondctl
                rmetadatactl
                rmetadataflowctl
                southctl
                tracectl

                ## !Work on my machine ::
                #project-engineroom             ## missing librados, zlib.pc
                #project-evacuator              ## missing zlib.pc
                #project-hvd                    ## missing librados, libguestfs.
                #project-hvdropletmetrics       ## missing libvirt.pc
                #project-imgdev                 ## missing zlib.pc
                #project-libvirt-hook-processor ## missing libvirt.pc
                #project-mongo-agent            ## missing libsystemd ("systemd/sd-journal.h")
                #project-octopus                ## missing libvirt.pc
                #project-puffer                 ## missing zlib.pc
              ];
            })
          ]);
      })
  ];
}
# vim: ft=nix fdm=indent fdl=0 fen fdo=all fcl=all

