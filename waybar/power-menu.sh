#!/bin/bash
op=$(printf 'Apagar\nReiniciar\nSuspender\nCerrar sesión' | fuzzel --dmenu --prompt "Energía " --width 24 --lines 4)
case "$op" in
  "Apagar") systemctl poweroff ;;
  "Reiniciar") systemctl reboot ;;
  "Suspender") systemctl suspend ;;
  "Cerrar sesión")
    if [ -n "$NIRI_SOCKET" ]; then niri msg action quit --skip-confirmation
    else hyprctl dispatch 'hl.dsp.exit()'; fi ;;
esac
