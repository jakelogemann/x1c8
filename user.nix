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

      #glxinfo
      #hddtemp
      #mtr
      _1password
      act
      actionlint
      aide
      aide
      alejandra
      bat
      buildah
      cargo-bloat
      cargo-deny
      cargo-edit
      cargo-expand
      cargo-outdated
      cargo-public-api
      cargo-tarpaulin
      cargo-udeps
      cargo-vet
      cargo-watch
      cargo-web
      commitlint
      coreutils
      cue
      cuelsp
      cuetools
      dasel
      delve
      direnv
      dmidecode
      dnsutils
      docker-credential-helpers
      dogdns
      expect
      expect
      fd
      file
      gh
      git-cliff
      glxinfo
      gnugrep
      gnumake
      gnupg
      gnused
      gnutar
      go
      go-cve-search
      godef
      gofumpt
      golangci-lint
      golangci-lint-langserver
      golint
      gopls
      goreleaser
      goss
      graphviz
      grpcurl
      gum
      helix
      ipmitool
      jless
      jq
      k9s
      killall
      kubectl
      llvm
      llvm-manpages
      lsb-release
      lsd
      lsof
      lynis
      navi
      neovim
      nerdctl
      nix
      nixos-rebuild
      nixpkgs-lint
      nvd
      ossec
      packer
      pass
      pciutils
      pinentry
      pstree
      psutils
      ranger
      ripgrep
      rust-analyzer
      rustup
      rusty-man
      shellcheck
      skim
      skopeo
      starship
      sysstat
      terraform
      tree
      unzip
      usbutils
      w3m
      whois
      wireguard-tools
      zip
      zoxide
      zstd

      (writeShellApplication {
        name = "ldapsearch";
        runtimeInputs = [openldap];
        text = "ldapsearch -xLLLH ldaps://ldap-primary.internal.digitalocean.com -b ou=Groups,dc=internal,dc=digitalocean,dc=com";
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
