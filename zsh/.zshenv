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

# virtualenv: Only `20` passes both checks:
#   activate script (-z): non-empty → won't prepend "(venv)" to PS1
#   pure prompt (== 20):  matches   → pure renders virtualenv in prompt
export VIRTUAL_ENV_DISABLE_PROMPT=20

# homebrew: Auto-update interval (24 hours), disable auto-update on install/upgrade
export HOMEBREW_AUTO_UPDATE_SECS=86400
export HOMEBREW_NO_AUTO_UPDATE=1

# fzf: shared base for zsh fzf-tab + nvim fzf-lua + plain `fzf`.
# Catppuccin Mocha palette — pure-style minimal (teal accent, mauve/peach for matches).
# To switch flavor: replace each hex below using the semantic name in the legend.
# Palette reference: https://catppuccin.com/palette
#   #94e2d5 = teal      (prompt, pointer)
#   #a6e3a1 = green     (marker)
#   #cba6f7 = mauve     (hl)
#   #fab387 = peach     (hl+)
#   #cdd6f4 = text      (fg, fg+)
#   #313244 = surface0  (bg+)
#   #6c7086 = surface2  (header, info)
export FZF_DEFAULT_OPTS="\
--bind=tab:down,btab:up \
--height=40% \
--layout=reverse \
--info=inline-right \
--prompt='❯ ' \
--pointer='❯' \
--marker='┃' \
--color='prompt:#94e2d5,pointer:#94e2d5,marker:#a6e3a1,hl:#cba6f7,hl+:#fab387,fg:#cdd6f4,fg+:#cdd6f4,bg+:#313244,gutter:-1,header:#6c7086,info:#6c7086'\
"

# k9s: Use ~/.config/k9s instead of ~/Library/Application Support/k9s
export K9S_CONFIG_DIR="$HOME/.config/k9s"

# kubeconfig
export KUBECONFIG=$(find ~/.kube -maxdepth 1 -type f \( -name '*.kubeconfig' -o -name '*.yaml' -o -name '*_config' \) | tr '\n' ':')

_ZSH_LOAD_TIMES+=(".zshenv:$(printf '%.2f' $(( (EPOCHREALTIME - _ZSHENV_T) * 1000 )))")
