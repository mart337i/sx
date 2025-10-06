#!/bin/bash

# fix-keybind.sh - Helper script to set up alternative key bindings for sx

echo "🔧 sx Key Binding Setup"
echo "======================="
echo ""
echo "Ctrl+S might be taken by terminal flow control."
echo "Let's set up an alternative key binding."
echo ""

# Function to test a key binding
test_binding() {
    local key="$1"
    local desc="$2"
    
    # Temporarily bind and test
    if bind -x "\"${key}\": echo 'Test successful'" 2>/dev/null; then
        bind -r "${key}" 2>/dev/null || true
        echo "✅ ${desc} is available"
        return 0
    else
        echo "❌ ${desc} is not available"
        return 1
    fi
}

echo "Testing available key combinations:"
echo ""

# Test various key combinations
declare -A keys=(
    ["\C-s"]="Ctrl+S"
    ["\C-x"]="Ctrl+X" 
    ["\C-o"]="Ctrl+O"
    ["\C-h"]="Ctrl+H"
    ["\e[1;5P"]="Ctrl+F1"
    ["\e[1;5Q"]="Ctrl+F2"
    ["\M-s"]="Alt+S"
    ["\M-x"]="Alt+X"
)

available_keys=()
for key_code in "${!keys[@]}"; do
    if test_binding "$key_code" "${keys[$key_code]}"; then
        available_keys+=("$key_code:${keys[$key_code]}")
    fi
done

echo ""
if [[ ${#available_keys[@]} -eq 0 ]]; then
    echo "❌ No available key combinations found"
    exit 1
fi

echo "Available key combinations:"
for i in "${!available_keys[@]}"; do
    IFS=':' read -r code desc <<< "${available_keys[$i]}"
    echo "  $((i+1))) $desc"
done

echo ""
echo -n "Choose a key combination (1-${#available_keys[@]}) [1]: "
read -r choice

# Default to 1 if empty
choice=${choice:-1}

# Validate choice
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt ${#available_keys[@]} ]]; then
    echo "❌ Invalid choice"
    exit 1
fi

# Get selected key
selected_index=$((choice-1))
IFS=':' read -r selected_code selected_desc <<< "${available_keys[$selected_index]}"

echo ""
echo "🎯 Setting up $selected_desc for sx..."

# Create/update bashrc entry
bashrc="$HOME/.bashrc"
config_line="export SX_KEY_BINDING='$selected_code'"

# Remove any existing SX_KEY_BINDING
if [[ -f "$bashrc" ]]; then
    grep -v "SX_KEY_BINDING" "$bashrc" > "$bashrc.tmp" || true
    mv "$bashrc.tmp" "$bashrc"
fi

# Add new binding
echo "" >> "$bashrc"
echo "# sx key binding configuration" >> "$bashrc"
echo "$config_line" >> "$bashrc"

echo "✅ Added $selected_desc binding to ~/.bashrc"
echo ""
echo "🔄 To activate the new binding:"
echo "   source ~/.bashrc"
echo "   source $(dirname "$0")/sx-integration.sh"
echo ""
echo "📝 Or restart your terminal"
echo ""
echo "🧪 Test the binding:"
echo "   Press $selected_desc to open sx"

# Apply immediately if possible
if [[ "$selected_code" != "\C-s" ]]; then
    # Disable flow control if using a ctrl key
    if [[ "$selected_code" =~ \\C- ]]; then
        stty -ixon 2>/dev/null || true
    fi
    
    # Try to apply the binding now
    export SX_KEY_BINDING="$selected_code"
    if source "$(dirname "$0")/sx-integration.sh" 2>/dev/null; then
        echo "🎉 Binding activated! Try pressing $selected_desc"
    fi
fi