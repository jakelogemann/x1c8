{
  self,
  config,
  pkgs,
  userName,
  system,
  hostName,
  ...
}:
with pkgs; {
  boot.extraModulePackages = [
    linuxPackages_latest.acpi_call
    linuxPackages_latest.cpupower
    tpm2-tools
    tpm2-tss
    i2c-tools
  ];
  environment.systemPackages =
    [
      (writeShellScriptBin "jf" "exec docker run --rm -it --mount type=bind,source=\"$HOME/.jfrog\",target=/root/.jfrog 'releases-docker.jfrog.io/jfrog/jfrog-cli-v2-jf' jf \"$@\"")
      (writeShellScriptBin "list-git-vars" "${lib.getExe bat} -l=ini --file-name 'git var -l (sorted)' <(${lib.getExe git} var -l | sort)")
      (writeShellScriptBin "system-repl" (let
        entrypoint = ''
          rec {
            inherit (flake.outputs.nixosConfigurations."${hostName}") pkgs lib options;
            currentConfig = flake.outputs.nixosConfigurations."${hostName}".config;
            inherit (flake.inputs) nixpkgs;
            flake = builtins.getFlake "${self}";
            hostName = "${hostName}";
            system = "${system}";
          }
        '';
      in "exec nix repl \"$@\" ${writeText "entrypoint.nix" entrypoint}"))

      commonUtils
      aide
      alejandra
      docker-credential-helpers
      expect
      jless
      lynis
      navi
      yubikey-manager
      ossec
      ranger
      dogdns
      shellcheck
      buildah
      skopeo
      nerdctl
    ]
    ++ lib.optionals (config.services.xserver.enable) (with pkgs; [
      arandr
      scrot
      firefox
      flameshot
      xbindkeys
      xclip
      xdotool
      xorg.xev
      xorg.xprop

      (writeShellApplication {
        name = "alacritty";
        runtimeInputs = [alacritty terminus-nerdfont xcwd];
        text = let
          config = rec {
            cursor.style.blinking = "On";
            cursor.style.shape = "block";
            env.TERM = "alacritty";
            font.builtin_box_drawing = false;
            font.glyph_offset.x = -1;
            font.glyph_offset.y = -1;
            font.normal.family = "TerminessTTF Nerd Font Mono";
            font.offset.x = 0;
            font.offset.y = 1;
            font.size = 9.5;
            font.use_thin_strokes = true;
            live_config_reload = false;
            mouse.hide_when_typing = true;
            selection.save_to_clipboard = true;
            window.dynamic_padding = true;
            window.padding.x = 5;
            window.padding.y = 5;
          };
        in
          lib.concatStringsSep " " [
            "exec alacritty"
            "--working-directory=\"$(xcwd)\""
            "--config-file='${writeText "alacritty.yml" (builtins.toJSON config)}'"
            "\"$@\""
          ];
      })

      (writeShellApplication {
        name = "rofi";
        runtimeInputs = [rofi terminus-nerdfont];
        text = let
        in
          lib.concatStringsSep " " [
            "exec rofi"
            "-markup"
            "-modi drun,ssh,window,run"
            "-font 'TerminessTTF Nerd Font Mono 12'"
            "\"$@\""
          ];
      })
    ])
    ++ lib.optionals (builtins.hasAttr "do-nixpkgs" pkgs) (with pkgs.do-nixpkgs; [
      (writeShellScriptBin "data_bags" "cd ~/do/chef/data_bags && ${lib.getExe jless} $(find . -mindepth 1 -type f -name '*.json' | ${skim}/bin/sk)")
      dao
      do-xdg
      fly
      ghe
      staff-cert
      vault
      vpn
      (symlinkJoin {
        name = "cthulhu-project-bins";
        paths = [ 

          ## "Works on my machine" ::
          anglerfish
          artifact
          backup_scheduler
          canary
          corp
          courier
          deployer
          deptracker
          dev_productivity
          dns
          docc
          droplet
          edgenotifications
          emu
          jump

          ## Still Testing:
          # harpoon
          # hvaddr
          # hvannounced
          # hvdropletmetrics
          # hvflow
          # hvrouter
          # hvvalidate
          # imgdev
          # ipam
          # k8s-updater
          # libvirt-hook-processor
          # looker
          # loudmouth
          # mailer
          # mariner
          # migrate
          # mongo-agent
          # mongo-cockroach-agent
          # netconfig
          # netsecpol
          # networktracerd
          # north
          # octopus
          # octopus2
          # ovsdb
          # plinkod
          # puffer
          # respond
          # rmetadata
          # roe
          # sealice
          # south
          # telemetry
          # versiond
          # vnc-proxy

          ## !Work on my machine ::
          # imgdev     ## missing zlib.pc
          # hvd        ## missing librados, libguestfs.
          # engineroom ## missing librados, zlib.pc
          # evacuator  ## missing zlib.pc
        ];
      })
    ]);
}
