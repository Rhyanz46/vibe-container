#!/bin/bash
# Quick script to exec into Claude Code container
# Usage: ./exec.sh [user] [command]
#   ./exec.sh                    # Enter as default user (root)
#   ./exec.sh claude             # Enter as user 'claude'
#   ./exec.sh dev                # Enter as user 'dev'
#   ./exec.sh claude "docker ps" # Run command as user 'claude'

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

# Check if first argument is a username (claude or dev)
if [ "$1" = "claude" ] || [ "$1" = "dev" ]; then
    TARGET_USER="$1"
    shift  # Remove username from arguments

    if [ $# -eq 0 ]; then
        # No command - start interactive shell as user
        if [ -t 0 ]; then
            echo "🚀 Entering Claude Code container as '${TARGET_USER}'..."
            echo ""
        fi
        docker exec ${INTERACTIVE_FLAG} -u "${TARGET_USER}" "${CONTAINER_NAME}" bash -l
    else
        # Run command as user
        docker exec ${INTERACTIVE_FLAG} -u "${TARGET_USER}" "${CONTAINER_NAME}" bash -l -c "$@"
    fi
else
    # No username specified - use default behavior
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
fi
