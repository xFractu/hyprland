#!/bin/bash
op=$(printf 'Apagar\nReiniciar\nSuspender\nCerrar sesión' | wofi --dmenu --prompt "Energía" --width 250 --height 200)
case "$op" in
  "Apagar") systemctl poweroff ;;
  "Reiniciar") systemctl reboot ;;
  "Suspender") systemctl suspend ;;
  "Cerrar sesión") hyprctl dispatch 'hl.dsp.exit()' ;;
esac
