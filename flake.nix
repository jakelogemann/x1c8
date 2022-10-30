{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-templates.url = "github:nixos/templates";

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    fnctl = {
      url = "github:jakelogemann/fnctl";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hardware.follows = "nixos-hardware";
      inputs.templates.follows = "nixos-templates";
      inputs.utils.follows = "flake-utils";
      inputs.nix-filter.follows = "nix-filter";
    };

    blocklists = {
      type = "github";
      owner = "stevenblack";
      repo = "hosts";
      ref = "master";
      flake = false;
    };

    cthulhu = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "cthulhu";
      flake = false;
    };

    servicecatalog-snapshot = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "servicecatalog-snapshots";
      flake = false;
    };

    dobe = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "dobe";
      flake = false;
    };

    qemu = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "qemu";
      flake = false;
    };

    kernel = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "kernel";
      flake = false;
    };

    rolo = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "rolo";
      flake = false;
    };

    systemd = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "systemd";
      flake = false;
    };

    go-libvirt = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "go-libvirt";
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
    flake-utils,
    ...
  }: let
    /*
    preferences are loaded from a TOML file located in this directory. the data
    in here is free-form and should be kept as minimalist as possible.
    */
    prefs = builtins.fromTOML (builtins.readFile ./prefs.toml);
  in {
    overlays = {
      custom = next: prev: let
        callPackage = prev.lib.callPackageWith (prev // {inherit self prefs;});
      in rec {
        gomod2nix = self.inputs.gomod2nix.packages.${prev.system}.default;
        neovim = callPackage ./pkg/nvim {};

        my-rustools = prev.symlinkJoin {
          name = "my-rustools";
          paths = with prev; [
            llvm
            llvm-manpages
            rustup
            rusty-man
          ];
        };

        my-x11tools = prev.symlinkJoin {
          name = "my-x11tools";
          paths = with prev; [
            scrot
            _1password-gui
            arandr
            slack
            xbindkeys
            xclip
            xdotool
            kitty
            kitty-themes
            logseq
            firefox
            firefox-devedition-bin
            flameshot
          ];
        };

        my-virtools = prev.symlinkJoin {
          name = "my-virtools";
          paths = with prev; [
            act
            actionlint
            buildah
            docker-credential-helpers
            firecracker
            k9s
            kubectl
            nerdctl
            packer
            qemu_full
            skopeo
          ];
        };

        my-systools = prev.symlinkJoin {
          name = "my-systools";
          paths = with prev; [
            bpftools
            dmidecode
            dnsutils
            dogdns
            glxinfo
            hddtemp
            ipmitool
            lsb-release
            lsof
            lynis
            mtr
            pciutils
            pinentry
            pstree
            psutils
            shellcheck
            sysstat
            tree
            usbutils
            whois
            wireguard-tools
          ];
        };

        my-commontools = prev.symlinkJoin {
          name = "my-commontools";
          paths = with prev; [
            dasel
            bat
            coreutils
            skim
            cue
            ranger
            ripgrep
            file
            gh
            git-cliff
            gnugrep
            gnumake
            gnupg
            gnused
            gnutar
            gum
            jq
            lsd
            unrar
            unzip
            zip
          ];
        };

        my-gotools = prev.symlinkJoin {
          name = "my-gotools";
          paths = with prev; [
            go
            grpcurl
            gomod2nix
            go-cve-search
            godef
            gofumpt
            golangci-lint
            golangci-lint-langserver
            golint
            gomod2nix
            gopls
            goreleaser
            goss
          ];
        };
      };
      /*
      this is a wrapper around the do-nixpkgs repo (with my (experimental!) customizations).
      */
      do-internal = next: prev:
        with prev; {
          do-nixpkgs = self.inputs.do-nixpkgs.packages.${prev.system};

          buildCthulhuBins = {
            cthulhu ? self.inputs.cthulhu,
            name ? "cthulhu-bins",
            subPackages ? [
              "doge/dorpc/protoc-gen-dorpc"
              "teams/compute/orca2/cmd/explainer"
              "teams/compute/orca2/cmd/orca2ctl"
              "teams/delivery/docc/cmd/docc"
              "teams/delivery/artifact/cmd/artifactctl"
              "teams/droplet/service/cmd/dropletctl"
              "teams/security/certtool"
              "teams/paas/apps/cmd/appctl"
              "teams/compute/k8saas/cmd/k8saasctl"
              "teams/compute/k8saas/cmd/k8saas-clusterlint"
              "teams/compute/k8saas/cmd/templatectl"
              "teams/compute/rmetadata/cmd/rmetadatactl"
            ],
            tags ? [
              "cdep"
              "ceph"
              "ceph_preview"
              "czmq"
              "guestfs"
              "nautilus"
              "rabbit"
              "without_lxc"
            ],
          }:
            buildGoModule rec {
              inherit name subPackages tags;
              ldflags = [
                "-s"
                "-w"
                "-X do/doge/version.commit=${version}"
                "-X do/doge/version.gitTreeState=clean"
              ];
              src = builtins.toString cthulhu;
              modRoot = "${src}/docode/src/do";
              vendorSha256 = null;
              version =
                if cthulhu ? "shortRev"
                then cthulhu.shortRev
                else if cthulhu ? "rev"
                then cthulhu.rev
                else "dev";
              doCheck = false;
              nativeBuildInputs = lib.concatLists [
                [cacert git gnumake jq pkg-config zlib rdkafka]
                (lib.optionals (!stdenv.isDarwin) [ceph-dev.lib])
              ];
              overrideModAttrs = _: rec {
                CGO_ENABLED = "0";
                GO111MODULE = "on";
                GOPROXY = "direct";
                GOPRIVATE = "*.internal.digitalocean.com,github.com/digitalocean";
                GOFLAGS = "-mod=vendor -trimpath";
                GONOPROXY = GOPRIVATE;
                GONOSUMDB = GOPRIVATE;
              };
            };

          do-internal = prev.symlinkJoin rec {
            name = "do-internal";
            paths = with self.inputs.do-nixpkgs.packages.${prev.system};
              [
                (prev.writeShellScriptBin name "exec dirname $(dirname $(readlink $(which $0)))")
                (prev.writeShellScriptBin "jf" "exec docker run --rm -it --mount type=bind,source=\"$HOME/.jfrog\",target=/root/.jfrog 'releases-docker.jfrog.io/jfrog/jfrog-cli-v2-jf' jf \"$@\"")
                (prev.writeShellApplication {
                  name = "ghe";
                  runtimeInputs = with prev; [gh];
                  text = prev.lib.concatStringsSep " " ["exec" "env" "GH_HOST='github.internal.digitalocean.com'" "gh" "\"$@\""];
                })
                (prev.writeShellApplication {
                  name = "vault";
                  runtimeInputs = with prev; [vault];
                  text = prev.lib.concatStringsSep " " ["exec" "env" "VAULT_CACERT=${sammyca}" "VAULT_ADDR=https://vault-api.internal.digitalocean.com:8200" "vault" "\"$@\""];
                })
                (prev.writeShellApplication {
                  name = "vpn";
                  runtimeInputs = with prev; [coreutils gnused openconnect];
                  text = let
                    _a = "$";
                    _c = "{cmd[@]}";
                  in ''
                    declare -a cmd=( openconnect )
                    cmd+=( --csd-wrapper=${prev.openconnect}/libexec/openconnect/hipreport.sh )
                    cmd+=( -F _challenge:passwd=1 )
                    cmd+=( --protocol=gp )
                    cmd+=( --non-inter --background --pid-file=/run/vpn.pid )
                    cmd+=( --os=linux-64 )
                    cmd+=( --passwd-on-stdin )
                    cmd+=( -F _login:user="$1" "https://$2.digitalocean.com/ssl-vpn" )
                    set -x; exec "${_a}${_c}"
                  '';
                })
              ]
              ++ (builtins.map (p: self.inputs.do-nixpkgs.packages."${prev.system}"."${p}") [
                # Project-based Packages
                "project-artifact"
                "project-deptracker"
                "project-dns"
                "project-docc"
                "project-droplet"
                "project-harpoon"
                "project-hvrouter"
                "project-netsecpol"
                "project-networktracerd"
                "project-north"
                "project-orca2"
                "project-plinkod"
                "project-respond"
                "project-rmetadata"
                "project-south"
                "project-telemetry"
                # Individual packages (a la carte)
                "autoreview"
                "certdump"
                "certtool"
                "deployer"
                "fly"
                "gitdash"
                "hvaddrctl"
                "hvannouncectl"
                "hvrouterctl"
                "ipamgetctl"
                "jump"
                "gen-dorpc-proto"
                "ghz"
                "jsonnet"
                "plinkoctl"
                "respondctl"
                "staff-cert"
                "tracectl"
                "vault"
              ]);
          };
        };
    };

    nixosConfigurations = {
      /*
      this is a specific host's configuration (my laptop, to be specific).
      you probably don't actually want to use this... but feel free to have a
      bowl of copy+pasta :)
      */
      laptop = nixpkgs.lib.nixosSystem rec {
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
              hardware.cpu.intel.updateMicrocode = true;
              hardware.gpgSmartcards.enable = true;
              hardware.ksm.enable = true;
              hardware.mcelog.enable = true;
              time.hardwareClockInLocalTime = true;
              time.timeZone = "America/New_York";

              boot = {
                binfmt.emulatedSystems = ["aarch64-linux"];
                enableContainers = true;
                #kernel.sysctl."kernel.modules_disabled" = 1;
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
                kernel.sysctl."net.ipv4.conf.all.accept_redirects" = 0;
                kernel.sysctl."net.ipv4.conf.all.log_martians" = 1;
                kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 0;
                kernel.sysctl."net.ipv4.conf.all.rp_filter" = 1;
                kernel.sysctl."net.ipv4.conf.all.send_redirects" = 0;
                kernel.sysctl."net.ipv4.conf.default.accept_redirects" = 0;
                kernel.sysctl."net.ipv6.conf.all.accept_redirects" = 0;
                kernel.sysctl."vm.swappiness" = 20;
                kernel.sysctl."net.ipv6.conf.default.accept_redirects" = 0;
                loader.systemd-boot.enable = true;
                supportedFilesystems = lib.mkForce ["btrfs" "vfat"];
              };

              # ssh.ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
              # ssh.kexAlgorithms = ["curve25519-sha256@libssh.org" "diffie-hellman-group-exchange-sha256"];
              # ssh.macs = ["hmac-sha2-512-etm@openssh.com" "hmac-sha1"];
              # virtualisation.docker.rootless.daemon.settings.fixed-cidr-v6 = "fd00::/80";
              # virtualisation.docker.rootless.daemon.settings.ipv6 = true;
              nix.nrBuildUsers = 8;
              powerManagement.cpuFreqGovernor = "powersave";
              console.earlySetup = true;
              console.font = "Lat2-Terminus16";
              console.useXkbConfig = true;

              documentation = {
                dev.enable = false;
                doc.enable = true;
                enable = true;
                man.enable = true;
                man.generateCaches = false;
                man.man-db.enable = true;
                nixos.includeAllModules = true;
                nixos.options.warningsAreErrors = false;
              };

              environment = {
                pathsToLink = ["/share/zsh"];
                shellAliases = {
                  git-vars = "${lib.getExe pkgs.bat} -l=ini --file-name 'git var -l' <(git var -l)";
                  l = "ls -alh";
                  la = "${lib.getExe pkgs.lsd} -a";
                  ll = "${lib.getExe pkgs.lsd} -l";
                  lla = "${lib.getExe pkgs.lsd} -la";
                  ls = lib.getExe pkgs.lsd;
                  lt = "${lib.getExe pkgs.lsd} --tree";
                  systemctl-fzf-service = "systemctl --no-pager --no-legend list-unit-files | cut -d' ' -f1 | sk -mp 'system services> '";
                  systemctl-fzf-user-service = "systemctl --user --no-pager --no-legend list-unit-files | cut -d' ' -f1 | sk -mp 'user services> '";
                  systemctl-edit = "sudo systemctl edit --full --force";
                  tmux = "tmux -2u";
                  dmesg = "sudo dmesg";
                  tf = "terraform";
                  dc = "docker compose";
                  g = "git";
                  find-broken-symlinks = "find -L . -type l 2>/dev/null";
                  rm-broken-symlinks = "find -L . -type l -exec rm -fv {} \; 2>/dev/null";
                };
                variables = {
                  EDITOR = lib.getExe pkgs.neovim;
                  BAT_STYLE = "header-filename,grid";
                  BROWSER = lib.getExe pkgs.firefox-devedition-bin;
                  PAGER = lib.getExe pkgs.bat;
                  GO111MODULE = "on";
                  GOFLAGS = "-mod=vendor";
                  GONOPROXY = "*.internal.digitalocean.com,github.com/digitalocean";
                  GONOSUMDB = "*.internal.digitalocean.com,github.com/digitalocean";
                  GOPRIVATE = "*.internal.digitalocean.com,github.com/digitalocean";
                  GOPROXY = "direct";
                  GOSUMDB = "sum.golang.org";
                  CGO_ENABLED = "0";
                };
              };

              fonts = {
                enableDefaultFonts = true;
                fonts = builtins.map (p: pkgs.${p}) prefs.packages.fonts;
                fontconfig = {
                  enable = true;
                  antialias = true;
                  defaultFonts.emoji = ["Noto Color Emoji"];
                  defaultFonts.monospace = ["DaddyTimeMono Nerd Font" "TerminessTTF Nerd Font Mono" "DejaVu Sans Mono"];
                  defaultFonts.sansSerif = ["DejaVu Sans"];
                  defaultFonts.serif = ["DejaVu Serif"];
                  hinting.autohint = true;
                  hinting.style = "hintslight";
                };
              };

              fileSystems = {
                "/" = {
                  device = "/dev/disk/by-uuid/45264d57-59a7-428b-a85a-35fa35c1ddeb";
                  fsType = "btrfs";
                };
                "/boot" = {
                  device = "/dev/disk/by-uuid/6696-7F45";
                  fsType = "vfat";
                };
              };

              networking = {
                dhcpcd.extraConfig = lib.mkForce "nohook resolv.conf";
                domain = "local";
                enableIPv6 = true;
                firewall.allowPing = true;
                firewall.allowedTCPPorts = [];
                firewall.allowedUDPPorts = [];
                firewall.autoLoadConntrackHelpers = true;
                firewall.checkReversePath = false;
                firewall.enable = true;
                firewall.logRefusedConnections = true;
                firewall.logRefusedPackets = true;
                firewall.logReversePathDrops = true;
                firewall.pingLimit = "--limit 1/minute --limit-burst 5";
                firewall.rejectPackets = true;
                hostName = prefs.host.name;
                nameservers =
                  prefs.dns.v4.ns
                  ++ [
                    "8.8.8.8"
                    "8.8.4.4"
                  ];
                #   resolvconf.enable = lib.mkForce false;
                useDHCP = true;
                #   networkmanager.dns = lib.mkForce "none";
                #   networkmanager.enable = true;
                #   useHostResolvConf = true;
                useNetworkd = true;
                usePredictableInterfaceNames = true;
                wireless.iwd.enable = true;
                wireless.userControlled.enable = true;
                wireless.interfaces = ["wlan0"];
              };

              programs = {
                kbdlight.enable = true;
                iftop.enable = true;
                light.enable = true;
                iotop.enable = true;
                htop.enable = true;
                git.enable = true;
                git.lfs.enable = true;
                starship.enable = true;
                xwayland.enable = true;

                git.config = {
                  alias.aliases = "config --show-scope --get-regexp alias";
                  alias.unstage = "restore --staged";
                  alias.amend = "commit --amend";
                  alias.amendall = "commit --amend --all";
                  alias.amendit = "commit --amend --no-edit";
                  alias.branches = "branch --all";
                  alias.l = "log --pretty=oneline --graph --abbrev-commit";
                  alias.quick-rebase = "rebase --interactive --root --autosquash --autostash";
                  alias.remotes = "remote --verbose";
                  alias.list-vars = "!${lib.getExe pkgs.bat} -l=ini --file-name 'git var -l (sorted)' <(git var -l | sort)";
                  alias.user = "config --show-scope --get-regexp user";
                  alias.wtf-config = "config --show-scope --show-origin --list --includes";
                  apply.whitespace = "fix";
                  branch.sort = "-committerdate";
                  core.excludesfile = pkgs.writeText "git-excludes" (lib.concatStringsSep "\n" ["*~" "tags" ".nvimlog" "*.swp" "*.swo" "*.log" ".DS_Store"]);
                  core.ignorecase = true;
                  core.pager = lib.getExe pkgs.delta;
                  core.untrackedcache = true;
                  credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
                  credential."https://github.*".helper = "${lib.getExe pkgs.gh} auth git-credential";
                  credential."https://github.internal.digitalocean.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
                  diff.bin.textconv = "hexdump -v -C";
                  diff.renames = "copies";
                  help.autocorrect = 1;
                  init.defaultbranch = "main";
                  interactive.difffilter = "${lib.getExe pkgs.delta} --color-only";
                  pull.ff = true;
                  pull.rebase = true;
                  push.default = "simple";
                  push.followtags = true;
                };

                starship.settings = {
                  add_newline = false;
                  character.error_symbol = "[➜](bold red)";
                  golang.symbol = "";
                  character.success_symbol = "[➜](bold green)";
                  character.vicmd_symbol = "[](bold magenta)";
                  format = "$directory $character";
                  right_format = "$all";
                  git_status.disabled = true;
                  directory.truncate_to_repo = false;
                  git_branch.disabled = true;
                  shlvl.disabled = false;
                  time.disabled = false;
                  scan_timeout = 10;
                };

                ssh = {
                  extraConfig = builtins.readFile ./pkg/ssh_config;
                  forwardX11 = false;
                  hostKeyAlgorithms = ["ecdsa-sha2-nistp256" "ssh-ed25519" "ssh-rsa"];
                  setXAuthLocation = false;
                  startAgent = false;
                };

                tmux = {
                  aggressiveResize = true;
                  baseIndex = 1;
                  enable = true;
                  newSession = true;
                  plugins = with pkgs.tmuxPlugins; [pain-control onedark-theme sensible];
                  reverseSplit = true;
                  secureSocket = true;
                  shortcut = "a";
                  terminal = "tmux-256color";
                };

                sway = {
                  enable = true;
                  wrapperFeatures.base = true;
                  wrapperFeatures.gtk = true;
                  extraPackages = with pkgs; [
                    swaylock
                    dmenu
                    foot
                    swayidle
                    wofi
                    light
                    i3status-rust
                  ];
                  extraSessionCommands = ''
                    # SDL:
                    export SDL_VIDEODRIVER=wayland
                    # QT (needs qt5.qtwayland in systemPackages):
                    export QT_QPA_PLATFORM=wayland-egl
                    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
                    # Fix for some Java AWT applications (e.g. Android Studio),
                    # use this if they aren't displayed properly:
                    export _JAVA_AWT_WM_NONREPARENTING=1
                  '';
                };

                zsh = {
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
                  interactiveShellInit = ''
                    source "${./pkg/zshrc}"
                    hash -d current-sw=/run/current-system/sw
                    hash -d booted-sw=/run/booted-system/sw
                    eval "$(${lib.getExe pkgs.direnv} hook zsh)"
                    eval "$(${lib.getExe pkgs.navi} widget zsh)"
                    eval "$(${lib.getExe pkgs.starship} init zsh)"
                    eval "$(${lib.getExe pkgs.zoxide} init zsh)"
                    source "${pkgs.skim}/share/skim/key-bindings.zsh"
                  '';
                };

                gnupg.agent.enable = true;
                gnupg.agent.enableBrowserSocket = true;
                gnupg.agent.enableSSHSupport = true;
                wireshark.enable = true;
                wireshark.package = pkgs.wireshark;
              };

              security = {
                allowUserNamespaces = true;
                dhparams.enable = true;
                forcePageTableIsolation = true;
                lockKernelModules = true;
                pam.enableEcryptfs = true;
                polkit.adminIdentities = ["unix-user:${prefs.user.login}"];
                protectKernelImage = true;
                rtkit.enable = true;
                sudo.enable = true;
                tpm2.enable = true;
                tpm2.pkcs11.enable = true;
                virtualisation.flushL1DataCache = "always";
              };

              services = {
                acpid.enable = true;
                dnscrypt-proxy2.enable = true;
                earlyoom.enable = true;
                earlyoom.freeMemThreshold = 10;
                fwupd.enable = true;
                journald.extraConfig = lib.concatStringsSep "\n" ["SystemMaxUse=1G"];
                journald.forwardToSyslog = false;
                tlp.enable = true;
                unclutter.enable = true;
                upower.enable = true;
              };

              services.xserver = {
                autorun = true;
                displayManager.autoLogin.enable = true;
                displayManager.autoLogin.user = prefs.user.login;
                displayManager.defaultSession = "none+i3";
                enable = true;
                enableCtrlAltBackspace = true;
                layout = "us";
                libinput.touchpad.disableWhileTyping = true;
                videoDrivers = ["modesetting"];
                windowManager.i3.enable = true;
                windowManager.i3.package = pkgs.i3-gaps;
                xkbOptions = "altwin:swap_lalt_lwin,ctrl:nocaps,terminate:ctrl_alt_bksp";
              };

              xdg.mime = {
                enable = true;
                defaultApplications."application/pdf" = "firefox.desktop";
                removedAssociations."audio/mp3" = ["mpv.desktop" "umpv.desktop"];
                removedAssociations."inode/directory" = "codium.desktop";
              };

              swapDevices = [{device = "/dev/disk/by-uuid/e3b45cba-578e-46b9-8633-c6b67f9a556d";}];
              users.groups.users = {};
              users.groups.wheel = {};
              virtualisation.oci-containers.backend = "podman";
              virtualisation.podman.dockerCompat = true;
              virtualisation.podman.dockerSocket.enable = true;
              virtualisation.podman.enable = true;

              systemd = {
                services.systemd-udev-settle.enable = false;
                services.NetworkManager-wait-online.enable = false;
                services.systemd-networkd-wait-online.enable = false;
              };

              environment.etc = {
                "i3/config".text = builtins.readFile ./pkg/i3_config;
                "sway/config".text = builtins.readFile ./pkg/sway_config;
                "xdg/kitty/kitty.conf".text = lib.concatStringsSep "\n" [
                  "font_family DaddyTimeMono Nerd Font"
                  "editor ${lib.getExe pkgs.neovim}"
                ];
              };

              environment.systemPackages = lib.concatLists [
                (builtins.map (entry:
                  pkgs.makeDesktopItem {
                    name = "internal-${entry}";
                    desktopName = "Open ${entry}.internal.";
                    exec = "xdg-open https://${entry}.internal.digitalocean.com";
                  })
                prefs.internalHostnames)
                (builtins.map (entry: pkgs.makeDesktopItem entry) prefs.desktopItem)
                (builtins.map (p: pkgs."${p}") [
                  "_1password"
                  "aide"
                  "alejandra"
                  "commitlint"
                  "cuelsp"
                  "cuetools"
                  "delve"
                  "direnv"
                  "expect"
                  "fd"
                  "gh-dash"
                  "graphviz"
                  "jless"
                  "my-commontools"
                  "my-gotools"
                  "my-rustools"
                  "my-systools"
                  "my-virtools"
                  "my-x11tools"
                  "navi"
                  "neovim"
                  "ossec"
                  "parallel"
                  "pass"
                  "topgrade"
                  "w3m"
                  "yubikey-manager"
                  "zoxide"
                  "zstd"
                ])
                (with pkgs; [
                  (pkgs.writeShellApplication {
                    name = "system";
                    runtimeInputs = with pkgs; [
                      bat
                      git
                      lsd
                      nix
                      nixos-rebuild
                    ];
                    text = ''
                      [[ $# -gt 0 ]] || exec $0 help;
                      case $1 in
                      bin) echo "/run/current-system/sw/bin";;
                      bins) lsd --no-symlink "$($0 bin)";;
                      boot|build|build-vm*|dry-activate|dry-build|test|switch) cd "${prefs.repo.path}" && nixos-rebuild --flake "$(pwd)#${prefs.host.name}" "$@" ;;
                      develop) [[ $UID -ne 0 ]] && nix develop "${prefs.repo.path}#$2";;
                      edit) [[ $UID -ne 0 ]] && cd "${prefs.repo.path}" && $EDITOR flake.nix;;
                      flake) [[ $UID -ne 0 ]] && cd "${prefs.repo.path}" && nix "$@";;
                      git) [[ $UID -ne 0 ]] && cd "${prefs.repo.path}" && exec "$@";;
                      help) bat -l=bash --style=header-filename,grid,snip "$0" -r=8: ;;
                      pager) $0 tree | bat --file-name="$0 $*" --plain;;
                      repo|path|dir) echo "${prefs.repo.path}";;
                      tree) lsd --tree --no-symlink;;
                      shutdown|poweroff|reboot|journalctl) exec "$@";;
                        repl) nix repl ${(pkgs.writeText "repl.nix" ''
                          let flake = builtins.getFlake "${prefs.repo.path}"; in (flake.inputs // rec {
                           inherit (flake.outputs.nixosConfigurations."${prefs.host.name}") pkgs options config;
                           lib = pkgs.lib // flake.lib;
                           inherit (config.networking) hostName;
                           system = "${system}";
                           # commented, but viable alternative:
                           ## flake = builtins.getFlake "${self}";
                        })
                      '')};;
                        *) $0 help && exit 127;;
                      esac'';
                  })

                  (pkgs.writeShellApplication {
                    name = "rofi";
                    runtimeInputs = [rofi terminus-nerdfont];
                    text = lib.concatStringsSep " " [
                      "exec rofi"
                      "-markup"
                      "-modi drun,ssh,window,run"
                      "-font 'DaddyTimeMono Nerd Font 12'"
                      "\"$@\""
                    ];
                  })
                ])
              ];

              # This value determines the NixOS release from which the default
              # settings for stateful data, like file locations and database versions
              # on your system were taken. It‘s perfectly fine and recommended to leave
              # this value at the release version of the first install of this system.
              # Before changing this value read the documentation for this option
              # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
              system.stateVersion = lib.mkForce "22.05";
              system.autoUpgrade.enable = true;
            })
          ];
      };
    };

    nixosModules = {
      myDNS = {
        config,
        lib,
        pkgs,
        ...
      }:
        lib.mkIf config.services.dnscrypt-proxy2.enable {
          networking.nameservers = ["127.0.0.1"];
          # networking.resolvconf.enable = lib.mkForce false;
          networking.networkmanager.dns = lib.mkForce "none";
          # networking.useHostResolvConf = true;
          systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = lib.mkForce "dnscrypt-proxy2";
          services.dnscrypt-proxy2.settings = {
            # Server Controls
            # ----------------
            block_ipv6 = false;
            block_undelegated = true;
            block_unqualified = true;
            blocked_query_response = "refused";
            edns_client_subnet = ["0.0.0.0/0" "2001:db8::/32"];
            ipv4_servers = true;
            ipv6_servers = true;
            require_dnssec = true;
            require_nofilter = false;
            require_nolog = true;
            server_names = ["cloudflare" "cloudflare-ipv6" "cloudflare-security" "cloudflare-security-ipv6"];
            # Caching & TTLs
            # --------------
            cloak_ttl = 600;
            cache_size = 4096;
            cache_min_ttl = 2400;
            cache_max_ttl = 86400;
            cache_neg_min_ttl = 60;
            cache_neg_max_ttl = 600;
            # Logging Controls
            # ----------------
            use_syslog = true;
            # query_log.file = "/dev/stdout";
            # query_log.ignored_qtypes = ["DNSKEY"];
            # blocked_names.log_file = "/dev/stdout";
            # allowed_ips.log_file = "/dev/stdout";
            # blocked_ips.log_file = "/dev/stdout";
            # allowed_names.log_file = "/dev/stdout";

            allowed_ips.allowed_ips_file = pkgs.writeText "allowed_ips" (lib.concatStringsSep "\n" [
              /*
              Allowed IP lists support the same patterns as IP blocklists If an
              IP response matches an allow ip entry, the corresponding session
              will bypass IP filters.

              Time-based rules are also supported to make some websites only
              accessible at specific times of the day.
              */
            ]);

            allowed_names.allowed_names_file = pkgs.writeText "allowed_names" (lib.concatStringsSep "\n" []);
            blocked_ips.blocked_ips_file = pkgs.writeText "blocked_ips" (lib.concatStringsSep "\n" []);

            cloaking_rules = pkgs.writeText "cloaking_rules" (lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}  ${value}") {
              /*
              Cloaking returns a predefined address for a specific name.
              In addition to acting as a HOSTS file, it can also return the IP address
              of a different name. It will also do CNAME flattening.
              */
              "www.google.*" = "forcesafesearch.google.com";
              "www.bing.com" = "strict.bing.com";
              "=duckduckgo.com" = "safe.duckduckgo.com";
            }));

            forwarding_rules = let
              iDNS = lib.concatStringsSep "," prefs.dns.v4.ns;
            in
              pkgs.writeText "forwarding_rules" (lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}  ${value}") {
                "do.co" = iDNS;
                "*.do.co" = iDNS;
                "internal.digitalocean.com" = iDNS;
                "*.internal.digitalocean.com" = iDNS;
                "10.in.arpa" = iDNS;
              }));

            sources.public-resolvers = {
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
              ];
              cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 72;
              prefix = "";
            };

            sources.relays = {
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

            sources. odoh-servers = {
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

            sources.odoh-relays = {
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

            blocked_names.blocked_names_file =
              pkgs.writeText "blocked_names"
              (lib.concatStringsSep "\n" (builtins.map (b: builtins.readFile "${self.inputs.blocklists.outPath}/data/${b}/hosts") ["Adguard-cname" "URLHaus" "adaway.org"]));
          };
        };
      nixConfig = {
        config,
        lib,
        pkgs,
        ...
      }: {
        nix.daemonCPUSchedPolicy = "idle";
        nix.daemonIOSchedPriority = 5;
        nix.gc.automatic = true;
        nix.gc.dates = "daily";
        nix.optimise.automatic = true;
        nix.optimise.dates = ["daily"];
        nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
        nix.settings.allow-dirty = true;
        nix.settings.auto-optimise-store = true;
        nix.settings.cores = 2;
        nix.settings.experimental-features = ["nix-command" "flakes" "ca-derivations"];
        nix.settings.log-lines = 50;
        nix.settings.max-free = 64 * 1024 * 1024 * 1024;
        nix.settings.system-features = ["kvm"];
        nix.settings.warn-dirty = false;
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = lib.mkForce (builtins.attrValues self.overlays);
      };
      emax = {
        config,
        lib,
        pkgs,
        ...
      }: {
        services.emacs = {
          enable = false;
          install = false;
          package = pkgs.emacsWithPackages (epkgs: [
            epkgs.melpaStablePackages.magit
          ]);
        };
      };
      /*
      do-internal represents "internal" digitalocean configuration.
      beyond that... I haven't decided what this module does yet..
      */
      do-internal = {
        config,
        lib,
        pkgs,
        ...
      }: {
        imports = [
          self.inputs.do-nixpkgs.nixosModules.kolide-launcher
          self.inputs.do-nixpkgs.nixosModules.sentinelone
        ];
        security.pki.certificateFiles = [pkgs.do-nixpkgs.sammyca];
        services.sentinelone.enable = true;
        services.kolide-launcher.enable = true;
        services.kolide-launcher.secretFilepath = "/home/${prefs.user.login}/.do/kolide.secret";
        nix.registry.do-nixpkgs.flake = self.inputs.do-nixpkgs;
        system.nixos.tags = ["digitalocean"];
        networking.hosts = prefs.networking.hosts;
        environment.systemPackages = [pkgs.do-internal];
      };

      /*
      x1c8 contains the configuration that is specific to my Lenovo
      X1 Carbon (8th gen), but generic enough to perhaps reuse.
      */
      x1c8 = {
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

        boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
        boot.kernelParams = ["i8042.reset=1" "i8042.nomux=1"];
        hardware.acpilight.enable = true;
        hardware.enableAllFirmware = true;
        hardware.opengl.enable = true;
        hardware.opengl.extraPackages = [pkgs.intel-compute-runtime];
        hardware.pulseaudio.enable = true;
        hardware.uinput.enable = true;
        networking.wireless.interfaces = ["wlan0"];
        networking.wireless.iwd.enable = true;
        networking.wireless.userControlled.enable = true;
        sound.enable = true;
        sound.mediaKeys.enable = true;

        boot.extraModprobeConfig = ''
          options kvm_intel nested=1
          options iwlwifi disable_11ax=1
        '';

        boot.extraModulePackages = with pkgs; [
          linuxPackages_latest.acpi_call
          linuxPackages_latest.cpupower
          linuxPackages_latest.tp_smapi
          linuxPackages_latest.bpftrace
          tpm2-tools
          tpm2-tss
          i2c-tools
        ];

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
      };

      /*
      this contains ... well.. me. (unless "you" configure it)
      */
      ${prefs.user.login} = {
        config,
        lib,
        pkgs,
        ...
      }: {
        users.users.${prefs.user.login} = {
          extraGroups = ["video" "users" prefs.user.login];
          group = prefs.user.login;
          initialPassword = "";
          home = "/home/${prefs.user.login}";
          shell = pkgs.zsh;
          uid = 1000;
          isNormalUser = true;
        };
        nix.settings.allowed-users = [prefs.user.login];
        nix.settings.trusted-users = [prefs.user.login];
        users.groups.${prefs.user.login}.gid = 990;
        system.nixos.tags = [prefs.user.login];
        security.pam.u2f.enable = true;
        security.pam.u2f.control = "sufficient";

        security.pam.u2f.authFile = pkgs.writeText "u2f-authFile" (lib.concatStringsSep "\n" [
          "${prefs.user.login}:PbfYUgHNUk54RUZu7mOz9DjZ1cYajfXJMQqpVH+jOgoBEyfDmH6JGoJy+zrixAkAjfJxJHdoI7AOhX3rvUfWyQ==,JzU6nKSnlWdd8kpjfIkihYV9AXxTAyNfzdF83haYD9fCsHoBfqKj/pw4xbkl+dl3nOGoOvvgUQcaFHgjVtwYVA==,es256,+presence"
        ]);

        security.sudo.extraRules = [
          {
            users = [prefs.user.login];
            runAs = "root";
            commands =
              ["ALL"]
              ++ (builtins.map (name: {
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
                  "vpn"
                  "dmesg"
                  "systemctl"
                ]);
          }
        ];
      };
    };

    lib = rec {
      inherit (flake-utils.lib) filterPackages mkApp check-utils;
      supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux"];
      eachSystem = flake-utils.lib.eachSystem supportedSystems;
      eachSystemMap = flake-utils.lib.eachSystemMap supportedSystems;
      overlaysList = builtins.attrValues self.overlays;
      modulesList = builtins.attrValues self.nixosModules;
      withPkgs = f:
        eachSystemMap (system:
          f (import nixpkgs {
            inherit system;
            overlays = overlaysList;
          }));
    };

    packages = self.lib.withPkgs (pkgs: {
      inherit (pkgs) neovim do-internal gomod2nix;
    });

    apps = self.lib.withPkgs (pkgs: {
      docc = self.lib.mkApp {
        drv = pkgs.do-internal;
        exePath = "/bin/docc";
      };
      fly = self.lib.mkApp {drv = pkgs.do-nixpkgs.fly;};
      do-internal = self.lib.mkApp {
        drv = pkgs.do-internal;
        exePath = "/bin/do-internal";
      };
      nvim = self.lib.mkApp {
        drv = pkgs.neovim;
        exePath = "/bin/nvim";
      };
      default = self.lib.mkApp {
        drv = pkgs.writeShellApplication {
          name = "system";
          runtimeInputs = with pkgs; [
            bat
            git
            lsd
            nix
            nixos-rebuild
          ];
          text = ''
            [[ $# -gt 0 ]] || exec $0 help;
            case $1 in
            bin) echo "/run/current-system/sw/bin";;
            bins) lsd --no-symlink "$($0 bin)";;
            boot|build|build-vm*|dry-activate|dry-build|test|switch) cd "${prefs.repo.path}" && nixos-rebuild --flake "$(pwd)#${prefs.host.name}" "$@" ;;
            develop) [[ $UID -ne 0 ]] && nix develop "${prefs.repo.path}#$2";;
            edit) [[ $UID -ne 0 ]] && cd "${prefs.repo.path}" && $EDITOR flake.nix;;
            flake) [[ $UID -ne 0 ]] && cd "${prefs.repo.path}" && nix "$@";;
            update) [[ $UID -ne 0 ]] && cd "${prefs.repo.path}" && nix flake "$@";;
            git) [[ $UID -ne 0 ]] && cd "${prefs.repo.path}" && exec "$@";;
            help) bat -l=bash --style=header-filename,grid,snip "$0" -r=8: ;;
            pager) $0 tree | bat --file-name="$0 $*" --plain;;
            repo|path|dir) echo "${prefs.repo.path}";;
            tree) lsd --tree --no-symlink;;
            shutdown|poweroff|reboot|journalctl) exec "$@";;
            repl) nix repl ${(pkgs.writeText "repl.nix" ''
              let flake = builtins.getFlake "${prefs.repo.path}"; in (flake.inputs // rec {
               inherit (flake.outputs.nixosConfigurations."${prefs.host.name}") pkgs options config;
               lib = pkgs.lib // flake.lib;
               inherit (config.networking) hostName;
               # commented, but viable alternative:
               ## flake = builtins.getFlake "${self}";
              })
            '')};;
              *) $0 help && exit 127;;
              esac'';
        };
      };
    });

    formatter = self.lib.withPkgs (pkgs: pkgs.alejandra);

    devShells = self.lib.withPkgs (pkgs:
      with pkgs; rec {
        go = mkShell {
          name = "my-gotools";
          paths = [my-commontools my-gotools];
        };

        default = go;
      });
  };
  # vim:sts=2:et:ft=nix:fdm=indent:fdl=0:fcl=all:fdo=all
}
