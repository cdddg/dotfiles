#!/bin/bash

set -e

# Install specified Python minor versions via pyenv
# and bootstrap pip packages for all installed versions.
# Usage: setup-pyenv.sh 3.12 3.13 3.14

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

# Install the latest patch versions of Python
MINORS=("$@")
if [[ ${#MINORS[@]} -eq 0 ]]; then
    echo "Usage: $0 <minor_version>..." >&2
    echo "Example: $0 3.12 3.13 3.14" >&2
    exit 1
fi
for minor in "${MINORS[@]}"; do
    latest=$(pyenv install --list | grep -E "^\s*$minor\.[0-9]+" | tail -1 | tr -d '[:space:]')
    [[ -z "$latest" ]] && continue
    if pyenv versions --bare | grep -qx "$latest"; then
        echo "Python $latest is already installed."
    else
        pyenv install "$latest"
    fi
done

# Upgrade pip and install essential packages for all installed versions
for ver in $(pyenv versions --bare); do
    python="$HOME/.pyenv/versions/$ver/bin/python"
    pip_list=$("$python" -m pip freeze)
    if [[ -n "$pip_list" ]]; then
        echo "$pip_list" | "$python" -m pip uninstall -y -r /dev/stdin
    fi
    "$python" -m pip install --upgrade pip pynvim virtualenv &
done
wait
