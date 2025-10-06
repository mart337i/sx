#!/bin/bash

# test.sh - Test script for sx functionality

set -euo pipefail

echo "🧪 Testing sx functionality..."
echo "================================"

# Check if fzf is available for testing
if ! command -v fzf &> /dev/null; then
    echo "⚠️  fzf not found - some tests will be skipped"
    echo "   Install with: sudo apt install fzf"
fi

# Test 1: Help command
echo "📖 Test 1: Help command"
./sx --help > /dev/null && echo "✅ Help command works" || echo "❌ Help command failed"

# Test 2: Version command
echo "📖 Test 2: Version command"
./sx --version > /dev/null && echo "✅ Version command works" || echo "❌ Version command failed"

# Test 3: Import FileZilla XML
echo "📖 Test 3: Import FileZilla XML"
# Clean up any existing servers
rm -f ~/.config/sx/servers
./sx --import test-filezilla.xml > /dev/null && echo "✅ FileZilla import works" || echo "❌ FileZilla import failed"

# Test 4: List servers
echo "📖 Test 4: List servers"
./sx --list > /dev/null && echo "✅ List servers works" || echo "❌ List servers failed"

# Test 5: Add server manually
echo "📖 Test 5: Add server manually"
./sx --add "Test Manual" "manual.example.com" "testuser" "22" > /dev/null && echo "✅ Add server works" || echo "❌ Add server failed"

# Test 6: Check server count
echo "📖 Test 6: Check server count"
count=$(./sx --list | grep -c "Server" || true)
if [[ "$count" -eq 6 ]]; then
    echo "✅ Correct server count (6 servers)"
else
    echo "❌ Wrong server count (expected 6, got $count)"
fi

# Test 7: Check configuration directory
echo "📖 Test 7: Check configuration"
if [[ -f ~/.config/sx/servers ]] && [[ -s ~/.config/sx/servers ]]; then
    echo "✅ Configuration directory and files exist"
else
    echo "❌ Configuration directory or files missing"
fi

# Test 8: Check bash integration file
echo "📖 Test 8: Check bash integration"
if [[ -f sx-integration.sh ]]; then
    echo "✅ Bash integration file exists"
else
    echo "❌ Bash integration file missing"
fi

# Test 9: Check permissions
echo "📖 Test 9: Check permissions"
if [[ -x sx ]]; then
    echo "✅ Main script is executable"
else
    echo "❌ Main script is not executable"
fi

if [[ -x install.sh ]]; then
    echo "✅ Install script is executable"
else
    echo "❌ Install script is not executable"
fi

echo ""
echo "🎯 Test Summary"
echo "==============="
echo "All basic functionality tests completed!"
echo ""
echo "To test interactively (requires fzf):"
echo "  ./sx"
echo ""
echo "To test Ctrl+S binding:"
echo "  source sx-integration.sh"
echo "  # Then press Ctrl+S"
echo ""
echo "📦 Installation:"
echo "  ./install.sh"