#!/bin/bash
current=$(tmux display-message -p '#I')
tmux list-windows -F '#I #W' | while read line
do
    window=$(echo $line | cut -d ' ' -f 1)
    if [[ $window == $current ]]; then
        echo "#[fg=green,bg=black] $line #[default]"
    else
        echo "$line"
    fi
done | tmux choose-tree -f -
