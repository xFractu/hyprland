#!/bin/bash
# Selector de tema: paleta, acento y fondo (imagen o video)
THEME_DIR="$HOME/.config/theme"
WALL_DIR="$HOME/Pictures/wallpapers"
VIDEO_DIR="$HOME/Videos/wallpapers"
mkdir -p "$THEME_DIR" "$VIDEO_DIR"

get() { cat "$THEME_DIR/$1" 2>/dev/null || echo "$2"; }

declare -A ACC_DARK=(
  [Azul]="89b4fa" [Morado]="cba6f7" [Rosa]="f5c2e7" [Rojo]="f38ba8"
  [Naranja]="fab387" [Amarillo]="f9e2af" [Verde]="a6e3a1" [Turquesa]="94e2d5"
  [Blanco]="f5f5f5" [Plata]="c4c4c4" [Gris]="9a9a9a" [Grafito]="707070"
)
declare -A ACC_LIGHT=(
  [Azul]="1e66f5" [Morado]="8839ef" [Rosa]="ea76cb" [Rojo]="d20f39"
  [Naranja]="fe640b" [Amarillo]="df8e1d" [Verde]="40a02b" [Turquesa]="179299"
  [Blanco]="2b2b2b" [Plata]="5c5c5c" [Gris]="7c7c7c" [Grafito]="9ca0b0"
)
declare -A ACC_MONO=(
  [Azul]="e8e8e8" [Morado]="d0d0d0" [Rosa]="c4c4c4" [Rojo]="ffffff"
  [Naranja]="b8b8b8" [Amarillo]="b8b8b8" [Verde]="8c8c8c" [Turquesa]="a0a0a0"
  [Blanco]="f5f5f5" [Plata]="c4c4c4" [Gris]="9a9a9a" [Grafito]="707070"
)
ORDER=(Azul Morado Rosa Rojo Naranja Amarillo Verde Turquesa Blanco Plata Gris Grafito)
MONO_ORDER=(Blanco Plata Gris Grafito)
FLAVORS=(Mocha Macchiato Frappe Latte Mono)

accent_hex() {
  case "$2" in
    Latte) echo "${ACC_LIGHT[$1]}" ;;
    Mono)  echo "${ACC_MONO[$1]}" ;;
    *)     echo "${ACC_DARK[$1]}" ;;
  esac
}

# base mantle surface0 surface1 muted text secundario
palette() {
  case "$1" in
    Mocha)     echo "1e1e2e 181825 313244 45475a 6c7086 cdd6f4 b4befe" ;;
    Macchiato) echo "24273a 1e2030 363a4f 494d64 6e738d cad3f5 b7bdf8" ;;
    Frappe)    echo "303446 292c3c 414559 51576d 737994 c6d0f5 babbf1" ;;
    Latte)     echo "eff1f5 e6e9ef ccd0da bcc0cc 9ca0b0 4c4f69 7287fd" ;;
    Mono)      echo "0d0d0d 080808 1c1c1c 2e2e2e 6b6b6b e8e8e8 a8a8a8" ;;
  esac
}

