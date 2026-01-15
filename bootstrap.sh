#!/usr/bin/env bash
# =============================================================================
# Bootstrap Script for Development Environment
# =============================================================================
# This script sets up a complete development environment on a fresh machine.
# Supports: Ubuntu/Debian, Fedora, Arch Linux, macOS
#
# Usage:
#   ./bootstrap.sh              # Interactive mode
#   ./bootstrap.sh --yes        # Non-interactive (auto-confirm all)
#   ./bootstrap.sh --help       # Show help
#
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================

# Default dotfiles repository (change this to your repo)
DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:JustinMundt/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"

# Go version to install
GO_VERSION="1.22.0"

# Nerd Font to install
NERD_FONT="JetBrainsMono"
NERD_FONT_VERSION="v3.1.1"

# =============================================================================
# Colors and Formatting
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =============================================================================
# Global Variables
# =============================================================================

AUTO_YES=false
SKIP_LANGS=false
SKIP_TOOLS=false
SKIP_SHELL=false
SKIP_DOCKER=false
SKIP_FONTS=false
SKIP_KEYD=false
OS=""
PKG_MANAGER=""
SUDO_CMD=""

# Track what was installed for summary
INSTALLED_ITEMS=()

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${CYAN}--- $1 ---${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_step() {
    echo -e "${MAGENTA}>>>${NC} $1"
}

# Prompt for confirmation (respects --yes flag)
confirm() {
    local prompt="$1"
    local default="${2:-y}"
    
    if [ "$AUTO_YES" = true ]; then
        return 0
    fi
    
    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi
    
    read -rp "$prompt" response
    response="${response:-$default}"
    
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Add to installed items list
mark_installed() {
    INSTALLED_ITEMS+=("$1")
}

# Check for dotfiles updates from GitHub
check_dotfiles_update() {
    # Only check if we're running from an existing dotfiles directory
    if [ -d "$DOTFILES_DIR/.git" ]; then
        print_section "Checking for Dotfiles Updates"
        
        cd "$DOTFILES_DIR"
        
        # Fetch latest from remote
        print_step "Fetching latest from remote..."
        git fetch origin 2>/dev/null || {
            print_warning "Could not fetch from remote (no network or SSH key issue)"
            return
        }
        
        # Check if we're behind
        local LOCAL=$(git rev-parse HEAD 2>/dev/null)
        local REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
        
        if [ -z "$REMOTE" ]; then
            print_info "No upstream branch configured, skipping update check"
            return
        fi
        
        if [ "$LOCAL" != "$REMOTE" ]; then
            print_info "Updates available from GitHub"
            if confirm "Pull latest changes from GitHub before proceeding?"; then
                print_step "Pulling latest changes..."
                git pull --ff-only || {
                    print_warning "Could not fast-forward, you may have local changes"
                    print_info "Continuing with current version..."
                }
            fi
        else
            print_success "Dotfiles are up to date"
        fi
    fi
}

# =============================================================================
# Argument Parsing
# =============================================================================

show_help() {
    echo -e "${BOLD}Bootstrap Script for Development Environment${NC}"
    echo ""
    echo -e "${BOLD}USAGE:${NC}"
    echo "    ./bootstrap.sh [OPTIONS]"
    echo ""
    echo -e "${BOLD}OPTIONS:${NC}"
    echo "    -y, --yes           Non-interactive mode (auto-confirm all prompts)"
    echo "    -h, --help          Show this help message"
    echo "    --skip-langs        Skip language installations (Go, Rust, Node.js)"
    echo "    --skip-tools        Skip tool installations (lazygit, gh)"
    echo "    --skip-docker       Skip Docker installation"
    echo "    --skip-shell        Skip shell setup (zsh, oh-my-zsh)"
    echo "    --skip-fonts        Skip Nerd Font installation"
    echo "    --skip-keyd         Skip keyd installation (Caps Lock to Ctrl remap)"
    echo "    --dotfiles-repo URL Set custom dotfiles repository URL"
    echo ""
    echo -e "${BOLD}ENVIRONMENT VARIABLES:${NC}"
    echo "    DOTFILES_REPO       URL of dotfiles repository to clone"
    echo "                        Default: ${DOTFILES_REPO}"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo "    # Interactive installation"
    echo "    ./bootstrap.sh"
    echo ""
    echo "    # Fully automated installation"
    echo "    ./bootstrap.sh --yes"
    echo ""
    echo "    # Skip Docker and use custom dotfiles repo"
    echo "    ./bootstrap.sh --skip-docker --dotfiles-repo git@github.com:user/dots.git"
    echo ""
    echo -e "${BOLD}SUPPORTED OPERATING SYSTEMS:${NC}"
    echo "    - Ubuntu / Debian"
    echo "    - Fedora"
    echo "    - Arch Linux"
    echo "    - macOS"
    echo ""
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes)
                AUTO_YES=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            --skip-langs)
                SKIP_LANGS=true
                shift
                ;;
            --skip-tools)
                SKIP_TOOLS=true
                shift
                ;;
            --skip-docker)
                SKIP_DOCKER=true
                shift
                ;;
            --skip-shell)
                SKIP_SHELL=true
                shift
                ;;
            --skip-fonts)
                SKIP_FONTS=true
                shift
                ;;
            --skip-keyd)
                SKIP_KEYD=true
                shift
                ;;
            --dotfiles-repo)
                DOTFILES_REPO="$2"
                shift 2
                ;;
            --dotfiles-repo=*)
                DOTFILES_REPO="${1#*=}"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# OS Detection
