#!/usr/bin/env bash
[[ -n "$XDG_RUNTIME_DIR" ]] || XDG_RUNTIME_DIR="/run/user/$(id -u)"

declare -a VAR_NAMES=("PATH" "DISPLAY" "XDG_SEAT" "XDG_RUNTIME_DIR" "TERM" "EDITOR")
VAR_NAMES+=("XDG_SESSION_CLASS" "XDG_SESSION_ID" "XDG_SESSION_TYPE" "WAYLAND_DISPLAY"  )

is_running(){ pgrep -xfU "${UID:-$(id -u)}" "$@" ;}
ensure_running(){ is_running "$1" || eval "${2:-$1} &"; }
ensure_dir_exists(){ test -d "$1" || mkdir -vp "$1"; }
update_systemd_env(){ echo "syncing: ${@}" && systemctl --user --quiet import-environment "$@"; }

ensure_dir_exists "$XDG_RUNTIME_DIR"
exec >$XDG_RUNTIME_DIR/sway-exec_always.log 2>&1 && set -euo verbose

# import latest value of environment variables like PATH, DISPLAY, etc.
update_systemd_env "${VAR_NAMES[@]}"

# Wayland bar.
ensure_running "waybar"

# Make is a notification daemon (similar to dunst)
ensure_running "mako"

# D-Bus session
ensure_running "dbus-daemon --session .*" "dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus"

# Foot server, so we can use footclient as term
ensure_running 'foot --server .*' 'foot --server --log-no-syslog --log-level=warning'
