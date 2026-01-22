# Dockerfile for Claude Code on Ubuntu
# Updated for 2026 with Ubuntu 24.04 LTS, Node.js 25, and Golang 1.23
# Complete development environment for Claude Code

FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install basic dependencies and development tools
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    git \
    vim \
    nano \
    ripgrep \
    wget \
    jq \
    unzip \
    sudo \
    bash-completion \
    command-not-found \
    git-core \
    man-db \
    less \
    xz-utils \
    libssl-dev \
    nginx \
    # Playwright/browser dependencies
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2t64 \
    libpango-1.0-0 \
    libxcursor1 \
    libgtk-3-0t64 \
    libcairo2 \
    librsvg2-2 \
    libu2f-udev \
    libvulkan1 \
    python3 \
    python3-pip \
    python3-venv \
    python3-full \
    && rm -rf /var/lib/apt/lists/*

# Note: pip is already installed via python3-pip (version 24.0)
# Skipping upgrade to avoid Debian package management issues
# pip 24.0 is sufficient for most use cases

# Install Golang 1.23
RUN wget https://go.dev/dl/go1.23.5.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.23.5.linux-amd64.tar.gz && \
    rm go1.23.5.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/claude/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Create a non-root user first
RUN useradd -m -s /bin/bash claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/claude/go && \
    chown -R claude:claude /home/claude/go

# Install NVM (Node Version Manager) as non-root user
USER claude
ENV NVM_DIR="/home/claude/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Install Node.js versions: 20 (LTS), 22 (LTS), and 25 (Current)
RUN . "$NVM_DIR/nvm.sh" && \
    nvm install 20 && \
    nvm install 22 && \
    nvm install 25 && \
    nvm use 25 && \
    nvm alias default 25 && \
    npm install -g npm

USER root

# Create .bashrc configuration for non-root user
RUN echo '# Source global definitions' >> /home/claude/.bashrc && \
    echo 'if [ -f /etc/bashrc ]; then' >> /home/claude/.bashrc && \
    echo '    . /etc/bashrc' >> /home/claude/.bashrc && \
    echo 'fi' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Load NVM (Node Version Manager)' >> /home/claude/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /home/claude/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"' >> /home/claude/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \\. "$NVM_DIR/bash_completion"' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Enable bash completion' >> /home/claude/.bashrc && \
    echo 'if ! shopt -oq posix; then' >> /home/claude/.bashrc && \
    echo '  if [ -f /usr/share/bash-completion/bash_completion ]; then' >> /home/claude/.bashrc && \
    echo '    . /usr/share/bash-completion/bash_completion' >> /home/claude/.bashrc && \
    echo '  elif [ -f /etc/bash_completion ]; then' >> /home/claude/.bashrc && \
    echo '    . /etc/bash_completion' >> /home/claude/.bashrc && \
    echo '  fi' >> /home/claude/.bashrc && \
    echo 'fi' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Git completion' >> /home/claude/.bashrc && \
    echo 'if [ -f /usr/share/bash-completion/completions/git ]; then' >> /home/claude/.bashrc && \
    echo '    . /usr/share/bash-completion/completions/git' >> /home/claude/.bashrc && \
    echo 'fi' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Go completion' >> /home/claude/.bashrc && \
    echo 'complete -F _complete_go go 2>/dev/null || true' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Node.js/npm completion' >> /home/claude/.bashrc && \
    echo 'eval "$(npm completion 2>/dev/null)"' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# History settings' >> /home/claude/.bashrc && \
    echo 'export HISTSIZE=10000' >> /home/claude/.bashrc && \
    echo 'export HISTFILESIZE=20000' >> /home/claude/.bashrc && \
    echo 'export HISTCONTROL=ignoreboth:erasedups' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Shopt settings' >> /home/claude/.bashrc && \
    echo 'shopt -s histappend' >> /home/claude/.bashrc && \
    echo 'shopt -s checkwinsize' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '#Aliases' >> /home/claude/.bashrc && \
    echo 'alias ll="ls -alF"' >> /home/claude/.bashrc && \
    echo 'alias la="ls -A"' >> /home/claude/.bashrc && \
    echo 'alias l="ls -CF"' >> /home/claude/.bashrc && \
    echo 'alias cls="clear"' >> /home/claude/.bashrc && \
    echo 'alias ..="cd .."' >> /home/claude/.bashrc && \
    echo 'alias ...="cd ../.."' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Colors' >> /home/claude/.bashrc && \
    echo 'export LS_COLORS=$LS_COLORS"di=1;34:ln=1;36:ex=1;32"' >> /home/claude/.bashrc && \
    echo 'alias grep="grep --color=auto"' >> /home/claude/.bashrc && \
    echo 'alias ls="ls --color=auto"' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Go environment' >> /home/claude/.bashrc && \
    echo 'export PATH=/home/claude/go/bin:$PATH' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Colorful prompt (better for light/dark mode)' >> /home/claude/.bashrc && \
    echo 'export PROMPT_DIRTY="*"' >> /home/claude/.bashrc && \
    echo 'export PROMPT_COMMAND=''""' >> /home/claude/.bashrc && \
    echo 'function git_branch() {' >> /home/claude/.bashrc && \
    echo '    git branch 2>/dev/null | grep '"'"'^*'"'"' | sed '"'"'s/^ \\* //'"'"' | head -n1' >> /home/claude/.bashrc && \
    echo '}' >> /home/claude/.bashrc && \
    echo 'function parse_git_branch() {' >> /home/claude/.bashrc && \
    echo '    git branch 2>/dev/null | sed -e '"'"'/^[^*]/d'"'"' -e '"'"'s/* \\(.*\\)/\\1/'"'"' | head -n1' >> /home/claude/.bashrc && \
    echo '}' >> /home/claude/.bashrc && \
    echo 'export PS1="\\u@\\h:\\w\\$ "' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Container environment context' >> /home/claude/.bashrc && \
    echo 'export CONTAINER_ENV="isolated"' >> /home/claude/.bashrc && \
    echo 'export NETWORK_MODE="host"' >> /home/claude/.bashrc && \
    echo '' >> /home/claude/.bashrc && \
    echo '# Show welcome message' >> /home/claude/.bashrc && \
    echo 'echo "🚀 Claude Code Dev Environment (Container)"' >> /home/claude/.bashrc && \
    echo 'echo "==============================="' >> /home/claude/.bashrc && \
    echo 'echo "⚠️  Environment: ISOLATED CONTAINER"' >> /home/claude/.bashrc && \
    echo 'echo "ℹ️  Network Mode: Host (all ports exposed)"' >> /home/claude/.bashrc && \
    echo 'echo "ℹ️  Docker Daemon: tcp://localhost:2375 (via host)"' >> /home/claude/.bashrc && \
    echo 'echo "==============================="' >> /home/claude/.bashrc && \
    echo 'echo "Go: $(go version 2>/dev/null | awk '"'"'{print $3}'"'"')"' >> /home/claude/.bashrc && \
    echo 'echo "Node.js: $(node --version 2>/dev/null) (Default: $(nvm version 2>/dev/null))"' >> /home/claude/.bashrc && \
    echo 'echo "Python: $(python3 --version 2>/dev/null)"' >> /home/claude/.bashrc && \
    echo 'echo "pip: $(python3 -m pip --version 2>/dev/null)"' >> /home/claude/.bashrc && \
    echo 'echo "Available: $(nvm version 2>/dev/null | tr " " "\\n" | grep -v "N/A" | sort -u | tr "\\n" " ")"' >> /home/claude/.bashrc && \
    echo 'echo "npm: $(npm --version 2>/dev/null)"' >> /home/claude/.bashrc && \
    echo 'echo "nginx: $(nginx -v 2>&1 || echo \"installed\")"' >> /home/claude/.bashrc && \
    echo 'echo "Playwright: $(npx playwright --version 2>/dev/null || echo \"installed\")"' >> /home/claude/.bashrc && \
    echo 'echo "Playwright MCP: $(npm list -g playwright-mcp 2>/dev/null | grep playwright-mcp | awk '"'"'{print $2}'"'"' || echo \"installed\")"' >> /home/claude/.bashrc && \
    echo 'echo "==============================="' >> /home/claude/.bashrc && \
    echo 'echo ""' >> /home/claude/.bashrc && \
    chown -R claude:claude /home/claude/.bashrc

# Create .bash_profile for login shell (shows welcome message and installation prompts)
RUN echo '#!/bin/bash' > /home/claude/.bash_profile && \
    echo '' >> /home/claude/.bash_profile && \
    echo '# Source .bashrc if it exists' >> /home/claude/.bash_profile && \
    echo 'if [ -f ~/.bashrc ]; then' >> /home/claude/.bash_profile && \
    echo '    source ~/.bashrc' >> /home/claude/.bash_profile && \
    echo 'fi' >> /home/claude/.bash_profile && \
    echo '' >> /home/claude/.bash_profile && \
    echo '# Only show welcome message and prompts in interactive login shell' >> /home/claude/.bash_profile && \
    echo 'if [[ $- == *i* && -t 1 ]]; then' >> /home/claude/.bash_profile && \
    echo '    # Check if this is first login in this session' >> /home/claude/.bash_profile && \
    echo '    if [ -z "$CLAUDE_WELCOME_SHOWN" ]; then' >> /home/claude/.bash_profile && \
    echo '        export CLAUDE_WELCOME_SHOWN=1' >> /home/claude/.bash_profile && \
    echo '        echo ""' >> /home/claude/.bash_profile && \
    echo '        echo "╔════════════════════════════════════════════════════════════╗"' >> /home/claude/.bash_profile && \
    echo '        echo "║          Welcome to Claude Code Dev Environment           ║"' >> /home/claude/.bash_profile && \
    echo '        echo "╚════════════════════════════════════════════════════════════╝"' >> /home/claude/.bash_profile && \
    echo '        echo ""' >> /home/claude/.bash_profile && \
    echo '        echo "🔧 Your Development Tools:"' >> /home/claude/.bash_profile && \
    echo '        echo "   • Go: $(go version 2>/dev/null | awk '"'"'{print $3}'"'"')"' >> /home/claude/.bash_profile && \
    echo '        echo "   • Node.js: $(node --version 2>/dev/null) (Default: $(nvm version 2>/dev/null))"' >> /home/claude/.bash_profile && \
    echo '        echo "   • Python: $(python3 --version 2>/dev/null)"' >> /home/claude/.bash_profile && \
    echo '        echo "   • npm: $(npm --version 2>/dev/null)"' >> /home/claude/.bash_profile && \
    echo '        echo ""' >> /home/claude/.bash_profile && \
    echo '        echo "🔑 Your SSH Public Key (for GitHub/GitLab):"' >> /home/claude/.bash_profile && \
    echo '        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"' >> /home/claude/.bash_profile && \
    echo '        cat /home/claude/.ssh/id_ed25519.pub' >> /home/claude/.bash_profile && \
    echo '        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"' >> /home/claude/.bash_profile && \
    echo '        echo ""' >> /home/claude/.bash_profile && \
    echo '        echo "💡 Quick Commands:"' >> /home/claude/.bash_profile && \
    echo '        echo "   • cd /workspace       - Go to project directory"' >> /home/claude/.bash_profile && \
    echo '        echo "   • docker ps          - List containers (via host Docker daemon)"' >> /home/claude/.bash_profile && \
    echo '        echo "   • nvm use 22         - Switch Node.js to v22"' >> /home/claude/.bash_profile && \
    echo '        echo ""' >> /home/claude/.bash_profile && \
    echo '' >> /home/claude/.bash_profile && \
    echo '        # Check and offer Playwright MCP installation' >> /home/claude/.bash_profile && \
    echo '        # Load NVM first to ensure npm/npx are available' >> /home/claude/.bash_profile && \
    echo '        if [ -s "$NVM_DIR/nvm.sh" ]; then' >> /home/claude/.bash_profile && \
    echo '            . "$NVM_DIR/nvm.sh"' >> /home/claude/.bash_profile && \
    echo '        fi' >> /home/claude/.bash_profile && \
    echo '        if npm list -g playwright-mcp &> /dev/null; then' >> /home/claude/.bash_profile && \
    echo '            echo "✅ Playwright MCP already installed"' >> /home/claude/.bash_profile && \
    echo '        else' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "🎭 Playwright MCP Not Installed"' >> /home/claude/.bash_profile && \
    echo '            echo "==============================="' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "Would you like to install Playwright MCP now?"' >> /home/claude/.bash_profile && \
    echo '            echo "This enables browser automation and AI integration features."' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            read -p "Install Playwright MCP? (y/N): " -n 1 -r' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/.bash_profile && \
    echo '                echo "📦 Installing Playwright MCP..."' >> /home/claude/.bash_profile && \
    echo '                . "$NVM_DIR/nvm.sh" && nvm use 25' >> /home/claude/.bash_profile && \
    echo '                npm install -g playwright-mcp' >> /home/claude/.bash_profile && \
    echo '                echo "✅ Playwright MCP installed successfully!"' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "💡 Note: Playwright browsers (Chromium) will be downloaded on first use"' >> /home/claude/.bash_profile && \
    echo '                echo "   You can install them manually with: npx playwright install chromium"' >> /home/claude/.bash_profile && \
    echo '            else' >> /home/claude/.bash_profile && \
    echo '                echo "⏭️  Skipping Playwright MCP installation"' >> /home/claude/.bash_profile && \
    echo '                echo "   You can install it later with: npm install -g playwright-mcp"' >> /home/claude/.bash_profile && \
    echo '            fi' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '        fi' >> /home/claude/.bash_profile && \
    echo '' >> /home/claude/.bash_profile && \
    echo '        # Check and offer Flutter installation' >> /home/claude/.bash_profile && \
    echo '        # Check directory existence instead of command (more reliable for persistent storage)' >> /home/claude/.bash_profile && \
    echo '        if [ -d ~/flutter ]; then' >> /home/claude/.bash_profile && \
    echo '            echo "✅ Flutter already installed (persistent in ~/flutter)"' >> /home/claude/.bash_profile && \
    echo '        elif ! command -v flutter &> /dev/null; then' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "📱 Flutter Development"' >> /home/claude/.bash_profile && \
    echo '            echo "==========================="' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "Flutter is not installed."' >> /home/claude/.bash_profile && \
    echo '            echo "Flutter SDK for mobile, web, and desktop app development."' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            read -p "Install Flutter SDK? (y/N): " -n 1 -r' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/.bash_profile && \
    echo '                echo "📦 Installing Flutter..."' >> /home/claude/.bash_profile && \
    echo '                cd ~ && git clone https://github.com/flutter/flutter.git -b stable --depth 1' >> /home/claude/.bash_profile && \
    echo '                echo "export PATH=\"\$HOME/flutter/bin:\$PATH\"" >> ~/.bashrc' >> /home/claude/.bash_profile && \
    echo '                export PATH="$HOME/flutter/bin:$PATH"' >> /home/claude/.bash_profile && \
    echo '                flutter precache --web' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "✅ Flutter installed successfully!"' >> /home/claude/.bash_profile && \
    echo '                echo "   Version: $(flutter --version 2>&1 | head -1)"' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "🔧 Components installed:"' >> /home/claude/.bash_profile && \
    echo '                echo "   ✅ Flutter SDK (stable channel)"' >> /home/claude/.bash_profile && \
    echo '                echo "   ✅ Dart SDK (included in Flutter)"' >> /home/claude/.bash_profile && \
    echo '                echo "   ✅ Web build tools"' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "⚠️  For mobile development, additional setup needed:"' >> /home/claude/.bash_profile && \
    echo '                echo "   1. flutter doctor"' >> /home/claude/.bash_profile && \
    echo '                echo "   2. flutter doctor --android-licenses  (for Android)"' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "💡 Desktop platforms (Linux/Windows/macOS) work out of the box!"' >> /home/claude/.bash_profile && \
    echo '            else' >> /home/claude/.bash_profile && \
    echo '                echo "⏭️  Skipping Flutter installation"' >> /home/claude/.bash_profile && \
    echo '            fi' >> /home/claude/.bash_profile && \
    echo '        else' >> /home/claude/.bash_profile && \
    echo '            echo "✅ Flutter already installed: $(flutter --version 2>&1 | head -1)"' >> /home/claude/.bash_profile && \
    echo '        fi' >> /home/claude/.bash_profile && \
    echo '' >> /home/claude/.bash_profile && \
    echo '        # Check and offer Rust installation' >> /home/claude/.bash_profile && \
    echo '        # Check directory existence instead of command (more reliable for persistent storage)' >> /home/claude/.bash_profile && \
    echo '        if [ -d ~/.cargo ]; then' >> /home/claude/.bash_profile && \
    echo '            echo "✅ Rust already installed (persistent in ~/.cargo)"' >> /home/claude/.bash_profile && \
    echo '        elif ! command -v cargo &> /dev/null; then' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "🦀 Rust Development"' >> /home/claude/.bash_profile && \
    echo '            echo "====================="' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "Rust is not installed."' >> /home/claude/.bash_profile && \
    echo '            echo "Systems programming language focused on safety and performance."' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            read -p "Install Rust? (y/N): " -n 1 -r' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/.bash_profile && \
    echo '                echo "📦 Installing Rust..."' >> /home/claude/.bash_profile && \
    echo '                curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y' >> /home/claude/.bash_profile && \
    echo '                . "$HOME/.cargo/env"' >> /home/claude/.bash_profile && \
    echo '                echo "source \$HOME/.cargo/env" >> ~/.bashrc' >> /home/claude/.bash_profile && \
    echo '                echo "✅ Rust installed successfully!"' >> /home/claude/.bash_profile && \
    echo '                echo "   Cargo: $(cargo --version)"' >> /home/claude/.bash_profile && \
    echo '                echo "   Rustc: $(rustc --version)"' >> /home/claude/.bash_profile && \
    echo '            else' >> /home/claude/.bash_profile && \
    echo '                echo "⏭️  Skipping Rust installation"' >> /home/claude/.bash_profile && \
    echo '            fi' >> /home/claude/.bash_profile && \
    echo '        else' >> /home/claude/.bash_profile && \
    echo '            echo "✅ Rust already installed: $(rustc --version)"' >> /home/claude/.bash_profile && \
    echo '        fi' >> /home/claude/.bash_profile && \
    echo '' >> /home/claude/.bash_profile && \
    echo '        # Check and offer Java/Kotlin installation' >> /home/claude/.bash_profile && \
    echo '        # Java is installed in Docker image layer (system directory)' >> /home/claude/.bash_profile && \
    echo '        if ! command -v java &> /dev/null; then' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "☕ Java/Kotlin Development"' >> /home/claude/.bash_profile && \
    echo '            echo "============================="' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "Java is not installed."' >> /home/claude/.bash_profile && \
    echo '            echo "Needed for Android, backend, and enterprise development."' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            read -p "Install Java JDK (OpenJDK 21)? (y/N): " -n 1 -r' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/.bash_profile && \
    echo '                echo "📦 Installing Java..."' >> /home/claude/.bash_profile && \
    echo '                sudo apt-get update && sudo apt-get install -y openjdk-21-jdk' >> /home/claude/.bash_profile && \
    echo '                echo "✅ Java installed successfully!"' >> /home/claude/.bash_profile && \
    echo '                echo "   Java: $(java -version 2>&1 | head -1)"' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "💡 For Kotlin development, install Kotlin compiler:"' >> /home/claude/.bash_profile && \
    echo '                echo "   curl -sSL https://get.kotlinc.org | bash"' >> /home/claude/.bash_profile && \
    echo '            else' >> /home/claude/.bash_profile && \
    echo '                echo "⏭️  Skipping Java installation"' >> /home/claude/.bash_profile && \
    echo '            fi' >> /home/claude/.bash_profile && \
    echo '        else' >> /home/claude/.bash_profile && \
    echo '            echo "✅ Java already installed: $(java -version 2>&1 | head -1)"' >> /home/claude/.bash_profile && \
    echo '        fi' >> /home/claude/.bash_profile && \
    echo '        echo ""' >> /home/claude/.bash_profile && \
    echo '        # Check and offer Docker CLI installation' >> /home/claude/.bash_profile && \
    echo '        # Docker CLI is installed in /usr/local/bin (system directory)' >> /home/claude/.bash_profile && \
    echo '        if ! command -v docker &> /dev/null; then' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "🐳 Docker CLI Not Installed"' >> /home/claude/.bash_profile && \
    echo '            echo "==========================="' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            echo "Docker CLI is not installed."' >> /home/claude/.bash_profile && \
    echo '            echo "Manage host Docker containers from within the container."' >> /home/claude/.bash_profile && \
    echo '            echo "Connects to host Docker daemon via: tcp://localhost:2375"' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            read -p "Install Docker CLI? (y/N): " -n 1 -r' >> /home/claude/.bash_profile && \
    echo '            echo ""' >> /home/claude/.bash_profile && \
    echo '            if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/.bash_profile && \
    echo '                echo "📦 Installing Docker CLI..."' >> /home/claude/.bash_profile && \
    echo '                curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz | tar xz -C /tmp &&' >> /home/claude/.bash_profile && \
    echo '                sudo mv /tmp/docker/docker /usr/local/bin/ &&' >> /home/claude/.bash_profile && \
    echo '                sudo rm -rf /tmp/docker &&' >> /home/claude/.bash_profile && \
    echo '                sudo chmod +x /usr/local/bin/docker &&' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "✅ Docker CLI installed successfully!"' >> /home/claude/.bash_profile && \
    echo '                echo "   Version: $(docker --version)"' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "💡 Connected to host Docker daemon:"' >> /home/claude/.bash_profile && \
    echo '                echo "   DOCKER_HOST=$DOCKER_HOST"' >> /home/claude/.bash_profile && \
    echo '                echo ""' >> /home/claude/.bash_profile && \
    echo '                echo "Try it:"' >> /home/claude/.bash_profile && \
    echo '                echo "   docker ps          # List host containers"' >> /home/claude/.bash_profile && \
    echo '                echo "   docker images      # List host images"' >> /home/claude/.bash_profile && \
    echo '                echo "   docker compose up  # Run docker-compose"' >> /home/claude/.bash_profile && \
    echo '            else' >> /home/claude/.bash_profile && \
    echo '                echo "⏭️  Skipping Docker CLI installation"' >> /home/claude/.bash_profile && \
    echo '                echo "   You can install it later with:"' >> /home/claude/.bash_profile && \
    echo '                echo "   curl -fsSL https://get.docker.com | sh"' >> /home/claude/.bash_profile && \
    echo '            fi' >> /home/claude/.bash_profile && \
    echo '        else' >> /home/claude/.bash_profile && \
    echo '            echo "✅ Docker CLI already installed: $(docker --version)"' >> /home/claude/.bash_profile && \
    echo '            echo "   Connected to: $DOCKER_HOST"' >> /home/claude/.bash_profile && \
    echo '        fi' >> /home/claude/.bash_profile && \
    echo '        echo ""' >> /home/claude/.bash_profile && \
    echo '    fi' >> /home/claude/.bash_profile && \
    echo 'fi' >> /home/claude/.bash_profile && \
    chown -R claude:claude /home/claude/.bash_profile

# Create .inputrc for better keyboard handling
RUN echo '# Bell style' >> /home/claude/.inputrc && \
    echo 'set bell-style none' >> /home/claude/.inputrc && \
    echo '' >> /home/claude/.inputrc && \
    echo '# Completion' >> /home/claude/.inputrc && \
    echo 'set completion-ignore-case on' >> /home/claude/.inputrc && \
    echo 'set completion-map-case on' >> /home/claude/.inputrc && \
    echo 'set show-all-if-ambiguous on' >> /home/claude/.inputrc && \
    echo 'set show-all-if-unmodified on' >> /home/claude/.inputrc && \
    echo 'set page-completions on' >> /home/claude/.inputrc && \
    echo '' >> /home/claude/.inputrc && \
    echo '# History' >> /home/claude/.inputrc && \
    echo 'set history-size 10000' >> /home/claude/.inputrc && \
    echo 'set history-preserve-point on' >> /home/claude/.inputrc && \
    echo '' >> /home/claude/.inputrc && \
    echo '# Colors' >> /home/claude/.inputrc && \
    echo 'set colored-stats on' >> /home/claude/.inputrc && \
    echo 'set visible-stats on' >> /home/claude/.inputrc && \
    echo 'set mark-symlinked-directories on' >> /home/claude/.inputrc && \
    echo '' >> /home/claude/.inputrc && \
    echo '# Editing' >> /home/claude/.inputrc && \
    echo 'set editing-mode vi' >> /home/claude/.inputrc && \
    echo 'set keymap vi' >> /home/claude/.inputrc && \
    chown -R claude:claude /home/claude/.inputrc

# Set up environment for the non-root user
ENV HOME=/home/claude
ENV PATH="/home/claude/.local/bin:${PATH}"

# Create working directory and set ownership
WORKDIR /workspace
RUN chown -R claude:claude /workspace

# Create container context README for Claude AI (in home directory to avoid mount conflicts)
RUN cat > /home/claude/CONTAINER_CONTEXT.md << 'EOF'
# Container Environment Context

## ⚠️ IMPORTANT: You Are Running Inside an Isolated Container

### Environment Type
- **Containerized**: Yes, you are in a Docker container
- **Isolation**: Process, filesystem, and resource isolated from host
- **Network Mode**: Host (shares host network stack)

### Key Implications

1. **All Services Run on Host Machine**
   - Any services you start (web servers, databases, APIs) run INSIDE this container
   - To access services from OUTSIDE, they must be accessible via host network
   - Ports are automatically exposed (host network mode)

2. **Docker Access**
   - Docker CLI is available via `docker` command
   - Connects to HOST Docker daemon via: `tcp://localhost:2375`
   - You can manage host containers from inside this container
   - Example: `docker ps` shows containers running on HOST

3. **Filesystem**
   - `/workspace` is mounted from host directory
   - Changes in `/workspace` reflect on host immediately
   - All other directories are container-specific (except mounted volumes)

4. **Network**
   - Container shares host network stack
   - `localhost` in container = `localhost` on host
   - All ports are automatically exposed
   - No port mapping needed

5. **Development Workflow**
   - Code in `/workspace` - synchronized with host
   - Install dependencies inside container
   - Run services inside container
   - Access via `localhost` from host machine

### Environment Variables
- `CONTAINER_ENV=isolated` - Indicates containerized environment
- `NETWORK_MODE=host` - Host networking mode
- `DOCKER_HOST=tcp://localhost:2375` - Docker daemon connection

### Quick Reference
```bash
# Check what's running on host
docker ps

# Run a service inside container (accessible from host)
python -m http.server 8000  # Access from host: http://localhost:8000

# Build and run Docker containers on host
docker build -t myapp .
docker run -d myapp

# File operations in workspace sync to host
echo "test" > /workspace/test.txt  # Visible on host
```

### Best Practices
1. Install all dependencies inside container
2. Run development servers inside container
3. Access services via `localhost` from host
4. Use Docker CLI to manage host containers
5. Remember: Container processes ≠ Host processes (except Docker)

### Support
For issues or questions, check the main project README.
EOF
RUN chown claude:claude /home/claude/CONTAINER_CONTEXT.md

# Install Claude Code using the native installer
USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root

# Configure git for Go module downloads (use public URLs)
RUN git config --global url."https://github.com/".insteadOf "git@github.com:" && \
    go env -w GOPRIVATE= && \
    go env -w GOSUMDB=off

# Install common Go development tools (with retries for network issues)
RUN go install golang.org/x/tools/cmd/goimports@latest || true && \
    go install github.com/cweill/gotests/...@latest || true && \
    go install honnef.co/go/tools/cmd/staticcheck@latest || true

# Create cache directory for Playwright
RUN mkdir -p /home/claude/.cache && \
    chown -R claude:claude /home/claude/.cache

# Install Playwright and Playwright MCP as user claude (deferred to runtime due to build constraints)
# RUN instructions commented out - will be installed on first container start via entrypoint
# USER claude
# RUN . "$NVM_DIR/nvm.sh" && \
#     nvm use 25 && \
#     npm install -g @playwright/test && \
#     npx playwright install chromium firefox webkit && \
#     npm install -g playwright-mcp

# Create MCP configuration directory
RUN mkdir -p /home/claude/.mcp

# Create entrypoint script for auto-setup (runs as root, switches to claude for user operations)
RUN echo '#!/bin/bash' > /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Fix .ssh directory ownership if needed' >> /home/claude/entrypoint.sh && \
    echo 'mkdir -p /home/claude/.ssh' >> /home/claude/entrypoint.sh && \
    echo 'chown -R claude:claude /home/claude/.ssh 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'chmod 700 /home/claude/.ssh' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Fix /workspace ownership if it is a mounted volume' >> /home/claude/entrypoint.sh && \
    echo 'if [ -d /workspace ]; then' >> /home/claude/entrypoint.sh && \
    echo '    chown -R claude:claude /workspace 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Fix Claude Code data directories ownership to prevent permission errors' >> /home/claude/entrypoint.sh && \
    echo 'for dir in .claude .local .npm .ssh go .cache .mcp flutter .cargo .rustup .kotlin workspace; do' >> /home/claude/entrypoint.sh && \
    echo '    if [ -d /home/claude/$dir ]; then' >> /home/claude/entrypoint.sh && \
    echo '        chown -R claude:claude /home/claude/$dir 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo '    fi' >> /home/claude/entrypoint.sh && \
    echo 'done' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Fix .config directory ownership and create Flutter config directory' >> /home/claude/entrypoint.sh && \
    echo 'chown -R claude:claude /home/claude/.config 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'mkdir -p /home/claude/.config/flutter 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'chown -R claude:claude /home/claude/.config/flutter 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'chmod 755 /home/claude/.config 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'chmod 755 /home/claude/.config/flutter 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Run setup as claude user using sudo' >> /home/claude/entrypoint.sh && \
    echo 'sudo -u claude bash -s <<"EOF"' >> /home/claude/entrypoint.sh && \
    echo '# Auto-setup SSH key if not exists' >> /home/claude/entrypoint.sh && \
    echo 'if [ ! -f /home/claude/.ssh/id_ed25519 ]; then' >> /home/claude/entrypoint.sh && \
    echo '    echo "🔑 Generating SSH key..."' >> /home/claude/entrypoint.sh && \
    echo '    ssh-keygen -t ed25519 -C "claude-code@container" -f /home/claude/.ssh/id_ed25519 -N ""' >> /home/claude/entrypoint.sh && \
    echo '    chmod 600 /home/claude/.ssh/id_ed25519' >> /home/claude/entrypoint.sh && \
    echo '    chmod 644 /home/claude/.ssh/id_ed25519.pub' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ SSH key generated!"' >> /home/claude/entrypoint.sh && \
    echo 'else' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ SSH key already exists"' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Ensure SSH key files have correct permissions (fix for mounted/existing keys)' >> /home/claude/entrypoint.sh && \
    echo 'chmod 600 /home/claude/.ssh/id_ed25519 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'chmod 644 /home/claude/.ssh/id_ed25519.pub 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Fix .config directory for Flutter' >> /home/claude/entrypoint.sh && \
    echo 'mkdir -p ~/.config/flutter 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'chmod 755 ~/.config 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo 'chmod 755 ~/.config/flutter 2>/dev/null || true' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Setup git config if not exists' >> /home/claude/entrypoint.sh && \
    echo 'if [ ! -f /home/claude/.gitconfig ]; then' >> /home/claude/entrypoint.sh && \
    echo '    echo "⚙️  Setting up git config..."' >> /home/claude/entrypoint.sh && \
    echo '    git config --global user.name "Claude Code Dev"' >> /home/claude/entrypoint.sh && \
    echo '    git config --global user.email "claude-code@container"' >> /home/claude/entrypoint.sh && \
    echo '    git config --global init.defaultBranch main' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ Git config done!"' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Add git hosts to known_hosts' >> /home/claude/entrypoint.sh && \
    echo 'ssh-keyscan github.com > /home/claude/.ssh/known_hosts 2>/dev/null' >> /home/claude/entrypoint.sh && \
    echo 'ssh-keyscan gitlab.com >> /home/claude/.ssh/known_hosts 2>/dev/null' >> /home/claude/entrypoint.sh && \
    echo 'chmod 644 /home/claude/.ssh/known_hosts' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Show welcome message and SSH key' >> /home/claude/entrypoint.sh && \
    echo 'echo ""' >> /home/claude/entrypoint.sh && \
    echo 'echo "╔════════════════════════════════════════════════════════════╗"' >> /home/claude/entrypoint.sh && \
    echo 'echo "║          Welcome to Claude Code Dev Environment           ║"' >> /home/claude/entrypoint.sh && \
    echo 'echo "╚════════════════════════════════════════════════════════════╝"' >> /home/claude/entrypoint.sh && \
    echo 'echo ""' >> /home/claude/entrypoint.sh && \
    echo 'echo "🔧 Your Development Tools:"' >> /home/claude/entrypoint.sh && \
    echo 'echo "   • Go: $(go version 2>/dev/null | awk '"'"'{print $3}'"'"')"' >> /home/claude/entrypoint.sh && \
    echo 'echo "   • Node.js: $(node --version 2>/dev/null) (Default: $(nvm version 2>/dev/null))"' >> /home/claude/entrypoint.sh && \
    echo 'echo "   • Python: $(python3 --version 2>/dev/null)"' >> /home/claude/entrypoint.sh && \
    echo 'echo "   • npm: $(npm --version 2>/dev/null)"' >> /home/claude/entrypoint.sh && \
    echo 'echo ""' >> /home/claude/entrypoint.sh && \
    echo 'echo "🔑 Your SSH Public Key (for GitHub/GitLab):"' >> /home/claude/entrypoint.sh && \
    echo 'echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"' >> /home/claude/entrypoint.sh && \
    echo 'cat /home/claude/.ssh/id_ed25519.pub' >> /home/claude/entrypoint.sh && \
    echo 'echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"' >> /home/claude/entrypoint.sh && \
    echo 'echo ""' >> /home/claude/entrypoint.sh && \
    echo 'echo "💡 Quick Commands:"' >> /home/claude/entrypoint.sh && \
    echo 'echo "   • cd /workspace       - Go to project directory"' >> /home/claude/entrypoint.sh && \
    echo 'echo "   • docker ps          - List containers"' >> /home/claude/entrypoint.sh && \
    echo 'echo "   • nvm use 22         - Switch Node.js to v22"' >> /home/claude/entrypoint.sh && \
    echo 'echo ""' >> /home/claude/entrypoint.sh && \
    echo '# Check and offer Playwright MCP installation' >> /home/claude/entrypoint.sh && \
    echo 'if ! command -v npx &> /dev/null; then' >> /home/claude/entrypoint.sh && \
    echo '    echo "⚠️  npx not found. Skipping Playwright MCP installation."' >> /home/claude/entrypoint.sh && \
    echo 'elif npm list -g playwright-mcp &> /dev/null; then' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ Playwright MCP already installed"' >> /home/claude/entrypoint.sh && \
    echo 'else' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "🎭 Playwright MCP Not Installed"' >> /home/claude/entrypoint.sh && \
    echo '    echo "==============================="' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "Would you like to install Playwright MCP now?"' >> /home/claude/entrypoint.sh && \
    echo '    echo "This enables browser automation and AI integration features."' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    read -p "Install Playwright MCP? (y/N): " -n 1 -r' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/entrypoint.sh && \
    echo '        echo "📦 Installing Playwright MCP..."' >> /home/claude/entrypoint.sh && \
    echo '        . "$NVM_DIR/nvm.sh" && nvm use 25' >> /home/claude/entrypoint.sh && \
    echo '        npm install -g playwright-mcp' >> /home/claude/entrypoint.sh && \
    echo '        echo "✅ Playwright MCP installed successfully!"' >> /home/claude/entrypoint.sh && \
    echo '        echo ""' >> /home/claude/entrypoint.sh && \
    echo '        echo "💡 Note: Playwright browsers (Chromium) will be downloaded on first use"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   You can install them manually with: npx playwright install chromium"' >> /home/claude/entrypoint.sh && \
    echo '    else' >> /home/claude/entrypoint.sh && \
    echo '        echo "⏭️  Skipping Playwright MCP installation"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   You can install it later with: npm install -g playwright-mcp"' >> /home/claude/entrypoint.sh && \
    echo '    fi' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Check and offer Flutter installation' >> /home/claude/entrypoint.sh && \
    echo 'if ! command -v flutter &> /dev/null; then' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "📱 Flutter Development"' >> /home/claude/entrypoint.sh && \
    echo '    echo "==========================="' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "Flutter is not installed."' >> /home/claude/entrypoint.sh && \
    echo '    echo "Flutter SDK for mobile, web, and desktop app development."' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    read -p "Install Flutter SDK? (y/N): " -n 1 -r' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/entrypoint.sh && \
    echo '        echo "📦 Installing Flutter..."' >> /home/claude/entrypoint.sh && \
    echo '        cd ~ && git clone https://github.com/flutter/flutter.git -b stable --depth 1' >> /home/claude/entrypoint.sh && \
    echo '        echo "export PATH=\"\$HOME/flutter/bin:\$PATH\"" >> ~/.bashrc' >> /home/claude/entrypoint.sh && \
    echo '        export PATH="$HOME/flutter/bin:$PATH"' >> /home/claude/entrypoint.sh && \
    echo '        flutter precache --web' >> /home/claude/entrypoint.sh && \
    echo '        echo ""' >> /home/claude/entrypoint.sh && \
    echo '        echo "✅ Flutter installed successfully!"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   Version: $(flutter --version 2>&1 | head -1)"' >> /home/claude/entrypoint.sh && \
    echo '        echo ""' >> /home/claude/entrypoint.sh && \
    echo '        echo "🔧 Components installed:"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   ✅ Flutter SDK (stable channel)"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   ✅ Dart SDK (included in Flutter)"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   ✅ Web build tools"' >> /home/claude/entrypoint.sh && \
    echo '        echo ""' >> /home/claude/entrypoint.sh && \
    echo '        echo "⚠️  For mobile development, additional setup needed:"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   1. flutter doctor"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   2. flutter doctor --android-licenses  (for Android)"' >> /home/claude/entrypoint.sh && \
    echo '        echo ""' >> /home/claude/entrypoint.sh && \
    echo '        echo "💡 Desktop platforms (Linux/Windows/macOS) work out of the box!"' >> /home/claude/entrypoint.sh && \
    echo '    else' >> /home/claude/entrypoint.sh && \
    echo '        echo "⏭️  Skipping Flutter installation"' >> /home/claude/entrypoint.sh && \
    echo '    fi' >> /home/claude/entrypoint.sh && \
    echo 'else' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ Flutter already installed: $(flutter --version 2>&1 | head -1)"' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Check and offer Rust installation' >> /home/claude/entrypoint.sh && \
    echo 'if ! command -v cargo &> /dev/null; then' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "🦀 Rust Development"' >> /home/claude/entrypoint.sh && \
    echo '    echo "====================="' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "Rust is not installed."' >> /home/claude/entrypoint.sh && \
    echo '    echo "Systems programming language focused on safety and performance."' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    read -p "Install Rust? (y/N): " -n 1 -r' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/entrypoint.sh && \
    echo '        echo "📦 Installing Rust..."' >> /home/claude/entrypoint.sh && \
    echo '        curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y' >> /home/claude/entrypoint.sh && \
    echo '        . "$HOME/.cargo/env"' >> /home/claude/entrypoint.sh && \
    echo '        echo "source \$HOME/.cargo/env" >> ~/.bashrc' >> /home/claude/entrypoint.sh && \
    echo '        echo "✅ Rust installed successfully!"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   Cargo: $(cargo --version)"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   Rustc: $(rustc --version)"' >> /home/claude/entrypoint.sh && \
    echo '    else' >> /home/claude/entrypoint.sh && \
    echo '        echo "⏭️  Skipping Rust installation"' >> /home/claude/entrypoint.sh && \
    echo '    fi' >> /home/claude/entrypoint.sh && \
    echo 'else' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ Rust already installed: $(rustc --version)"' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Check and offer Java/Kotlin installation' >> /home/claude/entrypoint.sh && \
    echo 'if ! command -v java &> /dev/null; then' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "☕ Java/Kotlin Development"' >> /home/claude/entrypoint.sh && \
    echo '    echo "============================="' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "Java is not installed."' >> /home/claude/entrypoint.sh && \
    echo '    echo "Needed for Android, backend, and enterprise development."' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    read -p "Install Java JDK (OpenJDK 21)? (y/N): " -n 1 -r' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    if [[ $REPLY =~ ^[Yy]$ ]]; then' >> /home/claude/entrypoint.sh && \
    echo '        echo "📦 Installing Java..."' >> /home/claude/entrypoint.sh && \
    echo '        sudo apt-get update && sudo apt-get install -y openjdk-21-jdk' >> /home/claude/entrypoint.sh && \
    echo '        echo "✅ Java installed successfully!"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   Java: $(java -version 2>&1 | head -1)"' >> /home/claude/entrypoint.sh && \
    echo '        echo ""' >> /home/claude/entrypoint.sh && \
    echo '        echo "💡 For Kotlin development, install Kotlin compiler:"' >> /home/claude/entrypoint.sh && \
    echo '        echo "   curl -sSL https://get.kotlinc.org | bash"' >> /home/claude/entrypoint.sh && \
    echo '    else' >> /home/claude/entrypoint.sh && \
    echo '        echo "⏭️  Skipping Java installation"' >> /home/claude/entrypoint.sh && \
    echo '    fi' >> /home/claude/entrypoint.sh && \
    echo 'else' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ Java already installed: $(java -version 2>&1 | head -1)"' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Simple prompt (no colors to avoid Claude Code light mode issues)' >> /home/claude/entrypoint.sh && \
    echo 'export PS1="\\u@\\h:\\w\\$ "' >> /home/claude/entrypoint.sh && \
    echo 'EOF' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Fix npm cache ownership to prevent permission errors' >> /home/claude/entrypoint.sh && \
    echo 'if [ -d /home/claude/.npm ]; then' >> /home/claude/entrypoint.sh && \
    echo '    # Check if cache has root-owned files (from build)' >> /home/claude/entrypoint.sh && \
    echo '    if find /home/claude/.npm -user root -type d 2>/dev/null | grep -q .; then' >> /home/claude/entrypoint.sh && \
    echo '        echo "🔧 Fixing npm cache permissions (root-owned files detected)..."' >> /home/claude/entrypoint.sh && \
    echo '        chown -R claude:claude /home/claude/.npm' >> /home/claude/entrypoint.sh && \
    echo '        echo "✅ npm cache permissions fixed!"' >> /home/claude/entrypoint.sh && \
    echo '        echo ""' >> /home/claude/entrypoint.sh && \
    echo '    fi' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
    echo '' >> /home/claude/entrypoint.sh && \
    echo '# Execute the main command as claude user' >> /home/claude/entrypoint.sh && \
    echo 'exec sudo -u claude "$@"' >> /home/claude/entrypoint.sh && \
    chmod +x /home/claude/entrypoint.sh && \
    chown claude:claude /home/claude/entrypoint.sh

# Create default MCP config for Playwright
RUN echo '{' > /home/claude/.mcp/config.json && \
    echo '  "mcpServers": {' >> /home/claude/.mcp/config.json && \
    echo '    "playwright": {' >> /home/claude/.mcp/config.json && \
    echo '      "command": "npx",' >> /home/claude/.mcp/config.json && \
    echo '      "args": ["-y", "playwright-mcp"],' >> /home/claude/.mcp/config.json && \
    echo '      "env": {' >> /home/claude/.mcp/config.json && \
    echo '        "HEADLESS": "true"' >> /home/claude/.mcp/config.json && \
    echo '      }' >> /home/claude/.mcp/config.json && \
    echo '    }' >> /home/claude/.mcp/config.json && \
    echo '  }' >> /home/claude/.mcp/config.json && \
    echo '}' >> /home/claude/.mcp/config.json

USER root

# Verify installation and display versions
RUN echo "=== Environment Information ===" && \
    echo "Ubuntu: $(cat /etc/os-release | grep VERSION_ID)" && \
    echo "Node.js: $(node --version)" && \
    echo "npm: $(npm --version)" && \
    echo "NVM: $(. $NVM_DIR/nvm.sh && nvm --version)" && \
    echo "NVM Installed Versions: $(. $NVM_DIR/nvm.sh && nvm ls | grep -E 'v20|v22|v25' | tr '\n' ' ')" && \
    echo "Golang: $(go version)" && \
    echo "Python: $(python3 --version)" && \
    echo "pip: $(python3 -m pip --version)" && \
    echo "ripgrep: $(rg --version | head -n1)" && \
    echo "Claude Code: $(claude --version 2>/dev/null || echo 'Installation complete')" && \
    echo "Go tools: $(ls ~/go/bin/ 2>/dev/null | xargs || echo 'None installed')" && \
    echo "=============================="

# Default command - start interactive bash shell with auto-setup
ENTRYPOINT ["/home/claude/entrypoint.sh"]
CMD ["/bin/bash"]
