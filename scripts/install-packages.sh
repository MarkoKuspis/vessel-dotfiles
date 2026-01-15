#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/vessel-dotfiles"
PKGDIR="${REPO}/packages"

PACMAN_EXPLICIT="${PKGDIR}/pacman-explicit.txt"
PACMAN_FOREIGN="${PKGDIR}/pacman-foreign.txt"

if [[ ! -f "$PACMAN_EXPLICIT" ]]; then
  echo "ERROR: Missing $PACMAN_EXPLICIT" >&2
  echo "Run: ${REPO}/scripts/export-packages.sh on a configured machine first." >&2
  exit 1
fi

echo "== Installing official repo packages from: $PACMAN_EXPLICIT =="

# Ensure pacman DB is fresh-ish
sudo pacman -Sy --noconfirm

# Install explicit packages. --needed avoids reinstalling.
# --noconfirm keeps it non-interactive; remove if you prefer prompts.
sudo pacman -S --needed --noconfirm $(<"$PACMAN_EXPLICIT")

echo
echo "== Done with official packages =="

# AUR / foreign packages are optional and require an AUR helper
if [[ -f "$PACMAN_FOREIGN" && -s "$PACMAN_FOREIGN" ]]; then
  AUR_HELPER=""

  if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
  elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
  fi

  if [[ -z "$AUR_HELPER" ]]; then
    echo
    echo "NOTE: Found foreign/AUR list at $PACMAN_FOREIGN but no AUR helper (yay/paru) installed."
    echo "      Skipping AUR packages."
    echo "      If you want AUR installs, install one of these first:"
    echo "        sudo pacman -S --needed base-devel git"
    echo "        # then install yay or paru"
  else
    echo
    echo "== Installing AUR/foreign packages via $AUR_HELPER from: $PACMAN_FOREIGN =="

    # Most helpers will prompt for sudo/password as needed.
    # --needed avoids reinstalls; --noconfirm may be too aggressive for AUR; keep interactive by default.
    if [[ "$AUR_HELPER" == "yay" ]]; then
      yay -S --needed --noconfirm $(<"$PACMAN_FOREIGN")
    else
      paru -S --needed --noconfirm $(<"$PACMAN_FOREIGN")
    fi

    echo
    echo "== Done with AUR/foreign packages =="
  fi
else
  echo
  echo "NOTE: No foreign/AUR package list found (or it's empty). Skipping AUR packages."
fi

echo
echo "All package installs complete."
