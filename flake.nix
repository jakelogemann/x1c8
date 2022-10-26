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

    AstroNvim = {
      type = "github";
      owner = "astronvim";
      repo = "astronvim";
      ref = "v2.4.2";
      flake = false;
    };

    cthulhu = {
      type = "github";
      host = "github.internal.digitalocean.com";
      owner = "digitalocean";
      repo = "cthulhu";
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
    ...
  }: let
    /*
    preferences are loaded from a TOML file located in this directory. the data
    in here is free-form and should be kept as minimalist as possible.
    */
    prefs = builtins.fromTOML (builtins.readFile ./prefs.toml);
  in {
    overlays = {
      gomod2nix = self.inputs.gomod2nix.overlays.default;
      my-nvim = next: prev: {
        neovim = prev.neovim.override {
          extraName = "-jlogemann";
          viAlias = true;
          vimAlias = true;

          configure = {
            customRC = ''
              luafile ${./pkg/nvim.lua}
            '';
            packages.default = with prev.vimPlugins; {
              start = [

                NrrwRgn
                alpha-nvim
                cmp-buffer 
                cmp-calc
                cmp-emoji
                cmp-nvim-lsp 
                cmp-omni
                cmp-path 
                cmp-spell
                cmp-treesitter
                copilot-vim
                editorconfig-nvim
                feline-nvim
                gitsigns-nvim
                i3config-vim
                neorg
                nord-nvim
                nvim-cmp 
                nvim-cursorline
                nvim-dap
                nvim-dap-ui
                nvim-lspconfig
                nvim-web-devicons
                plenary-nvim
                telescope-nvim
                trouble-nvim
                vim-automkdir
                vim-caddyfile
                vim-concourse
                vim-cue
                vim-easy-align
                vim-gnupg
                vim-go
                vim-hcl
                vim-lastplace
                vim-nix

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
            };

          };
        };
      };
      /*
      this is a wrapper around the do-nixpkgs repo (with my (experimental!) customizations).
      */
      do-internal = next: prev:
        with prev; {
          do-nixpkgs = self.inputs.do-nixpkgs.packages.${prev.system};
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
              nix.registry.nixpkgs.flake = self.inputs.nixpkgs;

              hardware.cpu.intel.updateMicrocode = true;
              hardware.gpgSmartcards.enable = true;
              hardware.ksm.enable = true;
              hardware.mcelog.enable = true;
              nix.daemonCPUSchedPolicy = "idle";
              nix.daemonIOSchedPriority = 5;

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
              nixpkgs.config.allowUnfree = true;
              nix.nrBuildUsers = 8;
              nixpkgs.overlays = lib.mkForce (builtins.attrValues self.overlays);
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
                  EDITOR = "nvim";
                  BAT_STYLE = "header-filename,grid";
                  BROWSER = "firefox";
                  PAGER = lib.getExe pkgs.bat;
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

              nix.gc = {
                automatic = true;
                dates = "daily";
              };

              nix.optimise = {
                automatic = true;
                dates = ["daily"];
              };

              nix.settings = {
                allow-dirty = true;
                cores = 2;
                auto-optimise-store = true;
                experimental-features = ["nix-command" "flakes" "ca-derivations"];
                system-features = ["kvm"];
                log-lines = 50;
                max-free = 64 * 1024 * 1024 * 1024;
                warn-dirty = false;
              };

              programs = {
                iftop.enable = true;
                iotop.enable = true;
                htop.enable = true;
                git.enable = true;
                git.lfs.enable = true;
                starship.enable = true;

                git.config = {
                  alias.aliases = "config --show-scope --get-regexp alias";
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
                  credential."https://github.com".helper = "gh auth git-credential";
                  credential."https://github.internal.digitalocean.com".helper = "ghe auth git-credential";
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
              };

              security = {
                sudo.enable = true;
                allowUserNamespaces = true;
                forcePageTableIsolation = true;
                polkit.adminIdentities = ["unix-user:${prefs.user.login}"];
                protectKernelImage = true;
                rtkit.enable = true;
                tpm2.enable = true;
                virtualisation.flushL1DataCache = "always";
              };

              services = {
                acpid.enable = true;
                unclutter.enable = true;
                earlyoom.enable = true;
                earlyoom.freeMemThreshold = 10;
                tlp.enable = true;
                upower.enable = true;
                fwupd.enable = true;
                journald.extraConfig = lib.concatStringsSep "\n" ["SystemMaxUse=1G"];
                journald.forwardToSyslog = false;

                dnscrypt-proxy2 = {
                  enable = lib.mkForce false;
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
                    # blocked_names.blocked_names_file =
                    #   pkgs.writeText "blocked_names"
                    #   (lib.concatStringsSep "\n" (builtins.map (b: builtins.readFile "${self.inputs.blocklists.outPath}/data/${b}/hosts") ["Adguard-cname" "URLHaus" "adaway.org"]));

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
                # services.dnscrypt-proxy2.serviceConfig.StateDirectory = lib.mkForce "dnscrypt-proxy2";
                services.systemd-udev-settle.enable = false;
                services.NetworkManager-wait-online.enable = false;
                services.systemd-networkd-wait-online.enable = false;
              };

              environment.systemPackages =
                (builtins.map (p: pkgs."${p}") prefs.packages.global)
                ++ (with pkgs; [
                  (pkgs.writeShellApplication rec {
                    name = "system";
                    runtimeInputs = with pkgs; [
                      bat
                      git
                      lsd
                      nix
                      nixos-rebuild
                    ];
                    text = ''
                      [[ $# -gt 0 ]] || exec $0 help; cd "${prefs.repo.path}";
                      case $1 in
                        bin) echo "/run/current-system/sw/bin";;
                        bins) lsd --no-symlink "$($0 bin)";;
                        boot|build|build-vm*|dry-activate|dry-build|test|switch) nixos-rebuild --flake "$(pwd)#${prefs.host.name}" "$@" ;;
                        edit) [[ $UID -ne 0 ]] && $EDITOR flake.nix;;
                        flake) [[ $UID -ne 0 ]] && nix "$@";;
                        git) [[ $UID -ne 0 ]] && exec "$@";;
                        help) bat -l=bash --style=header-filename,grid,snip "$0" -r=8: ;;
                        pager) $0 tree | bat --file-name="$0 $*" --plain;;
                        repo|path|dir) pwd;;
                        tree) lsd --tree --no-symlink;;
                        shutdown|poweroff|reboot|journalctl) exec "$@";;
                        repl) nix repl ${(pkgs.writeText "repl.nix" ''
                         rec {
                           inherit (flake.outputs.nixosConfigurations."${prefs.host.name}") pkgs lib options config;
                           inherit (flake.inputs) nixpkgs do-nixpkgs nixos-hardware;
                           flake = builtins.getFlake "${prefs.repo.path}";
                           #flake = builtins.getFlake "${self}";
                           hostName = "${prefs.host.name}";
                           system = "${system}";
                        }
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
                        font.normal.family = "DaddyTimeMono Nerd Font";
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
                ]);

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
      emax = {
        config,
        lib,
        pkgs,
        ...
      }: {
        services.emacs = {
          enable = true;
          install = true;
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
        networking.hosts."162.243.188.132" = ["vpn-nyc3.digitalocean.com"];
        networking.hosts."162.243.188.133" = ["coffee-nyc3.digitalocean.com"];
        networking.hosts."138.68.32.133" = ["coffee-sfo2.digitalocean.com"];
        networking.hosts."138.68.32.132" = ["vpn-sfo2.digitalocean.com"];
        # networking.hosts."10.38.5.231" = ["servicecatalog-staging.internal.digitalocean.com"];
        environment.systemPackages = [pkgs.do-internal];
      };

      /*
      lenovo-x1c8 contains the configuration that is specific to my Lenovo
      X1 Carbon (8th gen), but generic enough to perhaps reuse.
      */
      lenovo-x1c8 = {
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

        security.pam.u2f = {
          enable = true;
          control = "sufficient";
          authFile = pkgs.writeText "u2f-authFile" (lib.concatStringsSep "\n" [
            "${prefs.user.login}:PbfYUgHNUk54RUZu7mOz9DjZ1cYajfXJMQqpVH+jOgoBEyfDmH6JGoJy+zrixAkAjfJxJHdoI7AOhX3rvUfWyQ==,JzU6nKSnlWdd8kpjfIkihYV9AXxTAyNfzdF83haYD9fCsHoBfqKj/pw4xbkl+dl3nOGoOvvgUQcaFHgjVtwYVA==,es256,+presence"
          ]);
        };

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

    # finally, inherit a few values from another project i maintain (utility functions and formatting).
    inherit (self.inputs.fnctl) lib formatter;
  };
  # vim:sts=2:et:ft=nix:fdm=indent:fdl=0:fcl=all:fdo=all
}
