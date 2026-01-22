#!/bin/bash
# Script to check GPU/Display acceleration in container

echo "================================"
echo "GPU & ACCELERATION CHECK"
echo "================================"
echo ""

echo "🖥️  Display Information:"
echo "DISPLAY: $DISPLAY"
echo "XAUTHORITY: $XAUTHORITY"
echo ""

echo "📊 DRI Devices (GPU Access):"
if ls /dev/dri/ 2>/dev/null; then
    ls -la /dev/dri/
    echo "✅ DRI devices available"
else
    echo "❌ No DRI devices found (using software rendering)"
fi
echo ""

echo "🎮 OpenGL Information:"
if command -v glxinfo &> /dev/null; then
    echo "Renderer: $(glxinfo | grep 'OpenGL renderer' | cut -d: -f2)"
    echo "Version: $(glxinfo | grep 'OpenGL version' | cut -d: -f2)"
else
    echo "glxinfo not installed"
    echo "Install with: sudo apt-get install mesa-utils"
fi
echo ""

echo "🔧 Environment Variables:"
env | grep -E "DISPLAY|XAUTHORITY|LIBGL|__GL|__NV" | sort
echo ""

echo "💡 Recommendations:"
if [ ! -d /dev/dri ]; then
    echo "⚠️  No GPU access detected"
    echo ""
    echo "Your container is using SOFTWARE RENDERING (CPU-based)."
    echo "This is normal for:"
    echo "  • WSL (Windows Subsystem for Linux)"
    echo "  • Remote servers/VMs"
    echo "  • Systems without dedicated GPU"
    echo ""
    echo "To improve performance:"
    echo "  1. Use native apps instead of GUI when possible"
    echo "  2. For browsers: use --disable-gpu flag"
    echo "  3. Enable X11 forwarding if using SSH"
    echo ""
    echo "If you DO have a GPU and want hardware acceleration:"
    echo "  • Linux: Ensure DRI devices are available"
    echo "  • NVIDIA: Install nvidia-docker2 and uncomment 'runtime: nvidia'"
    echo "  • WSL: Use WSLg (Windows 11) or X11 forwarding"
else
    echo "✅ GPU access available! Hardware acceleration should work."
fi
echo ""

echo "🧪 Test Rendering:"
if command -v glxgears &> /dev/null; then
    echo "Running glxgears (5 seconds)..."
    timeout 5 glxgears 2>&1 | tail -1
else
    echo "glxgears not installed (optional)"
fi
echo ""
