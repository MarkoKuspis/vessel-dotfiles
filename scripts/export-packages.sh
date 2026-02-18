#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/vessel-dotfiles"
OUTDIR="${REPO}/packages"
mkdir -p "$OUTDIR"

# pacman (official + explicit + AUR/foreign)
if command -v pacman >/dev/null 2>&1; then
  pacman -Q | sort > "${OUTDIR}/pacman.txt" || true
  pacman -Qqe | sort > "${OUTDIR}/pacman-explicit.txt" || true
  pacman -Qqm | sort > "${OUTDIR}/aur.txt" || true
fi

# flatpak
if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application,version 2>/dev/null | sort > "${OUTDIR}/flatpak.txt" || true
fi

# snap
if command -v snap >/dev/null 2>&1; then
  snap list 2>/dev/null | tail -n +2 | awk '{print $1}' | sort > "${OUTDIR}/snap.txt" || true
fi

# pip (python)
if command -v pip3 >/dev/null 2>&1; then
  pip3 freeze 2>/dev/null | sort > "${OUTDIR}/pip.txt" || true
fi

# npm (node)
if command -v npm >/dev/null 2>&1; then
  npm -g ls --depth=0 --parseable 2>/dev/null | sed '1d' | xargs -r -n1 basename 2>/dev/null | sort > "${OUTDIR}/npm.txt" || true
fi

# cargo (rust)
if command -v cargo >/dev/null 2>&1; then
  cargo install --list 2>/dev/null | awk '/^([^ ]+).*v[0-9]/ {print $1}' | sed 's/:$//' | sort > "${OUTDIR}/cargo.txt" || true
fi

# nix (nix-env or new CLI)
if command -v nix-env >/dev/null 2>&1; then
  nix-env -q 2>/dev/null | sort > "${OUTDIR}/nix.txt" || true
elif command -v nix >/dev/null 2>&1; then
  nix profile list --no-name 2>/dev/null | awk '{print $1}' | sort > "${OUTDIR}/nix.txt" || true
fi

# brew (linuxbrew/homebrew)
if command -v brew >/dev/null 2>&1; then
  brew list 2>/dev/null | sort > "${OUTDIR}/brew.txt" || true
fi

# Snapshot info
{
  echo "Date: $(date -Is)"
  echo "Kernel: $(uname -r)"
  echo "Host: $(hostnamectl --static 2>/dev/null || hostname)"
} > "${OUTDIR}/info.txt"

echo "Wrote package lists to: ${OUTDIR}"
