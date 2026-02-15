#!/bin/bash

# ROCm 6.3.3 Installation Script for AMD MI50
# This script will install ROCm 6.3.3 (last officially supported version for MI50)
# Run this AFTER rebooting from the uninstall script

set -e  # Exit on error

echo "========================================"
echo "ROCm 6.3.3 Installation for AMD MI50"
echo "========================================"
echo ""

# Create temp directory
echo "Creating temporary directory..."
mkdir -p ~/tmp/rocm-install-6.3.3
cd ~/tmp/rocm-install-6.3.3
echo "Working directory: $(pwd)"
echo ""

# Install ROCm 6.3.3
echo "========================================"
echo "Installing ROCm 6.3.3 base packages"
echo "========================================"
echo ""

echo "Downloading ROCm 6.3.3 installer..."
wget https://repo.radeon.com/amdgpu-install/6.3.3/ubuntu/noble/amdgpu-install_6.3.60303-1_all.deb

echo "Fixing file permissions for apt..."
chmod 644 amdgpu-install_6.3.60303-1_all.deb

echo "Installing amdgpu-install package..."
sudo apt install -y ./amdgpu-install_6.3.60303-1_all.deb

echo "Updating package list..."
sudo apt update

echo "Installing Python dependencies..."
sudo apt install -y python3-setuptools python3-wheel

echo "Installing OpenSSL (needed for downloading dependencies via HTTPS when building llama.cpp)..."
sudo apt install -y libssl-dev

echo "Adding user to render and video groups..."
sudo usermod -a -G render,video $LOGNAME

echo "Installing ROCm..."
sudo apt install -y rocm

echo "ROCm 6.3.3 packages installed successfully"
echo ""

# Completion message
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "ROCm 6.3.3 is the last officially supported version for MI50."
echo "No manual gfx906 tensor files needed - full support included!"
echo ""
echo "You MUST reboot to load the new ROCm kernel modules."
echo ""
echo "After reboot, verify installation with:"
echo "  - rocminfo"
echo "  - sudo update-alternatives --display rocm"
echo ""
echo "If prompted during boot for MOK enrollment (Secure Boot),"
echo "follow the on-screen instructions to enroll the kernel module."
echo ""
echo "To free up space, you may delete the temp files downloaded to '~/tmp/rocm-install-6.3.3'."
echo ""
read -p "Reboot now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
else
    echo "Remember to reboot before using ROCm!"
fi
