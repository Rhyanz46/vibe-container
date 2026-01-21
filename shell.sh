#!/bin/bash
# Quick access script to enter Claude Code container
# Usage: ./shell.sh

CONTAINER_NAME="claude-code-container"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Container '${CONTAINER_NAME}' is not running!"
    echo ""
    echo "Starting container..."
    docker-compose up -d

    # Wait for container to be ready
    echo "Waiting for container to be ready..."
    sleep 3
fi

# Enter the container with login shell to trigger entrypoint
echo "🚀 Entering Claude Code container..."
echo ""

# Set proper TERM for color support
export TERM="${TERM:-xterm-256color}"

# Enter container with proper TERM for color support
docker exec -it -e TERM="${TERM}" ${CONTAINER_NAME} bash -l
