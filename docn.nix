{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  assertions = lib.mapAttrsToList (message: assertion: {inherit assertion message;}) {
    /*
    if this module is included the following conditions must be
    satisfied in order to build the machine:
    */
    "sshd is forbidden" = !config.services.sshd.enable;
    "samba is disabled" = !config.services.samba.enable;
    "avahi is disabled" = !config.services.avahi.enable;
    "sudo is enabled" = config.security.sudo.enable;
    # "kolide is enabled" = config.services.kolide-launcher.enable;
  };
  imports = [
    self.inputs.do-nixpkgs.nixosModules.kolide-launcher
    self.inputs.do-nixpkgs.nixosModules.sentinelone
  ];
  security.pki.certificateFiles = [pkgs.do-nixpkgs.sammyca];
  services.sentinelone.enable = false;
  # services.kolide-launcher.enable = true;
  nix.registry.do-nixpkgs.flake = self.inputs.do-nixpkgs;
  system.nixos.tags = ["digitalocean"];
  networking.nameservers = ["127.0.0.1"];
  # networking.resolvconf.enable = lib.mkForce false;
  networking.networkmanager.dns = lib.mkForce "none";
  # networking.useHostResolvConf = true;
  networking.hosts."162.243.188.132" = ["vpn-nyc3.digitalocean.com"];
  networking.hosts."162.243.188.133" = ["coffee-nyc3.digitalocean.com"];
  networking.hosts."138.68.32.133" = ["coffee-sfo2.digitalocean.com"];
  networking.hosts."138.68.32.132" = ["vpn-sfo2.digitalocean.com"];
  environment.variables = rec {
    CGO_ENABLED = "0";
    GO111MODULE = "on";
    GOPROXY = "direct";
    GOPRIVATE = "*.internal.digitalocean.com,github.com/digitalocean";
    GOFLAGS = "-mod=vendor -trimpath";
    GONOPROXY = GOPRIVATE;
    GONOSUMDB = GOPRIVATE;
  };
  environment.systemPackages = with pkgs; [
    (cthulhu {})
    do-nixpkgs.fly
    staff-cert
    dao
    openconnect
    (writeShellScriptBin "jf" "exec docker run --rm -it --mount type=bind,source=\"$HOME/.jfrog\",target=/root/.jfrog 'releases-docker.jfrog.io/jfrog/jfrog-cli-v2-jf' jf \"$@\"")
    (writeShellScriptBin "ghe" "exec env GH_HOST=github.internal.digitalocean.com ${lib.getExe gh} \"$@\"")
    (writeShellScriptBin "vault" "exec env VAULT_CACERT=${sammyca} VAULT_ADDR=https://vault-api.internal.digitalocean.com:8200 ${lib.getExe vault} \"$@\"")
    (writeShellScriptBin "vpn" ''
      # Example Usage:  op read ...PASSWD | MFA=839917 ENDPOINT=coffee-nyc3 USER=jlogemann vpn
      [[ -n "$MFA" ]] || read -r -p "MFA: " MFA
      [[ -n "$USER" ]] || read -r -p "USER: " USER
      [[ -n "$ENDPOINT" ]] || read -r -p "ENDPOINT: " ENDPOINT
      CONNECT_URL="https://$ENDPOINT.digitalocean.com/ssl-vpn"
      PKG_DIR="$(dirname $(dirname $(readlink $(which openconnect))))"
      declare -a vpn_args=( --protocol=gp )
      vpn_args+=( --csd-wrapper=$PKG_DIR/libexec/openconnect/hipreport.sh )
      vpn_args+=( -F _challenge:passwd="$MFA" )
      vpn_args+=( --background )
      vpn_args+=( --pid-file=$HOME/.local/vpn.pid )
      vpn_args+=( --os=linux-64 )
      vpn_args+=( --passwd-on-stdin )
      vpn_args+=( -F _login:user="$USER" )
      vpn_args+=( "$CONNECT_URL" )
      set -x && sudo openconnect "''${vpn_args[@]}"
    '')
  ];
  systemd = {
    slices.compliance.enable = true;
    services.sentinelone = lib.mkIf config.services.sentinelone.enable {
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
    services.kolide-launcher = lib.mkIf config.services.kolide-launcher.enable {
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
    slices.discovery.enable = true;
    services.dnscrypt-proxy2 = {
      serviceConfig.Slice = "discovery.slice";
      serviceConfig.StateDirectory = lib.mkForce "dnscrypt-proxy2";
      serviceConfig.CPUWeight = lib.mkForce 10;
      serviceConfig.CPUQuota = lib.mkForce "10%";
      serviceConfig.DevicePolicy = "closed";
      serviceConfig.PrivateDevices = true;
      serviceConfig.PrivateMounts = true;
      serviceConfig.PrivateTmp = true;
      serviceConfig.PrivateUsers = false;
      serviceConfig.DynamicUser = true;
      serviceConfig.ProtectHome = true;
      serviceConfig.ProtectKernelModules = true;
      serviceConfig.ProtectKernelTunables = true;
    };
  };

  services.dnscrypt-proxy2.settings = {
    # Server Controls
    # ----------------
    block_ipv6 = false;
    block_undelegated = true;
    block_unqualified = true;
    blocked_query_response = "refused";
    lb_strategy = "ph";
    edns_client_subnet = ["0.0.0.0/0" "2001:db8::/32"];
    ipv4_servers = true;
    ipv6_servers = true;
    require_dnssec = true;
    require_nofilter = true;
    require_nolog = true;
    skip_incompatible = true;
    disabled_server_names = [
      "cloudflare"
      "cloudflare-ipv6"
      "cloudflare-security"
      "cloudflare-security-ipv6"
    ];
    server_names = [
      "dnscrypt.ca-2"
      "dnscrypt.ca-2-doh"
      "dnscrypt.ca-2-doh-ipv6"
      "dnscrypt.ca-2-ipv6"
      "dns.digitale-gesellschaft.ch"
      "dns.digitale-gesellschaft.ch-2"
      "dns.digitale-gesellschaft.ch-ipv6"
      "dns.digitale-gesellschaft.ch-ipv6-2"
    ];
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
      iDNS = lib.concatStringsSep "," ["10.124.57.141" "10.124.57.160"];
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
}