# =============================================================================

detect_os() {
    print_section "Detecting Operating System"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
        SUDO_CMD=""
        print_success "Detected macOS"
    elif [ -f /etc/os-release ]; then
        source /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                OS="debian"
                PKG_MANAGER="apt"
                SUDO_CMD="sudo"
                print_success "Detected $PRETTY_NAME (Debian-based)"
                ;;
            fedora)
                OS="fedora"
                PKG_MANAGER="dnf"
                SUDO_CMD="sudo"
                print_success "Detected $PRETTY_NAME"
                ;;
            arch|manjaro|endeavouros)
                OS="arch"
                PKG_MANAGER="pacman"
                SUDO_CMD="sudo"
                print_success "Detected $PRETTY_NAME (Arch-based)"
                ;;
            *)
                # Check for debian-based via ID_LIKE
                if [[ "$ID_LIKE" == *"debian"* ]]; then
                    OS="debian"
                    PKG_MANAGER="apt"
                    SUDO_CMD="sudo"
                    print_success "Detected $PRETTY_NAME (Debian-based)"
                else
                    print_error "Unsupported distribution: $ID"
                    exit 1
                fi
                ;;
        esac
    else
        print_error "Cannot detect operating system"
        exit 1
    fi
}

# =============================================================================
# Package Manager Helpers
# =============================================================================

pkg_update() {
    print_step "Updating package manager..."
    case "$PKG_MANAGER" in
        apt)
            $SUDO_CMD apt update
            ;;
        dnf)
            $SUDO_CMD dnf check-update || true
            ;;
        pacman)
            $SUDO_CMD pacman -Sy
            ;;
        brew)
            brew update
            ;;
    esac
}

pkg_install() {
    local packages=("$@")
    print_step "Installing: ${packages[*]}"
    
    case "$PKG_MANAGER" in
        apt)
            $SUDO_CMD apt install -y "${packages[@]}"
            ;;
        dnf)
            $SUDO_CMD dnf install -y "${packages[@]}"
            ;;
        pacman)
            $SUDO_CMD pacman -S --noconfirm --needed "${packages[@]}"
            ;;
        brew)
            brew install "${packages[@]}" || true
            ;;
    esac
}

# =============================================================================
# System Dependencies
# =============================================================================

install_system_deps() {
    print_header "Installing System Dependencies"
    
    if ! confirm "Install system dependencies (git, stow, ripgrep, fzf, tmux, etc.)?"; then
        print_warning "Skipping system dependencies"
        return
    fi
    
    pkg_update
    
    case "$OS" in
        debian)
            pkg_install \
                git \
                curl \
                wget \
                stow \
                unzip \
                build-essential \
                ripgrep \
                fd-find \
                fzf \
                tmux \
                zsh \
                clang \
                clang-format \
                cmake \
                gettext \
                python3 \
                python3-pip \
                python3-venv \
                shellcheck \
                luarocks
            # Install luacheck via luarocks
            $SUDO_CMD luarocks install luacheck 2>/dev/null || true
            ;;
        fedora)
            pkg_install \
                git \
                curl \
                wget \
                stow \
                unzip \
                gcc \
                gcc-c++ \
                make \
                ripgrep \
                fd-find \
                fzf \
                tmux \
                zsh \
                clang \
                clang-tools-extra \
                cmake \
                gettext \
                python3 \
                python3-pip \
                ShellCheck \
                luarocks
            # Install luacheck via luarocks
            $SUDO_CMD luarocks install luacheck 2>/dev/null || true
            ;;
        arch)
            pkg_install \
                git \
                curl \
                wget \
                stow \
                unzip \
                base-devel \
                ripgrep \
                fd \
                fzf \
                tmux \
                zsh \
                clang \
                cmake \
                gettext \
                python \
                python-pip \
                shellcheck \
                luacheck
            ;;
        macos)
            # Check for Homebrew
            if ! command_exists brew; then
                print_step "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            pkg_install \
                git \
                curl \
                wget \
                stow \
                unzip \
                ripgrep \
                fd \
                fzf \
                tmux \
                zsh \
                cmake \
                gettext \
                python3 \
                clang-format \
                shellcheck \
                luacheck
            ;;
    esac
    
    mark_installed "System dependencies"
    print_success "System dependencies installed"
}

# =============================================================================
# Python Setup (pynvim + linters/formatters)
# =============================================================================

