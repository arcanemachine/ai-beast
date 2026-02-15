#!/bin/bash
set -e

echo "=== llama.cpp + Vulkan setup ==="

# 1) Update packages
sudo apt update
sudo apt upgrade -y

# 2) Dependencies
sudo apt install -y \
  build-essential \
  cmake \
  git \
  python3 \
  libvulkan-dev \
  vulkan-tools \
  mesa-vulkan-drivers

# 3) Vulkan check (optional)
echo "=== Vulkan devices ==="
vulkaninfo | grep -i "deviceName\|driverName" || echo "vulkaninfo failed (ok if headless/SSH)"

# 4) Get / update llama.cpp
INSTALL_DIR="$HOME/code/ai/llama.cpp"
if [ -d "$INSTALL_DIR" ]; then
  cd "$INSTALL_DIR"
  git pull
else
  git clone https://github.com/ggml-org/llama.cpp.git "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# 5) Build with Vulkan
rm -rf build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DGGML_VULKAN=ON
cmake --build build --config Release -j"$(nproc)"

echo
echo "=== DONE ==="
echo "llama-cli is here:"
echo "  $INSTALL_DIR/build/bin/llama-cli"
echo
echo "Example run (MI50 as device 1):"
echo "  cd $INSTALL_DIR"
echo "  ./build/bin/llama-cli -m /path/to/model.gguf -ngl 99 --vulkan-device 1"
echo
