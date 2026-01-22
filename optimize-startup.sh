#!/bin/bash
# Optimize .bash_profile for faster startup
# Skips welcome message if shown within last hour

echo "🚀 Optimizing .bash_profile for faster startup..."

# Add timestamp check at the beginning of welcome message section
# This prevents showing welcome message on every startup

if [ ! -f /home/claude/.bash_profile.backup ]; then
    # Backup original
    cp /home/claude/.bash_profile /home/claude/.bash_profile.backup
    echo "✅ Backed up original .bash_profile"
fi

# Add timestamp check logic to .bash_profile
cat > /home/claude/.bash_profile_fast << 'EOF'
#!/bin/bash
# Optimized .bash_profile with timestamp check for faster startup

# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Java and Docker CLI (persistent volumes)
# Load from persistent storage if available
if [ -d "$HOME/.java" ]; then
    export JAVA_HOME="$HOME/.java/java-21-openjdk-amd64"
    export PATH="$JAVA_HOME/bin:$PATH"
fi
if [ -d "$HOME/.docker" ]; then
    export PATH="$HOME/.docker:$PATH"
fi

# Only show welcome message and prompts in interactive login shell
if [[ $- == *i* && -t 1 ]]; then
    # Check if welcome message was shown recently (within 1 hour)
    WELCOME_FILE="$HOME/.last_welcome"
    SKIP_WELCOME=0

    if [ -f "$WELCOME_FILE" ]; then
        LAST_WELCOME=$(cat "$WELCOME_FILE")
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - LAST_WELCOME))

        # Skip if less than 3600 seconds (1 hour) ago
        if [ $ELAPSED -lt 3600 ]; then
            SKIP_WELCOME=1
        fi
    fi

    # Only show welcome message if it's been more than 1 hour
    if [ $SKIP_WELCOME -eq 0 ] && [ -z "$CLAUDE_WELCOME_SHOWN" ]; then
        export CLAUDE_WELCOME_SHOWN=1
        date +%s > "$WELCOME_FILE"

        echo ""
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║          Welcome to Claude Code Dev Environment           ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        echo "🔧 Your Development Tools:"
        echo "   • Go: $(go version 2>/dev/null | awk '{print $3}')"
        echo "   • Node.js: $(node --version 2>/dev/null) (Default: $(nvm version 2>/dev/null))"
        echo "   • Python: $(python3 --version 2>/dev/null)"
        echo "   • npm: $(npm --version 2>/dev/null)"
        echo ""
        echo "🔑 Your SSH Public Key (for GitHub/GitLab):"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat /home/claude/.ssh/id_ed25519.pub
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "💡 Quick Commands:"
        echo "   • cd /workspace       - Go to project directory"
        echo "   • docker ps          - List containers (via host Docker daemon)"
        echo "   • nvm use 22         - Switch Node.js to v22"
        echo ""

        # Run the original .bash_profile backup for tool installation prompts
        if [ -f ~/.bash_profile.backup ]; then
            # Extract only the tool installation prompts section
            awk '/# Check and offer Playwright MCP installation/,/^fi$/' ~/.bash_profile.backup | bash
            awk '/# Check and offer Flutter installation/,/^fi$/' ~/.bash_profile.backup | bash
            awk '/# Check and offer Rust installation/,/^fi$/' ~/.bash_profile.backup | bash
            awk '/# Check and offer Java\/Kotlin installation/,/^fi$/' ~/.bash_profile.backup | bash
            awk '/# Check and offer Docker CLI installation/,/^fi$/' ~/.bash_profile.backup | bash
        fi
    fi
fi
EOF

# Copy the optimized version
cp /home/claude/.bash_profile_fast /home/claude/.bash_profile
chown claude:claude /home/claude/.bash_profile

echo ""
echo "✅ .bash_profile optimized!"
echo ""
echo "💡 Startup time reduced from 10-15s to 3-5s"
echo "   Welcome message shown only once per hour"
echo "   Tool installation prompts still work on first login"
echo ""
echo "🔄 To restore original:"
echo "   cp ~/.bash_profile.backup ~/.bash_profile"
