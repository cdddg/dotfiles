#!/usr/bin/env bash
# shellcheck disable=SC2059,2162
#
# Neovim Complete Reset Script
#
# This script removes all Neovim data directories including:
#   - Installed plugins (lazy.nvim)
#   - LSP servers and tools (Mason)
#   - Treesitter parsers
#   - All cache and state files
#   - Logs and temporary files
#
# Usage: ./clean.sh
#
# After running this script:
#   1. Restart Neovim
#   2. Plugins will auto-install via lazy.nvim
#   3. Run :Mason to reinstall LSP servers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories to clean
NVIM_DATA="$HOME/.local/share/nvim"
NVIM_STATE="$HOME/.local/state/nvim"
NVIM_CACHE="$HOME/.cache/nvim"

printf "${YELLOW}⚠️  Neovim Cleanup Tool${NC}\n"
printf "\n"
printf "This will DELETE the following directories:\n"
printf "  ${BLUE}•${NC} $NVIM_DATA (plugins, mason, etc.)\n"
printf "  ${BLUE}•${NC} $NVIM_STATE (logs, state files)\n"
printf "  ${BLUE}•${NC} $NVIM_CACHE (cache files)\n"
printf "\n"
printf "${RED}WARNING: This action cannot be undone!${NC}\n"
printf "\n"
read -p "Type 'YES' to confirm: " confirm

# Convert to uppercase and check
confirm_upper=$(echo "$confirm" | tr '[:lower:]' '[:upper:]')
if [ "$confirm_upper" != "YES" ] && [ "$confirm_upper" != "Y" ] && [ "$confirm" != "1" ]; then
    printf "${BLUE}Cleanup cancelled${NC}\n"
    exit 0
fi

printf "\n"
printf "${BLUE}🧹 Starting cleanup...${NC}\n"

# Function to remove directory
remove_dir() {
    local dir=$1
    if [ -d "$dir" ]; then
        printf "${BLUE}Removing:${NC} $dir\n"
        rm -rf "$dir"
        printf "${GREEN}✓${NC} Removed: $dir\n"
    else
        printf "${YELLOW}⊘${NC} Not found: $dir (skipping)\n"
    fi
}

# Remove directories
remove_dir "$NVIM_DATA"
remove_dir "$NVIM_STATE"
remove_dir "$NVIM_CACHE"

printf "\n"
printf "${GREEN}✅ Cleanup complete!${NC}\n"
printf "\n"
printf "${BLUE}Next steps:${NC}\n"
printf "  1. Restart Neovim\n"
printf "  2. Run ${YELLOW}:Lazy sync${NC} to reinstall plugins\n"
printf "  3. Run ${YELLOW}:Mason${NC} to reinstall LSP servers\n"
