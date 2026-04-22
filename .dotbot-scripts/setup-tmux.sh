#!/bin/bash

set -e

# Install tmux plugin manager (TPM) if missing,
# then install/update all plugins and reload tmux config.
# Usage: setup-tmux.sh

TPM_VERSION="v3.1.0"
TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    mkdir -p "$TPM_DIR"
    curl -fsSL "https://github.com/tmux-plugins/tpm/archive/refs/tags/${TPM_VERSION}.tar.gz" \
        | tar xz -C "$TPM_DIR" --strip-components=1
fi

"$TPM_DIR/bin/install_plugins"
"$TPM_DIR/bin/update_plugins" all
tmux source-file ~/.tmux.conf
