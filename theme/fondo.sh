#!/bin/bash
# uso: fondo.sh [animado|normal|toggle|init]
VIDEO="$HOME/Videos/wallpapers/berserk.mp4"
CFG="$HOME/.config/noctalia/fondo-animado.toml"
STATE="$HOME/.local/state/fondo-modo"
ULTIMO="$HOME/.local/state/fondo-ultimo"
mkdir -p "$(dirname "$STATE")"

avisar() { command -v notify-send > /dev/null && notify-send "Fondo de pantalla" "$1"; }

# apunta la imagen actual de Noctalia (solo si es un archivo real)
guardar_imagen() {
  local p
  p=$(noctalia msg wallpaper-get 2>/dev/null | head -1)
  p="${p/#\~/$HOME}"
  [ -f "$p" ] && echo "$p" > "$ULTIMO"
}

iniciar_video() {
  pkill mpvpaper
  sleep 0.3
  OUT=$(niri msg --json outputs | jq -r 'keys[0]')
  setsid mpvpaper -o "no-audio loop hwdec=auto" "$OUT" "$VIDEO" > /dev/null 2>&1 &
}

animado() {
  guardar_imagen
  rm -f "$CFG.off"
  printf '[wallpaper]\nenabled = false\n' > "$CFG"
  iniciar_video
  echo animado > "$STATE"
  avisar "Fondo animado"
}

normal() {
  pkill mpvpaper
  [ -f "$CFG" ] && mv "$CFG" "$CFG.off"
  echo normal > "$STATE"
  pkill noctalia; sleep 1; setsid noctalia > /dev/null 2>&1 & sleep 3
  img=$(cat "$ULTIMO" 2>/dev/null)
  [ -z "$img" ] && img=$(noctalia msg wallpaper-get 2>/dev/null | head -1)
  [ -n "$img" ] && noctalia msg wallpaper-set "$img"
  avisar "Fondo normal"
}

modo=$(cat "$STATE" 2>/dev/null || echo animado)

case "$1" in
  animado) animado ;;
  normal)  normal ;;
  init)    sleep 1; [ -f "$ULTIMO" ] || guardar_imagen; [ "$modo" = "animado" ] && iniciar_video ;;
  *)       [ "$modo" = "animado" ] && normal || animado ;;
esac
