#!/bin/bash
source "$HOME/.config/theme/theme.sh"
flavor=$(get flavor Mocha)
accent=$(get accent Azul)
hex=$(accent_hex "$accent" "$flavor")
[ -z "$hex" ] && hex="89b4fa"
read -r base mantle s0 s1 muted text second <<< "$(palette "$flavor")"

# fuzzel con la paleta
mkdir -p "$HOME/.config/fuzzel"
cat > "$HOME/.config/fuzzel/fuzzel.ini" << CONF
[main]
font=JetBrainsMono Nerd Font:size=12
prompt=" "
width=40
lines=10

[colors]
background=${base}ee
text=${text}ff
match=${hex}ff
selection=${s1}ff
selection-text=${text}ff
border=${hex}ff

[border]
width=2
radius=12
CONF

# compositor
if [ -n "$NIRI_SOCKET" ]; then
  cfg="$HOME/.config/niri/config.kdl"
  [ -f "$cfg" ] && sed -i "s|^\(\s*\)active-color \"[^\"]*\"|\1active-color \"#$hex\"|" "$cfg"
  wb="-c $HOME/.config/waybar/config-niri.jsonc"
else
  hyprctl reload > /dev/null 2>&1
  wb=""
fi

# reinicio de waybar
pkill waybar
sleep 0.3
setsid waybar $wb > /dev/null 2>&1 &
