#!/bin/bash

# ROCm Uninstall Script
# This script will remove all previous ROCm versions

set -e  # Exit on error

echo "========================================"
echo "ROCm Uninstall Script"
echo "========================================"
echo ""

echo "Removing ROCm core packages..."
sudo apt autoremove -y rocm-core || true

echo "Removing AMDGPU DKMS..."
sudo apt autoremove -y amdgpu-dkms || true

echo "Purging amdgpu-install..."
sudo apt purge -y amdgpu-install || true

echo "Removing all HSA/HIP/LLVM/ROCm packages..."
sudo apt-get purge -y hsa* hip* llvm* rocm* || true

echo "Removing repository files..."
sudo rm -f /etc/apt/sources.list.d/rocm.list
sudo rm -f /etc/apt/sources.list.d/amdgpu.list

echo "Clearing cache..."
sudo rm -rf /var/cache/apt/*
sudo apt-get clean all
sudo apt autoremove -y

echo ""
echo "========================================"
echo "Uninstall Complete!"
echo "========================================"
echo ""
echo "You MUST reboot before installing a new version of ROCm."
echo "This ensures all old kernel modules are unloaded."
echo ""
echo "After reboot, run: ./install-rocm-x.x-mi50.sh"
echo ""
read -p "Reboot now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
else
    echo "Remember to reboot before installing a new version of ROCm!"
fi
