#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/vessel-dotfiles"
PKGDIR="${REPO}/packages"

# Per-manager files
PACMAN_EXPLICIT="${PKGDIR}/pacman-explicit.txt"
PACMAN_ALL="${PKGDIR}/pacman.txt"
AUR_FILE="${PKGDIR}/aur.txt"
FLATPAK_FILE="${PKGDIR}/flatpak.txt"
SNAP_FILE="${PKGDIR}/snap.txt"
PIP_FILE="${PKGDIR}/pip.txt"
CARGO_FILE="${PKGDIR}/cargo.txt"
NIX_FILE="${PKGDIR}/nix.txt"
BREW_FILE="${PKGDIR}/brew.txt"

echo "== Installing packages from $PKGDIR =="

# pacman: prefer explicit list, fall back to all
if [[ -f "$PACMAN_EXPLICIT" && -s "$PACMAN_EXPLICIT" ]]; then
  echo "== Installing pacman explicit packages from: $PACMAN_EXPLICIT =="
  sudo pacman -Sy --noconfirm
  sudo pacman -S --needed --noconfirm $(<"$PACMAN_EXPLICIT") || true
  echo "== Done with pacman explicit packages =="
elif [[ -f "$PACMAN_ALL" && -s "$PACMAN_ALL" ]]; then
  echo "== Installing pacman packages from: $PACMAN_ALL =="
  sudo pacman -Sy --noconfirm
  sudo pacman -S --needed --noconfirm $(<"$PACMAN_ALL") || true
  echo "== Done with pacman packages =="
else
  echo "NOTE: No pacman package list found; skipping pacman installs."
fi

# AUR / foreign packages are optional and require an AUR helper
if [[ -f "$AUR_FILE" && -s "$AUR_FILE" ]]; then
  AUR_HELPER=""
  if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
  elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
  fi

  if [[ -z "$AUR_HELPER" ]]; then
    echo "NOTE: AUR list present but no AUR helper (yay/paru) found; skipping AUR installs."
  else
    echo "== Installing AUR packages via $AUR_HELPER from: $AUR_FILE =="
    if [[ "$AUR_HELPER" == "yay" ]]; then
      yay -S --needed - < "$AUR_FILE" || yay -S --needed $(<"$AUR_FILE") || true
    else
      paru -S --needed - < "$AUR_FILE" || paru -S --needed $(<"$AUR_FILE") || true
    fi
    echo "== Done with AUR packages =="
  fi
else
  echo "NOTE: No AUR list found; skipping AUR installs."
fi

# flatpak
if [[ -f "$FLATPAK_FILE" && -s "$FLATPAK_FILE" ]]; then
  if command -v flatpak >/dev/null 2>&1; then
    echo "== Installing flatpaks from: $FLATPAK_FILE =="
    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue
      flatpak install -y "$pkg" || flatpak install --user -y "$pkg" || true
    done < "$FLATPAK_FILE"
    echo "== Done with flatpaks =="
  else
    echo "NOTE: flatpak list present but flatpak not installed; skipping."
  fi
fi

# snap
if [[ -f "$SNAP_FILE" && -s "$SNAP_FILE" ]]; then
  if command -v snap >/dev/null 2>&1; then
    echo "== Installing snaps from: $SNAP_FILE =="
    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue
      sudo snap install "$pkg" || true
    done < "$SNAP_FILE"
    echo "== Done with snaps =="
  else
    echo "NOTE: snap list present but snap not installed; skipping."
  fi
fi

# pip
if [[ -f "$PIP_FILE" && -s "$PIP_FILE" ]]; then
  if command -v pip3 >/dev/null 2>&1; then
    echo "== Installing pip packages from: $PIP_FILE =="
    pip3 install --user -r "$PIP_FILE" || true
    echo "== Done with pip packages =="
  else
    echo "NOTE: pip3 list present but pip3 not installed; skipping."
  fi
fi

# cargo
if [[ -f "$CARGO_FILE" && -s "$CARGO_FILE" ]]; then
  if command -v cargo >/dev/null 2>&1; then
    echo "== Installing cargo packages from: $CARGO_FILE =="
    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue
      cargo install "$pkg" || true
    done < "$CARGO_FILE"
    echo "== Done with cargo packages =="
  else
    echo "NOTE: cargo list present but cargo not installed; skipping."
  fi
fi

# nix
if [[ -f "$NIX_FILE" && -s "$NIX_FILE" ]]; then
  if command -v nix-env >/dev/null 2>&1 || command -v nix >/dev/null 2>&1; then
    echo "== Installing nix packages from: $NIX_FILE =="
    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue
      if command -v nix-env >/dev/null 2>&1; then
        nix-env -iA "$pkg" || nix-env -i "$pkg" || true
      else
        nix profile install "$pkg" || true
      fi
    done < "$NIX_FILE"
    echo "== Done with nix packages =="
  else
    echo "NOTE: nix list present but nix not installed; skipping."
  fi
fi

# brew
if [[ -f "$BREW_FILE" && -s "$BREW_FILE" ]]; then
  if command -v brew >/dev/null 2>&1; then
    echo "== Installing brew packages from: $BREW_FILE =="
    xargs -a "$BREW_FILE" -r brew install || true
    echo "== Done with brew packages =="
  else
    echo "NOTE: brew list present but brew not installed; skipping."
  fi
fi

echo
echo "All package installs complete (where supported and present)."