apply() {
  local flavor accent hex red yellow base mantle s0 s1 muted text second
  flavor=$(get flavor Mocha)
  accent=$(get accent Azul)
  hex=$(accent_hex "$accent" "$flavor")
  [ -z "$hex" ] && hex="89b4fa"
  red=$(accent_hex Rojo "$flavor")
  yellow=$(accent_hex Amarillo "$flavor")
  read -r base mantle s0 s1 muted text second <<< "$(palette "$flavor")"

  # waybar
  cat > "$HOME/.config/waybar/colors.css" << CSS
@define-color accent #$hex;
@define-color bg #$base;
@define-color mantle #$mantle;
@define-color surface #$s0;
@define-color surface2 #$s1;
@define-color muted #$muted;
@define-color text #$text;
@define-color red #$red;
@define-color yellow #$yellow;
CSS

  # hyprland
  cat > "$HOME/.config/hypr/colors.lua" << LUA
return { accent = "rgb($hex)", accent2 = "rgb($second)", inactive = "rgb($s1)" }
LUA

  # kitty
  cat > "$HOME/.config/kitty/accent.conf" << CONF
foreground #$text
background #$base
selection_foreground #$base
selection_background #$hex
cursor #$hex
cursor_text_color #$base
url_color #$hex
active_border_color #$hex
inactive_border_color #$s1
CONF

  # en Mono, los 16 colores de la terminal también son grises
  if [ "$flavor" = "Mono" ]; then
    cat >> "$HOME/.config/kitty/accent.conf" << 'CONF'
color0 #2e2e2e
color8 #5a5a5a
color1 #d0d0d0
color9 #e8e8e8
color2 #9a9a9a
color10 #b8b8b8
color3 #bcbcbc
color11 #d4d4d4
color4 #888888
color12 #a8a8a8
color5 #aaaaaa
color13 #c8c8c8
color6 #999999
color14 #b4b4b4
color7 #d8d8d8
color15 #ffffff
CONF
  fi

  # neovim
  if [ "$flavor" = "Mono" ]; then
    echo "mono" > "$THEME_DIR/nvim-colorscheme"
  else
    echo "catppuccin-${flavor,,}" > "$THEME_DIR/nvim-colorscheme"
  fi

  "$THEME_DIR/lock-theme.sh"
  "$THEME_DIR/tui-theme.sh"

  "$THEME_DIR/reload.sh"
  pkill -SIGUSR1 -x kitty
}

pick_flavor() {
  local c
  c=$(printf '%s\n' "${FLAVORS[@]}" | fuzzel --dmenu --prompt "Paleta " --width 24 --lines 8)
  [ -n "$c" ] && echo "$c" > "$THEME_DIR/flavor" && apply
}

pick_accent() {
  local c list=("${ORDER[@]}")
  [ "$(get flavor Mocha)" = "Mono" ] && list=("${MONO_ORDER[@]}")
  c=$(printf '%s\n' "${list[@]}" | fuzzel --dmenu --prompt "Color " --width 24 --lines 8)
  [ -n "$c" ] && echo "$c" > "$THEME_DIR/accent" && apply
}

set_wallpaper() {
  pkill mpvpaper
  echo "image" > "$THEME_DIR/wallmode"
  cat > "$HOME/.config/hypr/hyprpaper.conf" << CONF
wallpaper {
    monitor =
    path = $1
    fit_mode = cover
}
CONF
  pkill hyprpaper
  sleep 0.3
  setsid hyprpaper > /dev/null 2>&1 &
}

set_video() {
  pkill hyprpaper
  pkill mpvpaper
  echo "video:$1" > "$THEME_DIR/wallmode"
  setsid mpvpaper -o "no-audio loop hwdec=auto" ALL "$1" > /dev/null 2>&1 &
}

pick_wallpaper() {
  shopt -s nullglob
  local choice f
  choice=$(for f in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
    echo "img:$f:text:$(basename "$f")"
  done | wofi --dmenu --allow-images --prompt "Fondo" --width 800 --height 600)
  choice="${choice##*text:}"
  [ -n "$choice" ] && set_wallpaper "$WALL_DIR/$choice"
}

pick_video() {
  shopt -s nullglob
  local choice f
  choice=$(for f in "$VIDEO_DIR"/*.{mp4,webm,mkv,gif}; do basename "$f"; done \
    | fuzzel --dmenu --prompt "Video " --width 24 --lines 8)
  [ -n "$choice" ] && set_video "$VIDEO_DIR/$choice"
}

init() {
  local mode
  mode=$(get wallmode image)
  case "$mode" in video:*) sleep 1; set_video "${mode#video:}" ;; esac
}

case "$1" in
  menu)
    op=$(printf 'Fondo de pantalla\nFondo animado\nPaleta\nColor de acento' \
      | fuzzel --dmenu --prompt "Tema " --width 24 --lines 8)
    case "$op" in
      "Fondo de pantalla") pick_wallpaper ;;
      "Fondo animado") pick_video ;;
      "Paleta") pick_flavor ;;
      "Color de acento") pick_accent ;;
    esac ;;
  apply) apply ;;
  init) init ;;
esac
