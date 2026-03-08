_ZSHRC_T=$EPOCHREALTIME

# zsh: shell options
WORDCHARS=${WORDCHARS//[\/\-]/}
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# zinit: A flexible and fast Zsh plugin manager.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" --depth=1
fi
source "${ZINIT_HOME}/zinit.zsh"

# sindresorhus/pure: Pretty, minimal and fast ZSH prompt.
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure
zstyle ':prompt:pure:prompt:*' color cyan
zstyle ':prompt:pure:git:stash' show yes
zstyle ':prompt:pure:virtualenv' show yes
PURE_SUSPENDED_JOBS_SYMBOL="⏸"

# git hooks indicator: show pre-commit/pre-push status in pure prompt
autoload -Uz add-zsh-hook
_prompt_pure_check_git_hooks() {
  local git_dir hooks_path
  git_dir=$(git rev-parse --git-dir 2>/dev/null) || { prompt_pure_hooks_indicator=''; return; }
  hooks_path=$(git config core.hooksPath 2>/dev/null)
  : ${hooks_path:=$git_dir/hooks}
  [[ $hooks_path != /* ]] && hooks_path=$(git rev-parse --show-toplevel)/$hooks_path

  prompt_pure_hooks_indicator=' '
  for hook in pre-commit pre-push; do
    [[ -x $hooks_path/$hook ]] \
      && prompt_pure_hooks_indicator+=%F{green}✓%f || prompt_pure_hooks_indicator+=%F{yellow}✗%f
  done
}
add-zsh-hook precmd _prompt_pure_check_git_hooks
PROMPT=${PROMPT/'%(19V.'/'${prompt_pure_hooks_indicator}%(19V.'}

# zdharma-continuum/fast-syntax-highlighting: Feature-rich syntax highlighting for Zsh.
zinit ice lucid wait='0' atinit='zpcompinit'
zinit light zdharma-continuum/fast-syntax-highlighting

# zsh-users/zsh-completions: Additional completion definitions for Zsh.
zinit ice lucid wait='0'
zinit light zsh-users/zsh-completions

# zsh: completion settings
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'

# zsh-users/zsh-autosuggestions: Fish-like fast/unobtrusive autosuggestions for zsh.
zinit ice lucid wait="0" atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# ohmyzsh/ohmyzsh: A delightful community-driven framework for managing your zsh configuration.
# zinit snippet OMZ::lib/completion.zsh -- disable OMZ completion
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/git.zsh
zinit ice lucid wait"2" && zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit ice lucid wait"2" && zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit ice lucid wait"2" && zinit snippet OMZ::plugins/extract

# MichaelAquilina/zsh-autoswitch-virtualenv: Automatically switch python virtualenvs when you cd into a directory.
zinit light MichaelAquilina/zsh-autoswitch-virtualenv

# Aloxaf/fzf-tab: Replace zsh's default completion selection menu with fzf!
zinit light Aloxaf/fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'  # switch group using `,` and `.`
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 120 20
zstyle ':fzf-tab:*' popup-pad 0 0

# romkatv/zsh-defer: Defer execution of commands until zsh is idle.
zinit light romkatv/zsh-defer
zsh-defer -a -c '
  eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
'
# Ghostty keybindings
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  # Shift+Enter: treat as Enter
  if [[ -n "$TMUX" ]]; then
    bindkey '\e[13;2u' accept-line      # Kitty protocol format (Ghostty + tmux)
  else
    bindkey '\e[27;2;13~' accept-line   # xterm format (Ghostty without tmux)
  fi
fi

zsh-defer -a -c '
  eval "$(pyenv init - zsh)"
  eval "$(poetryenv init - zsh)"
  if [[ -n "$VIRTUAL_ENV" ]]; then
    #
    # Remove old VIRTUAL_ENV/bin from path, then prepend it
    #
    path=("$VIRTUAL_ENV/bin" ${path:#"$VIRTUAL_ENV/bin"})
  fi
  hash -r
'

source ~/.zsh_functions
source ~/.zsh_aliases

_ZSH_LOAD_TIMES+=(".zshrc:$(printf '%.2f' $(( (EPOCHREALTIME - _ZSHRC_T) * 1000 )))")
if (( ${#_ZSH_LOAD_TIMES[@]} )); then
  local summary_line="" total_duration=0.0
  for item in "${_ZSH_LOAD_TIMES[@]}"; do
    local file=${item%%:*}
    local duration=${item##*:}
    summary_line+="${file}:${duration}ms  "
    (( total_duration += duration ))
  done

  local label="load"
  [[ $- == *i* && $- == *l* ]] && label="login init"
  [[ $- == *i* && $- != *l* ]] && label="interactive init"
  [[ $- != *i* ]] && label="non-interactive init"

  printf "\r\033[K  %s %s %.2fms | %s\n" "$ZSH_NAME" "$label" "$total_duration" "$summary_line"
fi
