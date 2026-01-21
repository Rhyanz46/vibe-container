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
    echo '# Show welcome message' >> /home/claude/.bashrc && \
    echo 'echo "🚀 Claude Code Dev Environment"' >> /home/claude/.bashrc && \
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
    echo '# Run setup as claude user using sudo' >> /home/claude/entrypoint.sh && \
    echo 'sudo -u claude bash -s <<"EOF"' >> /home/claude/entrypoint.sh && \
    echo '# Auto-setup SSH key if not exists' >> /home/claude/entrypoint.sh && \
    echo 'if [ ! -f /home/claude/.ssh/id_ed25519 ]; then' >> /home/claude/entrypoint.sh && \
    echo '    echo "🔑 Generating SSH key..."' >> /home/claude/entrypoint.sh && \
    echo '    ssh-keygen -t ed25519 -C "claude-code@container" -f /home/claude/.ssh/id_ed25519 -N ""' >> /home/claude/entrypoint.sh && \
    echo '    chmod 600 /home/claude/.ssh/id_ed25519' >> /home/claude/entrypoint.sh && \
    echo '    chmod 644 /home/claude/.ssh/id_ed25519.pub' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ SSH key generated!"' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo '    echo "📋 Public key (add this to GitHub/GitLab):"' >> /home/claude/entrypoint.sh && \
    echo '    cat /home/claude/.ssh/id_ed25519.pub' >> /home/claude/entrypoint.sh && \
    echo '    echo ""' >> /home/claude/entrypoint.sh && \
    echo 'else' >> /home/claude/entrypoint.sh && \
    echo '    echo "✅ SSH key already exists"' >> /home/claude/entrypoint.sh && \
    echo 'fi' >> /home/claude/entrypoint.sh && \
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
    echo '# Simple prompt (no colors to avoid Claude Code light mode issues)' >> /home/claude/entrypoint.sh && \
    echo 'export PS1="\\u@\\h:\\w\\$ "' >> /home/claude/entrypoint.sh && \
    echo 'EOF' >> /home/claude/entrypoint.sh && \
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
