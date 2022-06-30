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
      with lib; {
        imports = [
          do-nixpkgs.nixosModules.kolide-launcher
          # do-nixpkgs.nixosModules.sentinelone
          self.inputs.fnctl.inputs.hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
          self.inputs.home-manager.nixosModules.home-manager
          ./network.nix
          ./home.nix
          ./pkgs.nix
        ];
        system.stateVersion = lib.mkForce stateVersion;
        boot = {
          # kernel.sysctl."kernel.modules_disabled" = 1;
          initrd.availableKernelModules = ["nvme" "usb_storage" "sd_mod"];
          initrd.kernelModules = ["dm-snapshot" "br_netfilter"];
          initrd.luks.devices.root.allowDiscards = true;
          initrd.luks.devices.root.device = "/dev/disk/by-uuid/c680bcae-9d30-4845-825c-225666887138";
          initrd.luks.devices.root.preLVM = true;
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

        programs.git.config.aliases.aliases = "!git config --get-regexp '^alias\.' | sed -e 's/^alias\.//' -e 's/\ /\ =\ /'";
        programs.git.config.aliases.amend = "git commit --amend --no-edit";
        programs.git.config.aliases.amendall = "git commit --all --amend --edit";
        programs.git.config.aliases.amendit = "git commit --amend --edit";
        programs.git.config.aliases.b = "branch -lav";
        programs.git.config.aliases.force-push = "push --force-with-lease=+HEAD";
        programs.git.config.aliases.fp = "fetch --all --prune";
        programs.git.config.aliases.lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        programs.git.config.aliases.lglc = "log --not --remotes --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        programs.git.config.aliases.lglcd = "submodule foreach git log --branches --not --remotes --oneline --decorate";
        programs.git.config.aliases.loga = "log --graph --decorate --name-status --all";
        programs.git.config.aliases.quick-rebase = "rebase --interactive --root --autosquash --auto-stash";
        programs.git.config.aliases.remotes = "!git remote -v | sort -k3";
        programs.git.config.aliases.st = "status -uno";
        programs.git.config.commit.gpgSign = false;
        programs.git.config.core.pager = lib.getExe pkgs.delta;
        programs.git.config.core.editor = lib.getExe pkgs.neovim;
        programs.git.config.interactive.difffilter = "${lib.getExe pkgs.delta} --color-only";
        programs.git.config.pull.ff = true;
        programs.git.config.pull.rebase = true;
        programs.git.config.user.email = specialArgs.userEmail;
        programs.git.config.user.name = specialArgs.userFullName;
        programs.git.config.init.defaultBranch = "main";
        programs.git.config.url."https://github.com/".insteadOf = ["gh:" "github:"];
        programs.git.enable = true;
        programs.git.lfs.enable = true;
        users.groups.${userName}.gid = 990;
        users.groups.users = {};
        users.groups.wheel = {};
        # security.pki.certificateFiles = [ pkgs.do-nixpkgs.sammyca ];
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
        fonts.fontconfig.defaultFonts.monospace = ["DejaVu Sans Mono"];
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
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        nix.allowedUsers = [userName];
        nix.extraOptions = ''experimental-features = nix-command flakes ca-derivations'';
        nix.gc.automatic = true;
        nix.gc.dates = "daily";
        nix.gc.options = ''--max-freed "$((30 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
        nix.settings.allowed-users = lib.mkDefault ["root" userName];
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = lib.mkForce [self.overlays.default];
        powerManagement.cpuFreqGovernor = "powersave";
        security.allowUserNamespaces = true;
        security.forcePageTableIsolation = true;
        security.rtkit.enable = true;
        security.sudo.enable = true;
        security.tpm2.enable = true;
        security.virtualisation.flushL1DataCache = "always";
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
        services.xserver.useGlamor = true;
        services.xserver.videoDrivers = ["modesetting"];
        services.xserver.windowManager.i3.enable = true;
        services.xserver.windowManager.i3.package = pkgs.i3-gaps;
        services.xserver.xkbOptions = "altwin:swap_lalt_lwin,ctrl:nocaps,terminate:ctrl_alt_bksp";
        sound.enable = true;
        sound.mediaKeys.enable = true;
        swapDevices = [{device = "/dev/disk/by-uuid/e3b45cba-578e-46b9-8633-c6b67f9a556d";}];
        system.nixos.tags = ["digitalocean"];
        virtualisation.docker.rootless.daemon.settings.default-cgroupns-mode = "private";
        virtualisation.docker.rootless.daemon.settings.default-ipc-mode = "private";
        virtualisation.docker.rootless.daemon.settings.default-runtime = "runc";
        virtualisation.docker.rootless.daemon.settings.experimental = true;
        virtualisation.docker.rootless.daemon.settings.icc = false;
        virtualisation.docker.rootless.enable = true;
        virtualisation.docker.rootless.package = pkgs.docker-edge;
        virtualisation.docker.rootless.setSocketVariable = true;

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
      })
  ];
}
