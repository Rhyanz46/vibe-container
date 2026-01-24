#!/bin/bash
# Auto-start SSH server on container startup
# This script is stored in persistent volume and runs on every container start

echo "🔧 Starting SSH server..."

# Check if sshd is already running
if pgrep -x "sshd" > /dev/null; then
    echo "✅ SSH server already running (PID: $(pgrep -x sshd | head -1))"
else
    # Start sshd in background (no logging to avoid permission issues)
    sudo /usr/sbin/sshd

    # Wait a moment for sshd to start
    sleep 2

    # Check if sshd started successfully
    if pgrep -x "sshd" > /dev/null; then
        echo "✅ SSH server started successfully!"
        PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
        echo "📡 Listening on port ${PORT:-7721}"
        echo ""
        echo "💡 To connect from host:"
        echo "   ssh claude@localhost -p ${PORT:-7721}"
    else
        echo "❌ Failed to start SSH server"
        echo "Running config test..."
        sudo /usr/sbin/sshd -t  # Test config to show errors
        exit 1
    fi
fi
