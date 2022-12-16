{
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
