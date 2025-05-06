zmodload zsh/datetime
zsh_start=$EPOCHREALTIME

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

# arcticicestudio/nord-dircolors: Nord theme for dircolors with LS_COLORS support.
zinit ice atclone"dircolors -b LS_COLORS > clrs.zsh" \
  atpull'%atclone' pick"clrs.zsh" nocompile'!' \
  atload'zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"'
zinit light arcticicestudio/nord-dircolors

# zdharma-continuum/fast-syntax-highlighting: Feature-rich syntax highlighting for Zsh.
zinit ice lucid wait='0' atinit='zpcompinit'
zinit light zdharma-continuum/fast-syntax-highlighting

# zsh-users/zsh-completions: Additional completion definitions for Zsh.
zinit ice lucid wait='0'
zinit light zsh-users/zsh-completions

# zsh-users/zsh-autosuggestions: Fish-like fast/unobtrusive autosuggestions for zsh.
zinit ice lucid wait="0" atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# ohmyzsh/ohmyzsh: A delightful community-driven framework for managing your zsh configuration.
# zinit snippet OMZ::lib/completion.zsh -- disable OMZ completion
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/git.zsh
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit snippet OMZ::plugins/extract

# MichaelAquilina/zsh-autoswitch-virtualenv: Automatically switch python virtualenvs when you cd into a directory.
zinit wait lucid for MichaelAquilina/zsh-autoswitch-virtualenv

# junegunn/fzf-bin: A command-line fuzzy finder (GitHub release binary).
zinit ice from"gh-r" as"program"
zinit load junegunn/fzf-bin

# Aloxaf/fzf-tab: Replace zsh's default completion selection menu with fzf!
zinit light Aloxaf/fzf-tab
zstyle ':completion:*:git-checkout:*' sort false  # disable sort when completing `git checkout`
zstyle ':completion:*:descriptions' format '[%d]'  # # set descriptions format to enable group support
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'  # preview directory's content with exa when completing cd
zstyle ':fzf-tab:*' switch-group ',' '.'  # switch group using `,` and `.`
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# zsh: shell options
WORDCHARS=${WORDCHARS//[\/\-_]/}
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

source ~/.zsh_aliases
source ~/.zsh_functions

printf "\r\033[K  .zshrc loaded in %.4fs\n" "$(echo "$EPOCHREALTIME - $zsh_start" | bc -l)"
