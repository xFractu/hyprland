#!/bin/bash
source "$HOME/.config/theme/theme.sh"
flavor=$(get flavor Mocha)
accent=$(get accent Azul)
hex=$(accent_hex "$accent" "$flavor")
red=$(accent_hex Rojo "$flavor")
green=$(accent_hex Verde "$flavor")
read -r base mantle s0 s1 muted text second <<< "$(palette "$flavor")"

cat > "$HOME/.config/hypr/hyprlock-colors.conf" << CONF
\$accent = rgb($hex)
\$text = rgb($text)
\$muted = rgb($muted)
\$inner = rgba(${base}cc)
\$ok = rgb($green)
\$fail = rgb($red)
CONF
