#!/bin/bash

set -e

# Install npm packages listed in the given file, globally.
# Lines starting with # and blank lines are ignored.
# Usage: install-npm-globals.sh [packages file]

PACKAGES_FILE="${1:-./npm-packages.txt}"

grep -vE '^\s*($|#)' "$PACKAGES_FILE" | \
    xargs -n1 -I {} sh -c '
        printf "%s -> " "{}"
        npm install --no-fund -g "{}" 2>&1 |
        grep -E "(added|changed|removed|up to date|updated|audited)" |
        head -1
    '
