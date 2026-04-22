#!/bin/bash

set -e

# Install Homebrew (if missing) and apply the Brewfile,
# then upgrade every brew/cask listed in it.
# Usage: setup-brew.sh [Brewfile]

BREWFILE="${1:-./Brewfile}"

if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update
brew bundle --file="$BREWFILE"
brew bundle list --brews --file="$BREWFILE" | xargs brew upgrade
brew bundle list --casks --file="$BREWFILE" | xargs brew upgrade --cask
