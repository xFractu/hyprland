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
