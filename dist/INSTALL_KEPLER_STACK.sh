#!/bin/bash
# Kepler Resurrection Installer - Amelia PRO-GRADE
# Target: GTX 700/600 Series on Kernel 7.0+
set -e

# Amelia (Developer): "Succinct implementation mode. Executing installation sequence."

# 1. DEPENDENCIES
sudo apt-get update
sudo apt-get install -y dkms libglvnd-dev pkg-config gcc-11 g++-11 x11-common

# 2. THE BRIDGE (DKMS SOURCE)
# Assuming 470.256.02 is already extracted to /usr/src/
if [ -d "/usr/src/nvidia-470.256.02" ]; then
    echo "Applying Aperture Bridge to DKMS source..."
    sudo patch -p1 -d /usr/src/nvidia-470.256.02/kernel < ./nvidia_aperture_bridge.patch
    sudo dkms install -m nvidia -v 470.256.02 --force
fi

# 3. BINARIES & SHIELDS
sudo cp ./nvidia-fan-curve.sh /usr/local/bin/
sudo cp ./cuda-env.sh /usr/local/bin/
sudo cp ./gcc-cuda-shield /usr/local/bin/
sudo chmod +x /usr/local/bin/nvidia-fan-curve.sh /usr/local/bin/cuda-env.sh /usr/local/bin/gcc-cuda-shield

# 4. GLVND PRIORITIZATION
sudo mkdir -p /usr/share/glvnd/egl_vendor.d /usr/share/glvnd/glx_vendor.d
echo '{"file_format_version" : "1.0.0","ICD" : {"library_path": "libEGL_nvidia.so.0"}}' | sudo tee /usr/share/glvnd/egl_vendor.d/10_nvidia.json
echo '{"file_format_version" : "1.0.0","ICD" : {"library_path": "libGLX_nvidia.so.0"}}' | sudo tee /usr/share/glvnd/glx_vendor.d/10_nvidia.json

# 5. THERMAL SERVICE
cat << 'EOF' | sudo tee /etc/systemd/system/nvidia-fan-curve.service
[Unit]
Description=NVIDIA Fan Curve Automation
After=display-manager.service

[Service]
Type=simple
ExecStart=/usr/local/bin/nvidia-fan-curve.sh
Restart=always
RestartSec=10

[Install]
WantedBy=graphical.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable nvidia-fan-curve.service

# 6. GRUB LOCKDOWN
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia.NVreg_EnableGpuFirmware=0 nvidia-drm.modeset=1 /' /etc/default/grub
sudo update-grub

echo "Amelia (Developer): Installation complete. System-wide bridge active. Reboot required."
