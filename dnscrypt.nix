{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  dnsServers = concatStringsSep "," [
    "10.124.57.141"
    "10.124.57.160"
  ];
in {
  options.digitalocean.dnscrypt = {
    enable = mkEnableOption "private/secure dnscrypt-proxy2 config";
    forwarding_rules = mkOption {
      description = "Route queries for specific domains to a dedicated set of servers.";
      type = types.lines;
      default = ''
        internal.digitalocean.com ${dnsServers}
        *.internal.digitalocean.com ${dnsServers}
        10.in.arpa ${dnsServers}
      '';
    };
    cloaking_rules = mkOption {
      description = ''
        Cloaking returns a predefined address for a specific name.
        In addition to acting as a HOSTS file, it can also return the IP address
        of a different name. It will also do CNAME flattening.
      '';
      type = types.lines;
      default = ''
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
    };
    allowed_ips = mkOption {
      description = ''
        Allowed IP lists support the same patterns as IP blocklists
        If an IP response matches an allow ip entry, the corresponding session
        will bypass IP filters.

        Time-based rules are also supported to make some websites only accessible at specific times of the day.
      '';
      type = types.lines;
      default = ''
      '';
    };
    blocked_ips = mkOption {
      description = ''
        IP blocklists are made of one pattern per line.
      '';
      type = types.lines;
      default = ''
      '';
    };
    allowed_names = mkOption {
      type = types.lines;
      example = ''
        example.com
        =example.com
        droplet.*
        droplet*.example.*
        droplet*.example[0-9]*.com
      '';

      description = ''
        Allowlists support the same patterns as blocklists
        If a name matches an allowlist entry, the corresponding session
        will bypass names and IP filters.

        Time-based rules are also supported to make some websites only accessible at specific times of the day.
      '';

      default = ''
        *.internal.digitalocean.com
        *.github.com
        *.gitlab.com
        *.docker.com
      '';
    };
    blocked_names = mkOption {
      description = ''
        Blocklists are made of one pattern per line. Example blocklist files can
        be found at https://download.dnscrypt.info/blocklists/ A script to build
        blocklists from public feeds can be found in the
        `utils/generate-domains-blocklists` directory of the dnscrypt-proxy
        source code.
      '';
      type = types.lines;
      example = ''
        example.com
        =example.com
        *sex*
        ads.*
        ads*.example.*
        ads*.example[0-9]*.com
      '';
      default = ''
        *.local
      '';
    };
  };

  config = mkIf config.digitalocean.dnscrypt.enable {
    networking.nameservers = mkForce ["127.0.0.1" "::1"];
    networking.resolvconf.enable = mkForce false;
    networking.dhcpcd.extraConfig = mkForce "nohook resolv.conf";
    networking.networkmanager.dns = mkForce "none";
    systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = mkForce "dnscrypt-proxy2";
    services.dnscrypt-proxy2.enable = mkForce true;
    services.dnscrypt-proxy2.settings = {
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
      allowed_ips.allowed_ips_file = pkgs.writeText "allowed_ips" config.digitalocean.dnscrypt.allowed_ips;
      cloaking_rules = pkgs.writeText "cloaking_rules" config.digitalocean.dnscrypt.cloaking_rules;
      forwarding_rules = pkgs.writeText "forwarding_rules" config.digitalocean.dnscrypt.forwarding_rules;
      cloak_ttl = 600;
      allowed_names.allowed_names_file = pkgs.writeText "allowed_names" config.digitalocean.dnscrypt.allowed_names;
      blocked_names.blocked_names_file = pkgs.writeText "blocked_names" config.digitalocean.dnscrypt.blocked_names;
      blocked_ips.blocked_ips_file = pkgs.writeText "blocked_ips" config.digitalocean.dnscrypt.blocked_ips;
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
}
