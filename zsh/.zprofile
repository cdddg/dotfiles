# coreutils: Add GNU utilities (e.g. ls with --color) to PATH
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

# pyenv: Set root & add shims/bin to PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# pyenv: Init --path (required for login shell)
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

# npm: Add global packages to PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# User custom scripts from ~/bin
export PATH="$HOME/bin:$PATH"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
