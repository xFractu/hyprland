#!/bin/bash
# uso: tui.sh nombre [opciones de kitty] comando [args]
name="$1"; shift
dir="$HOME/.config/theme"
hex=$(cat "$dir/accent-hex" 2>/dev/null || echo "89b4fa")
base=$(cat "$dir/base-hex" 2>/dev/null || echo "1e1e2e")
case "$name" in
  cava|cmatrix|pipes|lavat|clock) op=0.96 ;;
  *) op=0.85 ;;
esac
exec kitty --class "tui-$name" \
  -o confirm_os_window_close=0 \
  -o background_opacity=$op \
  -o "color0=#$base" \
  -o "transparent_background_colors=#$base@$op" \
  -o "color2=#$hex" -o "color10=#$hex" \
  "$@"
