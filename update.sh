#!/bin/bash
# Update script for Claude Code Container
# This script handles rebuilding the image and restarting the container
# with the latest configuration.

set -e

echo "🔄 Updating Claude Code Container..."
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    print_error "Neither docker-compose nor docker compose plugin found!"
    exit 1
fi

print_status "Using: $COMPOSE_CMD"

# Step 1: Stop and remove existing container
echo ""
echo "📦 Step 1: Stopping existing container..."
$COMPOSE_CMD down --remove-orphans || true
print_status "Container stopped"

# Step 2: Build new image with latest Dockerfile
echo ""
echo "🔨 Step 2: Building new image..."
echo "   (This may take a few minutes...)"
$COMPOSE_CMD build --pull
print_status "Image built successfully"

# Step 3: Start container with new image
echo ""
echo "🚀 Step 3: Starting container..."
$COMPOSE_CMD up -d
print_status "Container started"

# Step 4: Wait for container to be healthy
echo ""
echo "⏳ Step 4: Waiting for container to be ready..."
sleep 5

# Check if container is running
if $COMPOSE_CMD ps | grep -q "Up"; then
    print_status "Container is running"
else
    print_error "Container failed to start!"
    echo ""
    echo "📋 Checking logs..."
    $COMPOSE_CMD logs --tail=20
    exit 1
fi

# Step 5: Verify services
echo ""
echo "🔍 Step 5: Verifying services..."

# Check SSH server
if $COMPOSE_CMD exec -T claude-code pgrep -x "sshd" > /dev/null 2>&1; then
    print_status "SSH server is running"
else
    print_warning "SSH server may not be running yet"
fi

# Check supervisor
if $COMPOSE_CMD exec -T claude-code pgrep -x "supervisord" > /dev/null 2>&1; then
    print_status "Supervisor is running"
else
    print_warning "Supervisor may not be running yet"
fi

# Check Docker CLI
if $COMPOSE_CMD exec -T claude-code which docker > /dev/null 2>&1; then
    print_status "Docker CLI is available"
else
    print_warning "Docker CLI may not be installed yet"
fi

echo ""
echo "===================================="
print_status "Update completed successfully!"
echo ""
echo "💡 Useful commands:"
echo "   ./shell.sh          # Enter container shell"
echo "   docker compose logs # View container logs"
echo "   docker compose ps   # Check container status"
echo ""
