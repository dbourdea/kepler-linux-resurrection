# Project: Kepler Linux Resurrection (GTX 760 on Kernel 7.0)

## Overview
This document chronicles the successful restoration and hardening of a legacy NVIDIA GTX 760 (Kepler architecture) on Ubuntu 26.04 running Linux Kernel 7.0. Official support for this hardware ended with the 470 driver branch, which is natively incompatible with Kernel 7.0.

## Phase 1: Driver Restoration
### The Conflict
Ubuntu 26.04 dropped the `nvidia-driver-470` package. Modern drivers (535+) do not support Kepler. Kernel 7.0 introduced significant changes to memory management and GPL-only symbols that broke original 470 sources.

### The Fix
1. **Clean Slate**: Purged all modern nvidia-* packages and ghost modules.
2. **Community Patching**: Utilized the `joanbm/nvidia-470xx-linux-mainline` patchset.
3. **Iterative Compilation**: Force-compiled the `470.256.02` driver through DKMS, bridging the "symbol wall" for `migrate_vma` and `kvmalloc`.
4. **Boot Sealing**: Blacklisted `nouveau` and regenerated `initramfs` to ensure zero early-boot driver hijack.

## Phase 2: Performance Hardening (Bmad Pro-Grade)
### 1. Persistence Layer
Manually built and enabled `nvidia-persistenced` to prevent the card from cycling power states, which causes instability on modern kernels.

### 2. Auto-Reclocking Service
Created a device-aware systemd service (`nvidia-reclock.service`) that monitors /dev/nvidia0 and forces the card from its 324MHz "safe state" to its **1000MHz+ "Performance State" (0f)**.

### 3. Surgical GRUB Configuration
Applied the following parameters:
- `nvidia.NVreg_EnableGpuFirmware=0`: Disables GSP checks (unsupported on Kepler).
- `nvidia-drm.modeset=1`: Enables hardware-level modesetting for Xorg stability.
- `log_buf_len=1M`: Expanded diagnostic logging.

## Phase 3: Scraper Re-Engineering
Concurrent with the driver work, the `euler-scraper` was rebuilt from a "weasel-grade" script into a production microservice:
- **Concurrency Control**: Semaphore-based (1-instance limit).
- **Network Optimization**: Blocked media/ads (70% bandwidth reduction).
- **Stability**: Added a "Zombie-Killer" hard-timer for browser processes.

## Next Steps: CUDA Legacy Integration
- Installation of CUDA Toolkit 11.4 (Final branch with CC 3.0 support).
- Path isolation to prevent overwriting the patched 470 driver.
