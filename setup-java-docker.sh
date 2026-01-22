#!/bin/bash
# Script to install Java and Docker CLI to persistent volumes

echo "🔧 Setting up Java and Docker CLI in persistent volumes..."

# Install Java OpenJDK 21 to persistent volume
echo ""
echo "📦 Installing Java OpenJDK 21 to ~/.java..."
if [ ! -d ~/.java ]; then
    sudo apt-get update
    sudo apt-get install -y openjdk-21-jdk

    # Create persistent directory
    mkdir -p ~/.java

    # Copy Java installation to persistent volume
    sudo cp -r /usr/lib/jvm/* ~/.java/
    sudo chown -R claude:claude ~/.java

    echo "✅ Java installed to ~/.java/"
else
    echo "✅ Java already exists in ~/.java/"
fi

# Install Docker CLI to persistent volume
echo ""
echo "📦 Installing Docker CLI to ~/.docker..."
if [ ! -d ~/.docker ]; then
    cd /tmp
    curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz | tar xz

    # Create persistent directory
    mkdir -p ~/.docker

    # Copy Docker CLI to persistent volume
    sudo cp docker/docker ~/.docker/
    sudo rm -rf docker docker-27.3.1.tgz
    sudo chown -R claude:claude ~/.docker

    echo "✅ Docker CLI installed to ~/.docker/"
else
    echo "✅ Docker CLI already exists in ~/.docker/"
fi

echo ""
echo "🎉 Java and Docker CLI setup complete!"
echo ""
echo "Please restart your shell or run:"
echo "  source ~/.bashrc"
echo ""
echo "Then verify with:"
echo "  java -version"
echo "  docker --version"
