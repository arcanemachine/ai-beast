#!/bin/bash

# ROCm 6.4.1 Installation Script for AMD MI50
# This script will install ROCm 6.4.1 (last officially supported version for MI50)
# Run this AFTER rebooting from the uninstall script

set -e  # Exit on error

echo "========================================"
echo "ROCm 6.4.1 Installation for AMD MI50"
echo "========================================"
echo ""

# Create temp directory
echo "Creating temporary directory..."
mkdir -p ~/tmp/rocm-install-6.4.1
cd ~/tmp/rocm-install-6.4.1
echo "Working directory: $(pwd)"
echo ""

# Install ROCm 6.4.1
echo "========================================"
echo "Installing ROCm 6.4.1 base packages"
echo "========================================"
echo ""

echo "Downloading ROCm 6.4.1 installer..."
wget https://repo.radeon.com/amdgpu-install/6.4.1/ubuntu/noble/amdgpu-install_6.4.60401-1_all.deb

echo "Fixing file permissions for apt..."
chmod 644 amdgpu-install_6.4.60401-1_all.deb

echo "Installing amdgpu-install package..."
sudo apt install -y ./amdgpu-install_6.4.60401-1_all.deb

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

echo "ROCm 6.4.1 packages installed successfully"
echo ""

# Step 2: Add gfx906 Tensor Files
echo "========================================"
echo "Step 2: Adding gfx906 tensor files for MI50"
echo "========================================"
echo ""

echo "Downloading ROCm 6.4 rocblas from Arch Linux repository..."
wget https://archive.archlinux.org/packages/r/rocblas/rocblas-6.4.1-1-x86_64.pkg.tar.zst

echo "Extracting rocblas archive..."
tar -xf rocblas-6.4.1-1-x86_64.pkg.tar.zst

echo "Copying gfx906 files to ROCm installation..."
sudo cp opt/rocm/lib/rocblas/library/*gfx906* /opt/rocm/lib/rocblas/library/

echo "Verifying gfx906 files were copied..."
ls -lh /opt/rocm/lib/rocblas/library/*gfx906* | head -5

echo "gfx906 tensor files added successfully"
echo ""

# Completion message
echo "========================================"
echo "Installation Complete!"
echo "========================================"
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
echo "To free up space, you may delete the temp files downloaded to '~/tmp/rocm-install-7-1'."
echo ""
read -p "Reboot now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
else
    echo "Remember to reboot before using ROCm!"
fi
