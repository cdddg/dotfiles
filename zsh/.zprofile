_ZPROFILE_T=$EPOCHREALTIME

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

_ZSH_LOAD_TIMES+=(".zprofile:$(printf '%.2f' $(( (EPOCHREALTIME - _ZPROFILE_T) * 1000 )))")
