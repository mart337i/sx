#!/bin/bash

# install.sh - Installation script for sx
# Interactive SSH server selector with FileZilla import support

set -euo pipefail

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/sx"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing=()
    
    if ! command_exists fzf; then
        missing+=("fzf")
    fi
    
    if ! command_exists ssh; then
        missing+=("ssh")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
        echo
        echo "Please install the missing dependencies:"
        echo
        echo "Ubuntu/Debian:"
        echo "  sudo apt update && sudo apt install fzf openssh-client"
        echo
        echo "macOS (with Homebrew):"
        echo "  brew install fzf openssh"
        echo
        echo "Arch Linux:"
        echo "  sudo pacman -S fzf openssh"
        echo
        echo "CentOS/RHEL/Fedora:"
        echo "  sudo dnf install fzf openssh-clients"
        echo
        exit 1
    fi
    
    log_success "All dependencies are installed"
}

# Create necessary directories
setup_directories() {
    log_info "Setting up directories..."
    
    if [[ ! -d "${INSTALL_DIR}" ]]; then
        mkdir -p "${INSTALL_DIR}"
        log_info "Created directory: ${INSTALL_DIR}"
    fi
    
    if [[ ! -d "${CONFIG_DIR}" ]]; then
        mkdir -p "${CONFIG_DIR}"
        log_info "Created directory: ${CONFIG_DIR}"
    fi
    
    # Ensure install directory is in PATH
    if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
        log_warn "${INSTALL_DIR} is not in your PATH"
        echo "Consider adding this to your ~/.bashrc:"
        echo "export PATH=\"\${HOME}/.local/bin:\${PATH}\""
    fi
}

# Install sx files
install_files() {
    log_info "Installing sx files..."
    
    # Copy main script
    cp "${SCRIPT_DIR}/sx" "${INSTALL_DIR}/sx"
    chmod +x "${INSTALL_DIR}/sx"
    log_success "Installed sx to ${INSTALL_DIR}/sx"
    
    # Copy integration script
    cp "${SCRIPT_DIR}/sx-integration.sh" "${CONFIG_DIR}/sx-integration.sh"
    log_success "Installed integration script to ${CONFIG_DIR}/sx-integration.sh"
}

# Setup bash integration
setup_bash_integration() {
    local bashrc="${HOME}/.bashrc"
    local integration_line="source \"${CONFIG_DIR}/sx-integration.sh\""
    
    log_info "Setting up bash integration..."
    
    if [[ -f "${bashrc}" ]] && grep -q "sx-integration.sh" "${bashrc}"; then
        log_warn "sx integration already exists in ${bashrc}"
        return 0
    fi
    
    echo
    echo "Do you want to add sx integration to your ~/.bashrc? (y/N)"
    echo "This will enable a hotkey for sx (Ctrl+S or alternative if taken)."
    read -r response
    
    if [[ "${response}" =~ ^[Yy]$ ]]; then
        echo "" >> "${bashrc}"
        echo "# sx - Interactive SSH selector" >> "${bashrc}"
        echo "${integration_line}" >> "${bashrc}"
        log_success "Added sx integration to ${bashrc}"
        echo "Run 'source ~/.bashrc' or restart your terminal to activate the hotkey"
        echo ""
        echo "⚠️  If Ctrl+S doesn't work (common issue), run:"
        echo "   ./fix-keybind.sh"
    else
        log_info "Skipped bash integration setup"
        echo "To manually enable sx integration, add this line to your ~/.bashrc:"
        echo "  ${integration_line}"
    fi
}

# Create sample FileZilla XML for testing
create_sample_xml() {
    local sample_file="${CONFIG_DIR}/sample-filezilla.xml"
    
    if [[ ! -f "${sample_file}" ]]; then
        log_info "Creating sample FileZilla XML file..."
        
        cat > "${sample_file}" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<FileZilla3 version="3.60.2" platform="linux">
    <Servers>
        <Server>
            <Host>example.com</Host>
            <Port>22</Port>
            <Protocol>1</Protocol>
            <Type>0</Type>
            <User>root</User>
            <Name>Example Server</Name>
        </Server>
        <Server>
            <Host>192.168.1.100</Host>
            <Port>2222</Port>
            <Protocol>1</Protocol>
            <Type>0</Type>
            <User>admin</User>
            <Name>Local Server</Name>
        </Server>
        <Server>
            <Host>myserver.local</Host>
            <Port>22</Port>
            <Protocol>1</Protocol>
            <Type>0</Type>
            <User>deploy</User>
            <Name>Deploy Server</Name>
        </Server>
    </Servers>
</FileZilla3>
EOF
        
        log_success "Created sample FileZilla XML: ${sample_file}"
        echo "You can test sx with: sx --import \"${sample_file}\""
    fi
}

# Show post-installation instructions
show_instructions() {
    echo
    log_success "sx installation completed!"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 QUICK START"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "1. Import servers from FileZilla:"
    echo "   sx --import /path/to/filezilla/export.xml"
    echo
    echo "2. Or add servers manually:"
    echo "   sx --add \"My Server\" \"example.com\" \"user\" \"22\""
    echo
    echo "3. Use sx interactively:"
    echo "   sx                    # Opens server selector"
    echo "   Ctrl+S               # Same as above (after bash integration)"
    echo
    echo "4. Other commands:"
    echo "   sx --list            # List all servers"
    echo "   sx --help            # Show help"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📁 FILEZILLA EXPORT INSTRUCTIONS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "1. Open FileZilla"
    echo "2. Go to File → Export..."
    echo "3. Select 'Export site manager entries'"
    echo "4. Choose a location and save as XML"
    echo "5. Run: sx --import /path/to/exported/file.xml"
    echo ""
    echo "📖 For detailed documentation:"
    echo "   https://github.com/mart337i/sx"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⌨️  KEY BINDINGS (in interactive mode)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "Enter           Connect to selected server"
    echo "Ctrl+R          Reload server list"
    echo "Ctrl+E          Copy connection string to clipboard"
    echo "Esc/Ctrl+C      Cancel and exit"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ -f "${CONFIG_DIR}/sample-filezilla.xml" ]]; then
        echo
        echo "🧪 Test with sample data:"
        echo "   sx --import \"${CONFIG_DIR}/sample-filezilla.xml\""
    fi
    
    echo
    echo "📖 For more information: sx --help"
    echo
}

# Main installation function
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 sx - Interactive SSH Selector Installation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Version: ${VERSION}"
    echo
    
    check_dependencies
    setup_directories
    install_files
    setup_bash_integration
    create_sample_xml
    show_instructions
}

# Handle Ctrl+C gracefully
trap 'echo; log_error "Installation cancelled by user"; exit 1' INT

# Run main function
main "$@"