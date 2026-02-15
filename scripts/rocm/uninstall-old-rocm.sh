#!/bin/bash

# ROCm Complete Uninstallation Script for Ubuntu
# Run with: sudo bash uninstall_rocm.sh

set -e

echo "=== ROCm Complete Uninstallation Script ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "[1/9] Running amdgpu-install uninstall..."
if command -v amdgpu-install &> /dev/null; then
    amdgpu-install --uninstall || true
else
    echo "amdgpu-install not found, skipping..."
fi

echo "[2/9] Removing ROCm core packages..."
apt autoremove -y rocm || true
apt autoremove -y rocm-core || true

echo "[3/9] Purging all ROCm-related packages..."
apt remove --purge -y 'rocm*' 'rock-dkms' 'hsa-rocr-dev' || true
apt remove --purge -y 'amdgpu*' 'amd*' || true

echo "[4/9] Removing kernel driver..."
apt autoremove -y amdgpu-dkms || true

echo "[5/9] Running autoremove cleanup..."
apt autoremove --purge -y

echo "[6/9] Removing ROCm directories..."
rm -rf /opt/rocm*

echo "[7/9] Removing repository files..."
rm -f /etc/apt/sources.list.d/rocm.list
rm -f /etc/apt/sources.list.d/amdgpu.list
rm -rf /etc/apt/sources.list.d/amdgpu*
rm -rf /etc/apt/sources.list.d/rocm*

echo "[8/9] Clearing package cache..."
rm -rf /var/cache/apt/*
apt clean all

echo "[9/9] Updating package lists..."
apt update

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
    reboot
else
    echo "Remember to reboot before installing a new version of ROCm!"
fi
cho ""
