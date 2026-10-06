#!/bin/bash
source "$HOME/.config/theme/theme.sh"
flavor=$(get flavor Mocha)
accent=$(get accent Azul)
hex=$(accent_hex "$accent" "$flavor")
red=$(accent_hex Rojo "$flavor")
green=$(accent_hex Verde "$flavor")
yellow=$(accent_hex Amarillo "$flavor")
read -r base mantle s0 s1 muted text second <<< "$(palette "$flavor")"
echo "$hex" > "$THEME_DIR/accent-hex"
echo "$base" > "$THEME_DIR/base-hex"

mkdir -p "$HOME/.config/btop/themes"
cat > "$HOME/.config/btop/themes/mytheme.theme" << CONF
theme[main_bg]="#$base"
theme[main_fg]="#$text"
theme[title]="#$text"
theme[hi_fg]="#$hex"
theme[selected_bg]="#$s1"
theme[selected_fg]="#$hex"
theme[inactive_fg]="#$muted"
theme[graph_text]="#$text"
theme[meter_bg]="#$s1"
theme[proc_misc]="#$hex"
theme[cpu_box]="#$hex"
theme[mem_box]="#$green"
theme[net_box]="#$second"
theme[proc_box]="#$red"
theme[div_line]="#$s1"
theme[temp_start]="#$green"
theme[temp_mid]="#$yellow"
theme[temp_end]="#$red"
theme[cpu_start]="#$hex"
theme[cpu_mid]="#$second"
theme[cpu_end]="#$red"
theme[used_start]="#$green"
theme[used_mid]="#$yellow"
theme[used_end]="#$red"
theme[download_start]="#$hex"
theme[download_mid]="#$second"
theme[download_end]="#$red"
theme[upload_start]="#$hex"
theme[upload_mid]="#$second"
theme[upload_end]="#$red"
CONF

# cava: degradado con la paleta (bajo = gris oscuro, medio = acento, alto = texto)
mix() {
  local a=$1 b=$2 i=$3 n=$4
  printf '%02x%02x%02x' \
    $(( (0x${a:0:2} * (n-i) + 0x${b:0:2} * i) / n )) \
    $(( (0x${a:2:2} * (n-i) + 0x${b:2:2} * i) / n )) \
    $(( (0x${a:4:2} * (n-i) + 0x${b:4:2} * i) / n ))
}

CAVA_CFG="$HOME/.config/cava/config"
if [ -f "$CAVA_CFG" ]; then
  sed -i -E "s/^;? *gradient *=.*/gradient = 1/" "$CAVA_CFG"
  for i in 1 2 3 4 5 6 7 8; do
    if [ "$i" -le 4 ]; then
      col=$(mix "$muted" "$hex" $((i-1)) 3)
    else
      col=$(mix "$hex" "$text" $((i-4)) 4)
    fi
    sed -i -E "s/^;? *gradient_color_$i *=.*/gradient_color_$i = '#$col'/" "$CAVA_CFG"
  done
fi
