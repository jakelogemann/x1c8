{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-templates.url = "github:nixos/templates";
    pnix.url = "github:polis-dev/pnix";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nmd = {
      url = "gitlab:rycee/nmd";
      flake = false;
    };

    nmt = {
      url = "gitlab:rycee/nmt";
      flake = false;
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    cntr = {
      url = "github:Mic92/cntr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-regression.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    go-nix = {
      url = "github:nix-community/go-nix";
      flake = false;
    };

    naersk-lib = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixago = {
      url = "github:nix-community/nixago";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixago-exts.follows = "nixago-exts";
    };

    nixago-exts = {
      url = "github:nix-community/nixago-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixago.follows = "nixago";
      inputs.flake-utils.follows = "flake-utils";
    };

    zsh-autocomplete = {
      url = "github:marlonrichert/zsh-autocomplete";
      flake = false;
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nixpkgs-lint = {
      url = "github:nix-community/nixpkgs-lint";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.naersk.follows = "naersk-lib";
      inputs.flake-compat.follows = "flake-compat";
      inputs.utils.follows = "flake-utils";
    };

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
      # url = "git+https://github.internal.digitalocean.com/digitalocean/do-nixpkgs?ref=master";
      url = "/home/jlogemann/laptop/vendor/do-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
      inputs.cthulhu.follows = "cthulhu";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      inputs.naersk-lib.follows = "naersk-lib";
    };
  };

  outputs = {
    self,
    pnix,
    nixpkgs,
    flake-utils,
    ...
  }: {
    overlays.rust = self.inputs.rust-overlay.overlays.default;
    overlays.neovim = import ./overlays/neovim.nix;
    overlays.default = next: prev: rec {
      do-nixpkgs = self.inputs.do-nixpkgs.packages.${prev.system};

      inherit (self.inputs.cntr.packages.${prev.system}) cntr;
      inherit (self.inputs.do-nixpkgs.packages.${prev.system}) fly sammyca;

      staff-cert = self.inputs.do-nixpkgs.packages.${prev.system}.staff-cert.overrideAttrs (old: {
        src = builtins.fetchurl {
          url = "https://security.nyc3.digitaloceanspaces.com/artifacts/staff-cert/release/staff_cert_linux_nocgo";
          sha256 = "sha256:0pi383lsbjj0fgad2w1b77k1akkn0n7y0pnqymnmzmyjv5lw7x7g";
        };
      });

      dao = prev.buildGoModule rec {
        name = "dao";
        ldflags = [
          "-s"
          "-w"
          "-X github.internal.digitalocean.com/digitalocean/dao/internal/cmd.daoVersion=${version}"
          "-X github.internal.digitalocean.com/digitalocean/dao/internal/cmd.daoBuild=${version}"
          "-X github.internal.digitalocean.com/digitalocean/dao/internal/cmd.daoOSArch=${prev.system}"
        ];
        src = builtins.toString self.inputs.dao;
        modRoot = "${src}";
        vendorSha256 = null;
        version =
          if self.inputs.dao ? "shortRev"
          then self.inputs.dao.shortRev
          else if self.inputs.dao ? "rev"
          then self.inputs.dao.rev
          else "dev";
        doCheck = false;
        nativeBuildInputs = with prev; [
          cacert
          git
          gnumake
          jq
          pkg-config
          zlib
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

      cthulhu = {
        cthulhuSrc ? self.inputs.cthulhu,
        name ? "cthulhu",
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
        prev.buildGoModule rec {
          inherit name subPackages tags;
          ldflags = [
            "-s"
            "-w"
            "-X do/doge/version.commit=${version}"
            "-X do/doge/version.gitTreeState=clean"
          ];
          src = builtins.toString cthulhuSrc;
          modRoot = "${src}/docode/src/do";
          vendorSha256 = null;
          version =
            if cthulhuSrc ? "shortRev"
            then cthulhuSrc.shortRev
            else if cthulhuSrc ? "rev"
            then cthulhuSrc.rev
            else "dev";
          doCheck = false;
          nativeBuildInputs = with prev;
            lib.concatLists [
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
    };

    /*
    this is a specific host's configuration (my laptop, to be specific).
    you probably don't actually want to use this... but feel free to have a
    bowl of copy+pasta :)
    */
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {inherit self nixpkgs system;};
      modules = [
        ./desktop/module.nix
        ./docn.nix
        ./x1c8.nix
        ./user.nix
        ({
          config,
          lib,
          pkgs,
          ...
        }: {
          hardware.gpgSmartcards.enable = true;
          hardware.logitech.wireless.enable = true;
          hardware.logitech.wireless.enableGraphical = true;
          time.hardwareClockInLocalTime = true;
          time.timeZone = "America/New_York";
          services.kolide-launcher.secretFilepath = "/home/jlogemann/.do/kolide.secret";
          services.fprintd.enable = true;

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
            profileRelativeEnvVars.MANPATH = ["/man" "/share/man"];
            profileRelativeEnvVars.PATH = ["/bin"];
            shellAliases = {
              git-vars = "${lib.getExe pkgs.bat} -l=ini --file-name 'git var -l' <(git var -l)";
              l = "ls -alh";
              la = "${lib.getExe pkgs.lsd} -a";
              ll = "${lib.getExe pkgs.lsd} -l";
              lla = "${lib.getExe pkgs.lsd} -la";
              ls = lib.getExe pkgs.lsd;
              lt = "${lib.getExe pkgs.lsd} --tree";
              tmux = "tmux -2u";
              dmesg = "sudo dmesg";
              tf = "terraform";
              dc = "docker compose";
              g = "git";
              ga = "git add";
              gb = "git branch";
              gci = "git commit";
              gd = "git diff";
              gds = "git diff --staged";
              gco = "git checkout";
              gl = "git log --oneline";
              gll = "git log";
              grb = "git rebase";
              grs = "git reset";
              grm = "git rm";
              grt = "git restore";
              gs = "git status";
              gst = "git stash";
              gsw = "git switch";
              find-broken-symlinks = "find -L . -type l 2>/dev/null";
              rm-broken-symlinks = "find -L . -type l -exec rm -fv {} \; 2>/dev/null";
            };
            variables = {
              EDITOR = "nvim";
              BAT_STYLE = "grid";
              BROWSER = lib.getExe pkgs.firefox-devedition-bin;
              PAGER = lib.getExe pkgs.bat;
            };
          };

          programs.git = {
            enable = true;
            lfs.enable = true;
            config = {
              apply.whitespace = "fix";
              branch.sort = "-committerdate";
              color.branch.current = "yellow bold";
              color.branch.local = "green bold";
              color.branch.remote = "cyan bold";
              color.diff.frag = "magenta bold";
              color.diff.meta = "yellow bold";
              color.diff.new = "green bold";
              color.diff.old = "red bold";
              color.diff.whitespace = "red reverse";
              color.status.added = "green bold";
              color.status.changed = "yellow bold";
              color.status.untracked = "red bold";
              color.ui = "auto";
              core.ignorecase = true;
              core.pager = lib.getExe pkgs.delta;
              core.untrackedcache = true;
              credential."https://github.*".helper = "${lib.getExe pkgs.gh} auth git-credential";
              credential."https://github.internal.digitalocean.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
              delta.decorations.minus-style = "red bold normal";
              delta.decorations.plus-style = "green bold normal";
              delta.decorations.minus-emph-style = "white bold red";
              delta.decorations.minus-non-emph-style = "red bold normal";
              delta.decorations.plus-emph-style = "white bold green";
              delta.decorations.plus-non-emph-style = "green bold normal";
              delta.decorations.file-style = "yellow bold none";
              delta.decorations.file-decoration-style = "yellow box";
              delta.decorations.hunk-header-style = "magenta bold";
              delta.decorations.hunk-header-decoration-style = "magenta box";
              delta.decorations.minus-empty-line-marker-style = "normal normal";
              delta.decorations.plus-empty-line-marker-style = "normal normal";
              delta.decorations.line-numbers-right-format = "{np:^4}│ ";
              delta.features = "line-numbers decorations";
              delta.line-numbers = true;
              diff.bin.textconv = "hexdump -v -C";
              diff.renames = "copies";
              diff.tool = "vimdiff";
              help.autocorrect = 1;
              init.defaultbranch = "main";
              interactive.difffilter = "${lib.getExe pkgs.delta} --color-only";
              pull.ff = true;
              pull.rebase = true;
              push.default = "simple";
              push.followtags = true;
              rerere.autoupdate = true;
              rerere.enabled = true;
              core.excludesfile = builtins.toFile "git-excludes" (builtins.concatStringsSep "\n" [
                # Compiled
                "tags"
                "*.com"
                "*.class"
                "*.dll"
                "*.exe"
                "*.o"
                "*.so"
                # Editor's Temporary Files
                "*~"
                "*.swp"
                "*.swo"
                ".vscode"
                # Log files
                "*.log"
                ".nvimlog"
                # macOS-specific
                ".DS_Store*"
                "Icon?"
                "Thumbs.db"
                "ehthumbs.db"
                "*.dmg"
                # Archives
                "*.7z"
                "*.gz"
                "*.iso"
                "*.jar"
                "*.rar"
                "*.tar"
                "*.zip"
              ]);
              alias = {
                aliases = "config --show-scope --get-regexp alias";
                amend = "commit --amend";
                amendall = "commit --amend --all";
                amendit = "commit --amend --no-edit";
                branches = "branch --all";
                head-refs = "for-each-ref --format='%(refname:short)' refs/heads/ :";
                l = "log --pretty=oneline --graph --abbrev-commit";
                skip = "update-index --skip-worktree";
                unskip = "update-index --no-skip-worktree";
                list-vars = "!${lib.getExe pkgs.bat} -l=ini --file-name 'git var -l (sorted)' <(git var -l | sort)";
                quick-rebase = "rebase --interactive --root --autosquash --autostash";
                remotes = "remote --verbose";
                unstage = "restore --staged";
                user = "config --show-scope --get-regexp user";
                show-config = "config --show-scope --show-origin --list --includes";
              };
            };
          };

          fonts = {
            enableDefaultFonts = true;
            fonts = with pkgs; [nerdfonts dejavu_fonts terminus-nerdfont];
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
            # dhcpcd.extraConfig = lib.mkForce "nohook resolv.conf";
            hostName = "laptop";
            nameservers = ["8.8.8.8" "8.8.4.4"];
            domain = "local";
            enableIPv6 = true;

            firewall = {
              allowPing = true;
              allowedTCPPorts = [];
              allowedUDPPorts = [];
              autoLoadConntrackHelpers = false;
              checkReversePath = "loose";
              enable = true;
              extraPackages = with pkgs; [ipset];
              logRefusedConnections = true;
              logRefusedPackets = false;
              logRefusedUnicastsOnly = true;
              logReversePathDrops = true;
              pingLimit = "--limit 1/minute --limit-burst 5";
              rejectPackets = false;
            };

            #   resolvconf.enable = lib.mkForce false;
            useDHCP = true;
            #   networkmanager.dns = lib.mkForce "none";
            #   networkmanager.enable = true;
            #   useHostResolvConf = true;
            useNetworkd = true;
            usePredictableInterfaceNames = true;
          };

          nix = {
            daemonCPUSchedPolicy = "idle";
            daemonIOSchedClass = "idle";
            daemonIOSchedPriority = 5;
            gc.automatic = true;
            gc.dates = "daily";
            optimise.automatic = true;
            optimise.dates = ["daily"];
            registry.nixpkgs.flake = self.inputs.nixpkgs;
            settings.allow-dirty = true;
            settings.auto-optimise-store = true;
            settings.cores = 2;
            settings.experimental-features = ["nix-command" "flakes" "ca-derivations"];
            settings.extra-substituters = [
              /*
              "https://helix.cachix.org"
              */
            ];
            settings.extra-trusted-public-keys = [
              /*
              "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
              */
            ];
            settings.log-lines = 50;
            settings.max-free = 64 * 1024 * 1024 * 1024;
            settings.system-features = ["kvm"];
            settings.warn-dirty = false;
          };

          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = lib.mkForce (builtins.attrValues self.overlays);

          programs = {
            kbdlight.enable = true;
            iftop.enable = true;
            light.enable = true;
            iotop.enable = true;
            htop.enable = true;
            htop.settings.hide_kernel_threads = true;
            htop.settings.hide_userland_threads = true;
            htop.settings.tree_view = true;
            htop.settings.highlight_base_name = true;
            htop.settings.highlight_megabytes = true;
            htop.settings.cpu_count_from_zero = true;
            htop.settings.detailed_cpu_time = true;
            htop.settings.color_scheme = "6";
            starship.enable = true;

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
              extraConfig = builtins.readFile ./.ssh/config;
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

            zsh = {
              autosuggestions.enable = true;
              autosuggestions.extraConfig.ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
              autosuggestions.highlightStyle = "fg=cyan";
              autosuggestions.strategy = ["completion"];
              enable = true;
              # enableBashCompletion = true;
              enableCompletion = true;
              enableGlobalCompInit = true;
              histFile = "$HOME/.zsh_history";
              histSize = 100000;
              syntaxHighlighting.enable = true;
              syntaxHighlighting.highlighters = ["main" "brackets" "pattern" "root" "line"];
              syntaxHighlighting.styles.alias = "fg=magenta,bold";
              interactiveShellInit = ''
                eval "$(${lib.getExe pkgs.dao} completion zsh)"
                eval "$(${lib.getExe pkgs.direnv} hook zsh)"
                eval "$(${lib.getExe pkgs.navi} widget zsh)"
                eval "$(${lib.getExe pkgs.zoxide} init zsh)"
                source "${pkgs.skim}/share/skim/key-bindings.zsh"
                # source "${self.inputs.zsh-autocomplete.outPath}/zsh-autocomplete.plugin.zsh"
                source ${./.zshrc}
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
            pam.u2f.authFile = builtins.toFile "u2f-authfile" ''
              jlogemann:PbfYUgHNUk54RUZu7mOz9DjZ1cYajfXJMQqpVH+jOgoBEyfDmH6JGoJy+zrixAkAjfJxJHdoI7AOhX3rvUfWyQ==,JzU6nKSnlWdd8kpjfIkihYV9AXxTAyNfzdF83haYD9fCsHoBfqKj/pw4xbkl+dl3nOGoOvvgUQcaFHgjVtwYVA==,es256,+presence
            '';
            pam.u2f.control = "sufficient";
            pam.u2f.enable = true;
            polkit.adminIdentities = ["unix-user:jlogemann"];
            protectKernelImage = true;
            rtkit.enable = true;
            sudo.enable = true;
            tpm2.enable = true;
            tpm2.pkcs11.enable = true;
            virtualisation.flushL1DataCache = "cond";
          };

          services = {
            acpid.enable = true;
            dnscrypt-proxy2.enable = true;
            fwupd.enable = true;
            journald.extraConfig = lib.concatStringsSep "\n" ["SystemMaxUse=1G"];
            journald.forwardToSyslog = false;
            tlp.enable = true;
            upower.enable = true;
            /*
            X11 Login Configuration
            */
            xserver = {
              autorun = false;
              displayManager.autoLogin.user = "jlogemann";
              displayManager.autoLogin.enable = true;
              enable = false;
              enableCtrlAltBackspace = true;
              displayManager.defaultSession = "sway";
              layout = "us";
              libinput.touchpad.disableWhileTyping = true;
              videoDrivers = ["modesetting"];
              xkbOptions = "altwin:swap_lalt_lwin,ctrl:nocaps,terminate:ctrl_alt_bksp";
            };
          };

          swapDevices = [{device = "/dev/disk/by-uuid/e3b45cba-578e-46b9-8633-c6b67f9a556d";}];
          users.groups.users = {};
          users.groups.wheel = {};

          virtualisation = {
            oci-containers.backend = "podman";
            podman.dockerCompat = true;
            podman.dockerSocket.enable = true;
            podman.enable = true;
          };

          systemd = {
            services.systemd-udev-settle.enable = false;
            services.sentinelone = {
              serviceConfig.ReadOnlyPaths = ["/etc" "/home" "/opt" "/nix" "/boot" "/proc"];
              serviceConfig.ReadWritePaths = ["/opt/sentinelone"];
              serviceConfig.CPUWeight = lib.mkForce 10;
              serviceConfig.Slice = "compliance.slice";
              serviceConfig.CPUQuota = lib.mkForce "10%";
              serviceConfig.DevicePolicy = "closed";
              serviceConfig.PrivateDevices = false;
              serviceConfig.PrivateMounts = false;
              serviceConfig.PrivateTmp = false;
              serviceConfig.PrivateIPC = true;
              serviceConfig.PrivateUsers = false;
              serviceConfig.ProtectHome = false;
              serviceConfig.ProtectControlGroups = false;
              serviceConfig.ProtectKernelModules = true;
              serviceConfig.ProtectKernelTunables = true;
            };
            services.kolide-launcher = {
              serviceConfig.ReadOnlyPaths = ["/etc" "/home" "/opt" "/nix" "/boot" "/proc" "/srv" "/sys" "/bin" "/mnt"];
              serviceConfig.CPUWeight = 10;
              serviceConfig.Slice = "compliance.slice";
              serviceConfig.LockPersonality = true;
              serviceConfig.CPUQuota = "10%";
              serviceConfig.DevicePolicy = "closed";
              serviceConfig.PrivateDevices = false;
              serviceConfig.PrivateIPC = true;
              serviceConfig.PrivateNetwork = true;
              serviceConfig.PrivateMounts = false;
              serviceConfig.PrivateTmp = true;
              serviceConfig.PrivateUsers = false;
              serviceConfig.ProtectHome = false;
              serviceConfig.ProtectClock = true;
              serviceConfig.ProtectSystem = true;
              serviceConfig.ProtectProc = true;
              serviceConfig.ProtectControlGroups = false;
              serviceConfig.ProtectKernelModules = true;
              serviceConfig.ProtectKernelTunables = true;
            };
            services.NetworkManager-wait-online.enable = lib.mkForce false;
            services.systemd-networkd-wait-online.enable = lib.mkForce false;
          };

          environment.etc = {
            "zshrc.local" = {
              mode = "0444";
              text = ''
                __SYSTEM_ZSHRC_LOCAL=loading
                hash -d current-sw=/run/current-system/sw
                hash -d booted-sw=/run/booted-system/sw
                __SYSTEM_ZSHRC_LOCAL=loaded
              '';
            };
          };

          environment.systemPackages = with pkgs; [
            (writeShellApplication {
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
                cd "/home/jlogemann/laptop"
                case $1 in
                  bin) echo "/run/current-system/sw/bin";;
                  bins) lsd --no-symlink "$($0 bin)";;
                  boot|build|build-vm*|dry-activate|dry-build|test|switch)  nixos-rebuild --flake "$(pwd)#laptop" "$@" ;;
                  dev|develop) [[ $UID -ne 0 ]] && nix develop "$HOME/laptop#''${2:-default}";;
                  edit) [[ $UID -ne 0 ]] &&  $EDITOR ;;
                  flake) [[ $UID -ne 0 ]] &&  nix "$@";;
                  git) [[ $UID -ne 0 ]] &&  exec "$@";;
                  help) bat -l=bash --style=header-filename,grid,snip "$0" -r=8: ;;
                  update) [[ $UID -ne 0 ]] &&  nix flake "$@";;
                  pager) $0 tree | bat --file-name="$0 $*" --plain;;
                  repo|path|dir) echo "$HOME/laptop";;
                  tree) lsd --tree --no-symlink;;
                  shutdown|poweroff|reboot|journalctl) exec "$@";;
                  repl) nix repl ${(pkgs.writeText "repl.nix" ''
                       let flake = builtins.getFlake "/home/jlogemann/laptop"; in (flake.inputs // rec {
                       inherit (flake.outputs.nixosConfigurations."laptop") pkgs options config;
                       lib = pkgs.lib // flake.lib;
                       inherit (config.networking) hostName;
                       system = "${pkgs.system}";
                       })
                '')};;
                  *) $0 help && exit 127;;
                  esac'';
            })
          ];
          # This value determines the NixOS release from which the default
          # settings for stateful data, like file locations and database versions
          # on your system were taken. It‘s perfectly fine and recommended to leave
          # this value at the release version of the first install of this system.
          # Before changing this value read the documentation for this option
          # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
          system.stateVersion = lib.mkForce "22.11";
          system.autoUpgrade.enable = true;
        })
      ];
    };

    formatter = self.lib.withPkgs (pkgs: pkgs.alejandra);
    lib = import ./lib.nix self;
  };
  # vim:sts=2:et:ft=nix:fdm=indent:fdl=1
}
