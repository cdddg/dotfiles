_ZSHRC_T=$EPOCHREALTIME

# Enable zsh's built-in profiler when ZPROF is set. Run `ZPROF=1 zsh -i` (or
# `ZPROF=1 exec zsh`) to see a table of function call times at shell exit.
[[ -n $ZPROF ]] && zmodload zsh/zprof

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
  # Zero-fork: walk up to find .git, parse it ourselves. ~1000x faster than
  # shelling out to git. Trade-off: ignores `core.hooksPath` (husky/lefthook),
  # `$GIT_DIR` env override, and bare repos.
  local dir=$PWD git_marker git_dir content hook
  while [[ $dir != / ]]; do
    [[ -e $dir/.git ]] && { git_marker=$dir/.git; break; }
    dir=${dir:h}
  done

  if [[ -z $git_marker ]]; then
    prompt_pure_hooks_indicator=''
    prompt_pure_worktree_indicator=''
    return
  fi

  if [[ -d $git_marker ]]; then
    git_dir=$git_marker
    prompt_pure_worktree_indicator=''
  else
    # .git is a file -> linked worktree (gitdir points to .git/worktrees/<name>)
    # or submodule (gitdir points to .git/modules/<name>). Only worktrees light up.
    content=$(<$git_marker)
    git_dir=${content#gitdir: }
    [[ $git_dir != /* ]] && git_dir=$dir/$git_dir
    [[ $content == *worktrees/* ]] \
      && prompt_pure_worktree_indicator=" %F{magenta}%f" \
      || prompt_pure_worktree_indicator=''
  fi

  prompt_pure_hooks_indicator=' '
  for hook in pre-commit pre-push; do
    [[ -x $git_dir/hooks/$hook ]] \
      && prompt_pure_hooks_indicator+=%F{green}✔%f \
      || prompt_pure_hooks_indicator+=%F{yellow}✘%f
  done
}
# chpwd (not precmd) so it fires only on `cd`; the initial seeding call is
# deferred (see the zsh-defer block below) so it doesn't block startup.
add-zsh-hook chpwd _prompt_pure_check_git_hooks
PROMPT=${PROMPT/'%(14V.'/'${prompt_pure_worktree_indicator}%(14V.'}
PROMPT=${PROMPT/'%(19V.'/'${prompt_pure_hooks_indicator}%(19V.'}

# Plugin loading order matters — widget wrappers must load AFTER widget owners.
# Wrong order breaks fzf-tab + autosuggestion (ghost text won't be cleared).
#
#   1. zsh-completions          _xxx completion defs; doesn't wrap widgets
#   2. fzf-tab                  replaces completion widget; must load first
#   3. zsh-autosuggestions      wraps fzf-tab to detect accept events
#   4. fast-syntax-highlighting outermost wrap
#
# Ref: https://github.com/Aloxaf/fzf-tab#installation

# 1a. zsh-users/zsh-completions: Additional completion definitions for Zsh.
zinit ice lucid wait='0'
zinit light zsh-users/zsh-completions

# 1b. zsh: completion settings
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'

# 2. Aloxaf/fzf-tab: Replace zsh's default completion selection menu with fzf!
zinit ice lucid wait='0' atload='enable-fzf-tab'
zinit light Aloxaf/fzf-tab
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group ',' '.'  # switch group using `,` and `.`
# ftb-tmux-popup: render fzf-tab as a tmux floating popup (requires tmux session; otherwise falls back to inline).
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 120 20
zstyle ':fzf-tab:*' popup-pad 0 0

# 3. zsh-users/zsh-autosuggestions: Fish-like fast/unobtrusive autosuggestions for zsh.
zinit ice lucid wait="0" atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# 4. zdharma-continuum/fast-syntax-highlighting: Feature-rich syntax highlighting for Zsh.
zinit ice lucid wait='0'
zinit light zdharma-continuum/fast-syntax-highlighting

# MichaelAquilina/zsh-you-should-use: Reminds you to use existing aliases.
export YSU_MESSAGE_POSITION="after"
zinit ice lucid wait='1'
zinit light MichaelAquilina/zsh-you-should-use

# ohmyzsh/ohmyzsh: A delightful community-driven framework for managing your zsh configuration.
# zinit snippet OMZ::lib/completion.zsh -- disable OMZ completion
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/git.zsh
zinit ice lucid wait"2" atload'unalias gwtrm 2>/dev/null' && zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit ice lucid wait"2" && zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit ice lucid wait"2" && zinit snippet OMZ::plugins/extract

# MichaelAquilina/zsh-autoswitch-virtualenv: Automatically switch python virtualenvs when you cd into a directory.
# zinit light MichaelAquilina/zsh-autoswitch-virtualenv
# Temporarily pinned to own fork's PR branch until upstream merges
# https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv/pull/222
zinit ice ver"fix/rmvenv-in-project-poetry"
zinit light cdddg/zsh-autoswitch-virtualenv

# romkatv/zsh-defer: Defer execution of commands until zsh is idle.
zinit light romkatv/zsh-defer

# Opt-in per-defer profiling: `ZDEFER_PROFILE=1 exec zsh` then `_zdp_report`.
# Wraps zsh-defer -c payloads with EPOCHREALTIME; other usages pass through.
if [[ -n $ZDEFER_PROFILE ]]; then
  typeset -ga _zdp_cmds _zdp_times
  functions -c zsh-defer _zdp_orig
  zsh-defer() {
    [[ $1 != -c || -z $2 ]] && { _zdp_orig "$@"; return }
    _zdp_cmds+=("$2")
    _zdp_orig -c "_t=\$EPOCHREALTIME; $2; _zdp_times[${#_zdp_cmds}]=\$(( (EPOCHREALTIME-_t)*1000 ))"
  }
  _zdp_report() {
    local i
    for i in {1..${#_zdp_cmds}}; do
      printf "%7.1fms  %s\n" ${_zdp_times[i]:-0} ${_zdp_cmds[i]}
    done | sort -rn
  }
fi

# Ghostty keybindings
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  # Shift+Enter: treat as Enter
  if [[ -n "$TMUX" ]]; then
    bindkey '\e[13;2u' accept-line      # Kitty protocol format (Ghostty + tmux)
  else
    bindkey '\e[27;2;13~' accept-line   # xterm format (Ghostty without tmux)
  fi
fi

# zsh-defer runs each command once zsh is idle so the prompt renders instantly; one command per defer lets zle yield between them.
# Queue is FIFO and inits prepend fpath, so a defer placed later ends up higher in fpath.
RPS1='%F{240}loading…%f'

# Seed pure prompt's git-hooks indicator for the starting directory.
zsh-defer -c '_prompt_pure_check_git_hooks'

# Tool init: fpath priority increases top-to-bottom
zsh-defer -c 'eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"'
zsh-defer -c 'eval "$(poetryenv init - zsh)"'
# --no-rehash: skips `command pyenv rehash` (~50ms shims dir scan; rehash only
# matters after `pyenv install/uninstall`, which already runs it).
# --no-push-path: replaces the bash --norc PATH-dedup block with a pure-zsh
# check (~20ms saved by avoiding the bash fork).
zsh-defer -c 'eval "$(pyenv init - --no-rehash --no-push-path zsh)"'
zsh-defer -c 'eval "$(/opt/homebrew/bin/brew shellenv)"'

# User override: runs after all tool inits so ~/.zsh_completions sits at
# the front of fpath — custom _xxx files can shadow brew/tool versions.
zsh-defer -c 'fpath=(~/.zsh_completions $fpath)'

# compinit last: deferred FIFO ensures this runs after all fpath modifications above.
# -C skips security audit and dump rebuild when dump is fresh (<24h); otherwise
# fall through to full compinit so new fpath entries get picked up daily.
# Calls compinit directly instead of zinit's `zpcompinit`, which silently drops
# positional args and only honours ZINIT[COMPINIT_OPTS] — so `zpcompinit -C`
# is a no-op and compaudit still runs. Direct call keeps `-C` semantics intact.
_zsh_smart_compinit() {
  autoload -Uz compinit
  local dump=${ZINIT[ZCOMPDUMP_PATH]:-${ZDOTDIR:-$HOME}/.zcompdump}
  local fresh=($dump(Nmh-24))
  if (( $#fresh )); then
    compinit -C -d $dump
  else
    compinit -d $dump
  fi
}
zsh-defer -c '_zsh_smart_compinit'

# If a venv is already active at startup (e.g. inherited from tmux), force
# $VIRTUAL_ENV/bin back to the front so pyenv shims etc. don't shadow it.
zsh-defer -c '[[ -n $VIRTUAL_ENV ]] && path=("$VIRTUAL_ENV/bin" ${path:#"$VIRTUAL_ENV/bin"})'

# Cleanup: rehash so the new PATH takes effect, drop the loading indicator.
zsh-defer -c 'hash -r; unset RPS1'

source ~/.zsh_functions
source ~/.zsh_aliases

# Machine-local secrets (API tokens, etc.) — never committed. Optional.
[ -f ~/.secrets ] && source ~/.secrets

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
