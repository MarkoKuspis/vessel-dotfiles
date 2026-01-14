#!/usr/bin/env bash
set -e

echo "==> Installing official repo packages..."
sudo pacman -S --needed - < pacman.txt

if command -v yay &>/dev/null; then
  echo "==> Installing AUR packages..."
  yay -S --needed - < aur.txt
else
  echo "==> yay not found, skipping AUR packages"
fi

echo "==> Done."
