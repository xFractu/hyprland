#!/bin/bash
# uso: cambiar-video.sh nombre.mp4   (sin argumento, lista los videos)
DIR="$HOME/Videos/wallpapers"
if [ -z "$1" ] || [ ! -f "$DIR/$1" ]; then
  echo "Videos disponibles en $DIR:"
  ls "$DIR"
  exit 1
fi
sed -i "s|^VIDEO=.*|VIDEO=\"\$HOME/Videos/wallpapers/$1\"|" "$HOME/.config/theme/fondo.sh"
"$HOME/.config/theme/fondo.sh" animado
