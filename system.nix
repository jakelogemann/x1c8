{
  config,
  lib,
  pkgs,
  modulesPath,
  hostName,
  userName,
  overlays,
  flakeDir,
  ...
} @ inputs:
with builtins;
with lib; {
  system.nixos.tags = ["digitalocean"];
  programs.git.enable = true;
  programs.git.config.init.defaultBranch = "main";
  programs.git.config.url."https://github.com/".insteadOf = ["gh:" "github:"];

  environment.systemPackages = [
    (
      let
        vpn = pkgs.openconnect.outPath;
      in
        pkgs.writeShellScriptBin "do-vpn" (pkgs.lib.concatStringsSep " " [
          "exec"
          "${vpn}/bin/openconnect"
          "--protocol=gp"
          "--csd-wrapper=${vpn}/libexec/openconnect/hipreport.sh"
          "$*"
        ])
    )
  ];
  environment.pathsToLink = ["/share/zsh"];
  fileSystems."/".device = "/dev/disk/by-uuid/45264d57-59a7-428b-a85a-35fa35c1ddeb";
  fileSystems."/".fsType = "btrfs";
  fileSystems."/boot".device = "/dev/disk/by-uuid/6696-7F45";
  fileSystems."/boot".fsType = "vfat";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [intel-compute-runtime];
  hardware.pulseaudio.enable = true;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  nix.allowedUsers = [userName];
  nix.extraOptions = ''experimental-features = nix-command flakes'';
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = ''--max-freed "$((30 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
  nix.package = pkgs.nixFlakes;
  nix.settings.allowed-users = mkDefault ["root" userName];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = mkBefore overlays;
  powerManagement.cpuFreqGovernor = "powersave";
  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.histFile = "$HOME/.zsh_history";
  programs.zsh.histSize = 10000;
  security.allowUserNamespaces = true;
  security.forcePageTableIsolation = true;
  security.rtkit.enable = true;
  security.sudo.enable = true;
  security.tpm2.enable = true;
  security.virtualisation.flushL1DataCache = "always";
  services.earlyoom.enable = true;
  services.earlyoom.freeMemThreshold = 10;
  services.earlyoom.freeSwapThreshold = 10;
  services.journald.extraConfig = concatStringsSep "\n" ["SystemMaxUse=1G"];
  services.journald.forwardToSyslog = false;
  services.netdata.config.global."access log" = "syslog";
  services.netdata.config.global."dbengine multihost disk space" = 4096;
  services.netdata.config.global."debug log" = "syslog";
  services.netdata.config.global."error log" = "syslog";
  services.netdata.config.global."history" = 86400;
  services.netdata.config.global."memory mode" = "save";
  services.netdata.config.global."page cache size" = 128;
  services.netdata.config.registry."allow from" = "localhost";
  services.netdata.config.web."allow badges from" = "localhost";
  services.netdata.config.web."allow connections from" = "localhost";
  services.netdata.config.web."allow dashboard from" = "localhost";
  services.netdata.config.web."allow netdata.conf from" = "localhost";
  services.netdata.config.web."allow streaming from" = "localhost";
  services.netdata.config.web."bind to" = "127.0.0.1";
  services.netdata.enable = false;
  hardware.mcelog.enable = true;
  hardware.gpgSmartcards.enable = true;
  hardware.ksm.enable = true;
  services.sentinelone.enable = true;
  services.kolide-launcher.enable = true;
  services.kolide-launcher.secretFilepath = "/home/${userName}/.do/kolide.secret";
  # security.pki.certificateFiles = [ pkgs.do-nixpkgs.sammyca ];
  services.netdata.enableAnalyticsReporting = false;
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
  virtualisation.docker.rootless.package = pkgs.docker-edge;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;
  # virtualisation.docker.rootless.daemon.settings.fixed-cidr-v6 = "fd00::/80";
  virtualisation.docker.rootless.daemon.settings.default-runtime = "runc";
  virtualisation.docker.rootless.daemon.settings.default-cgroupns-mode = "private";
  virtualisation.docker.rootless.daemon.settings.default-ipc-mode = "private";
  virtualisation.docker.rootless.daemon.settings.icc = false;
  # virtualisation.docker.rootless.daemon.settings.ipv6 = true;
  virtualisation.docker.rootless.daemon.settings.experimental = true;
  swapDevices = [{device = "/dev/disk/by-uuid/e3b45cba-578e-46b9-8633-c6b67f9a556d";}];
  system.activationScripts.flakeDir = concatStringsSep ";\n" [
    "cd '${flakeDir}'"
    "${pkgs.git}/bin/git config core.sharedRepositiory ${userName}"
    "${pkgs.git}/bin/git config user.signingkey 294A961CA96246877C5EDD09B653A686539A8CA9"
    "${pkgs.git}/bin/git config commit.gpgsign no"
    "${pkgs.git}/bin/git config push.gpgSign no"
    "${pkgs.git}/bin/git ls-files --full-name | xargs -r chown -R ${userName}:${userName}"
    "${pkgs.git}/bin/git ls-files --full-name | xargs -r chmod -cR ug+rw ${flakeDir}"
    "chown -R ${userName}:${userName} .git && chmod -R ug+rw,o-rwx .git"
  ];
  environment.shellAliases.git-vars = "${getExe pkgs.bat} -l=ini --file-name 'git var -l' <(git var -l)";
}