install_python_packages() {
    print_section "Python Packages"
    
    if ! confirm "Install Python packages (pynvim, black, ruff, yamllint)?"; then
        print_warning "Skipping Python packages"
        return
    fi
    
    print_step "Installing Python packages..."
    
    # Packages to install: pynvim (Neovim), black (formatter), ruff (linter), yamllint (YAML linter)
    local python_packages="pynvim black ruff yamllint"
    
    # Use pip with --user or system pip depending on OS
    if [[ "$OS" == "macos" ]]; then
        pip3 install --user $python_packages
    else
        # On Linux, try pip3 with --break-system-packages for newer systems
        pip3 install --user $python_packages 2>/dev/null || \
        pip3 install --user --break-system-packages $python_packages 2>/dev/null || \
        $SUDO_CMD pip3 install $python_packages
    fi
    
    mark_installed "Python: pynvim, black, ruff, yamllint"
    print_success "Python packages installed"
}

# =============================================================================
# Go Installation
# =============================================================================

install_go() {
    print_header "Installing Go"
    
    if [ "$SKIP_LANGS" = true ]; then
        print_warning "Skipping Go (--skip-langs)"
        return
    fi
    
    if command_exists go; then
        local current_version
        current_version=$(go version | awk '{print $3}' | sed 's/go//')
        print_info "Go is already installed (version $current_version)"
        
        # Compare versions - skip if current >= target
        if printf '%s\n%s\n' "$GO_VERSION" "$current_version" | sort -V | head -1 | grep -q "^$GO_VERSION$"; then
            print_success "Go version is adequate (>= $GO_VERSION)"
            return
        else
            print_warning "Go version is below target ($GO_VERSION)"
            print_step "Auto-upgrading Go..."
        fi
    else
        if ! confirm "Install Go $GO_VERSION?"; then
            print_warning "Skipping Go"
            return
        fi
    fi
    
    print_step "Downloading Go $GO_VERSION..."
    
    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) print_error "Unsupported architecture: $(uname -m)"; return ;;
    esac
    
    local os_name
    case "$OS" in
        macos) os_name="darwin" ;;
        *) os_name="linux" ;;
    esac
    
    local go_tar="go${GO_VERSION}.${os_name}-${arch}.tar.gz"
    local go_url="https://go.dev/dl/${go_tar}"
    
    # Download
    curl -fsSL -o "/tmp/${go_tar}" "$go_url"
    
    # Remove old installation and extract
    print_step "Installing Go to /usr/local/go..."
    $SUDO_CMD rm -rf /usr/local/go
    $SUDO_CMD tar -C /usr/local -xzf "/tmp/${go_tar}"
    rm "/tmp/${go_tar}"
    
    # Add to PATH for current session
    export PATH=$PATH:/usr/local/go/bin
    
    mark_installed "Go $GO_VERSION"
    print_success "Go $GO_VERSION installed to /usr/local/go"
    print_info "Add to your PATH: export PATH=\$PATH:/usr/local/go/bin"
    
    # Install Go-based linters and formatters
    install_go_tools
}

install_go_tools() {
    print_section "Go Tools (linters/formatters)"
    
    if ! command_exists go; then
        print_warning "Go not installed, skipping Go tools"
        return
    fi
    
    print_step "Installing Go-based tools..."
    
    # gopls - Go language server (installed here instead of Mason to avoid errors)
    print_step "Installing gopls..."
    go install golang.org/x/tools/gopls@latest
    
    # gofumpt - stricter gofmt
    print_step "Installing gofumpt..."
    go install mvdan.cc/gofumpt@latest
    
    # shfmt - shell formatter
    print_step "Installing shfmt..."
    go install mvdan.cc/sh/v3/cmd/shfmt@latest
    
    # golangci-lint - comprehensive Go linter
    print_step "Installing golangci-lint..."
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    
    mark_installed "Go tools: gopls, gofumpt, shfmt, golangci-lint"
    print_success "Go tools installed"
}

# =============================================================================
# Rust Installation
# =============================================================================

install_rust() {
    print_header "Installing Rust"
    
    if [ "$SKIP_LANGS" = true ]; then
        print_warning "Skipping Rust (--skip-langs)"
        return
    fi
    
    if command_exists rustc; then
        local current_version
        current_version=$(rustc --version | awk '{print $2}')
        print_info "Rust is already installed (version $current_version)"
        print_step "Updating Rust via rustup..."
        rustup update
        mark_installed "Rust (rustup update)"
        print_success "Rust updated"
    else
        if ! confirm "Install Rust via rustup?"; then
            print_warning "Skipping Rust"
            return
        fi
        
        print_step "Installing Rust via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        
        # Source cargo env for current session
        source "$HOME/.cargo/env" 2>/dev/null || true
        
        mark_installed "Rust (rustup)"
        print_success "Rust installed"
    fi
    
    # Install Rust-based tools (stylua for Lua formatting)
    install_rust_tools
}

