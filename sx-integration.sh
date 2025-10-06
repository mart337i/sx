#!/bin/bash

# sx-integration.sh - Bash shell integration for sx
# Source this file in your ~/.bashrc to enable Ctrl+S binding

# Check if sx is available
if ! command -v sx &> /dev/null; then
    # Try to find sx in the same directory as this script
    SX_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -x "${SX_SCRIPT_DIR}/sx" ]]; then
        export PATH="${SX_SCRIPT_DIR}:${PATH}"
    else
        echo "Warning: sx command not found. Please ensure sx is in your PATH or in the same directory as this script." >&2
        return 1
    fi
fi

# Function to handle sx invocation
__sx_select() {
    local selected_cmd
    
    # Save current command line
    local current_cmd="${READLINE_LINE}"
    local current_point="${READLINE_POINT}"
    
    # Clear current line
    READLINE_LINE=""
    READLINE_POINT=0
    
    # Run sx and capture any output (though sx uses exec, so this is just for safety)
    if command -v sx &> /dev/null; then
        # Run sx in a way that it can take over the terminal
        sx
    else
        echo "sx command not found" >&2
        # Restore original command line
        READLINE_LINE="${current_cmd}"
        READLINE_POINT="${current_point}"
    fi
}

# Function to setup sx integration
setup_sx_integration() {
    # Disable terminal flow control to free up Ctrl+S
    stty -ixon 2>/dev/null || true
    
    # Try Ctrl+S first, fallback to Ctrl+X if that fails
    if bind -x '"\C-s": __sx_select' 2>/dev/null; then
        export SX_KEYBIND="Ctrl+S"
    else
        # Fallback to Ctrl+X (or user-defined key)
        local key="${SX_KEY_BINDING:-\C-x}"
        bind -x "\"${key}\": __sx_select"
        export SX_KEYBIND="${SX_KEY_BINDING:-Ctrl+X}"
    fi
    
    # Optional: Add some environment variables for sx
    export SX_FZF_OPTS="--height=60% --layout=reverse --border --preview-window=right:30%"
    
    # Optional: Define custom fzf options for sx
    if [[ -z "${FZF_DEFAULT_OPTS}" ]]; then
        export FZF_DEFAULT_OPTS="--height=40% --layout=reverse"
    fi
}

# Auto-setup on source
setup_sx_integration

# Provide manual setup function
sx_bind() {
    local key="${1:-\C-s}"
    bind -x "\"${key}\": __sx_select"
    echo "sx bound to key: ${key}"
}

# Function to show current bindings
sx_bindings() {
    echo "Current sx key bindings:"
    bind -P | grep __sx_select || echo "No sx bindings found"
    echo "Active binding: ${SX_KEYBIND:-Unknown}"
}

# Function to remove sx bindings
sx_unbind() {
    bind -r '\C-s' 2>/dev/null || true
    bind -r '\C-x' 2>/dev/null || true
    unset SX_KEYBIND
    echo "sx bindings removed"
}

# Helper function to check sx status
sx_status() {
    echo "sx Integration Status:"
    echo "====================="
    
    if command -v sx &> /dev/null; then
        echo "✓ sx command found: $(which sx)"
    else
        echo "✗ sx command not found"
    fi
    
    if command -v fzf &> /dev/null; then
        echo "✓ fzf found: $(which fzf)"
    else
        echo "✗ fzf not found (required dependency)"
    fi
    
    local servers_file="${HOME}/.config/sx/servers"
    if [[ -f "${servers_file}" ]] && [[ -s "${servers_file}" ]]; then
        local count=$(wc -l < "${servers_file}")
        echo "✓ Servers configured: ${count}"
    else
        echo "✗ No servers configured"
        echo "  Run: sx --import /path/to/filezilla.xml"
    fi
    
    echo ""
    echo "Key bindings:"
    sx_bindings
    
    echo ""
    echo "Usage:"
    echo "  ${SX_KEYBIND:-Ctrl+S/Ctrl+X} - Open sx server selector"
    echo "  sx --help - Show sx help"
    echo ""
    echo "Key binding options:"
    echo "  export SX_KEY_BINDING='\\C-o'  # Use Ctrl+O"
    echo "  export SX_KEY_BINDING='\\e[1;5P'  # Use Ctrl+F1" 
    echo "  source sx-integration.sh        # Reload with new binding"
}

# Add completion for sx command
if command -v complete &> /dev/null; then
    _sx_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local opts="--import --add --list --help --version -i -a -l -h -v"
        
        COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    }
    
    complete -F _sx_completion sx
fi

# Export functions for use in subshells
export -f __sx_select sx_bind sx_unbind sx_bindings sx_status

# Print integration status (comment out if you don't want this message)
echo "sx integration loaded. Press ${SX_KEYBIND:-Ctrl+S/Ctrl+X} to open SSH server selector."