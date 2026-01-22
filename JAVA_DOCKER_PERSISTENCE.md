# Java and Docker CLI Persistence Setup

## Overview
This document describes the changes made to add persistent storage for Java OpenJDK 21 and Docker CLI 27.3.1, keeping the Docker image size small while maintaining tool persistence across container rebuilds.

## Changes Made

### 1. docker-compose.yml
Added two new persistent volume mounts:
```yaml
# ===== OPTIONAL TOOLS (Persistent) =====
# Java OpenJDK (optional, keeps image small)
- ./data/.java:/home/claude/.java
# Docker CLI (optional, keeps image small)
- ./data/.docker:/home/claude/.docker
```

### 2. Dockerfile

#### Ownership Fix Loop (line 549)
Updated the entrypoint.sh ownership fix loop to include `.java` and `.docker`:
```bash
for dir in .claude .local .npm .nvm .ssh go .cache .mcp flutter .cargo .rustup .kotlin .java .docker workspace; do
```

#### PATH Configuration (lines 154-164)
Added Java and Docker CLI to PATH in .bashrc:
```bash
# Java environment (persistent in ~/.java)
if [ -d "$HOME/.java" ]; then
    export JAVA_HOME="$HOME/.java/java-21-openjdk-amd64"
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# Docker CLI (persistent in ~/.docker)
if [ -d "$HOME/.docker" ]; then
    export PATH="$HOME/.docker:$PATH"
fi
```

## Installation Script

Created `setup-java-docker.sh` to install Java and Docker CLI to persistent volumes after the container starts.

## Installation Steps

### 1. Build and Start Container
```bash
docker-compose down
docker-compose up -d --build
```

### 2. Install Tools to Persistent Volumes
```bash
docker exec -it claude-code-container bash
chmod +x /home/claude/workspace/setup-java-docker.sh
./setup-java-docker.sh
```

Or manually:

#### Java Installation
```bash
sudo apt-get update
sudo apt-get install -y openjdk-21-jdk
mkdir -p ~/.java
sudo cp -r /usr/lib/jvm/* ~/.java/
sudo chown -R claude:claude ~/.java
```

#### Docker CLI Installation
```bash
cd /tmp
curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz | tar xz
mkdir -p ~/.docker
sudo cp docker/docker ~/.docker/
sudo rm -rf docker docker-27.3.1.tgz
sudo chown -R claude:claude ~/.docker
```

### 3. Reload Shell Configuration
```bash
source ~/.bashrc
```

### 4. Verify Installation
```bash
java -version
docker --version
```

## Verification

After installation, verify persistence:

1. Check files exist in host directory:
   ```bash
   ls -la data/.java/
   ls -la data/.docker/
   ```

2. Verify tools work in container:
   ```bash
   docker exec claude-code-container java -version
   docker exec claude-code-container docker --version
   ```

3. Test persistence by rebuilding:
   ```bash
   docker-compose down
   docker-compose up -d
   docker exec claude-code-container java -version
   docker exec claude-code-container docker --version
   ```

## Directory Structure

```
./data/
├── .claude/              # Claude Code config
├── .local/               # Claude Code local files
├── .mcp/                 # MCP server configs
├── .npm/                 # npm cache
├── .nvm/                 # NVM and global npm packages
├── .ssh/                 # SSH keys
├── go/                   # Go workspace
├── .cache/               # Go build cache
├── flutter/              # Flutter SDK (persistent)
├── .cargo/               # Cargo packages (persistent)
├── .rustup/              # Rustup toolchains (persistent)
├── .kotlin/              # Kotlin compiler (persistent)
├── .java/                # Java OpenJDK 21 (persistent) ✨ NEW
├── .docker/              # Docker CLI 27.3.1 (persistent) ✨ NEW
└── workspace/            # Development workspace
```

## Benefits

1. **Small Image Size**: Java and Docker CLI not included in base image
2. **Persistence**: Tools survive container rebuilds
3. **Consistency**: Same approach as other dev tools (Flutter, Rust)
4. **Flexibility**: Easy to update versions by replacing files in persistent volumes

## Technical Details

### Java Installation
- **Version**: OpenJDK 21
- **Location**: `~/.java/java-21-openjdk-amd64/`
- **JAVA_HOME**: `$HOME/.java/java-21-openjdk-amd64`
- **Binaries**: `$JAVA_HOME/bin/`

### Docker CLI Installation
- **Version**: 27.3.1
- **Location**: `~/.docker/docker`
- **Static Binary**: Linux x86_64 stable release
- **Connection**: `DOCKER_HOST=tcp://localhost:2375`

## Changelog

### Version 2026.1.5
- Added persistent volume mounts for Java and Docker CLI
- Updated ownership fix loop to include `.java` and `.docker`
- Added PATH configuration for Java and Docker CLI in .bashrc
- Created setup script for easy installation

## Next Steps

After container rebuilds, Java and Docker CLI will be automatically available from the persistent volumes without reinstallation.

---

**Status**: 🚧 In Progress - Container building, tools to be installed
**Date**: 2026-01-22
