#!/bin/bash

set -e

# Install Catppuccin theme files into the k9s skins directory.
# Usage: install-catppuccin-k9s.sh

SKINS_DIR="$HOME/.config/k9s/skins"

mkdir -p "$SKINS_DIR"
curl -fsSL https://github.com/catppuccin/k9s/archive/main.tar.gz \
    | tar xz -C "$SKINS_DIR" --strip-components=2 k9s-main/dist
