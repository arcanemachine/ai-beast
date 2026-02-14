#!/bin/bash
# setup-mi50-power-limit.sh - Create systemd service for 175W power limit

echo "Creating systemd service for MI50 175W power limit..."

# Create the systemd service file
sudo tee /etc/systemd/system/mi50-power-limit.service > /dev/null <<EOF
[Unit]
Description=Set MI50 Power Limit to 175W
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/opt/rocm/bin/rocm-smi --setpoweroverdrive 175
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
sudo systemctl daemon-reexec

# Enable the service
sudo systemctl enable mi50-power-limit.service

# Start the service now
sudo systemctl start mi50-power-limit.service

echo ""
echo "Service created and enabled!"
echo ""
echo "Checking status:"
sudo systemctl status mi50-power-limit.service --no-pager

echo ""
echo "Current power settings:"
/opt/rocm/bin/rocm-smi --showpower

echo ""
echo "Done! MI50s will be set to 175W on every boot."
