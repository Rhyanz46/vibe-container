#!/bin/bash
# Quick script to exec into Claude Code container
# Usage: ./exec.sh [command]
#   If no command provided, starts bash shell
#   Otherwise, runs the specified command

CONTAINER_NAME="claude-code-container"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Container '${CONTAINER_NAME}' is not running!"
    echo ""
    echo "Start it with:"
    echo "  docker-compose up -d"
    exit 1
fi

# Detect if running in interactive mode
if [ -t 0 ]; then
    # Interactive mode - with TTY
    INTERACTIVE_FLAG="-it"
else
    # Non-interactive mode - without TTY
    INTERACTIVE_FLAG=""
fi

# If no arguments, start interactive bash (login shell to load .bashrc)
if [ $# -eq 0 ]; then
    if [ -t 0 ]; then
        echo "🚀 Entering Claude Code container..."
        echo ""
    fi
    docker exec ${INTERACTIVE_FLAG} "${CONTAINER_NAME}" bash -l
else
    # Run the provided command (as login shell to load .bashrc)
    docker exec ${INTERACTIVE_FLAG} "${CONTAINER_NAME}" bash -l -c "$@"
fi
