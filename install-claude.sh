#!/bin/bash
# Install Claude Code in container (if not exists)
# This is useful when volume mount doesn't have Claude Code installed

echo "📦 Installing Claude Code..."

# Check if already installed
if [ -f "$HOME/.local/bin/claude" ]; then
    echo "✅ Claude Code already installed: $($HOME/.local/bin/claude --version 2>/dev/null || echo 'version unknown')"
    exit 0
fi

# Install Claude Code
echo "⬇️  Downloading and installing..."
curl -fsSL https://claude.ai/install.sh | bash

# Verify installation
if [ -f "$HOME/.local/bin/claude" ]; then
    echo "✅ Claude Code installed successfully!"
    $HOME/.local/bin/claude --version
else
    echo "❌ Installation failed!"
    exit 1
fi
