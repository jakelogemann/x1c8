inputs @ {
  config,
  lib,
  pkgs,
  modulesPath,
  userName,
  hostName,
  ...
}: {
  home-manager.sharedModules = [
    ({
      config,
      pkgs,
      lib,
      ...
    }:
      with lib; {
        fonts.fontconfig.enable = true;

        home.enableNixpkgsReleaseCheck = false;
        programs.firefox.profiles.default = {
          name = "default";
          bookmarks = let
            internalDomains = [
              "abusefilters-ui"
              "account-cleaner-handler"
              "account-links-api"
              "account-links-data"
              "account-links-ui"
              "ad"
              "adminpolicymanager"
              "adns-ansible"
              "akips"
              "akips-int"
              "alerta"
              "alertservice"
              "alpha"
              "ama"
              "anglerfish"
              "ansible-statsd-production"
              "ansible-statsd-staging"
              "appadmin"
              "apps.pandora"
              "architecture"
              "argo-api"
              "argo-controller"
              "artifact"
              "artifactory"
              "artifactory-nyc3"
              "artifactory-primary"
              "artifactory-sfo2"
              "artifactory-staging"
              "artifactory-standby"
              "artifacts"
              "atlantis"
              "auto-maintenance-app"
              "auto-maintenance-app-staging"
              "autoreview"
              "autoreview.svc"
              "awx"
              "awx-last-production"
              "awx-last-staging"
              "awx-next-production"
              "awx-next-staging"
              "awx-production"
              "awx-staging"
              "awx-statsd-production"
              "awx-statsd-staging"
              "backstage"
              "baleen"
              "bandwidth-usage-api"
              "bgpalerter"
              "bigid"
              "bigid-dev"
              "billing"
              "billing-api"
              "billingredis"
              "bizops-matomo"
              "blog-admin-prod"
              "blog-prod"
              "bloom-links-data"
              "bloom-links-ui"
              "bolt.pandora"
              "broadside"
              "broadside-staging"
              "buildr"
              "buoy"
              "centralnetresourceapi"
              "chef"
              "chef-automate"
              "chef-ha"
              "chef-public"
              "chiplog"
              "ci"
              "cims"
              "cinc"
              "cloudflare-cache"
              "cloudflare-logs"
              "cloudflare-proxy"
              "cloudops-toolbox"
              "cloudshark"
              "cloudwatch"
              "codd"
              "codeclimate"
              "collectd-ingestor"
              "communityredis"
              "concourse"
              "concourse-db"
              "concourse-db-failover"
              "concourse-db-staging"
              "concourse-failover"
              "concourse-prod"
              "concourse-staging"
              "concourse-training"
              "confluence"
              "confluence-dev"
              "confluence-staging"
              "coral"
              "coral-api"
              "corero-ams2"
              "corero-ams3"
              "corero-blr1"
              "corero-fra1"
              "corero-lon1"
              "corero-nyc1"
              "corero-nyc2"
              "corero-nyc3"
              "corero-sfo1"
              "corero-sfo2"
              "corero-sgp1"
              "corero-tor1"
              "cortex"
              "crashreporter"
              "crl"
              "currents"
              "currents-stg"
              "dash.pandora"
              "dashboard"
              "data"
              "data"
              "dbaas"
              "dbaas-rabbitmq-lb"
              "dbaas-rabbitmq-nyc3-1"
              "dbaas-rabbitmq-nyc3-2"
              "dbaas-rabbitmq-nyc3-3"
              "dbaas-rabbitmq-nyc3-lb-1"
              "dbaas-rabbitmq-nyc3-lb-2"
              "dc-net-arch"
              "dcops-pdu-ftp"
              "dctrack"
              "dctrack-dev"
              "dctrack-test"
              "deptracker"
              "dev-api"
              "dev-atlantis"
              "dev-baleen"
              "dev-cloud"
              "dev-netbox"
              "dev-netbox-api"
              "dev2-api"
              "dev2-atlantis"
              "dev2-cloud"
              "dev2-www"
              "dev3-api"
              "dev3-atlantis"
              "dev3-cloud"
              "dev3-www"
              "dex"
              "djl"
              "dns-ansible"
              "dns-tools"
              "dnsapi"
              "do-aptly"
              "do-relic"
              "doaliastemporalfrontend"
              "dobe-versiond"
              "dobe-versiond-http"
              "docc-getting-started"
              "docc-user-guide"
              "docc-web-ui"
              "doccevents"
              "docker"
              "docker-v1"
              "docker-v2"
              "dockerhub-mirror"
              "docradmin"
              "doresearch"
              "drill"
              "drone"
              "drone-prod"
              "drone-staging"
              "droplet"
              "dropletapi"
              "dropletdocker"
              "dropletstats"
              "dropletworkers"
              "dsapi"
              "dust.pandora"
              "ecm-panel"
              "ecm-panel-api"
              "edge.pandora"
              "edgeflipper"
              "edgeflipperapi"
              "eds"
              "elauneind"
              "emu"
              "emu-http"
              "engineering"
              "es7-nginx-loges-nyc3"
              "estuary"
              "estuary-preprod"
              "estuary-stage"
              "experiment"
              "feedback"
              "feedback-stage"
              "flask-skeleton"
              "fleets"
              "flipd"
              "flipperui"
              "flux.pandora"
              "flux.stage-pandora"
              "frankenstein"
              "frankenstein-alert"
              "frozen"
              "funcadmin"
              "gdpr-disclosures"
              "gems"
              "general.pandora"
              "general.stage-pandora"
              "ghe-monitor"
              "gitdash"
              "github"
              "github-failover"
              "github-private"
              "github-staging"
              "github-test"
              "gjoa-neo4j"
              "glass"
              "glb-central"
              "glbadmin"
              "gocd"
              "gocd-prod"
              "gocd-staging"
              "godoc"
              "grafana"
              "grafana-backup"
              "hacktoberfest"
              "halp"
              "harbor"
              "harpoon-server"
              "harpoon-server-stage2"
              "hatch"
              "hcpu-review"
              "hive"
              "hvd-versiond"
              "hvd-versiond-http"
              "hyperkraken"
              "icinga-stage2"
              "inboundredis"
              "infra-architecture"
              "ip-mapper"
              "ipamd"
              "jackrackham-proxy"
              "janitor"
              "jira"
              "jira-dev"
              "jira-staging"
              "jsoneditor"
              "jump"
              "jump-east"
              "jump-west"
              "k8saasadmin"
              "k8saasapi"
              "k8saassvc"
              "kibana"
              "kibana-dev"
              "kibana-es7"
              "kibana-stage2"
              "knight-harpoon-server"
              "koncourse"
              "lb-cadence-web"
              "lbaasadmin"
              "ldap-master"
              "ldap-primary"
              "ldap-primary-nbg1"
              "ldap-primary-nyc3"
              "ldap-primary-sfo2"
              "ldap-primary-test"
              "ldap-readonly-nyc3"
              "ldapconsole"
              "ldapconsole-test"
              "letsencryptcerts"
              "lg"
              "lifecycle-events-kafka"
              "lifecycle-events-kafka-01"
              "lifecycle-events-kafka-02"
              "lifecycle-events-kafka-03"
              "lighthouse"
              "loadbalancersapi"
              "localdev"
              "lockbot"
              "logs"
              "logs-fra1"
              "logs-nyc3"
              "looker"
              "luca.pandora"
              "machine-state-api"
              "maintenances"
              "maintenances-server"
              "mandrillmanager"
              "manifestd"
              "mantis"
              "marina"
              "marketingredis"
              "marketplaceadmin"
              "marvel.dev"
              "marvel.mesos"
              "marvel.stage2"
              "mayday"
              "meta.pandora"
              "meta.stage-pandora"
              "metrics"
              "metrilyx"
              "metronome"
              "mirrors"
              "misc-db"
              "miscdb"
              "monitoring"
              "monitoring-ams2"
              "monitoring-ams3"
              "monitoring-api-ams2"
              "monitoring-api-ams3"
              "monitoring-api-blr1"
              "monitoring-api-fra1"
              "monitoring-api-lon1"
              "monitoring-api-nbg1"
              "monitoring-api-nyc2"
              "monitoring-api-nyc3"
              "monitoring-api-s2r1"
              "monitoring-api-s2r2"
              "monitoring-api-s2r3"
              "monitoring-api-s2r4"
              "monitoring-api-s2r5"
              "monitoring-api-s2r6"
              "monitoring-api-s2r7"
              "monitoring-api-s2r8"
              "monitoring-api-sfo1"
              "monitoring-api-sfo2"
              "monitoring-api-sfo3"
              "monitoring-api-sgp1"
              "monitoring-api-tor1"
              "monitoring-blr1"
              "monitoring-fra1"
              "monitoring-lon1"
              "monitoring-nbg1"
              "monitoring-nyc2"
              "monitoring-nyc3"
              "monitoring-s2r1"
              "monitoring-s2r2"
              "monitoring-s2r3"
              "monitoring-s2r4"
              "monitoring-s2r5"
              "monitoring-s2r6"
              "monitoring-s2r7"
              "monitoring-s2r8"
              "monitoring-sfo1"
              "monitoring-sfo2"
              "monitoring-sfo3"
              "monitoring-sgp1"
              "monitoring-tor1"
              "monitoringpreferences"
              "nautilus"
              "navcent"
              "navy.pandora"
              "nemo"
              "net-pypi"
              "net-spectrum01"
              "netbootd"
              "netbox"
              "netbox-api"
              "netbox-graphql"
              "netdb-graphql"
              "netgraph"
              "netlbadmin"
              "netnag"
              "netprod-pushgateway"
              "netprod-redash"
              "netsecpoldatamonitor"
              "netsmokeping"
              "networksnapshots"
              "notificationsserver"
              "nova.pandora"
              "nyc3-sslvpn1"
              "nyc3-sslvpn2"
              "objectstorage"
              "obs.pandora"
              "obs.stage-pandora"
              "observability"
              "observability-dev"
              "observability-stage2"
              "okta-react-example"
              "onfido-verification"
              "osavatars"
              "osbackend"
              "oxidized"
              "pan01"
              "pan02"
              "pandora"
              "pdu-upgrader"
              "peering"
              "peeringmanager-graphql"
              "perspective"
              "perspective-stage2"
              "phishlabs-takedown-ui"
              "photodna"
              "pilot"
              "plantuml"
              "policies"
              "polygraph"
              "postoffice"
              "power"
              "prod-alpha-mysql"
              "prod-codd-admin"
              "prod-codd-regional-mysql"
              "prod-dns01"
              "prod-glass"
              "prod-net-akips01"
              "prod-net-akips02"
              "prod-rdns-sensugo-ams2"
              "prod-rdns-sensugo-ams3"
              "prod-rdns-sensugo-blr1"
              "prod-rdns-sensugo-fra1"
              "prod-rdns-sensugo-lon1"
              "prod-rdns-sensugo-nbg1"
              "prod-rdns-sensugo-nyc2"
              "prod-rdns-sensugo-nyc3"
              "prod-rdns-sensugo-sfo1"
              "prod-rdns-sensugo-sfo2"
              "prod-rdns-sensugo-sfo3"
              "prod-rdns-sensugo-sgp1"
              "prod-rdns-sensugo-tor1"
              "prod-sec-ingest"
              "prod-timeseries-querysrv"
              "promdash"
              "promlens"
              "puff.pandora"
              "pufferfish"
              "pulpito"
              "r2d2"
              "raid-degrade-app"
              "rdns-ansible"
              "rdns-sensugo-proxy"
              "reboots"
              "regions"
              "resource-cleaner"
              "rolo"
              "rolo-grpc"
              "rundeck"
              "safe-action-service"
              "salesforceredirect"
              "salt-api"
              "salt-doc"
              "salt-master"
              "sammy-checker"
              "sammyca"
              "sc-pandora"
              "scd"
              "scsync"
              "seaotter"
              "seaotter-stage2"
              "seasteader"
              "secret-shark"
              "security-gocd"
              "security-ipam-ui"
              "securitycenter"
              "securitygroupsapi"
              "securitytools"
              "seczk"
              "sentry"
              "servers"
              "servicecatalog"
              "servicecatalog-staging"
              "servicedesk"
              "sfo2-sslvpn1"
              "sfo2-sslvpn2"
              "shield"
              "shipyard"
              "shipyard-api"
              "shipyard-dev"
              "shipyard-dev-api"
              "sku"
              "sku-grpc"
              "slm-api"
              "snorby"
              "spaceproxy"
              "spark-dispatcher"
              "spark-history"
              "splash-api"
              "splash-stage-api"
              "sql-linter"
              "stage-alertservice"
              "stage-alpha"
              "stage-atlantis"
              "stage-billing"
              "stage-billing-api"
              "stage-billingredis"
              "stage-chiplog"
              "stage-communityredis"
              "stage-developers"
              "stage-dsapi"
              "stage-eventbus-kb-001"
              "stage-eventbus-kb-002"
              "stage-eventbus-kb-003"
              "stage-feedback"
              "stage-hacktoberfest-2016"
              "stage-inbound"
              "stage-inboundredis"
              "stage-m"
              "stage-marketingredis"
              "stage-microsite-api"
              "stage-monitoringpreferences"
              "stage-notificationsserver"
              "stage-objectstorage"
              "stage-osavatars"
              "stage-osbackend"
              "stage-pandora"
              "stage-policies"
              "stage-rdns-sensugo-fra1"
              "stage-rdns-sensugo-nyc2"
              "stage-rdns-sensugo-nyc3"
              "stage-rdns-sensugo-sfo2"
              "stage-rdns-sensugo-sfo3"
              "stage-salesforceredirect"
              "stage-securitygroupsapi"
              "stage-servers"
              "stage-spaceproxy"
              "stage-spyglass"
              "stage-stats"
              "stage-tagscache"
              "stage-triggersredis"
              "stage-tws"
              "stage-volagg"
              "stage-volumes"
              "stage-vpcaggregator"
              "stage-vpcapi"
              "stage-webkafka01"
              "stage-www"
              "stage2-alpha-mysql"
              "stage2-codd-regional-mysql"
              "stage2-dns01"
              "stage2-docc-web-ui"
              "stage2-jump"
              "stage2-sentry"
              "starboard"
              "stats-shard-api"
              "stork8s"
              "supermarket"
              "systems-analytics"
              "tableau-server-poc"
              "tagscache"
              "tagsserver"
              "taro.pandora"
              "team-canaryinsight"
              "teams"
              "test-pocldap-primary"
              "test-pocldap-uswest"
              "test-stork8s"
              "teuthida"
              "teuthology"
              "tickets"
              "torpedo"
              "tracecollector"
              "tracecollector-http"
              "triggersredis"
              "twilio-logs"
              "tws-api-stage"
              "uptime-metrics"
              "user-canaryinsight"
              "vault-api"
              "vault-ui"
              "vega.pandora"
              "viperfish"
              "vnicd"
              "volagg"
              "volagg-swap"
              "volumes"
              "volumes-swap"
              "vpc-federator"
              "vpcaggregator"
              "vpcapi"
              "vpcsupportapi"
              "vpn-admin"
              "vpn-nyc3"
              "vpn-sfo2"
              "vsockdialersvc"
              "walrus"
              "wanguard-ams2"
              "wanguard-ams3"
              "wanguard-ams4"
              "wanguard-blr1"
              "wanguard-fra1"
              "wanguard-lon1"
              "wanguard-nbg1"
              "wanguard-nyc1"
              "wanguard-nyc2"
              "wanguard-nyc3"
              "wanguard-sfo1"
              "wanguard-sfo2"
              "wanguard-sgp1"
              "wanguard-tor1"
              "webapp-skeleton"
              "whackamole-ui"
              "wheel-of-misfortune"
              "whois"
              "whois2"
              "wookie"
              "yeti"
            ];
          in
            {
              "docc (stage2) web ui".url = "https://stage2-docc-web-ui.internal.digitalocean.com";
              "docc getting started".url = "https://docc-getting-started.internal.digitalocean.com";
              "docc user guide".url = "https://docc-user-guide.internal.digitalocean.com";
              "docc web ui".url = "https://docc-web-ui.internal.digitalocean.com";
              "people-wiki".url = "https://confluence.internal.digitalocean.com";
              "vpn-nyc3".url = "https://vpn-nyc3.digitalocean.com";
              "vpn-sfo2".url = "https://vpn-sfo2.digitalocean.com";
              "calendar".url = "https://calendar.google.com/";
              "email".url = "https://mail.google.com/";
              "browser config".url = "about:config";
              "browser preferences".url = "about:preferences";
              "fnctl/fnctl".url = "https://github.com/fnctl/fnctl";
              "new browser tab".url = "about:newtab";
            }
            // (builtins.listToAttrs (builtins.map (v: {
                name = v;
                value = {url = "https://${v}.internal.digitalocean.com";};
              })
              internalDomains));
          settings = {
            "browser.startup.homepage" = "about:newtab";
            "extensions.pocket.showHome" = false;
            "browser.search.region" = "US";
            "browser.bookmarks.autoExportHTML" = true;
            "browser.bookmarks.addedImportButton" = false;
            "browser.aboutwelcome.enabled" = true;
            "browser.aboutConfig.showWarning" = false;
            "browser.search.isUS" = true;
            "distribution.searchplugins.defaultLocale" = "en-US";
            "general.useragent.locale" = "en-US";
            "browser.bookmarks.showMobileBookmarks" = false;
            "security.warn_submit_secure_to_insecure" = true;
            "services.sync.engine.passwords" = false;
            "services.sync.engine.history" = false;
            "services.sync.engine.creditcards" = false;
            "browser.quitShortcut.disabled" = true;
            "services.sync.engine.perfs" = false;
            "services.sync.prefs.sync.browser.discovery.enabled" = false;
            "services.sync.prefs.sync.browser.formfill.enabled" = false;
            "services.sync.prefs.sync.browser.link.open_newwindow" = false;
            "services.sync.log.appender.file.logOnError" = false;
            "services.sync.log.appender.file.logOnSuccess" = false;
            "services.sync.engine.tabs" = false;
            "editor.password.mask_delay" = -1;
          };
        };

        programs.starship = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          settings.add_newline = false;
          settings.format = "$character";
          settings.right_format = "$all";
          settings.scan_timeout = 10;
          settings.character.success_symbol = "[➜](bold green)";
          settings.character.error_symbol = "[➜](bold red)";
          settings.character.vicmd_symbol = "[](bold magenta)";
          #settings.character.continuation_prompt = "[▶▶](dim cyan)";
        };

        programs.gh = {
          enable = true;
          settings.git_protocol = "ssh";
          settings.prompt = "enabled";
          settings.browser = "firefox";
          settings.aliases = {
            co = "pr checkout";
            pv = "pr view";
          };
        };

        programs.go = {
          enable = true;
          goPath = "go";
          packages = {
            /*
             "golang.org/x/text" = builtins.fetchGit "https://go.googlesource.com/text";
             "golang.org/x/time" = builtins.fetchGit "https://go.googlesource.com/time";
             */
          };
        };

        programs.zsh = {
          enable = true;
          enableAutosuggestions = true;
          enableCompletion = true;
          history.ignoreDups = true;
          history.ignoreSpace = true;
          history.expireDuplicatesFirst = true;
          history.share = true;
          history.extended = true;
          history.size = 1000000;
          history.ignorePatterns = ["rm *" "pkill *"];
          enableSyntaxHighlighting = false;
          enableVteIntegration = true;
          autocd = true;
          cdpath = ["/run/current-system" "/run/booted-system"];
          completionInit = ''
                autoload -Uz promptinit colors bashcompinit compinit && compinit && bashcompinit && promptinit && colors;
            # ZSH_HIGHLIGHT_STYLES[cursor]='bg=blue'
                eval "$(${getExe pkgs.fly} completion --shell zsh)"
          '';

          initExtra = ''
            setopt autocd autopushd nobeep cdablevars cdsilent chasedots chaselinks completealiases vi extendedhistory histexpiredupsfirst histfcntllock histignoredups histignorespace histsavenodups incappendhistory interactive interactivecomments menucomplete printexitvalue promptsubst pushdignoredups pushdminus pushdsilent pushdtohome sharehistory
            eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
            hash -d current-sw=/run/current-system/sw
            hash -d booted-sw=/run/booted-system/sw
            autoload -U edit-command-line && zle -N edit-command-line && bindkey '\\C-x\\C-e' edit-command-line
            bindkey '\\C-k' up-line-or-history
            bindkey '\\C-j' down-line-or-history
            bindkey '\\C-h' backward-word
            bindkey '\\C-l' forward-word
            source "${pkgs.skim}/share/skim/completion.zsh"
            source "${pkgs.skim}/share/skim/key-bindings.zsh"
            eval "$(${getExe pkgs.navi} widget zsh)"
          '';
        };

        /*
         *
         *** Miscellaneous Ad-hoc Configurations.
         *
         */
        home.stateVersion = "22.05";
        programs.nix-index.enable = true;
        programs.nix-index.enableBashIntegration = true;
        programs.nix-index.enableZshIntegration = true;
        programs.skim.enable = true;
        programs.skim.enableBashIntegration = true;
        programs.skim.enableZshIntegration = true;
        programs.zoxide.enable = true;
        programs.zoxide.enableBashIntegration = true;
        programs.zoxide.enableZshIntegration = true;
        programs.git.delta.enable = true;
        programs.git.enable = true;
        programs.git.ignores = ["*~" "tags" ".nvimlog" "*.swp" "*.swo" "*.log" ".DS_Store"];
        programs.git.attributes = ["*.pdf diff=pdf"];
        programs.git.lfs.enable = true;
        programs.git.extraConfig.pull.ff = true;
        programs.git.extraConfig.pull.rebase = true;
        programs.git.extraConfig.commit.gpgSign = false;
        programs.git.aliases.b = "branch -lav";
        programs.git.aliases.aliases = "!git config --get-regexp '^alias\.' | sed -e 's/^alias\.//' -e 's/\ /\ =\ /'";
        programs.git.aliases.remotes = "!git remote -v | sort -k3";
        programs.git.aliases.loga = "log --graph --decorate --name-status --all";
        programs.git.aliases.amend = "git commit --amend --no-edit";
        programs.git.aliases.amendall = "git commit --all --amend --edit";
        programs.git.aliases.quick-rebase = "rebase --interactive --root --autosquash --auto-stash";
        programs.git.aliases.force-push = "push --force-with-lease=+HEAD";
        programs.git.aliases.amendit = "git commit --amend --edit";
        programs.git.aliases.fp = "fetch --all --prune";
        programs.git.aliases.lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        programs.git.aliases.lglc = "log --not --remotes --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        programs.git.aliases.lglcd = "submodule foreach git log --branches --not --remotes --oneline --decorate";
        programs.git.aliases.st = "status -uno";
        services.gpg-agent.enable = true;
        services.gpg-agent.enableSshSupport = true;
        services.gpg-agent.defaultCacheTtl = 1800;
        programs.alacritty.enable = true;
        programs.lsd.enable = true;
        programs.lsd.enableAliases = true;
        programs.lsd.settings.date = "relative";
        programs.lsd.settings.ignore-globs = [".git" ".hg"];
        programs.command-not-found.enable = false;
        programs.bat.enable = true;
        programs.direnv.enable = true;
        programs.gpg.enable = true;
        programs.home-manager.enable = true;
        programs.man.enable = true;
        programs.man.generateCaches = true;
        programs.matplotlib.enable = false;
        programs.neomutt.enable = true;
        programs.neomutt.vimKeys = true;
        programs.password-store.enable = true;
        programs.topgrade.enable = true;
      })
  ];

  home-manager.users.${userName} = (
    {
      config,
      pkgs,
      lib,
      ...
    }:
      with lib; let
        theme.defaultFont = "TerminessTTF Nerd Font Mono";
        theme.defaultFontSize = "16";

        theme.ac = "#1E88E5";
        theme.mf = "#383838";

        theme.bg = "#111111";
        theme.fg = "#FFFFFF";

        # Colored
        theme.primary = "#91ddff";

        # Dark
        theme.secondary = "#141228";

        # Colored (light)
        theme.tertiary = "#65b2ff";

        # white
        theme.quaternary = "#ecf0f1";

        # middle gray
        theme.quinternary = "#20203d";

        # Red
        theme.urgency = "#e74c3c";

        theme.icon.vim = "";
        theme.icon.sound = "墳";
        theme.icon.muted = "婢";
        theme.icon.cpu = "";
        theme.icon.mem = "";
        theme.icon.apple = "";
        theme.icon.power = "";
        theme.icon.github = "";
        theme.icon.git = "";
        theme.icon.battery-empty = "";
        theme.icon.battery-low = "";
        theme.icon.battery-half = "";
        theme.icon.battery-high = "";
        theme.icon.battery-full = "";
      in {
        programs.git.userEmail = "jlogemann@digitalocean.com";
        programs.git.userName = "Jake Logemann";
        fonts.fontconfig.enable = true;
        programs.firefox.enable = true;
        programs.brave.enable = true;
        programs.google-chrome.enable = false;
        programs.kitty.enable = true;

        home.packages = with pkgs; [
          arandr
          feh
          flameshot
          inxi
          jless
          lynis
          scrot
          terminus-nerdfont
          vlc
          w3m
          whois
          xbindkeys
          xclip
          xdotool
          xorg.xev
          xorg.xprop
          xorg.xmodmap
          xorg.xwd
          youtube-dl
          yubikey-manager
          yubikey-personalization-gui
          zathura
        ];

        xsession.windowManager.i3 = let
          modifier = "Mod4";
        in {
          enable = true;
          package = pkgs.i3-gaps;
          config = with theme; {
            inherit modifier;
            assigns."0: extra" = [
              {
                class = "^Firefox$";
                window_role = "About";
              }
            ];
            assigns."1: extra" = [
              {
                class = "^Slack$";
                window_role = "browser-window";
              }
            ];
            assigns."1: web" = [{class = "^Firefox$";}];
            bars =
              lib.mkForce []
              /*
               disable i3bar/i3status.
               */
              ;
            floating.titlebar = false;
            fonts.names = [defaultFont];
            fonts.size = 14.0;
            fonts.style = "Bold Semi-Condensed";
            gaps.inner = 5;
            gaps.outer = 5;
            gaps.smartBorders = "no_gaps";
            gaps.smartGaps = false;
            terminal = "alacritty";
            window.border = 4;
            workspaceAutoBackAndForth = true;
            workspaceLayout = "default";

            colors.background = bg;
            colors.placeholder = {
              background = "#0c0c0c";
              border = "#000000";
              childBorder = "#0c0c0c";
              indicator = "#000000";
              text = "#ffffff";
            };

            colors.focused = {
              background = primary;
              border = primary;
              childBorder = primary;
              indicator = primary;
              text = fg;
            };

            colors.focusedInactive = {
              background = quinternary;
              border = quinternary;
              childBorder = quinternary;
              indicator = quinternary;
              text = fg;
            };

            colors.unfocused = {
              background = bg;
              border = bg;
              childBorder = bg;
              indicator = bg;
              text = fg;
            };

            colors.urgent = {
              background = urgency;
              border = urgency;
              childBorder = urgency;
              indicator = urgency;
              text = fg;
            };

            modes.autorandr = {
              "0" = "exec autorandr off";
              "1" = "exec autorandr default";
              "2" = "exec autorandr left";
              "3" = "exec autorandr dual";
              "h" = "exec autorandr horizontal";
              "v" = "exec autorandr vertical";
              "l" = "exec autorandr common";
              "Shift+l" = "exec autorandr clone-largest";
              "Escape" = "mode default";
              "Return" = "mode default";
            };

            modes.desktop = {
              "r" = "i3-msg reload";
              "Shift+r" = "i3-msg restart";
              "Shift+q" = "i3-msg exit";
              "Escape" = "mode default";
              "Return" = "mode default";
            };

            modes.move-container = {
              "0" = "move scratchpad; mode default;";
              "1" = "move container to workspace number 1; mode default;";
              "2" = "move container to workspace number 2; mode default;";
              "3" = "move container to workspace number 3; mode default;";
              "4" = "move container to workspace number 4; mode default;";
              "5" = "move container to workspace number 5; mode default;";
              "6" = "move container to workspace number 6; mode default;";
              "7" = "move container to workspace number 7; mode default;";
              "8" = "move container to workspace number 8; mode default;";
              "9" = "move container to workspace number 9; mode default;";
              "Escape" = "mode default";
              "Return" = "mode default";
            };

            modes.resize = {
              "Left" = "resize shrink width 10 px or 10 ppt";
              "Down" = "resize grow height 10 px or 10 ppt";
              "Up" = "resize shrink height 10 px or 10 ppt";
              "Right" = "resize grow width 10 px or 10 ppt";
              "Escape" = "mode default";
              "Return" = "mode default";
            };

            startup = [
              {
                command = "exec i3-msg workspace 1";
                always = true;
                notification = false;
              }
              {
                command = "systemctl --user restart polybar.service";
                always = true;
                notification = false;
              }
              /*
               {
               command = "${pkgs.feh}/bin/feh --bg-scale ~/background.png";
               always = true;
               notification = false;
               }
               */
            ];

            keybindings = with pkgs; {
              "XF86Display" = "exec ${xorg.xrandr}/bin/xrandr --output eDP-1 --auto --output DP-1 --off --output DP-2 --off --output HDMI-1 --off";
              "${modifier}+XF86Display" = "exec ${xorg.xrandr}/bin/xrandr --output eDP-1 --off --output DP-1 --auto --output DP-2 --auto --output HDMI-1 --auto";
              "XF86AudioMute" = "exec amixer set Master toggle";
              "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
              "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
              "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
              "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";

              "${modifier}+Shift+0" = "move scratchpad";
              "${modifier}+Shift+1" = "move container to workspace number 1";
              "${modifier}+Shift+2" = "move container to workspace number 2";
              "${modifier}+Shift+3" = "move container to workspace number 3";
              "${modifier}+Shift+4" = "move container to workspace number 4";
              "${modifier}+Shift+5" = "move container to workspace number 5";
              "${modifier}+Shift+6" = "move container to workspace number 6";
              "${modifier}+Shift+7" = "move container to workspace number 7";
              "${modifier}+Shift+8" = "move container to workspace number 8";
              "${modifier}+Shift+9" = "move container to workspace number 9";
              "${modifier}+0" = "scratchpad show";
              "${modifier}+1" = "workspace number 1";
              "${modifier}+2" = "workspace number 2";
              "${modifier}+3" = "workspace number 3";
              "${modifier}+4" = "workspace number 4";
              "${modifier}+5" = "workspace number 5";
              "${modifier}+6" = "workspace number 6";
              "${modifier}+7" = "workspace number 7";
              "${modifier}+8" = "workspace number 8";
              "${modifier}+9" = "workspace number 9";
              "${modifier}+Control+Shift+q" = "exec ${i3-gaps}/bin/i3-msg exit";
              "${modifier}+Ctrl+d" = "floating toggle";
              "${modifier}+v" = "split v";
              "${modifier}+minus" = "split h";
              "${modifier}+comma" = "mode desktop";
              "${modifier}+Control+a" = "mode autorandr";
              "${modifier}+period" = "mode move-container";
              "${modifier}+i" = "focus child";
              "${modifier}+u" = "mode resize";
              "${modifier}+o" = "focus parent";
              "${modifier}+b" = "bar mode toggle";

              "${modifier}+h" = "focus left";
              "${modifier}+j" = "focus down";
              "${modifier}+k" = "focus up";
              "${modifier}+l" = "focus right";
              "${modifier}+Left" = "focus left";
              "${modifier}+Down" = "focus down";
              "${modifier}+Up" = "focus up";
              "${modifier}+Right" = "focus right";

              "${modifier}+Shift+h" = "move left";
              "${modifier}+Shift+j" = "move down";
              "${modifier}+Shift+k" = "move up";
              "${modifier}+Shift+l" = "move right";
              "${modifier}+Shift+Left" = "move left";
              "${modifier}+Shift+Down" = "move down";
              "${modifier}+Shift+Up" = "move up";
              "${modifier}+Shift+Right" = "move right";

              "${modifier}+Ctrl+h" = "resize shrink width 4px or 4 ppt";
              "${modifier}+Ctrl+j" = "resize grow height 4px or 4 ppt";
              "${modifier}+Ctrl+k" = "resize shrink height 4px or 4 ppt";
              "${modifier}+Ctrl+l" = "resize grow width 4px or 4 ppt";
              "${modifier}+Ctrl+Left" = "resize shrink width 4px or 4 ppt";
              "${modifier}+Ctrl+Down" = "resize grow height 4px or 4 ppt";
              "${modifier}+Ctrl+Up" = "resize shrink height 4px or 4 ppt";
              "${modifier}+Ctrl+Right" = "resize grow width 4px or 4 ppt";

              "${modifier}+Ctrl+f" = "fullscreen toggle";
              "${modifier}+Shift+Tab" = "workspace prev_on_output";
              "${modifier}+Shift+q" = "kill";
              "${modifier}+Tab" = "workspace next_on_output";
              "${modifier}+f" = "exec ${alacritty}/bin/alacritty -e ranger";
              "${modifier}+d" = "exec ${dmenu}/bin/dmenu_run";
              "${modifier}+e" = "exec ${alacritty}/bin/alacritty -e vim";
              "${modifier}+grave" = "workspace back_and_forth";
              "${modifier}+Space" = "exec rofi -show drun";
              "${modifier}+r" = "exec rofi -show drun";
              "${modifier}+t" = "exec ${alacritty}/bin/alacritty";
              "${modifier}+w" = "exec ${firefox}/bin/firefox";
            };
          };
        };

        services.dunst = {
          enable = true;
          settings = {
            global = {
              geometry = "300x5-30+50";
              transparency = 10;
              frame_color = theme.tertiary;
              font = "${theme.defaultFont} ${theme.defaultFontSize}";
            };
            urgency_normal = {
              background = theme.bg;
              foreground = theme.fg;
              timeout = 10;
            };
          };
        };

        services.polybar = {
          enable = true;
          script = "polybar -q -r top & polybar -q -r bottom &";
          package = pkgs.polybar.override {
            i3GapsSupport = true;
            alsaSupport = true;
          };
          config = with theme; {
            "global/wm" = {
              margin-bottom = 0;
              margin-top = 0;
            };

            #====================BARS====================#

            "bar/top" = {
              bottom = false;
              fixed-center = true;

              width = "100%";
              height = 24;
              offset-x = "1%";

              scroll-up = "i3wm-wsnext";
              scroll-down = "i3wm-wsprev";

              background = bg;
              foreground = fg;

              radius = 0;

              font-0 = "${defaultFont}:size=${defaultFontSize};3";
              font-1 = "${defaultFont}:style=Bold:size=${defaultFontSize};3";

              modules-left = "distro-icon i3";
              modules-center = "title";
              modules-right = "audio date";

              locale = "en_US.UTF-8";
            };

            "bar/bottom" = {
              bottom = true;
              fixed-center = true;

              width = "100%";
              height = 19;

              offset-x = "1%";

              background = bg;
              foreground = fg;

              radius-top = 0;

              tray-position = "left";
              tray-detached = false;
              tray-maxsize = 15;
              tray-background = primary;
              tray-offset-x = -19;
              tray-offset-y = 0;
              tray-padding = 5;
              tray-scale = 1;
              padding = 0;

              font-0 = "${defaultFont}:size=${defaultFontSize};3";
              font-1 = "${defaultFont}:style=Bold:size=${defaultFontSize};3";
              modules-left = "tray ghe";
              modules-right = "network cpu memory battery powermenu";
              locale = "en_US.UTF-8";
            };

            "settings" = {
              throttle-output = 5;
              throttle-output-for = 10;
              throttle-input-for = 30;

              screenchange-reload = true;

              compositing-background = "source";
              compositing-foreground = "over";
              compositing-overline = "over";
              comppositing-underline = "over";
              compositing-border = "over";

              pseudo-transparency = "false";
            };

            #--------------------MODULES--------------------"

            "module/ghe" = {
              type = "custom/script";
              exec = let
                script = pkgs.writeShellScriptBin "ghe-check" ''
                  actual=$(${pkgs.curl}/bin/curl -sS https://github.internal.digitalocean.com/robots.txt | ${pkgs.openssl}/bin/openssl dgst -sha512 -)
                  expected="(stdin)= 4ace1fd091808f9bdc2377a791e68ba529c5e1e88d9bd3bed5852f08146fc16126ddca54e418c7754715cd33484f41dc5212586e77faa5c91fe864f51007321c"
                  if [[ "$actual" == "$expected" ]]; then echo -e '\ue709'; fi; exit 0;
                '';
              in "${script}/bin/ghe-check";
              interval = 30;
              format = "<label>";
              format-foreground = quaternary;
              format-background = secondary;
              format-padding = 1;
              label = "%output%";
              label-font = 1;
            };

            "module/distro-icon" = {
              type = "custom/script";
              exec = "${pkgs.coreutils}/bin/uname -r | ${pkgs.coreutils}/bin/cut -d- -f1";
              interval = 999999999;

              format = " <label>";
              format-foreground = quaternary;
              format-background = secondary;
              format-padding = 1;
              label = "%output%";
              label-font = 2;
            };

            "module/audio" = {
              type = "internal/alsa";

              format-volume = "${icon.sound} <label-volume>";
              format-volume-padding = 1;
              format-volume-foreground = secondary;
              format-volume-background = tertiary;
              label-volume = "%percentage%%";

              format-muted = "<label-muted>";
              format-muted-padding = 1;
              format-muted-foreground = secondary;
              format-muted-background = tertiary;
              format-muted-prefix = "${icon.muted} ";
              format-muted-prefix-foreground = urgency;
              format-muted-overline = bg;

              label-muted = "MUTE";
            };

            "module/battery" = {
              type = "internal/battery";
              full-at = 101; # to disable it
              battery = "BAT0"; # TODO: Better way to fill this
              adapter = "AC0";

              poll-interval = 2;

              label-full = "${icon.battery-full} 100%";
              format-full-padding = 1;
              format-full-foreground = secondary;
              format-full-background = primary;

              format-charging = "${icon.power} <animation-charging> <label-charging>";
              format-charging-padding = 1;
              format-charging-foreground = secondary;
              format-charging-background = primary;
              label-charging = "%percentage%% +%consumption%W";
              animation-charging-0 = icon.battery-empty;
              animation-charging-1 = icon.battery-low;
              animation-charging-2 = icon.battery-half;
              animation-charging-3 = icon.battery-high;
              animation-charging-4 = icon.battery-full;
              animation-charging-framerate = 500;

              format-discharging = "<ramp-capacity> <label-discharging>";
              format-discharging-padding = 1;
              format-discharging-foreground = secondary;
              format-discharging-background = primary;
              label-discharging = "%percentage%% -%consumption%W";
              ramp-capacity-0 = icon.battery-empty;
              ramp-capacity-0-foreground = urgency;
              ramp-capacity-1 = icon.battery-low;
              ramp-capacity-1-foreground = urgency;
              ramp-capacity-2 = icon.battery-half;
              ramp-capacity-3 = icon.battery-high;
              ramp-capacity-4 = icon.battery-full;
            };

            "module/cpu" = {
              type = "internal/cpu";

              interval = "0.5";

              format = "${icon.cpu} <label>";
              format-foreground = quaternary;
              format-background = secondary;
              format-padding = 1;

              label = "CPU %percentage%%";
            };

            "module/date" = {
              type = "internal/date";

              interval = "1.0";

              time = "%H:%M:%S";
              time-alt = "%Y-%m-%d%";

              format = "<label>";
              format-padding = 4;
              format-foreground = fg;

              label = "%time%";
            };

            "module/i3" = {
              type = "internal/i3";
              pin-workspaces = false;
              strip-wsnumbers = true;
              format = "<label-state> <label-mode>";
              format-background = tertiary;

              ws-icon-0 = "1;";
              ws-icon-1 = "2;";
              ws-icon-2 = "3;﬏";
              ws-icon-3 = "4;";
              ws-icon-4 = "5;";
              ws-icon-5 = "6;";
              ws-icon-6 = "7;";
              ws-icon-7 = "8;";
              ws-icon-8 = "9;";
              ws-icon-9 = "10;";

              label-mode = "%mode%";
              label-mode-padding = 1;

              label-unfocused = "%icon%";
              label-unfocused-foreground = quinternary;
              label-unfocused-padding = 1;

              label-focused = "%index% %icon%";
              label-focused-font = 2;
              label-focused-foreground = secondary;
              label-focused-padding = 1;

              label-visible = "%icon%";
              label-visible-padding = 1;

              label-urgent = "%index%";
              label-urgent-foreground = urgency;
              label-urgent-padding = 1;

              label-separator = "";
            };

            "module/title" = {
              type = "internal/xwindow";
              format = "<label>";
              format-foreground = secondary;
              label = "%title%";
              label-maxlen = 70;
            };

            "module/memory" = {
              type = "internal/memory";

              interval = 3;

              format = "${icon.mem} <label>";
              format-background = tertiary;
              format-foreground = secondary;
              format-padding = 1;

              label = "RAM %percentage_used%%";
            };

            "module/network" = {
              type = "internal/network";
              interface = "enp0s20f0u4u1";
              interval = "1.0";

              accumulate-stats = true;
              unknown-as-up = true;

              format-connected = "<label-connected>";
              format-connected-background = mf;
              format-connected-underline = bg;
              format-connected-overline = bg;
              format-connected-padding = 2;
              format-connected-margin = 0;

              format-disconnected = "<label-disconnected>";
              format-disconnected-background = mf;
              format-disconnected-underline = bg;
              format-disconnected-overline = bg;
              format-disconnected-padding = 2;
              format-disconnected-margin = 0;

              label-connected = "D %downspeed:2% | U %upspeed:2%";
              label-disconnected = "DISCONNECTED";
            };

            "module/temperature" = {
              type = "internal/temperature";

              interval = "0.5";

              thermal-zone = 0; # TODO: Find a better way to fill that
              warn-temperature = 60;
              units = true;

              format = "<label>";
              format-background = mf;
              format-underline = bg;
              format-overline = bg;
              format-padding = 2;
              format-margin = 0;

              format-warn = "<label-warn>";
              format-warn-background = mf;
              format-warn-underline = bg;
              format-warn-overline = bg;
              format-warn-padding = 2;
              format-warn-margin = 0;

              label = "TEMP %temperature-c%";
              label-warn = "TEMP %temperature-c%";
              label-warn-foreground = "#f00";
            };

            "module/powermenu" = {
              type = "custom/menu";
              expand-right = true;

              format = "<label-toggle> <menu>";
              format-background = secondary;
              format-padding = 1;

              label-open = "";
              label-close = "";
              label-separator = "  ";

              menu-0-0 = " Suspend";
              menu-0-0-exec = "systemctl suspend";
              menu-0-1 = " Reboot";
              menu-0-1-exec = "v";
              menu-0-2 = " Shutdown";
              menu-0-2-exec = "systemctl poweroff";
            };
          };
        };

        programs.autorandr = {
          enable = true;
          hooks.postswitch."notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
          hooks.postswitch."change-dpi" = ''
            case "$AUTORANDR_CURRENT_PROFILE" in
            default|dual|left) DPI=160 ;;
            *) echo "Unknown profle: $AUTORANDR_CURRENT_PROFILE" && exit 1 ;;
            esac; echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
          '';

          profiles = let
            fingerprints = {
              builtin = "00ffffffffffff0009e5db0700000000011c0104a51f1178027d50a657529f27125054000000010101010101010101010101010101013a3880de703828403020360035ae1000001afb2c80de703828403020360035ae1000001a000000fe00424f452043510a202020202020000000fe004e4531343046484d2d4e36310a0043";
              left = "00ffffffffffff0010acb7414c4b4241341e0104b53c22783eee95a3544c99260f5054a54b00e1c0d100d1c0b300a94081808100714f4dd000a0f0703e803020350055502100001a000000ff00424e4e354332330a2020202020000000fd00184b1e8c36010a202020202020000000fc0044454c4c205532373230510a200187020324f14c101f2005140413121103020123097f0783010000e305ff01e6060701605628a36600a0f0703e803020350055502100001a565e00a0a0a029503020350055502100001a114400a0800025503020360055502100001a0000000000000000000000000000000000000000000000000000000000000000000000000014";
              right = "00ffffffffffff0010acb7414c534541341e0104b53c22783eee95a3544c99260f5054a54b00e1c0d100d1c0b300a94081808100714f4dd000a0f0703e803020350055502100001a000000ff0037574e354332330a2020202020000000fd00184b1e8c36010a202020202020000000fc0044454c4c205532373230510a20017e020324f14c101f2005140413121103020123097f0783010000e305ff01e6060701605628a36600a0f0703e803020350055502100001a565e00a0a0a029503020350055502100001a114400a0800025503020360055502100001a0000000000000000000000000000000000000000000000000000000000000000000000000014";
            };
          in {
            default.fingerprint.eDP-1 = fingerprints.builtin;
            default.config.eDP-1.enable = true;
            default.config.eDP-1.primary = true;
            default.config.eDP-1.rotate = "normal";
            default.config.eDP-1.dpi = 160;
            default.config.eDP-1.mode = "1920x1080";
            default.config.eDP-1.position = "0x0";

            left.fingerprint.DP-1 = fingerprints.left;
            left.config.DP-1.enable = true;
            left.config.DP-1.primary = true;
            left.config.DP-1.rotate = "normal";
            left.config.DP-1.mode = "3840x2160";
            left.config.DP-1.position = "0x0";

            dual.fingerprint.DP-2 = fingerprints.right;
            dual.fingerprint.DP-1 = fingerprints.left;
            dual.config.DP-1.enable = true;
            dual.config.DP-1.primary = false;
            dual.config.DP-1.rotate = "normal";
            dual.config.DP-1.dpi = 160;
            dual.config.DP-1.mode = "1920x1080";
            dual.config.DP-1.position = "0x0";
            dual.config.DP-2.enable = true;
            dual.config.DP-2.primary = true;
            dual.config.DP-2.rotate = "normal";
            dual.config.DP-2.dpi = 160;
            dual.config.DP-2.mode = "1920x1080";
            dual.config.DP-2.position = "2560x0";
          };
        };

        programs.rofi = let
          /*
           Use `mkLiteral` for string-like values that should show without quotes, e.g.:
           {
           foo = "abc"; => foo: "abc";
           bar = mkLiteral "abc"; => bar: abc;
           };
           */
          inherit (config.lib.formats.rasi) mkLiteral;
        in {
          enable = true;
          pass.enable = true;
          cycle = true;
          font = with theme; "${defaultFont} ${defaultFontSize}";
          location = "center";
          terminal = "${pkgs.alacritty}/bin/alacritty";
          extraConfig = {
            hover-select = true;
            sidebar-mode = true;
            steal-focus = true;
            window-thumbnail = true;
            case-sensitive = false;
            sort = true;
            sorting-method = "fzf";
            display-drun = "App";
            display-ssh = "SSH";
            display-emoji = "Emoji";
            display-window = "Windows";
            display-run = "Run";
            display-filebrowser = "Files";
            display-keys = "Keys";
            ssh-command = "{terminal} -e {ssh-client} {host} [-p {port}]";
            window-format = "{c}: {t} on {w}";
            modi = "drun,window,ssh,filebrowser,emoji,keys";
            kb-row-up = "Up,Control+p,Control+k,ISO_Left_Tab";
            kb-row-down = "Down,Control+n,Control+j";
            kb-accept-entry = "Control+m,Return,KP_Enter";
            kb-remove-to-eol = "";
            kb-page-prev = "Page_Up";
            kb-page-next = "Page_Down";
            kb-primary-paste = "Control+V,Shift+Insert";
            kb-secondary-paste = "Control+v,Insert";
          };
          theme = {
            "*" = {
              text-color = mkLiteral "#ffeedd";
              background-color = mkLiteral "#000000";
              dark = mkLiteral "#1c1c1c";
              # Black
              black = mkLiteral "#3d352a";
              lightblack = mkLiteral "#554444";
              #
              # Red
              red = mkLiteral "#cd5c5c";
              lightred = mkLiteral "#cc5533";
              #
              # Green
              green = mkLiteral "#86af80";
              lightgreen = mkLiteral "#88cc22";
              #
              # Yellow
              yellow = mkLiteral "#e8ae5b";
              lightyellow = mkLiteral "#ffa75d";
              #
              # Blue
              blue = mkLiteral "#6495ed";
              lightblue = mkLiteral "#87ceeb";
              #
              # Magenta
              magenta = mkLiteral "#deb887";
              lightmagenta = mkLiteral "#996600";
              #
              # Cyan
              cyan = mkLiteral "#b0c4de";
              lightcyan = mkLiteral "#b0c4de";
              #
              # White
              white = mkLiteral "#bbaa99";
              lightwhite = mkLiteral "#ddccbb";
              #
              # Bold, Italic, Underline
              highlight = mkLiteral "bold #ffffff";
            };

            "window" = {
              height = mkLiteral "100%";
              width = mkLiteral "30em";
              location = mkLiteral "east";
              anchor = mkLiteral "east";
              border = mkLiteral "0px 2px 0px 0px";
              text-color = mkLiteral "@lightwhite";
            };
            "mode-switcher" = {
              border = mkLiteral "2px 0px 0px 0px";
              background-color = mkLiteral "@lightblack";
              padding = mkLiteral "4px";
            };
            "button selected" = {
              border-color = mkLiteral "@lightgreen";
              text-color = mkLiteral "@lightgreen";
            };
            "inputbar" = {
              background-color = mkLiteral "@lightblack";
              text-color = mkLiteral "@lightgreen";
              padding = mkLiteral "4px";
              border = mkLiteral "0px 0px 2px 0px";
            };
            "mainbox" = {
              expand = true;
              background-color = mkLiteral "#1c1c1cee";
              spacing = mkLiteral "1em";
            };
            "listview" = {
              padding = mkLiteral "0em 0.4em 0em 1em";
              dynamic = false;
              lines = 0;
            };
            "element-text" = {
              background-color = mkLiteral "inherit";
              text-color = mkLiteral "inherit";
            };
            "element selected  normal" = {
              background-color = mkLiteral "@blue";
            };
            "element normal active" = {
              text-color = mkLiteral "@lightblue";
            };
            "element normal urgent" = {
              text-color = mkLiteral "@lightred";
            };
            "element alternate normal" = {};
            "element alternate active" = {
              text-color = mkLiteral "@lightblue";
            };
            "element alternate urgent" = {
              text-color = mkLiteral "@lightred";
            };
            "element selected active" = {
              background-color = mkLiteral "@lightblue";
              text-color = mkLiteral "@dark";
            };
            "element selected urgent" = {
              background-color = mkLiteral "@lightred";
              text-color = mkLiteral "@dark";
            };
            "error-message" = {
              expand = true;
              background-color = mkLiteral "red";
              border-color = mkLiteral "darkred";
              border = mkLiteral "2px";
              padding = mkLiteral "1em";
            };
          };

          package = pkgs.rofi.override {
            plugins = [pkgs.rofi-emoji pkgs.rofi-systemd pkgs.rofi-power-menu pkgs.rofi-pass];
          };
        };
      }
  );
}
