#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/vessel-dotfiles"
CONFIG="$HOME/.config"
BACKUP_ROOT="$CONFIG/.dotfiles-backup"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"

LINKS=(
  "hypr/hyprland.conf:hypr/hyprland.conf"
  "hypr/hyprpaper.conf:hypr/hyprpaper.conf"

  "waybar/config.jsonc:waybar/config.jsonc"
  "waybar/style.css:waybar/style.css"

  "wofi/style.css:wofi/style.css"
  "wofi/config:wofi/config"

  "mako/config:mako/config"
  "foot/foot.ini:foot/foot.ini"
  "alacritty/alacritty.toml:alacritty/alacritty.toml"
  "zsh/spaceship.zsh:spaceship.zsh"
  "xdg/mimeapps.list:mimeapps.list"
)

# Special handling for .zshrc (goes to home directory)
ZSHRC_LINK="zsh/.zshrc"

die() { echo "ERROR: $*" >&2; exit 1; }

ensure_real_dir() {
  local d="$1"
  # If it's a symlink (your old Option B setup), remove it and create a real dir.
  if [[ -L "$d" ]]; then
    echo "Found symlink dir, removing (Option A requires real dirs): $d -> $(readlink "$d")"
    rm -f "$d"
  fi
  mkdir -p "$d"
}

backup_if_real_file() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local rel="${target#${CONFIG}/}"
    local dest="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    echo "Backed up: $target → $dest"
  fi
}

link_one() {
  local src_rel="$1"
  local dst_rel="$2"

  local src="$REPO/$src_rel"
  local dst="$CONFIG/$dst_rel"

  [[ -e "$src" ]] || { echo "WARN: missing source, skipping: $src"; return 0; }
  [[ ! -L "$src" ]] || die "repo source is a symlink (loop risk): $src (fix: make it a real file in repo)"

  ensure_real_dir "$(dirname "$dst")"

  # Idempotent: if correct symlink already exists, do nothing
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$src" ]]; then
    echo "OK: already linked $dst"
    return 0
  fi

  backup_if_real_file "$dst"

  # Remove wrong symlink
  [[ -L "$dst" ]] && rm -f "$dst"

  ln -s "$src" "$dst"
  echo "Linked: $dst → $src"
}

mkdir -p "$BACKUP_DIR"

echo "Linking dotfiles (Option A: file-level, idempotent)…"

# Ensure these are REAL dirs (kills your old folder symlinks)
ensure_real_dir "$CONFIG/hypr"
ensure_real_dir "$CONFIG/waybar"

for pair in "${LINKS[@]}"; do
  IFS=":" read -r src dst <<<"$pair"
  link_one "$src" "$dst"
done

# Link .zshrc to home directory (not .config)
if [[ -n "${ZSHRC_LINK:-}" ]]; then
  src="$REPO/$ZSHRC_LINK"
  dst="$HOME/.zshrc"
  
  if [[ -e "$src" ]]; then
    # Idempotent: if correct symlink already exists, do nothing
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$src" ]]; then
      echo "OK: already linked $dst"
    else
      ln -sf "$src" "$dst"
      echo "Linked: $dst → $src"
    fi
  fi
fi

echo
echo "Done."
echo "Backups (if any): $BACKUP_DIR"
