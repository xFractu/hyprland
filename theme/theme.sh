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
)
declare -A ACC_LIGHT=(
  [Azul]="1e66f5" [Morado]="8839ef" [Rosa]="ea76cb" [Rojo]="d20f39"
  [Naranja]="fe640b" [Amarillo]="df8e1d" [Verde]="40a02b" [Turquesa]="179299"
)
ORDER=(Azul Morado Rosa Rojo Naranja Amarillo Verde Turquesa)
FLAVORS=(Mocha Macchiato Frappe Latte)

accent_hex() {
  if [ "$2" = "Latte" ]; then echo "${ACC_LIGHT[$1]}"; else echo "${ACC_DARK[$1]}"; fi
}

# base mantle surface0 surface1 muted text secundario
palette() {
  case "$1" in
    Mocha)     echo "1e1e2e 181825 313244 45475a 6c7086 cdd6f4 b4befe" ;;
    Macchiato) echo "24273a 1e2030 363a4f 494d64 6e738d cad3f5 b7bdf8" ;;
    Frappe)    echo "303446 292c3c 414559 51576d 737994 c6d0f5 babbf1" ;;
    Latte)     echo "eff1f5 e6e9ef ccd0da bcc0cc 9ca0b0 4c4f69 7287fd" ;;
  esac
}

apply() {
  local flavor accent hex red yellow base mantle s0 s1 muted text second
  flavor=$(get flavor Mocha)
  accent=$(get accent Azul)
  hex=$(accent_hex "$accent" "$flavor")
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

  # neovim
  echo "catppuccin-${flavor,,}" > "$THEME_DIR/nvim-colorscheme"

  hyprctl reload > /dev/null 2>&1
  pkill -SIGUSR2 waybar
  pkill -SIGUSR1 -x kitty
}

pick_flavor() {
  local c
  c=$(printf '%s\n' "${FLAVORS[@]}" | wofi --dmenu --prompt "Paleta" --width 250 --height 240)
  [ -n "$c" ] && echo "$c" > "$THEME_DIR/flavor" && apply
}

pick_accent() {
  local c
  c=$(printf '%s\n' "${ORDER[@]}" | wofi --dmenu --prompt "Color" --width 250 --height 340)
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
    | wofi --dmenu --prompt "Video" --width 500 --height 400)
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
      | wofi --dmenu --prompt "Tema" --width 260 --height 220)
    case "$op" in
      "Fondo de pantalla") pick_wallpaper ;;
      "Fondo animado") pick_video ;;
      "Paleta") pick_flavor ;;
      "Color de acento") pick_accent ;;
    esac ;;
  apply) apply ;;
  init) init ;;
esac
