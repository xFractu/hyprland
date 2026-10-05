#!/bin/bash
# uso: tui.sh nombre [opciones de kitty] comando [args]
name="$1"; shift
dir="$HOME/.config/theme"
hex=$(cat "$dir/accent-hex" 2>/dev/null || echo "89b4fa")
base=$(cat "$dir/base-hex" 2>/dev/null || echo "1e1e2e")
exec kitty --class "tui-$name" \
  -o background_opacity=0.85 \
  -o "color0=#$base" \
  -o "transparent_background_colors=#$base@0.85" \
  -o "color2=#$hex" -o "color10=#$hex" \
  "$@"
