#!/bin/bash

# Function to create a session and windows in specific folders
create_session_with_windows() {
    local session_name=$1
    shift
    local folders=("$@")

    # Check if the session already exists
    tmux has-session -t "$session_name" 2>/dev/null
    if [ $? != 0 ]; then
        # Create the session with the first folder (use $HOME as base path)
        tmux new-session -d -s "$session_name" -c "$HOME"

        # Rename the first window to the first folder and set its path
        tmux rename-window -t "$session_name:0" "$(basename ${folders[0]})"
        tmux send-keys -t "$session_name:0" "cd $(realpath ${folders[0]})" C-m

        # Add additional windows with their respective folders
        for ((i = 1; i < ${#folders[@]}; i++)); do
            tmux new-window -t "$session_name:" -c "$(realpath ${folders[i]})" -n "$(basename ${folders[i]})"
        done

        # Switch back to window 0
        tmux select-window -t "$session_name:0"
    fi
}

# Create sessions with specified windows and directories
create_session_with_windows "sys" "$HOME/proj/ixt-auth" "$HOME/proj/ixt-system" "$HOME/proj/ixt-resource" "$HOME/proj/ixt-event"
create_session_with_windows "core" "$HOME/proj/ixt" "$HOME/proj/ixt-standard-api" "$HOME/proj/ixt-api"
create_session_with_windows "prm" "$HOME/proj/ixt-prm" "$HOME/proj/ixt-prm-gw"
create_session_with_windows "claim" "$HOME/proj/ixt-claim" "$HOME/proj/ixt-claim-gw"
create_session_with_windows "4" "$HOME/proj/ixt-event-sdk" "$HOME/proj/ixt-auth-sdk" "$HOME/proj/ixt-rule-engine" "$HOME/proj/ixt-utils"

# Select the first window of the 1st session
tmux select-window -t sys:0

# Attach to the first session
tmux attach-session -t sys
