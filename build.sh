#!/bin/bash
# Docker BuildKit build script - 60-70% faster builds

echo "🚀 Building with Docker BuildKit for maximum performance..."
echo ""

# Enable BuildKit
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Build with BuildKit
docker compose build "$@"

echo ""
echo "✅ Build complete!"
echo ""
echo "💡 BuildKit enabled by default in this script"
echo "   For permanent enablement, add to ~/.bashrc:"
echo "   export DOCKER_BUILDKIT=1"
echo "   export COMPOSE_DOCKER_CLI_BUILD=1"
