#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/vessel-dotfiles"
CONFIG="${HOME}/.config"
BACKUP_DIR="${HOME}/.config/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Map: <repo-relative-path> -> <config-relative-path>
# Add files to repo whenever you're ready; missing ones will be skipped with a warning.
declare -a LINKS=(
  # Hyprland
  "hypr/hyprland.conf:hypr/hyprland.conf"

  # Hyprpaper (wallpapers)
  "hypr/hyprpaper.conf:hypr/hyprpaper.conf"

  # Waybar
  "waybar/config.jsonc:waybar/config.jsonc"
  "waybar/style.css:waybar/style.css"

  # Wofi (launcher)
  "wofi/style.css:wofi/style.css"
  "wofi/config:wofi/config"

  # Mako (notifications)
  "mako/config:mako/config"

  # Foot (terminal)
  "foot/foot.ini:foot/foot.ini"

  # Optional: default app associations (if you choose to track it)
  "xdg/mimeapps.list:mimeapps.list"
)

mkdir -p "$BACKUP_DIR"

backup_if_needed() {
  local target="$1"

  # Don't back up if it's already a symlink
  if [[ -L "$target" ]]; then
    return 0
  fi

  if [[ -e "$target" ]]; then
    local rel="${target#${CONFIG}/}"
    local dest="${BACKUP_DIR}/${rel}"
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    echo "Backed up: $target -> $dest"
  fi
}

link_one() {
  local src_rel="$1"
  local dst_rel="$2"

  local src="${REPO}/${src_rel}"
  local dst="${CONFIG}/${dst_rel}"

  if [[ ! -e "$src" ]]; then
    echo "WARN: source missing, skipping: $src"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  backup_if_needed "$dst"

  # Replace wrong symlink
  if [[ -L "$dst" && "$(readlink "$dst")" != "$src" ]]; then
    rm -f "$dst"
  fi

  ln -sfn "$src" "$dst"
  echo "Linked: $dst -> $src"
}

for pair in "${LINKS[@]}"; do
  IFS=":" read -r src_rel dst_rel <<<"$pair"
  link_one "$src_rel" "$dst_rel"
done

echo
echo "Done."
echo "Backups (if any): $BACKUP_DIR"
