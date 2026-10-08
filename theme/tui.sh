#!/bin/bash
# uso: tui.sh nombre [opciones de kitty] comando [args]
OP_FETCH=0.88    # terminales con estilo (menor = más transparente)
OP_ANIM=0.88     # cava, cmatrix, pipes, lavat y reloj
BG_GRAY=""       # vacío = el negro del tema de Noctalia; o un gris, p. ej. 161616

name="$1"; shift
conf="$HOME/.config/kitty/themes/noctalia.conf"
base=$(awk '$1=="background"{print $2; exit}' "$conf" 2>/dev/null | tr -d '#')
[ -z "$base" ] && base="000000"
[ -n "$BG_GRAY" ] && base="$BG_GRAY"
case "$name" in
  cava|cmatrix|pipes|lavat|clock) op=$OP_ANIM ;;
  *) op=$OP_FETCH ;;
esac
exec kitty --class "tui-$name" \
  -o confirm_os_window_close=0 \
  -o "background=#$base" \
  -o "color0=#$base" \
  -o background_opacity=$op \
  -o "transparent_background_colors=#$base@$op" \
  "$@"
