#!/bin/bash

set -e

# This script sets up the required CFLAGS and LDFLAGS for Python installation,
# installs the latest patch versions of Python 3.9, 3.10 and 3.11 using pyenv,
# and upgrades pip, poetry, and virtualenv for all installed Python versions.

# Define environment variables
export CFLAGS=""
export LDFLAGS=""
[[ -n "$OPENSSL_PREFIX" ]] && {
    CFLAGS="$CFLAGS -I$OPENSSL_PREFIX/include"
    LDFLAGS="$LDFLAGS -L$OPENSSL_PREFIX/lib"
}
[[ -n "$READLINE_PREFIX" ]] && {
    CFLAGS="$CFLAGS -I$READLINE_PREFIX/include"
    LDFLAGS="$LDFLAGS -L$READLINE_PREFIX/lib"
}
[[ -n "$SDK_PATH" ]] && {
    CFLAGS="$CFLAGS -I$SDK_PATH/usr/include"
    LDFLAGS="$LDFLAGS -L$SDK_PATH/usr/lib"
}
export CFLAGS LDFLAGS

# Install the latest patch versions of Python
MINORS=("3.9" "3.10" "3.11" "3.12" "3.13" "3.14")
for minor in "${MINORS[@]}"; do
    for ver in "3.9" "3.10" "3.11" "3.12" "3.13" "3.14"; do
        latest_version=$(pyenv install --list | grep -E "^\s*$minor\.[0-9].*" | tail -1 | tr -d '[:space:]')
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
        $HOME/.pyenv/versions/$ver/bin/python -m pip install --upgrade pip pynvim virtualenv &
    done
done
