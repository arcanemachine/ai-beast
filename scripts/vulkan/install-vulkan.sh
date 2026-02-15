#!/bin/bash
set -e  # Exit on error

echo "=== llama.cpp + Vulkan + AMD MI50 Setup Script ==="
echo ""

# Detect Ubuntu version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_VERSION=$VERSION_ID
    OS_CODENAME=$VERSION_CODENAME
else
    echo "Cannot detect Ubuntu version"
    exit 1
fi

echo "Detected Ubuntu $OS_VERSION ($OS_CODENAME)"
echo ""

# Update system
echo "Step 1: Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install base dependencies
echo ""
echo "Step 2: Installing build dependencies..."
sudo apt install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    wget \
    python3 \
    python3-pip \
    pkg-config \
    libvulkan-dev \
    vulkan-tools \
    mesa-vulkan-drivers

# Install Vulkan SDK based on Ubuntu version
echo ""
echo "Step 3: Installing Vulkan SDK..."

if [ "$OS_VERSION" = "24.04" ]; then
    wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo tee /etc/apt/trusted.gpg.d/lunarg.asc
    sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-noble.list http://packages.lunarg.com/vulkan/lunarg-vulkan-noble.list
elif [ "$OS_VERSION" = "22.04" ]; then
    wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo tee /etc/apt/trusted.gpg.d/lunarg.asc
    sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list
else
    echo "Installing system Vulkan packages"
fi

sudo apt update
sudo apt install -y vulkan-sdk || sudo apt install -y libvulkan1 vulkan-tools

# Install AMDVLK driver manually for MI50
echo ""
echo "Step 4: Installing AMDVLK driver for MI50..."
read -p "Install AMDVLK driver? (recommended for MI50) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    AMDVLK_DIR="$HOME/amdvlk"
    mkdir -p "$AMDVLK_DIR"
    cd "$AMDVLK_DIR"
    
    # Download latest AMDVLK .deb package
    echo "Downloading AMDVLK package..."
    AMDVLK_URL=$(curl -s https://api.github.com/repos/GPUOpen-Drivers/AMDVLK/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
    
    if [ -z "$AMDVLK_URL" ]; then
        echo "Could not find AMDVLK package. Using known version..."
        wget https://github.com/GPUOpen-Drivers/AMDVLK/releases/download/v-2024.Q4.3/amdvlk_2024.Q4.3_amd64.deb
        AMDVLK_DEB="amdvlk_2024.Q4.3_amd64.deb"
    else
        wget "$AMDVLK_URL"
        AMDVLK_DEB=$(basename "$AMDVLK_URL")
    fi
    
    # Install the package
    sudo dpkg -i "$AMDVLK_DEB" || sudo apt-get install -f -y
    
    echo "AMDVLK installed from .deb package"
    cd -
fi

# Verify Vulkan installation
echo ""
echo "Step 5: Verifying Vulkan installation..."
echo "Available Vulkan devices:"
vulkaninfo --summary || echo "Warning: vulkaninfo failed. Check your GPU drivers."

# Clone llama.cpp
echo ""
echo "Step 6: Cloning llama.cpp repository..."
INSTALL_DIR="$HOME/llama.cpp"
if [ -d "$INSTALL_DIR" ]; then
    echo "llama.cpp directory already exists. Pulling latest changes..."
    cd "$INSTALL_DIR"
    git pull
else
    git clone https://github.com/ggml-org/llama.cpp.git --depth 1 "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

git submodule update --init --recursive

# Build llama.cpp with Vulkan
echo ""
echo "Step 7: Building llama.cpp with Vulkan support..."
cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_VULKAN=ON \
    -DLLAMA_BUILD_EXAMPLES=ON \
    -DLLAMA_BUILD_SERVER=ON

echo ""
echo "Step 8: Compiling (this may take several minutes)..."
cmake --build build --config Release -j $(nproc)

# Optional: Install binaries
echo ""
echo "Step 9: Installing binaries..."
sudo cmake --install build --config Release

# Create helper script for MI50 with optimal settings
echo ""
echo "Step 10: Creating helper scripts..."

cat > "$HOME/llama-mi50.sh" << 'EOF'
#!/bin/bash
# Helper script for running llama.cpp with AMD MI50

# Uncomment to force AMDVLK driver
# export AMD_VULKAN_ICD=AMDVLK

# Run llama-cli with Vulkan
MODEL_PATH="$1"
shift

if [ -z "$MODEL_PATH" ]; then
    echo "Usage: $0 <model.gguf> [additional args]"
    exit 1
fi

llama-cli --model "$MODEL_PATH" -ngl 99 "$@"
EOF

cat > "$HOME/check-vulkan-mi50.sh" << 'EOF'
#!/bin/bash
# Check Vulkan setup for MI50

echo "=== Vulkan Devices ==="
vulkaninfo | grep -A 10 "deviceName"

echo ""
echo "=== ICD Loaders ==="
ls -la /etc/vulkan/icd.d/
cat /etc/vulkan/icd.d/*.json

echo ""
echo "=== Environment ==="
echo "AMD_VULKAN_ICD: $AMD_VULKAN_ICD"
echo "VK_ICD_FILENAMES: $VK_ICD_FILENAMES"
EOF

chmod +x "$HOME/llama-mi50.sh"
chmod +x "$HOME/check-vulkan-mi50.sh"

# Print GPU information
echo ""
echo "=== GPU Information ==="
vulkaninfo | grep -i "deviceName\|driverName\|driverInfo\|apiVersion" || true

# Test llama.cpp
echo ""
echo "=== Testing llama.cpp ==="
llama-cli --version || echo "llama-cli not in PATH. Binary location: $INSTALL_DIR/build/bin/llama-cli"

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Installation directory: $INSTALL_DIR"
echo "Binaries installed to: /usr/local/bin"
echo "Helper scripts created:"
echo "  - $HOME/llama-mi50.sh (run models)"
echo "  - $HOME/check-vulkan-mi50.sh (check GPU setup)"
echo ""
echo "To test Vulkan setup:"
echo "  $HOME/check-vulkan-mi50.sh"
echo ""
echo "To run a model:"
echo "  llama-cli --model /path/to/model.gguf -ngl 99"
echo ""
echo "Or use the helper script:"
echo "  $HOME/llama-mi50.sh /path/to/model.gguf"
