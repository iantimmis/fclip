#!/bin/bash
set -e

# fclip installer script
# Usage: curl -LsSf https://iantimmis.github.io/fclip/install.sh | sh

REPO="iantimmis/fclip"
INSTALL_DIR="$HOME/.local/bin"
FCLIP_DIR="$HOME/.fclip"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Detect OS and architecture
detect_platform() {
    local os arch
    
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    
    case "$os" in
        linux) OS="linux" ;;
        darwin) OS="macos" ;;
        *) error "Unsupported operating system: $os" ;;
    esac
    
    case "$arch" in
        x86_64|amd64) ARCH="x86_64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $arch" ;;
    esac
    
    info "Detected platform: $OS-$ARCH"
}

# Get latest release version
get_latest_version() {
    info "Fetching latest version..."
    
    if command -v curl >/dev/null 2>&1; then
        VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    elif command -v wget >/dev/null 2>&1; then
        VERSION=$(wget -qO- "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    else
        error "Neither curl nor wget is available"
    fi
    
    if [ -z "$VERSION" ]; then
        error "Failed to get latest version"
    fi
    
    info "Latest version: $VERSION"
}

# Download and extract
download_fclip() {
    local url="https://github.com/$REPO/archive/$VERSION.tar.gz"
    local temp_dir=$(mktemp -d)
    local archive="$temp_dir/fclip.tar.gz"
    
    info "Downloading fclip $VERSION..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$archive" "$url" || error "Download failed"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$archive" "$url" || error "Download failed"
    fi
    
    info "Extracting archive..."
    tar -xzf "$archive" -C "$temp_dir" || error "Extraction failed"
    
    # Find the extracted directory (name format: fclip-version)
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -name "fclip-*" -type d | head -1)
    
    if [ -z "$extracted_dir" ]; then
        error "Could not find extracted directory"
    fi
    
    EXTRACTED_DIR="$extracted_dir"
    TEMP_DIR="$temp_dir"
}

# Install fclip
install_fclip() {
    info "Installing fclip to $INSTALL_DIR..."
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy scripts
    local src_dir="$EXTRACTED_DIR/src"
    if [ ! -d "$src_dir" ]; then
        error "Source directory not found: $src_dir"
    fi
    
    for script in fcopy fpaste fcut fstatus fclear; do
        if [ -f "$src_dir/$script" ]; then
            cp "$src_dir/$script" "$INSTALL_DIR/"
            chmod +x "$INSTALL_DIR/$script"
            info "Installed $script"
        else
            error "Script not found: $src_dir/$script"
        fi
    done
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    success "fclip installed successfully!"
}

# Check if PATH is configured
check_path() {
    if echo "$PATH" | grep -q "$INSTALL_DIR"; then
        success "fclip is ready to use!"
    else
        warn "Add $INSTALL_DIR to your PATH to use fclip"
        echo ""
        echo "Add this line to your shell configuration file:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        echo "For bash: ~/.bashrc or ~/.bash_profile"
        echo "For zsh: ~/.zshrc"
        echo "For fish: ~/.config/fish/config.fish"
    fi
}

# Show usage
show_usage() {
    echo ""
    echo "Usage:"
    echo "  fcopy <file_or_directory>  - Copy to clipboard"
    echo "  fpaste                     - Paste from clipboard"
    echo "  fcut <file_or_directory>   - Move via clipboard"
    echo "  fstatus                    - Show clipboard contents"
    echo "  fclear                     - Clear clipboard"
    echo ""
}

# Main installation flow
main() {
    echo ""
    echo "🗂️  fclip installer"
    echo ""
    
    # Check for required commands
    if ! command -v tar >/dev/null 2>&1; then
        error "tar is required but not installed"
    fi
    
    detect_platform
    get_latest_version
    download_fclip
    install_fclip
    check_path
    show_usage
    
    echo "Happy file clipping! 📋"
}

# Run main function
main "$@"