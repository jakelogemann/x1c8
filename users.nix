inputs @ {
  config,
  lib,
  pkgs,
  modulesPath,
  userName,
  hostName,
  flakeDir,
  ...
}:
with lib;
with builtins; {
  users.groups.${userName} = {gid = 990;};
  users.groups.users = {};
  users.groups.wheel = {};
  users.users.${userName} = {
    extraGroups = ["users" "wheel" "systemd-journal" "networkmanager" userName];
    group = userName;
    initialPassword = "";
    home = "/home/${userName}";
    shell = pkgs.zsh;
    uid = 1000;
    isNormalUser = true;
    packages = with pkgs;
      [
        wmctrl
        vscodium
        bat
        coreutils
        dict
        direnv
        expect
        fd
        file
        gnugrep
        gnumake
        gnupg
        gnused
        jless
        lsb-release
        lsof
        mtr
        nixpkgs-fmt
        pinentry
        ranger
        ripgrep
        shellcheck
        ssh-copy-id
        tmux
        tree
        unrar
        unzip
        usbutils
        w3m
        whois
        zip
        mdbook
        (pkgs.writeShellApplication {
          name = "system";
          runtimeInputs = with pkgs; [
            nixos-option
            bat
            nixos-rebuild
            alejandra
            nix
          ];
          text = ''
            show_help(){ bat --pager=never -r=8: -l=sh "$(which "$0")"; exit $(( $1 )); }
            if [ $# -lt 1 ]; then show_help $LINENO; fi; cmd="$1"; shift;
            if [ "$PWD" != "${flakeDir}" ]; then cd "${flakeDir}" || exit $LINENO; fi
            case $cmd in
              develop) exec nix develop "$@" ;;
              repl) exec nix repl "$@" . ;;
              fmt) exec git ls-files --full-name | grep -E \.nix$ | xargs -r alejandra "$@" ;;
              build|dry-build|dry-run|build-vm|build-vm-with-bootloader|dry-activate|switch)
                exec sudo nixos-rebuild --flake "$PWD" --install-bootloader "$cmd" "$@"
                ;;
              clean|prune|gc|optimise)
                nix-collect-garbage -d
                nix-store --optimise
                ;;
              archive|check|clone|lock|prefetch|show|metadata|update)
                exec nix flake "$cmd" "$@" ;;
              git) exec git "$@" ;;
              edit) exec "$EDITOR" "$PWD" ;;
              help|--help|-h) show_help 0 ;;
              *) show_help $LINENO ;;
            esac
          '';
        })
        (pkgs.writeShellScriptBin "data_bags" "cd ~/do/chef/data_bags && ${getExe pkgs.jless} $(find . -mindepth 1 -type f -name '*.json' | ${pkgs.skim}/bin/sk)")
        (pkgs.writeShellScriptBin "fix-display" "exec ${getExe pkgs.xorg.xrandr} --output eDP-1 --auto --output DP-1 --off --output DP-2 --off --output HDMI-1 --off \"$@\"")
        (pkgs.writeShellScriptBin "do-vpn" (concatStringsSep " " [
          "exec sudo ${getExe pkgs.openconnect}"
          "--passwd-on-stdin"
          "--background"
          "--non-inter"
          "--pid-file=/run/do-vpn.pid"
          "--local-hostname=${userName}"
          "--protocol=gp"
          "--csd-wrapper=${pkgs.openconnect}/libexec/openconnect/hipreport.sh"
          "-F _login:user=${userName}"
          "-F _challenge:passwd=1"
          "\"$@\""
        ]))
        (pkgs.writeShellScriptBin "vpn-nyc3" "exec do-vpn https://vpn-nyc3.digitalocean.com/ssl-vpn \"$@\"")
        (pkgs.writeShellScriptBin "vpn-sfo2" "exec do-vpn https://vpn-sfo2.digitalocean.com/ssl-vpn \"$@\"")

        (pkgs.writeShellApplication {
          name = "ghe";
          runtimeInputs = with pkgs; [gh];
          text = concatStringsSep " " ["exec" "env" "GH_HOST='github.internal.digitalocean.com'" "gh" "\"$@\""];
        })
      ]
      ++ optionals (builtins.hasAttr "do-nixpkgs" pkgs) (with pkgs.do-nixpkgs; [
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
  };
}
