#!/usr/bin/env bash
# Noctalia omni-menu — system action menu rendered by `noctalia dmenu`.
#
# Installed as the `omni-menu` binary via home/common/optional/apps/noctalia.nix.
# Edited live from this repo; no rebuild needed for changes here.
set -euo pipefail

# Present "key<TAB>description" pairs and echo back only the key.
# noctalia dmenu exits non-zero when dismissed, so callers exit quietly.
pick() {
  local prompt="$1"
  shift
  local sel
  sel=$(printf '%s\t%s\n' "$@" | noctalia dmenu -p "$prompt") || return 1
  printf '%s' "${sel%%$'\t'*}"
}

# Run a command in a terminal and hold the window open so output is
# readable; `noctalia dmenu` actions are otherwise detached.
in_term() {
  ghostty -e bash -lc "$1; printf '\n[done] press enter to close'; read -r" &
}

menu_nix() {
  local dir="$HOME/.config/nix"
  case "$(pick 'Nix' \
    'Home'     'Rebuild home-manager' \
    'System'   'Rebuild system-manager / NixOS' \
    'Rebuild'  'Rebuild home and system' \
    'Update'   'Update flake inputs' \
    'Check'    'Evaluate all configurations' \
    'Edit'     'Open the config in an editor')" in
    'Home')    in_term "cd '$dir' && just home" ;;
    'System')  in_term "cd '$dir' && just system" ;;
    'Rebuild') in_term "cd '$dir' && just rebuild" ;;
    'Update')  in_term "cd '$dir' && just update" ;;
    'Check')   in_term "cd '$dir' && just check" ;;
    'Edit')    in_term "cd '$dir' && \${EDITOR:-nvim} ." ;;
  esac
}

menu_toggles() {
  case "$(pick 'Toggles' \
    'Dark mode'  'Switch light/dark theme' \
    'Nightlight' 'Warm the display colours' \
    'Caffeine'   'Keep the screen awake' \
    'Do not disturb' 'Silence notifications' \
    'OSD'        'On-screen volume/brightness popups' \
    'Bar'        'Show or hide the bar' \
    'WiFi'       'Enable or disable WiFi' \
    'Bluetooth'  'Enable or disable Bluetooth')" in
    'Dark mode')      noctalia msg theme-mode-toggle ;;
    'Nightlight')     noctalia msg nightlight-toggle ;;
    'Caffeine')       noctalia msg caffeine-toggle ;;
    'Do not disturb') noctalia msg notification-dnd-toggle ;;
    'OSD')            noctalia msg osd-toggle ;;
    'Bar')            noctalia msg bar-toggle ;;
    'WiFi')           noctalia msg wifi-toggle ;;
    'Bluetooth')      noctalia msg bluetooth-toggle ;;
  esac
}

# Enumerate outputs from whichever compositor is running.
outputs_list() {
  if [ -n "${NIRI_SOCKET:-}" ]; then
    niri msg --json outputs \
      | jq -r 'if type == "object" then keys[] else .[].name end'
  elif [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    hyprctl monitors -j | jq -r '.[].name'
  fi
}

output_set() {
  local name="$1" state="$2"
  if [ -n "${NIRI_SOCKET:-}" ]; then
    niri msg output "$name" "$state"
  elif [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    case "$state" in
      off) hyprctl keyword monitor "$name,disable" ;;
      on)  hyprctl keyword monitor "$name,preferred,auto,1" ;;
    esac
  fi
}

menu_output() {
  local name="$1"
  case "$(pick "$name" \
    'Enable'  'Turn this output on' \
    'Disable' 'Turn this output off')" in
    'Enable')  output_set "$name" on ;;
    'Disable') output_set "$name" off ;;
  esac
}

menu_display() {
  local args=(
    'Settings'  'Open the monitor control centre'
    'Wallpaper' 'Next wallpaper'
    'Random'    'Random wallpaper'
  )
  local name
  while read -r name; do
    [ -n "$name" ] && args+=("$name" 'Enable or disable this output')
  done < <(outputs_list)

  local choice
  choice=$(pick 'Display' "${args[@]}") || return 0
  case "$choice" in
    'Settings')  noctalia msg panel-toggle control-center monitor ;;
    'Wallpaper') noctalia msg wallpaper-next ;;
    'Random')    noctalia msg wallpaper-random ;;
    "")          ;;
    *)           menu_output "$choice" ;;
  esac
}

case "$(pick 'System' \
  'Session'  'Lock, suspend, reboot, shut down' \
  'Nix'      'Rebuild, update, edit the config' \
  'Toggles'  'Theme, nightlight, caffeine, DND' \
  'Display'  'Outputs and wallpaper')" in
  # Noctalia already has a session panel; hand off rather than
  # reimplementing the same list in the menu.
  'Session') noctalia msg panel-open session ;;
  'Nix')     menu_nix ;;
  'Toggles') menu_toggles ;;
  'Display') menu_display ;;
esac
