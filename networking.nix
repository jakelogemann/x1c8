inputs @ {
  config,
  lib,
  pkgs,
  modulesPath,
  hostName,
  ...
}: {
  digitalocean.dnscrypt.enable = true;
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
  networking.hostName = hostName;
  networking.domain = "home.arpa";
  networking.hosts."10.74.61.250" = ["github.internal.digitalocean.com"];
  networking.hosts."10.38.6.155" = ["servicecatalog-staging.internal.digitalocean.com"];
  networking.interfaces.enp0s20f0u4u1.useDHCP = true;
  networking.interfaces.enp0s20f0u3u1.useDHCP = true;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.useHostResolvConf = true;
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = false;
  networking.wireless.userControlled.enable = true;
  networking.networkmanager.wifi.powersave = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
    networkmanager-openvpn
  ];
}
