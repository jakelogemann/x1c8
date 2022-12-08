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
        wezterm
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
      ];
    etc = {
      "sway/config" = {
        text = ''
          exec_always bash -eu ${./exec_always.sh}

          default_border pixel 4
          default_floating_border pixel 4
          floating_modifier Mod4
          focus_follows_mouse no
          focus_on_window_activation smart
          focus_wrapping yes
          font pango:DaddyTimeMono Nerd Font Bold 14.000000
          gaps inner 16
          gaps outer 6
          hide_edge_borders none
          mouse_warping output
          smart_borders no_gaps
          workspace_auto_back_and_forth yes
          workspace_layout default

          set {
            $browser "firefox"
            $exit "swaymsg exit"
            $launcher "wofi -c /etc/xdg/wofi/config"
            $reload "swaymsg reload"
            $file_manager "foot ranger"
            $screenshot  "grim -g \"$(slurp)\" - | wl-copy"
            $term "wezterm"
            $lock_screen "swaylock -c111111 -eFKl --font='DaddyTimeMono Nerd Font' --font-size=16  --indicator-idle-visible"
            $volume_down "amixer set Master 4%-"
            $volume_up "amixer set Master 4%+"
            $volume_toggle "amixer set Master toggle"
            $backlight_up "light -A 2"
            $backlight_down "light -U 2"
            $wifi "wifi"
            $bluetooth "bluetooth"
            $term_alt "foot"
          }

          include /etc/sway/config.d/*
        '';
      };

      "sway/config.d/assignments" = {
        text = ''
          assign [class="^Firefox$" window_role="browser"]        2
          assign [class="^Slack$"   window_role="browser-window"] 5
          assign [class="^Logseq$"  window_role="browser-window"] 4
        '';
      };

      "sway/config.d/colors" = {
        text = with builtins;
          concatStringsSep "\n" (attrValues (mapAttrs (k: vs: "${k} ${concatStringsSep " " (map (v: "#${v}") vs)}") (with cfg.colors; {
            "client.background" = [background];
            "client.focused" = [regular7 regular7 bright0 regular7 regular7];
            "client.focused_inactive" = [background background foreground background background];
            "client.placeholder" = [background regular7 foreground background regular7];
            "client.unfocused" = [background background foreground background background];
            "client.urgent" = [bright1 bright1 foreground bright1 bright1];
          })))
          + "\n";
      };

      "sway/config.d/keybinds" = {
        text = ''
          bindsym Mod4+Print  exec $screenshot
          bindsym Print       exec $screenshot
          bindsym Mod4+0 scratchpad show
          bindsym Mod4+1 workspace number 1
          bindsym Mod4+2 workspace number 2
          bindsym Mod4+3 workspace number 3
          bindsym Mod4+4 workspace number 4
          bindsym Mod4+5 workspace number 5
          bindsym Mod4+6 workspace number 6
          bindsym Mod4+7 workspace number 7
          bindsym Mod4+8 workspace number 8
          bindsym Mod4+9 workspace number 9
          bindsym Mod4+Control+Shift+q exec $exit
          bindsym Mod4+Control+a mode display
          bindsym Mod4+Ctrl+Down resize grow height 4px or 4 ppt
          bindsym Mod4+Ctrl+Left resize shrink width 4px or 4 ppt
          bindsym Mod4+Ctrl+Right resize grow width 4px or 4 ppt
          bindsym Mod4+Ctrl+Up resize shrink height 4px or 4 ppt
          bindsym Mod4+Ctrl+d floating toggle
          bindsym Mod4+Ctrl+f fullscreen toggle
          bindsym Mod4+Ctrl+h resize shrink width 4px or 4 ppt
          bindsym Mod4+Ctrl+j resize grow height 4px or 4 ppt
          bindsym Mod4+Ctrl+k resize shrink height 4px or 4 ppt
          bindsym Mod4+Ctrl+l resize grow width 4px or 4 ppt
          bindsym Mod4+Down focus down
          bindsym Mod4+F7 mode display
          bindsym Mod4+Left focus left
          bindsym Mod4+Right focus right
          bindsym Mod4+Shift+Escape exec $lock_screen
          bindsym Mod4+Control+Escape exec $lock_screen
          bindsym Mod4+Shift+0 move scratchpad
          bindsym Mod4+Shift+1 move container to workspace number 1
          bindsym Mod4+Shift+2 move container to workspace number 2
          bindsym Mod4+Shift+3 move container to workspace number 3
          bindsym Mod4+Shift+4 move container to workspace number 4
          bindsym Mod4+Shift+5 move container to workspace number 5
          bindsym Mod4+Shift+6 move container to workspace number 6
          bindsym Mod4+Shift+7 move container to workspace number 7
          bindsym Mod4+Shift+8 move container to workspace number 8
          bindsym Mod4+Shift+9 move container to workspace number 9
          bindsym Mod4+Shift+Down move down
          bindsym Mod4+Shift+Left move left
          bindsym Mod4+Shift+Right move right
          bindsym Mod4+Shift+Tab workspace prev_on_output
          bindsym Mod4+Shift+Up move up
          bindsym Mod4+Shift+h move left
          bindsym Mod4+Shift+j move down
          bindsym Mod4+Shift+k move up
          bindsym Mod4+Shift+l move right
          bindsym Mod4+Shift+q kill
          bindsym Mod4+Space exec $launcher
          bindsym Mod4+Tab workspace next_on_output
          bindsym Mod4+Up focus up
          bindsym Mod4+b bar mode toggle
          bindsym Mod4+d mode desktop
          bindsym Mod4+e exec $term nvim
          bindsym Mod4+f exec $file_manager
          bindsym Mod4+grave workspace back_and_forth
          bindsym Mod4+h focus left
          bindsym Mod4+i focus child
          bindsym Mod4+j focus down
          bindsym Mod4+k focus up
          bindsym Mod4+l focus right
          bindsym Mod4+minus split h
          bindsym Mod4+o focus parent
          bindsym Mod4+period mode move-container
          bindsym Mod4+r exec $launcher
          bindsym Mod4+t exec $term
          bindsym Mod4+Shift+t exec $term_alt
          bindsym Mod4+u mode resize
          bindsym Mod4+v split v
          bindsym Mod4+w exec $browser
          bindsym Pause mode display
          bindsym XF86Favorites exec $launcher
          bindsym XF86NotificationCenter exec $launcher
          bindsym XF86PickupPhone exec makoctl mode -r do-not-disturb
          bindsym XF86HangupPhone exec makoctl mode -a do-not-disturb
          bindsym XF86AudioLowerVolume exec $volume_down
          bindsym XF86AudioMute exec $volume_toggle
          bindsym XF86AudioRaiseVolume exec $volume_up
          bindsym XF86Display mode display
          bindsym XF86MonBrightnessDown exec $backlight_down
          bindsym XF86MonBrightnessUp exec $backlight_up
        '';
      };

      "sway/config.d/modes" = {
        text = ''
          mode "desktop" {
            bindsym Escape mode default
            bindsym Return mode default
            bindsym Shift+q exec $exit
            bindsym r exec $reload
          }
          mode "display" {
            bindsym 0 exec swaymsg output eDP-1 toggle; mode default
            bindsym 1 exec swaymsg output  DP-1 toggle; mode default
            bindsym 2 exec swaymsg output  DP-2 toggle; mode default
            bindsym Escape mode default
            bindsym Return exec swaymsg output eDP-1 mode 1920x1080 pos 0 0 scale 1 enable; mode default
          }
          mode "move-container" {
            bindsym 0 move scratchpad; mode default;
            bindsym 1 move container to workspace number 1; mode default;
            bindsym 2 move container to workspace number 2; mode default;
            bindsym 3 move container to workspace number 3; mode default;
            bindsym 4 move container to workspace number 4; mode default;
            bindsym 5 move container to workspace number 5; mode default;
            bindsym 6 move container to workspace number 6; mode default;
            bindsym 7 move container to workspace number 7; mode default;
            bindsym 8 move container to workspace number 8; mode default;
            bindsym 9 move container to workspace number 9; mode default;
            bindsym Escape mode default
            bindsym Return mode default
          }
          mode "resize" {
            bindsym Down resize grow height 10 px or 10 ppt
            bindsym Escape mode default
            bindsym Left resize shrink width 10 px or 10 ppt
            bindsym Return mode default
            bindsym Right resize grow width 10 px or 10 ppt
            bindsym Up resize shrink height 10 px or 10 ppt
          }
        '';
      };

      "sway/config.d/inputs" = {
        text = ''
          input type:touchpad {
              tap enabled
              drag enabled
              dwt enabled
          }

          input type:keyboard {
              xkb_layout "us"
              xkb_options "altwin:swap_lalt_lwin,ctrl:nocaps,terminate:ctrl_alt_bksp"
          }
        '';
      };

      "sway/config.d/outputs" = {
        text = ''
          output * bg  #${cfg.colors.bright0} solid_color

          output eDP-1 {
            pos 0 0
            max_render_time 5
            mode 1920x1080@59.999Hz
          }

          output DP-1 {
            pos 0 0
            max_render_time 5
            mode 3840x2160@59.997Hz
          }

          output DP-2 {
            pos 2160 0
            max_render_time 5
            mode 3840x2160@59.997Hz
          }
        '';
      };

      "xdg/mako/config" = {
        text = with cfg.colors; ''
          sort=-time
          font=DaddyTimeMono Nerd Font 12
          default-timeout=5000
          max-history=10
          on-button-left=dismiss
          on-button-middle=exec makoctl menu -n "$id" dmenu -p 'Select action: '
          border-radius=5
          max-icon-size=48
          icons=1
          anchor=top-center
          layer=overlay
          max-visible=5
          border-color=#${bright2}
          group-by=app-name
          text-color=#${foreground}CC
          margin=10,20,10
          width=600
          format=<b>%a</b> %s\n%b
          height=100
          background-color=#${background}DD
          [app-name="Firefox"]
          format=<b>%s</b>:\n%b
          border-color=#${bright1}
          [mode=do-not-disturb]
          invisible=1
        '';
      };

      "xdg/waybar/config" = {
        text = builtins.toJSON {
          layer = "top";
          position = "top";

          modules-left = [
            "sway/mode"
            "sway/workspaces"
            "sway/scratchpad"
          ];

          modules-center = [
            # "sway/window"
          ];

          modules-right = [
            "clock"
            "network"
            "battery"
            "cpu"
            "memory"
            # "sway/language"
            "idle_inhibitor"
            "backlight"
            "pulseaudio"
            "temperature"
            "keyboard-state"
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
            tooltip = true;
            tooltip-format-activated = "{icon}: Stay awake, inhibit idle.";
            tooltip-format-deactivated = "{icon}: Default System Idle Policy";
          };

          tray.spacing = 10;

          clock = {
            timezone = "America/New_York";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };

          cpu = {
            format = " {usage}%";
            tooltip = true;
          };

          memory = {
            format = "  {}%";
            tooltip = true;
            tooltip-format = " Memory Usage: {}%";
          };

          temperature = {
            /*
            "thermal-zone"= 2;
            "hwmon-path"= "/sys/class/hwmon/hwmon2/temp1_input";
            */
            critical-threshold = 80;
            format = "{temperatureC}°C";
            format-critical = "{icon} {temperatureC}°C";
            format-icons = ["" "" ""];
            tooltip = true;
          };

          backlight = {
            format = "{icon}";
            tooltip = true;
            tooltip-format = "Backlight: {percent}%";
            format-icons = ["" "" "" "" "" "" "" "" ""];
          };

          battery = {
            states."good" = 75;
            full-at = 95;
            states."warning" = 35;
            states."critical" = 20;
            interval = 60;
            format-time = "{H}h{M}m";
            format = "{icon} ";
            tooltip = true;
            tooltip-format-default = "{icon} Battery is at {capacity}% ({timeTo})";
            tooltip-format-charging = "  Charging {power} {timeTo} ({capacity}%)";
            tooltip-format-plugged = "  Plugged in ({capacity}%)";
            tooltip-format-battery = "{icon} is at {capacity}%";
            tooltip-format-full = "  Battery Full!";
            format-icons.default = ["" "" "" "" "" ];
            format-icons.good = "";
            format-icons.charging = "";
            format-icons.plugged = "";
            format-icons.critical = "⚠ ";
            format-icons.full = " ";
            format-icons.warning = " ";
          };

          network = {
            interface = "wlan0";
            format-wifi = " ";
            format-ethernet = " ";
            format-linked = "⚠ ";
            format-disconnected = "⚠  ";
            tooltip-format = "{ifname}";
            tooltip-format-wifi = "  {ifname}: {ipaddr}/{cidr} via {essid} ({signalStrength}%)";
            tooltip-format-disconnected = "⚠  {ifname}: Disconnected";
            tooltip-format-ethernet = "  {ifname}: {ipaddr}/{cidr} via {gwaddr}";
            tooltip-format-linked = "   {ifname} is P2P linked (No IP)";
          };

          pulseaudio = {
            scroll-step = 1;
            format = "{icon} {format_source}";
            format-bluetooth = "{icon} {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons.muted = " ";
            format-icons.headphone = "";
            format-icons.hands-free = "";
            format-icons.headset = "";
            format-icons.phone = "";
            format-icons.portable = "";
            format-icons.car = "";
            format-icons.default = ["" "" ""];
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
          ${with builtins; concatStringsSep "\n" (attrValues (mapAttrs (k: v: "${k}=${v}") cfg.colors))}

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

      "xdg/waybar/style.css" = {
        text = with cfg.colors; ''
          * {
            border-radius: 0;
            font-family: 'DaddyTimeMono Nerd Font';
            font-size: 14pt;
            min-height: 0;
          }

          window#waybar {
            background: #${background};
            color: #${foreground};
          }

          tooltip {
           background: #${background};
           color: #${foreground};
           border-radius: 15px;
           border-width: 2px;
           border-style: solid;
           border-color: #${bright4};
          }

          #workspaces button {
            padding-left: 10px;
            padding-right: 10px;
            min-width: 0;
            color: #${foreground};
            background-color: #${background};
          }

          #workspaces button.focused  { color: #${regular6}; background-color: #${background}; }
          #workspaces button.urgent   { color: #${bright1}; background-color: #${background}; }
          #workspaces button:hover    { color: #${bright6}; background-color: #${background}; }

          #backlight,
          #battery,
          #clock,
          #clock:hover,
          #cpu,
          #custom-vpn,
          #idle_inhibitor,
          #idle_inhibitor:hover,
          #keyboard-state,
          #memory,
          #network,
          #pulseaudio,
          #temperature,
          #workspaces {
            padding-left: 15px;
            padding-right: 15px;
            background: #${background};
            color: #${bright0};
            border-color: #${bright0};
            border-radius: 10px 10px 10px 10px;
            margin-top: 5px;
            margin-bottom: 5px;
            margin-left: 5px;
            margin-right: 0px;
          }
        '';
      };

      "xdg/wofi/style.css" = {
        text = with cfg.colors; ''
          * {
            font-family: 'DaddyTimeMono Nerd Font', 'Fira Code Nerd Font';
            font-size: 20px;
          }

          window {
            margin: 0px;
            border: 1px solid #bd93f9;
            background-color: #${background};
          }

          #input, #inner-box {
            margin: 5px;
            border: none;
            color: #${foreground};
            background-color: #${regular0};
          }

          #outer-box {
            margin: 5px;
            border: none;
            background-color: #${background};
          }

          #scroll {
            margin: 0px;
            border: none;
          }

          #text {
            margin: 5px 10px;
            border: none;
            color: #${foreground};
          }

          #entry:selected, #entry:selected * {
            background-color: #${bright0};
            color: #${bright4};
          }
        '';
      };
    };
  };
}
# vim:sts=2:et:ft=nix:fdm=indent:fdl=2

