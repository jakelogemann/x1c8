{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = builtins.fromTOML (builtins.readFile ./config.toml);
in {
  programs = {
    xwayland.enable = true;
    sway = {
      enable = true;
      wrapperFeatures.base = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (k: v: "export ${k}=${v}") {
        # SDL:
        SDL_VIDEODRIVER = "wayland";
        # QT (needs qt5.qtwayland in systemPackages):
        QT_QPA_PLATFORM = "wayland-egl";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        _JAVA_AWT_WM_NONREPARENTING = "1";
      }));
      extraPackages = with pkgs; [
        _1password-gui
        firefox
        firefox-wayland
        sway-contrib.inactive-windows-transparency
        sway-contrib.grimshot
        jq
        mako
        wayland-utils
        foot
        grim
        kitty
        light
        logseq
        slack
        slurp
        swaybg
        swaycwd
        swayidle
        swaylock
        waybar
        wl-clipboard
        wofi
        (writeShellScriptBin "sway-focus" (builtins.readFile ./sway-focus))
      ];
    };
  };
  /*
  XDG Configuration
  */
  xdg.mime = {
    enable = true;
    defaultApplications."application/pdf" = "firefox.desktop";
    removedAssociations."audio/mp3" = ["mpv.desktop" "umpv.desktop"];
    removedAssociations."inode/directory" = "codium.desktop";
  };
  /*
  Configuration Files
  */
  environment = {
    systemPackages = with pkgs;
      builtins.concatLists [
        (builtins.map (entry: makeDesktopItem entry) cfg.desktopItem)
        (builtins.map (entry:
          makeDesktopItem {
            name = "internal-${entry}";
            desktopName = "Open ${entry}.internal.";
            exec = "xdg-open https://${entry}.internal.digitalocean.com";
          })
        cfg.internalHostnames)
      ];
    etc = {
      "sway/config" = {
        text = builtins.readFile ./config;
      };

      "xdg/waybar/config" = {
        text = builtins.toJSON {
          layer = "top";
          position = "top";

          modules-left = [
            "sway/workspaces"
            "sway/mode"
            "sway/scratchpad"
          ];

          modules-center = [
            "sway/window"
          ];

          modules-right = [
            "idle_inhibitor"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "backlight"
            "keyboard-state"
            "sway/language"
            "battery"
            "clock"
            "tray"
          ];

          "sway/workspaces" = {
            disable-scroll = false;
            all-outputs = true;
            format = "{name}: {icon}";
            format-icons."1" = "";
            format-icons."2" = "";
            format-icons."3" = "";
            format-icons."4" = "";
            format-icons."5" = "";
            format-icons.urgent = "";
            format-icons.focused = "";
            format-icons.default = "";
          };

          keyboard-state = {
            numlock = true;
            capslock = true;
            format = "{name} {icon}";
            format-icons.locked = "";
            format-icons.unlocked = "";
          };

          "sway/mode".format = "<span style=\"italic\">{}</span>";

          "sway/scratchpad" = {
            format = "{icon} {count}";
            show-empty = false;
            format-icons = ["" ""];
            tooltip = true;
            tooltip-format = "{app}: {title}";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons.activated = "";
            format-icons.deactivated = "";
          };

          tray.spacing = 10;

          clock = {
            timezone = "America/New_York";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };

          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };

          memory = {
            format = "{}% ";
          };

          temperature = {
            /*
            "thermal-zone"= 2;
            "hwmon-path"= "/sys/class/hwmon/hwmon2/temp1_input";
            */
            critical-threshold = 80;
            format-critical = "{temperatureC}°C {icon}";
            format = "{temperatureC}°C {icon}";
            format-icons = ["" "" ""];
          };

          backlight = {
            format = "{percent}% {icon}";
            format-icons = ["" "" "" "" "" "" "" "" ""];
          };

          battery = {
            states."good" = 95;
            states."warning" = 30;
            states."critical" = 15;
            "format" = "{capacity}% {icon}";
            "format-charging" = "{capacity}% ";
            "format-plugged" = "{capacity}% ";
            "format-alt" = "{time} {icon}";
            "format-good" = "";
            "format-full" = "";
            format-icons = ["" "" "" "" ""];
          };

          network = {
            interface = "wlan0";
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          pulseaudio = {
            scroll-step = 1;
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons."headphone" = "";
            format-icons."hands-free" = "";
            format-icons."headset" = "";
            format-icons."phone" = "";
            format-icons."portable" = "";
            format-icons."car" = "";
            format-icons."default" = ["" "" ""];
            on-click = "pavucontrol";
          };

          /*
          "custom/media"= {
            format = "{icon} {}";
            return-type = "json";
            max-length = 40;
            format-icons.spotify = "";
            format-icons.default = "🎜";
            escape  = true;
            "exec"  = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
            "exec"  = "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" # Filter player based on name
          };
          */
        };
      };

      "xdg/wofi/config" = {
        text = builtins.concatStringsSep "\n" [
          "allow_images=true"
          "allow_markup=true"
          "gtk_dark=true"
          "hide_scroll=true"
          "image_size=24"
          "insensitive=true"
          "key_backward=Control_L-b"
          "key_down=Down,Control_L-j"
          "key_expand=Tab,Control_L-Space"
          "key_forward=Control_L-f"
          "key_left=Left,Control_L-h"
          "key_right=Right,Control_L-l"
          "key_up=Up,Control_L-k"
          "layer=overlay"
          "lines=20"
          "matching=fuzzy"
          "no_actions=false"
          "orientation=vertical"
          "parse_search=true"
          "print_command=true"
          "prompt="
          "show=drun"
          "sort_order=alphabetical"
          "style=/etc/xdg/wofi/style.css"
          "term=foot"
          "width=720"
        ];
      };

      "xdg/foot/foot.ini" = {
        text = ''
          # -*- conf -*-
          # vim: ft=dosini

          box-drawings-uses-font-glyphs=yes
          dpi-aware=auto
          font=DaddyTimeMono Nerd Font:size=8
          letter-spacing=0.85
          word-delimiters=,│`|:"'()[]{}<>
          bold-text-in-bright=no

          # app-id=foot
          # font-bold-italic=<bold+italic variant of regular font>
          # font-bold=<bold variant of regular font>
          # font-italic=<italic variant of regular font>
          # horizontal-letter-offset=1
          # initial-window-mode=windowed
          # initial-window-size-chars=<COLSxROWS>
          # initial-window-size-pixels=700x500  # Or,
          # line-height=1.15
          # locked-title=no
          # login-shell=no
          # notify=notify-send -a ''${app-id} -i ''${app-id} ''${title} ''${body}
          pad=4x4                         # optionally append 'center'
          # resize-delay-ms=100
          # selection-target=primary
          # shell=$SHELL (if set, otherwise user's default shell from /etc/passwd)
          # term=foot (or xterm-256color if built with -Dterminfo=disabled)
          # title=foot
          # underline-offset=<font metrics>
          # underline-thickness=<font underline thickness>
          # utempter=/usr/lib/utempter/utempter
          # vertical-letter-offset=1
          # workers=<number of logical CPUs>

          [environment]
          # name=value

          [bell]
          urgent=no
          notify=no
          command-focused=no

          [scrollback]
          lines=10000
          multiplier=3.0
          indicator-position=relative
          # indicator-format=

          [url]
          launch=xdg-open ''${url}
          label-letters=sadfjklewcmpgh
          osc8-underline=url-mode
          protocols=http, https, ftp, ftps, file, gemini, gopher
          uri-characters=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.,~:;/?#@!$&%*+="'()[]

          [cursor]
          style=beam
          # color=<inverse foreground/background>
          blink=yes
          beam-thickness=1.5

          [mouse]
          hide-when-typing=yes
          # alternate-scroll-mode=yes

          [colors]
          foreground=cdd6f4 # Text
          background=1e1e2e # Base
          regular0=45475a   # Surface 1
          regular1=f38ba8   # red
          regular2=a6e3a1   # green
          regular3=f9e2af   # yellow
          regular4=89b4fa   # blue
          regular5=f5c2e7   # pink
          regular6=94e2d5   # teal
          regular7=bac2de   # Subtext 1
          bright0=585b70    # Surface 2
          bright1=f38ba8    # red
          bright2=a6e3a1    # green
          bright3=f9e2af    # yellow
          bright4=89b4fa    # blue
          bright5=f5c2e7    # pink
          bright6=94e2d5    # teal
          bright7=a6adc8    # Subtext 0

          [csd]
          # preferred=server
          # size=26
          # font=<primary font>
          # color=<foreground color>
          # hide-when-typing=no
          # border-width=0
          # border-color=<csd.color>
          # button-width=26
          # button-color=<background color>
          # button-minimize-color=<regular4>
          # button-maximize-color=<regular2>
          # button-close-color=<regular1>

          [key-bindings]
          scrollback-up-page=Shift+Page_Up
          scrollback-up-half-page=none
          scrollback-up-line=none
          scrollback-down-page=Shift+Page_Down
          scrollback-down-half-page=none
          scrollback-down-line=none
          clipboard-copy=Control+Shift+c XF86Copy
          clipboard-paste=Control+Shift+v XF86Paste
          primary-paste=Shift+Insert
          search-start=Control+Shift+r
          font-increase=Control+plus Control+equal Control+KP_Add
          font-decrease=Control+minus Control+KP_Subtract
          font-reset=Control+0 Control+KP_0
          spawn-terminal=Control+Shift+n
          minimize=none
          maximize=none
          fullscreen=none
          pipe-visible=[sh -c "xurls | fuzzel | xargs -r firefox"] none
          pipe-scrollback=[sh -c "xurls | fuzzel | xargs -r firefox"] none
          pipe-selected=[xargs -r firefox] none
          show-urls-launch=Control+Shift+u
          show-urls-copy=none
          show-urls-persistent=none
          prompt-prev=Control+Shift+z
          prompt-next=Control+Shift+x
          unicode-input=Control+Insert
          noop=none

          [search-bindings]
          cancel=Control+g Control+c Escape
          commit=Return
          find-prev=Control+r
          find-next=Control+s
          cursor-left=Left Control+b
          cursor-left-word=Control+Left Mod1+b
          cursor-right=Right Control+f
          cursor-right-word=Control+Right Mod1+f
          cursor-home=Home Control+a
          cursor-end=End Control+e
          delete-prev=BackSpace
          delete-prev-word=Mod1+BackSpace Control+BackSpace
          delete-next=Delete
          delete-next-word=Mod1+d Control+Delete
          extend-to-word-boundary=Control+w
          extend-to-next-whitespace=Control+Shift+w
          clipboard-paste=Control+v Control+Shift+v Control+y XF86Paste
          primary-paste=Shift+Insert
          unicode-input=none

          [url-bindings]
          # cancel=Control+g Control+c Control+d Escape
          # toggle-url-visible=t

          [text-bindings]
          # Map Super+c -> Ctrl+c
          \x03=Mod4+c

          [mouse-bindings]
          selection-override-modifiers=Shift
          primary-paste=BTN_MIDDLE
          select-begin=BTN_LEFT
          select-begin-block=Control+BTN_LEFT
          select-extend=BTN_RIGHT
          select-extend-character-wise=Control+BTN_RIGHT
          select-word=BTN_LEFT-2
          select-word-whitespace=Control+BTN_LEFT-2
          select-row=BTN_LEFT-3
        '';
      };

      "xdg/waybar/style.css".text = builtins.readFile ./waybar.css;
      "xdg/wofi/style.css".text = builtins.readFile ./wofi.css;
    };
  };
}
