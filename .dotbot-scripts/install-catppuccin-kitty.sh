#!/bin/bash

set -e

# Install Catppuccin theme files for kitty.
# Usage: install-catppuccin-kitty.sh

THEME_DIR="$HOME/.config/kitty/catppuccin-theme"

if [ ! -d "$THEME_DIR" ]; then
    mkdir -p "$THEME_DIR"
    curl -fsSL https://github.com/catppuccin/kitty/archive/main.tar.gz \
        | tar xz -C "$THEME_DIR" --strip-components=1
fi
