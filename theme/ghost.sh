#!/bin/bash
cfg="$HOME/.config/niri/config.kdl"
if grep -q '^    opacity 0.9$' "$cfg"; then
  sed -i 's|^    opacity 0.9$|    opacity 0.5|' "$cfg"
else
  sed -i 's|^    opacity 0.5$|    opacity 0.9|' "$cfg"
fi
