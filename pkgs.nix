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
  users.users.root.packages = lib.mkAfter [ ];
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
      vpn
      lynis
      navi
      yubikey-manager
      ossec
      ranger
      shellcheck
    ]
    ++ lib.optionals (config.services.xserver.enable) (with pkgs; [
(writeShellApplication {
    name = "alacritty";
    runtimeInputs = [ alacritty terminus-nerdfont ];
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
    in lib.concatStringsSep " " [
      "exec alacritty" 
      "--config-file='${writeText "alacritty.yml" (builtins.toJSON config)}'" 
      "\"$@\""
    ];
  })
      arandr
      scrot
      firefox
      feh
      flameshot
      alacritty
      kitty
      yubikey-personalization-gui
      (writeShellScriptBin "fix-display" "exec ${lib.getExe xorg.xrandr} --output eDP-1 --auto --output DP-1 --off --output DP-2 --off --output HDMI-1 --off \"$@\"")
      xbindkeys
      xclip
      xdotool
      xorg.xev
      xorg.xprop
      xorg.xmodmap
      xorg.xwd
      zathura
    ])
    ++ lib.optionals (builtins.hasAttr "do-nixpkgs" pkgs) (with pkgs.do-nixpkgs; [
      (writeShellScriptBin "data_bags" "cd ~/do/chef/data_bags && ${lib.getExe jless} $(find . -mindepth 1 -type f -name '*.json' | ${skim}/bin/sk)")
      (writeShellScriptBin "do-vpn" (lib.concatStringsSep " " [
        "exec sudo ${lib.getExe openconnect}"
        "--passwd-on-stdin"
        "--background"
        "--non-inter"
        "--pid-file=/run/do-vpn.pid"
        "--local-hostname=${userName}"
        "--protocol=gp"
        "--csd-wrapper=${openconnect}/libexec/openconnect/hipreport.sh"
        "-F _login:user=${userName}"
        "-F _challenge:passwd=1"
        "\"$@\""
      ]))
      (writeShellScriptBin "vpn-nyc3" "exec do-vpn https://vpn-nyc3.digitalocean.com/ssl-vpn \"$@\"")
      (writeShellScriptBin "vpn-sfo2" "exec do-vpn https://vpn-sfo2.digitalocean.com/ssl-vpn \"$@\"")


      (writeShellApplication {
        name = "ghe";
        runtimeInputs = [gh];
        text = lib.concatStringsSep " " ["exec" "env" "GH_HOST='github.internal.digitalocean.com'" "gh" "\"$@\""];
      })
      dao
      certtool
      fly
      docc
      jump
      orca2ctl
      dropletctl
      dropship
      golang
      jsonnet
      orca-scripts
      staff-cert
      track-deploy
      vault
    ]);
}