install_rust_tools() {
    print_section "Rust Tools (linters/formatters)"
    
    if ! command_exists cargo; then
        print_warning "Cargo not installed, skipping Rust tools"
        return
    fi
    
    # Ensure rustfmt and clippy are installed (they come with rustup but verify)
    print_step "Ensuring rustfmt and clippy are installed..."
    rustup component add rustfmt clippy 2>/dev/null || true
    
    # stylua - Lua formatter
    print_step "Installing stylua (Lua formatter)..."
    cargo install stylua
    
    mark_installed "Rust tools: stylua, rustfmt, clippy"
    print_success "Rust tools installed"
}

# =============================================================================
# Node.js Installation (via nvm)
# =============================================================================

install_nodejs() {
    print_header "Installing Node.js"
    
    if [ "$SKIP_LANGS" = true ]; then
        print_warning "Skipping Node.js (--skip-langs)"
        return
    fi
    
    if ! confirm "Install Node.js via nvm?"; then
        print_warning "Skipping Node.js"
        return
    fi
    
    # Install nvm if not present
    if [ ! -d "$HOME/.nvm" ]; then
        print_step "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    else
        print_info "nvm is already installed"
    fi
    
    # Load nvm for current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS
    print_step "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
    
    mark_installed "Node.js (nvm + LTS)"
    print_success "Node.js LTS installed via nvm"
    
    # Install Node.js-based linters and formatters
    install_node_tools
}

install_node_tools() {
    print_section "Node.js Tools (linters/formatters)"
    
    if ! command_exists npm; then
        print_warning "npm not installed, skipping Node.js tools"
        return
    fi
    
    print_step "Installing Node.js-based linters and formatters..."
    
    # prettierd - faster prettier daemon
    # eslint_d - faster eslint daemon
    # jsonlint - JSON linter
    # markdownlint-cli - Markdown linter
    npm install -g @fsouza/prettierd eslint_d jsonlint markdownlint-cli
    
    mark_installed "Node.js tools: prettierd, eslint_d, jsonlint, markdownlint-cli"
    print_success "Node.js tools installed"
}

# =============================================================================
# lazygit Installation
# =============================================================================

install_lazygit() {
    print_header "Installing lazygit"
    
    if [ "$SKIP_TOOLS" = true ]; then
        print_warning "Skipping lazygit (--skip-tools)"
        return
    fi
    
    if command_exists lazygit; then
        print_info "lazygit is already installed"
        if ! confirm "Reinstall lazygit?"; then
            return
        fi
    else
        if ! confirm "Install lazygit (terminal UI for git)?"; then
            print_warning "Skipping lazygit"
            return
        fi
    fi
    
    case "$OS" in
        debian)
            # Install from GitHub releases
            print_step "Installing lazygit from GitHub releases..."
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
            $SUDO_CMD install /tmp/lazygit /usr/local/bin
            rm /tmp/lazygit.tar.gz /tmp/lazygit
            ;;
        fedora)
            $SUDO_CMD dnf copr enable -y atim/lazygit
            pkg_install lazygit
            ;;
        arch)
            pkg_install lazygit
            ;;
        macos)
            brew install lazygit
            ;;
    esac
    
    mark_installed "lazygit"
    print_success "lazygit installed"
}

# =============================================================================
# GitHub CLI Installation
# =============================================================================

install_gh() {
    print_header "Installing GitHub CLI"
    
    if [ "$SKIP_TOOLS" = true ]; then
        print_warning "Skipping GitHub CLI (--skip-tools)"
        return
    fi
    
    if command_exists gh; then
        print_info "GitHub CLI is already installed ($(gh --version | head -1))"
        return
    fi
    
    if ! confirm "Install GitHub CLI (gh)?"; then
        print_warning "Skipping GitHub CLI"
        return
    fi
    
    case "$OS" in
        debian)
            print_step "Adding GitHub CLI repository..."
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | $SUDO_CMD dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            $SUDO_CMD chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | $SUDO_CMD tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            $SUDO_CMD apt update
            pkg_install gh
            ;;
        fedora)
            $SUDO_CMD dnf install -y 'dnf-command(config-manager)'
            $SUDO_CMD dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            pkg_install gh
            ;;
        arch)
            pkg_install github-cli
            ;;
        macos)
            brew install gh
            ;;
    esac
    
    mark_installed "GitHub CLI (gh)"
    print_success "GitHub CLI installed"
}

# =============================================================================
# Docker Installation
# =============================================================================

