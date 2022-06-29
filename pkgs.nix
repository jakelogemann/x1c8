{
  pkgs,
  userName,
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
      neovim
      arandr
      firefox
      feh
      flameshot
      inxi
      jless
      alacritty
      topgrade
      kitty
      lsd
      lynis
      scrot
      w3m
      whois
      xbindkeys
      xclip
      xdotool
      xorg.xev
      xorg.xprop
      xorg.xmodmap
      xorg.xwd
      yubikey-manager
      yubikey-personalization-gui
      zathura

      ossec
      navi
      skim
      zoxide
      aide
      dmidecode
      hddtemp
      ipmitool
      glxinfo
      sysstat
      docker-credential-helpers
      (writeShellScriptBin "jf" "exec docker run --rm -it --mount type=bind,source=\"$HOME/.jfrog\",target=/root/.jfrog 'releases-docker.jfrog.io/jfrog/jfrog-cli-v2-jf' jf \"$@\"")
      (writeShellScriptBin "fix-display" "exec ${lib.getExe xorg.xrandr} --output eDP-1 --auto --output DP-1 --off --output DP-2 --off --output HDMI-1 --off \"$@\"")
      (writeShellScriptBin "list-git-vars" "${lib.getExe bat} -l=ini --file-name 'git var -l (sorted)' <(${lib.getExe git} var -l | sort)")
      bat
      coreutils
      direnv
      expect
      fd
      file
      gnugrep
      gnumake
      gnupg
      pass
      gnused
      jless
      lsb-release
      lsof
      mtr
      alejandra
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
    ]
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
