#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

###############################################################################
# Settings                                                                    #
###############################################################################

# Create symlink that points to the dotfiles settings.json
mkdir -p "$CURSOR_USER_DIR"
ln -sf "$DOTFILES_DIR/cursor/settings.json" "$CURSOR_USER_DIR/settings.json"

###############################################################################
# Extensions                                                                  #
###############################################################################

# Sync extensions list
extensions=()
while IFS= read -r line; do
  # Skip lines starting with # (comments) or empty lines
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
  extensions+=("$line")
done < "$DOTFILES_DIR/cursor/extensions.txt"

# Install extensions in list
for ext in "${extensions[@]}"; do
  cursor --install-extension "$ext"
done

# Uninstall extensions not in list
while IFS= read -r installed; do
  is_extension_in_list=0
  for ext in "${extensions[@]}"; do
    [[ "$(echo "$ext" | tr '[:upper:]' '[:lower:]')" == "$(echo "$installed" | tr '[:upper:]' '[:lower:]')" ]] && is_extension_in_list=1 && break
  done
  if [[ "$is_extension_in_list" -eq 0 ]]; then
    cursor --uninstall-extension "$installed"
  fi
done < <(cursor --list-extensions)
