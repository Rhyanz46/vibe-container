#!/bin/bash
# Script untuk monitoring network activity khusus claude-code-container

CONTAINER_NAME="claude-code-container"
CONTAINER_PID=$(docker inspect $CONTAINER_NAME --format='{{.State.Pid}}' 2>/dev/null)

if [ -z "$CONTAINER_PID" ]; then
    echo "❌ Container tidak ditemukan atau tidak running"
    exit 1
fi

echo "🔍 Network Monitor: $CONTAINER_NAME (PID: $CONTAINER_PID)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📊 Listening Ports:"
sudo nsenter -n -t $CONTAINER_PID ss -tuln | grep LISTEN | awk '{printf "  %-6s %s\n", $5, $1}'
echo ""

echo "🌐 Established Connections (External):"
sudo nsenter -n -t $CONTAINER_PID ss -tn | grep ESTAB | grep -v "127.0.0.1" | grep -v "172." | head -10 | awk '{printf "  %s <-> %s\n", $4, $5}'
echo ""

echo "📈 Connection Count by State:"
sudo nsenter -n -t $CONTAINER_PID ss -tan | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
echo ""

echo "🔥 Top 5 Active Remote Addresses:"
sudo nsenter -n -t $CONTAINER_PID ss -tn | grep ESTAB | awk '{print $6}' | sort | uniq -c | sort -rn | head -5
