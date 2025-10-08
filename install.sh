#!/bin/bash

# Simple installer for sx
set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/sx"

echo "Installing sx..."

# Check dependencies
if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is required. Install with:"
    echo "  Ubuntu/Debian: apt install fzf"
    echo "  macOS: brew install fzf"
    exit 1
fi

# Create directories
mkdir -p "${INSTALL_DIR}" "${CONFIG_DIR}"

# Copy files
cp sx "${INSTALL_DIR}/"
cp sx-integration.sh "${CONFIG_DIR}/"
chmod +x "${INSTALL_DIR}/sx"

# Add to PATH if needed
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
    echo "Added ~/.local/bin to PATH in ~/.bashrc"
fi

# Add integration to bashrc
if ! grep -q "sx-integration.sh" ~/.bashrc 2>/dev/null; then
    echo "source ~/.config/sx/sx-integration.sh" >> ~/.bashrc
    echo "Added sx integration to ~/.bashrc"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Restart your terminal or run:"
echo "  source ~/.bashrc"
echo ""
echo "Then press Ctrl+K to open sx"
echo ""
echo "Add servers with:"
echo "  sx --add name host user port"
echo "  sx --import filezilla-export.xml"