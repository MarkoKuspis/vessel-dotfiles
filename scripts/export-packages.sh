#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/vessel-dotfiles"
OUTDIR="${REPO}/packages"
mkdir -p "$OUTDIR"

# Explicitly installed packages (best for "what I chose")
pacman -Qqe | sort > "${OUTDIR}/pacman-explicit.txt"

# Foreign packages (typically AUR, custom builds)
pacman -Qqm | sort > "${OUTDIR}/pacman-foreign.txt"

# All packages
pacman -Qq | sort > "${OUTDIR}/pacman-all.txt"

# Useful context snapshot
{
  echo "Date: $(date -Is)"
  echo "Kernel: $(uname -r)"
  echo "Host: $(hostnamectl --static 2>/dev/null || hostname)"
  echo "NVIDIA:"
  nvidia-smi 2>/dev/null || echo "nvidia-smi not available"
} > "${OUTDIR}/pacman-info.txt"

echo "Wrote package lists to: ${OUTDIR}"
