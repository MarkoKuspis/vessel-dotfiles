#!/bin/bash

# Screenshot script for Hyprland using grim and slurp
# Creates screenshots directory if it doesn't exist

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="$SCREENSHOT_DIR/screenshot_$TIMESTAMP.png"

case "$1" in
    full)
        # Full screen screenshot
        grim "$FILENAME"
        notify-send -u low "Screenshot" "Full screen saved to $FILENAME"
        ;;
    area)
        # Area selection screenshot
        grim -g "$(slurp)" "$FILENAME"
        notify-send -u low "Screenshot" "Area saved to $FILENAME"
        ;;
    window)
        # Active window screenshot
        WINDOW_GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$WINDOW_GEOMETRY" "$FILENAME"
        notify-send -u low "Screenshot" "Window saved to $FILENAME"
        ;;
    *)
        echo "Usage: $0 {full|area|window}"
        exit 1
        ;;
esac

# Copy to clipboard
wl-copy < "$FILENAME"
