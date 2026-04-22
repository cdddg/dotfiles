#!/bin/bash

set -e

# Download k0nserv's kitty icon and apply it via cocoa_set_app_icon.
# Requires App Management permission on macOS.
# Usage: setup-kitty-icon.sh

if ! command -v kitty >/dev/null 2>&1; then
    echo "kitty not found, skipping"
    exit 0
fi

ICON_DIR="$HOME/.config/kitty/k0nserv-icon"
ICON_VERSION="2023-07-09"

if [ ! -d "$ICON_DIR" ]; then
    mkdir -p "$ICON_DIR"
    curl -fsSL "https://github.com/k0nserv/kitty-icon/archive/refs/tags/${ICON_VERSION}.tar.gz" \
        | tar xz -C "$ICON_DIR" --strip-components=1
fi

sudo kitty +runpy \
    'from kitty.fast_data_types import cocoa_set_app_icon; import sys; cocoa_set_app_icon(*sys.argv[1:]); print("OK")' \
    "$ICON_DIR/build/neue_outrun.icns"