install_docker() {
    print_header "Installing Docker"
    
    if [ "$SKIP_DOCKER" = true ]; then
        print_warning "Skipping Docker (--skip-docker)"
        return
    fi
    
    if command_exists docker; then
        print_info "Docker is already installed ($(docker --version))"
        return
    fi
    
    if ! confirm "Install Docker? (requires sudo, will add user to docker group)"; then
        print_warning "Skipping Docker"
        return
    fi
    
    case "$OS" in
        debian)
            print_step "Installing Docker via official repository..."
            # Remove old versions
            $SUDO_CMD apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
            
            # Add Docker's official GPG key
            $SUDO_CMD apt update
            $SUDO_CMD apt install -y ca-certificates curl gnupg
            $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.gpg
            
            # Add repository
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            $SUDO_CMD apt update
            $SUDO_CMD apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        fedora)
            $SUDO_CMD dnf -y install dnf-plugins-core
            $SUDO_CMD dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            $SUDO_CMD dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            $SUDO_CMD systemctl start docker
            $SUDO_CMD systemctl enable docker
            ;;
        arch)
            pkg_install docker docker-compose
            $SUDO_CMD systemctl start docker
            $SUDO_CMD systemctl enable docker
            ;;
        macos)
            print_info "On macOS, please install Docker Desktop from https://www.docker.com/products/docker-desktop"
            print_info "Or install via: brew install --cask docker"
            if confirm "Install Docker Desktop via Homebrew cask?"; then
                brew install --cask docker
            fi
            return
            ;;
    esac
    
    # Add user to docker group (Linux only)
    if [[ "$OS" != "macos" ]]; then
        print_step "Adding $USER to docker group..."
        $SUDO_CMD usermod -aG docker "$USER"
        print_warning "You may need to log out and back in for docker group changes to take effect"
    fi
    
    mark_installed "Docker"
    print_success "Docker installed"
    
    # Install hadolint for Dockerfile linting
    install_hadolint
}

# =============================================================================
# Hadolint Installation (Dockerfile linter)
# =============================================================================

install_hadolint() {
    print_section "Hadolint (Dockerfile Linter)"
    
    if command_exists hadolint; then
        print_info "hadolint is already installed"
        return
    fi
    
    print_step "Installing hadolint..."
    
    case "$OS" in
        macos)
            brew install hadolint
            ;;
        *)
            # Download binary from GitHub releases
            local arch
            case "$(uname -m)" in
                x86_64) arch="x86_64" ;;
                aarch64|arm64) arch="arm64" ;;
                *) 
                    print_warning "Unsupported architecture for hadolint: $(uname -m)"
                    return
                    ;;
            esac
            
            local hadolint_url="https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-${arch}"
            curl -fsSL -o /tmp/hadolint "$hadolint_url"
            chmod +x /tmp/hadolint
            $SUDO_CMD mv /tmp/hadolint /usr/local/bin/hadolint
            ;;
    esac
    
    mark_installed "hadolint"
    print_success "hadolint installed"
}

# =============================================================================
# Neovim Installation
# =============================================================================

install_neovim() {
    print_header "Installing Neovim"
    
    local MIN_VERSION="0.10.0"
    local need_install=false
    
    # Fetch latest version from GitHub first (needed for version comparison)
    print_step "Checking latest Neovim version..."
    local LATEST_VERSION
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -Po '"tag_name": "\K[^"]*' | sed 's/^v//')
    
    if [ -z "$LATEST_VERSION" ]; then
        print_warning "Could not fetch latest version from GitHub, will install if needed"
        LATEST_VERSION="99.99.99"  # Fallback to always consider upgrade
    else
        print_info "Latest Neovim version: v$LATEST_VERSION"
    fi
    
    if command_exists nvim; then
        local current_version
        current_version=$(nvim --version | head -1 | awk '{print $2}' | sed 's/^v//')
        print_info "Neovim is already installed (version $current_version)"
        
        # Check if current version is below minimum (0.10.0)
        if ! printf '%s\n%s\n' "$MIN_VERSION" "$current_version" | sort -V | head -1 | grep -q "^$MIN_VERSION$"; then
            print_warning "Neovim version is below minimum requirement ($MIN_VERSION)"
            print_info "Your config requires Neovim >= $MIN_VERSION for lazydev.nvim and vim.lsp.config API"
            print_step "Auto-upgrading Neovim..."
            need_install=true
        # Check if current version is at or above latest
        elif printf '%s\n%s\n' "$LATEST_VERSION" "$current_version" | sort -V | head -1 | grep -q "^$LATEST_VERSION$"; then
            print_success "Neovim is already at latest version"
            return
        else
            # Version meets minimum but is below latest - skip silently
            print_success "Neovim version is adequate (>= $MIN_VERSION)"
            return
        fi
    else
        if ! confirm "Install Neovim?"; then
            print_warning "Skipping Neovim"
            return
        fi
        need_install=true
    fi
    
    if [ "$need_install" != true ]; then
        return
    fi
    
    # Proceed with installation
    case "$OS" in
        macos)
            # Use Homebrew on macOS (provides latest stable)
            brew install neovim || brew upgrade neovim
            ;;
        *)
            # Linux: Install from GitHub releases for latest stable version
            if [ "$LATEST_VERSION" = "99.99.99" ]; then
                print_error "Cannot install without knowing latest version"
                print_info "Falling back to package manager..."
                case "$OS" in
                    debian) pkg_install neovim ;;
                    fedora) pkg_install neovim ;;
                    arch) pkg_install neovim ;;
                esac
                return
            fi
            
            local arch
            case "$(uname -m)" in
                x86_64) arch="x86_64" ;;
                aarch64|arm64) arch="aarch64" ;;
                *) 
                    print_error "Unsupported architecture: $(uname -m)"
                    print_info "Falling back to package manager..."
                    case "$OS" in
                        debian) pkg_install neovim ;;
                        fedora) pkg_install neovim ;;
                        arch) pkg_install neovim ;;
                    esac
                    return
                    ;;
            esac
            
            local nvim_tar="nvim-linux-${arch}.tar.gz"
            local nvim_url="https://github.com/neovim/neovim/releases/download/v${LATEST_VERSION}/${nvim_tar}"
            
            print_step "Downloading Neovim v${LATEST_VERSION}..."
            curl -fsSL -o "/tmp/${nvim_tar}" "$nvim_url"
            
            # Remove old installation if exists
            print_step "Installing Neovim to /opt/nvim..."
            $SUDO_CMD rm -rf /opt/nvim
            $SUDO_CMD mkdir -p /opt/nvim
            $SUDO_CMD tar -xzf "/tmp/${nvim_tar}" -C /opt/nvim --strip-components=1
            rm "/tmp/${nvim_tar}"
            
            # Create symlink to /usr/local/bin
            print_step "Creating symlink in /usr/local/bin..."
            $SUDO_CMD ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
            ;;
    esac
    
    mark_installed "Neovim"
    print_success "Neovim installed"
    
    # Verify version
    if command_exists nvim; then
        local version
        version=$(nvim --version | head -1)
        print_info "Installed: $version"
    fi
}

