#!/bin/bash
# =============================================================================
# Dotfiles Installation Script
# Uses GNU Stow to create symlinks from this repo to your home directory
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script lives
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}       Dotfiles Installation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check for stow
if ! command -v stow &> /dev/null; then
    echo -e "${RED}Error: GNU Stow is required but not installed.${NC}"
    echo -e "${YELLOW}Install it with: sudo apt install stow${NC}"
    exit 1
fi

echo -e "${GREEN}Found GNU Stow${NC}"
echo ""

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Create required directories if they don't exist
echo -e "${BLUE}Creating required directories...${NC}"
mkdir -p ~/.config/nvim
mkdir -p ~/.local/bin
echo -e "${GREEN}Done${NC}"
echo ""

# Define packages to stow
PACKAGES=(nvim tmux zsh scripts)

# Stow each package
echo -e "${BLUE}Stowing packages...${NC}"
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo -e "  ${YELLOW}Stowing ${pkg}...${NC}"
        stow -v --target="$HOME" "$pkg" 2>&1 | sed 's/^/    /'
    else
        echo -e "  ${RED}Warning: Package '$pkg' not found, skipping${NC}"
    fi
done
echo -e "${GREEN}Done${NC}"
echo ""

# Post-installation reminders
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo -e "  1. ${BLUE}Set up your secrets file:${NC}"
echo -e "     cp $DOTFILES_DIR/.secrets.example ~/.secrets"
echo -e "     # Then edit ~/.secrets and add your API keys"
echo ""
echo -e "  2. ${BLUE}Reload your shell:${NC}"
echo -e "     source ~/.zshrc"
echo ""
echo -e "  3. ${BLUE}(Optional) Install oh-my-zsh if not already installed:${NC}"
echo -e "     sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
echo ""
echo -e "  4. ${BLUE}(Optional) Reload tmux config:${NC}"
echo -e "     tmux source-file ~/.tmux.conf"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}To uninstall, run:${NC}"
echo -e "  cd $DOTFILES_DIR"
echo -e "  stow -D nvim tmux zsh scripts"
echo -e "${BLUE}========================================${NC}"
