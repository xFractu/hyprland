#!/bin/bash
# Quita el foco hasta que muevas el mouse de verdad, hagas clic o uses las flechas.
PAT="fuzzel --dmenu --config.*ghost.ini"
if pgrep -f "$PAT" > /dev/null; then
  pkill -f "$PAT"
  pkill -f "libinput debug-events"
  exit 0
fi

echo . | fuzzel --dmenu --config "$HOME/.config/fuzzel/ghost.ini" &
sleep 0.4

n=0
while true; do
  read -r -t 0.3 line
  rc=$?
  if [ $rc -eq 0 ]; then
    case "$line" in
      *POINTER_BUTTON*|*POINTER_SCROLL*) break ;;
      *POINTER_MOTION*) n=$((n+1)); [ "$n" -ge 8 ] && break ;;
    esac
  elif [ $rc -gt 128 ]; then
    n=0        # pausa: el movimiento no fue sostenido
  else
    break      # libinput terminó (sin permisos, por ejemplo)
  fi
done < <(libinput debug-events 2>/dev/null)

pkill -f "$PAT"
pkill -f "libinput debug-events"