# =============================================================================
# Dotfiles Setup
# =============================================================================

setup_dotfiles() {
    print_header "Setting Up Dotfiles"
    
    if [ -d "$DOTFILES_DIR" ]; then
        print_info "Dotfiles directory already exists at $DOTFILES_DIR"
        if ! confirm "Re-run stow to update symlinks?"; then
            return
        fi
    else
        if ! confirm "Clone dotfiles from $DOTFILES_REPO?"; then
            print_warning "Skipping dotfiles setup"
            return
        fi
        
        print_step "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
    
    # Run install.sh if it exists
    if [ -f "$DOTFILES_DIR/install.sh" ]; then
        print_step "Running dotfiles install.sh..."
        cd "$DOTFILES_DIR"
        chmod +x install.sh
        ./install.sh
    else
        print_warning "No install.sh found in dotfiles, running stow manually..."
        cd "$DOTFILES_DIR"
        
        # Create required directories
        mkdir -p ~/.config/nvim
        mkdir -p ~/.local/bin
        
        # Stow each package
        for pkg in nvim tmux zsh scripts; do
            if [ -d "$pkg" ]; then
                print_step "Stowing $pkg..."
                stow -v --target="$HOME" "$pkg"
            fi
        done
    fi
    
    # Create secrets file from example if it doesn't exist
    if [ ! -f "$HOME/.secrets" ] && [ -f "$DOTFILES_DIR/.secrets.example" ]; then
        print_step "Creating ~/.secrets from template..."
        cp "$DOTFILES_DIR/.secrets.example" "$HOME/.secrets"
        chmod 600 "$HOME/.secrets"
        print_warning "Remember to edit ~/.secrets and add your API keys!"
    fi
    
    mark_installed "Dotfiles (stow)"
    print_success "Dotfiles setup complete"
}

# =============================================================================
# Shell Setup (zsh + oh-my-zsh)
# =============================================================================

setup_shell() {
    print_header "Setting Up Shell"
    
    if [ "$SKIP_SHELL" = true ]; then
        print_warning "Skipping shell setup (--skip-shell)"
        return
    fi
    
    # Install oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        if confirm "Install oh-my-zsh?"; then
            print_step "Installing oh-my-zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            mark_installed "oh-my-zsh"
        fi
    else
        print_info "oh-my-zsh is already installed"
    fi
    
    # Install zsh plugins
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        if confirm "Install zsh-autosuggestions plugin?"; then
            print_step "Installing zsh-autosuggestions..."
            git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
            mark_installed "zsh-autosuggestions"
        fi
    else
        print_info "zsh-autosuggestions is already installed"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        if confirm "Install zsh-syntax-highlighting plugin?"; then
            print_step "Installing zsh-syntax-highlighting..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
            mark_installed "zsh-syntax-highlighting"
        fi
    else
        print_info "zsh-syntax-highlighting is already installed"
    fi
    
    # Change default shell to zsh
    local current_shell
    current_shell=$(basename "$SHELL")
    if [ "$current_shell" != "zsh" ]; then
        if confirm "Change default shell to zsh?"; then
            print_step "Changing default shell to zsh..."
            chsh -s "$(which zsh)"
            print_warning "You'll need to log out and back in for the shell change to take effect"
            mark_installed "Default shell: zsh"
        fi
    else
        print_info "Default shell is already zsh"
    fi
    
    print_success "Shell setup complete"
}

