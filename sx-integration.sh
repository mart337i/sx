#!/bin/bash

# sx-integration.sh - Shell integration for sx
# Source this in ~/.bashrc to enable Ctrl+K hotkey

# Ensure sx is available
if ! command -v sx &>/dev/null; then
    # Try local directory
    SX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    [[ -x "${SX_DIR}/sx" ]] && export PATH="${SX_DIR}:${PATH}"
fi

# Function to invoke sx
__sx_invoke() {
    local current_line="${READLINE_LINE}"
    local current_point="${READLINE_POINT}"
    
    READLINE_LINE=""
    READLINE_POINT=0
    
    if command -v sx &>/dev/null; then
        sx
    else
        echo "sx not found" >&2
        READLINE_LINE="${current_line}"
        READLINE_POINT="${current_point}"
    fi
}

# Set up Ctrl+K binding
setup_sx_binding() {
    # Disable flow control to free up Ctrl+S if needed
    stty -ixon 2>/dev/null || true
    
    # Use custom key if set, otherwise default to Ctrl+K
    local key="${SX_KEY_BINDING:-\C-k}"
    
    if bind -x "\"${key}\": __sx_invoke" 2>/dev/null; then
        export SX_ACTIVE_KEY="${key}"
        local key_name
        case "${key}" in
            '\C-k') key_name="Ctrl+K" ;;
            '\C-x') key_name="Ctrl+X" ;;
            '\C-s') key_name="Ctrl+S" ;;
            *) key_name="${key}" ;;
        esac
        echo "sx ready. Press ${key_name} to open SSH selector."
    else
        echo "Warning: Could not bind ${key}. Set SX_KEY_BINDING='\C-x' for alternative."
    fi
}

# Auto-setup
setup_sx_binding

# Export function
export -f __sx_invoke