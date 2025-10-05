#!/bin/bash

set -e

# This script sets up the required CFLAGS and LDFLAGS for Python installation, 
# installs the latest patch versions of Python 3.9, 3.10 and 3.11 using pyenv, 
# and upgrades pip, poetry, and virtualenv for all installed Python versions.

# Define environment variables
export CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix readline)/include -I$(xcrun --show-sdk-path)/usr/include"
export LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(xcrun --show-sdk-path)/usr/lib"

# Install the latest patch versions of Python
for ver in "3.9" "3.10" "3.11"; do
    latest_version=$(pyenv install --list | grep -E "^\s*$ver\.[0-9].*" | tail -1 | tr -d '[:space:]')
    if ! pyenv versions --bare | grep -qx "$latest_version"; then
        pyenv install $latest_version
    else
        echo "Python $latest_version is already installed."
    fi
done

# Upgrade pip, poetry, and virtualenv
for ver in $(ls $HOME/.pyenv/versions); do
    pip_list=$($HOME/.pyenv/versions/$ver/bin/python -m pip freeze)
    if [ ! -z "$pip_list" ]; then
        echo "$pip_list" | $HOME/.pyenv/versions/$ver/bin/python -m pip uninstall -y -r /dev/stdin
    fi
    $HOME/.pyenv/versions/$ver/bin/python -m pip install --upgrade pip poetry pynvim virtualenv &
done