# =============================================================================
# Nerd Font Installation
# =============================================================================

install_nerd_font() {
    print_header "Installing Nerd Font"
    
    if [ "$SKIP_FONTS" = true ]; then
        print_warning "Skipping Nerd Font (--skip-fonts)"
        return
    fi
    
    local font_dir
    case "$OS" in
        macos)
            font_dir="$HOME/Library/Fonts"
            ;;
        *)
            font_dir="$HOME/.local/share/fonts"
            ;;
    esac
    
    mkdir -p "$font_dir"
    
    # Check if already installed FIRST, before any prompts
    if ls "$font_dir"/*"$NERD_FONT"* &>/dev/null; then
        print_info "$NERD_FONT Nerd Font is already installed"
        # In --yes mode, don't reinstall existing software
        if [ "$AUTO_YES" = true ]; then
            return
        fi
        if ! confirm "Reinstall?"; then
            return
        fi
    else
        # Only prompt to install if not already present
        if ! confirm "Install $NERD_FONT Nerd Font?"; then
            print_warning "Skipping Nerd Font"
            return
        fi
    fi
    
    print_step "Downloading $NERD_FONT Nerd Font..."
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/${NERD_FONT}.zip"
    
    curl -fsSL -o "/tmp/${NERD_FONT}.zip" "$font_url"
    
    print_step "Installing font..."
    unzip -o "/tmp/${NERD_FONT}.zip" -d "$font_dir" -x "*.md" -x "*.txt" -x "LICENSE"
    rm "/tmp/${NERD_FONT}.zip"
    
    # Update font cache (Linux only)
    if [[ "$OS" != "macos" ]]; then
        print_step "Updating font cache..."
        fc-cache -fv "$font_dir"
    fi
    
    mark_installed "$NERD_FONT Nerd Font"
    print_success "$NERD_FONT Nerd Font installed"
    print_info "Remember to configure your terminal to use '$NERD_FONT Nerd Font'"
}

# =============================================================================
# Keyd Installation (Caps Lock to Ctrl)
# =============================================================================

install_keyd() {
    # Skip silently on macOS (use System Preferences instead)
    if [[ "$OS" == "macos" ]]; then
        return
    fi
    
    if [ "$SKIP_KEYD" = true ]; then
        print_warning "Skipping keyd (--skip-keyd)"
        return
    fi
    
    print_header "Installing keyd (Keyboard Remapping)"
    
    if command_exists keyd; then
        print_info "keyd is already installed"
        # Check if config exists
        if [ -f /etc/keyd/default.conf ]; then
            print_info "keyd config already exists at /etc/keyd/default.conf"
            return
        fi
    else
        if ! confirm "Install keyd (remaps Caps Lock to Ctrl)?"; then
            print_warning "Skipping keyd"
            return
        fi
        
        case "$OS" in
            arch)
                pkg_install keyd
                ;;
            fedora)
                print_step "Adding keyd COPR repository..."
                $SUDO_CMD dnf copr enable -y alternateved/keyd
                pkg_install keyd
                ;;
            debian)
                print_step "Building keyd from source..."
                
                # Install build dependencies
                $SUDO_CMD apt install -y build-essential git
                
                # Clone and build
                local KEYD_TMP="/tmp/keyd-build"
                rm -rf "$KEYD_TMP"
                git clone https://github.com/rvaiya/keyd "$KEYD_TMP"
                cd "$KEYD_TMP"
                make
                $SUDO_CMD make install
                
                # Clean up
                cd - >/dev/null
                rm -rf "$KEYD_TMP"
                ;;
        esac
    fi
    
    # Create keyd config
    print_step "Creating keyd configuration..."
    $SUDO_CMD mkdir -p /etc/keyd
    $SUDO_CMD tee /etc/keyd/default.conf > /dev/null <<EOF
[ids]
*

[main]
capslock = leftcontrol
EOF
    
    # Enable and start keyd service
    print_step "Enabling keyd service..."
    $SUDO_CMD systemctl enable keyd
    $SUDO_CMD systemctl restart keyd
    
    mark_installed "keyd (Caps Lock -> Ctrl)"
    print_success "keyd installed and configured"
    print_info "Caps Lock is now remapped to Ctrl"
}

# =============================================================================
# Neovim Post-Install (Lazy.nvim sync + Mason)
# =============================================================================

setup_neovim_plugins() {
    print_header "Setting Up Neovim Plugins"
    
    if ! command_exists nvim; then
        print_warning "Neovim not found, skipping plugin setup"
        return
    fi
    
    if ! confirm "Run Neovim headless to install plugins (Lazy.nvim), tree-sitter parsers, and LSP servers (Mason)?"; then
        print_warning "Skipping Neovim plugin setup"
        print_info "Plugins will be installed on first Neovim launch"
        return
    fi
    
    # Ensure Go and Cargo are in PATH for Mason to install LSP servers
    local NVIM_PATH="/usr/local/go/bin:$HOME/.cargo/bin:$PATH"
    
    print_step "Installing Neovim plugins via Lazy.nvim..."
    PATH="$NVIM_PATH" nvim --headless "+Lazy! sync" +qa || true
    
    print_step "Installing tree-sitter parsers..."
    PATH="$NVIM_PATH" nvim --headless "+TSUpdate" +qa || true
    
    print_step "Waiting for Mason to install LSP servers..."
    print_info "This may take a few minutes..."
    # Opening nvim triggers mason-lspconfig's ensure_installed
    # Give it 60 seconds to download and install LSP servers
    PATH="$NVIM_PATH" nvim --headless -c "sleep 60" -c "qa!" || true
    
    mark_installed "Neovim plugins (Lazy.nvim + TreeSitter)"
    print_success "Neovim plugins installed"
}

# =============================================================================
# Summary
# =============================================================================

print_summary() {
    print_header "Installation Complete!"
    
    if [ ${#INSTALLED_ITEMS[@]} -gt 0 ]; then
        echo -e "${GREEN}${BOLD}Installed:${NC}"
        for item in "${INSTALLED_ITEMS[@]}"; do
            echo -e "  ${GREEN}*${NC} $item"
        done
        echo ""
    fi
    
    echo -e "${YELLOW}${BOLD}Next Steps:${NC}"
    echo ""
    echo -e "  1. ${BLUE}Edit your secrets file:${NC}"
    echo -e "     ${CYAN}nano ~/.secrets${NC}"
    echo -e "     Add your API keys (OPENAI_API_KEY, etc.)"
    echo ""
    echo -e "  2. ${BLUE}Log out and back in${NC} for these changes to take effect:"
    echo -e "     - Default shell change (if changed to zsh)"
    echo -e "     - Docker group membership"
    echo ""
    echo -e "  3. ${BLUE}Reload your shell:${NC}"
    echo -e "     ${CYAN}source ~/.zshrc${NC}"
    echo ""
    echo -e "  4. ${BLUE}Open Neovim:${NC}"
    echo -e "     ${CYAN}nvim${NC}"
    echo -e "     Mason will automatically install remaining LSP servers"
    echo ""
    echo -e "  5. ${BLUE}Configure your terminal${NC} to use:"
    echo -e "     Font: ${CYAN}$NERD_FONT Nerd Font${NC}"
    echo ""
    
    if [[ "$DOTFILES_REPO" == *"YOUR_USERNAME"* ]]; then
        echo -e "${YELLOW}${BOLD}Important:${NC}"
        echo -e "  You're using the placeholder dotfiles repo URL."
        echo -e "  Update DOTFILES_REPO in this script or use --dotfiles-repo flag"
        echo ""
    fi
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}${BOLD}Happy coding!${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header "Development Environment Bootstrap"
    
    echo -e "${BOLD}This script will set up your development environment.${NC}"
    echo ""
    echo "Components to install:"
    echo "  - System dependencies (git, stow, ripgrep, fzf, tmux, shellcheck, etc.)"
    echo "  - Development languages (Go, Rust, Node.js)"
    echo "  - Development tools (lazygit, GitHub CLI, Docker)"
    echo "  - Linters & Formatters per language:"
    echo "      Lua: stylua, luacheck"
    echo "      Python: black, ruff, yamllint"
    echo "      JS/TS: prettierd, eslint_d"
    echo "      Go: gofumpt, golangci-lint"
    echo "      Rust: rustfmt, clippy"
    echo "      Shell: shfmt, shellcheck"
    echo "      C/C++: clang-format"
    echo "      Docker: hadolint"
    echo "      JSON/YAML/Markdown: jsonlint, markdownlint"
    echo "  - Neovim with plugins"
    echo "  - Dotfiles configuration"
    echo "  - Shell setup (zsh, oh-my-zsh, plugins)"
    echo "  - Nerd Font"
    echo "  - Keyboard remapping (Caps Lock -> Ctrl via keyd)"
    echo ""
    
    if [ "$AUTO_YES" = true ]; then
        echo -e "${YELLOW}Running in non-interactive mode (--yes)${NC}"
        echo ""
    fi
    
    if ! confirm "Continue with installation?"; then
        echo "Installation cancelled."
        exit 0
    fi
    
    # Check for dotfiles updates first (if running from existing dotfiles dir)
    check_dotfiles_update
    
    # Run installation steps
    detect_os
    install_system_deps
    install_python_packages
    install_go
    install_rust
    install_nodejs
    install_lazygit
    install_gh
    install_docker
    install_neovim
    setup_dotfiles
    setup_shell
    install_nerd_font
    install_keyd
    setup_neovim_plugins
    
    # Print summary
    print_summary
}

# Parse arguments and run
parse_args "$@"
main
