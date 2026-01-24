zmodload zsh/datetime 2>/dev/null || true
typeset -ga _ZSH_LOAD_TIMES

_ZSHENV_T=$EPOCHREALTIME

# macOS: Load system paths from /etc/paths and /etc/paths.d/*
# /etc/zprofile calls path_helper but only runs in login shells
# Without this, non-login shells (e.g., terminal splits) lack /usr/local/bin and other system paths
if [[ -x /usr/libexec/path_helper ]]; then
  eval "$(/usr/libexec/path_helper -s)"
fi

# coreutils: Add GNU utilities (e.g. ls with --color) to PATH
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

# pyenv: Set root & add shims/bin to PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# npm: Add global packages to PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# bob: Add bob's Neovim binary directory to PATH
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# local: Add user-installed binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

# homebrew: Auto-update interval (24 hours), disable auto-update on install/upgrade
export HOMEBREW_AUTO_UPDATE_SECS=86400
export HOMEBREW_NO_AUTO_UPDATE=1

_ZSH_LOAD_TIMES+=(".zshenv:$(printf '%.2f' $(( (EPOCHREALTIME - _ZSHENV_T) * 1000 )))")
