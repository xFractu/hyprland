#!/bin/bash
pkill -f "fuzzel --dmenu --config.*ghost.ini"
pkill -f "libinput debug-events"
exec niri msg action "$@"
