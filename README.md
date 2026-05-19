# Project: Kepler Linux Resurrection (GTX 760 on Kernel 7.0)

![NVIDIA GeForce GTX 760](gtx760.jpg)

## Overview
This document chronicles the successful restoration and hardening of a legacy NVIDIA GTX 760 (Kepler architecture) on Ubuntu 26.04 running Linux Kernel 7.0. Official support for this hardware ended with the 470 driver branch, which is natively incompatible with Kernel 7.0.

## Hardware Specifications (GK104)
| Component | Specification |
| :--- | :--- |
| **GPU Chip** | GK104 (Kepler Architecture) |
| **CUDA Cores** | 1,152 |
| **VRAM** | 2 GB GDDR5 (256-bit interface) |
| **Base / Boost Clock** | 980 MHz / 1,033 MHz |
| **TDP** | 170W |
| **Release Date** | June 2013 |
| **Compute Capability** | 3.0 |

## Phase 1: Driver Restoration
### The Conflict
Ubuntu 26.04 dropped the `nvidia-driver-470` package. Modern drivers (535+) do not support Kepler. Kernel 7.0 introduced significant changes to memory management and GPL-only symbols that broke original 470 sources.

### The Fix
1. **Clean Slate**: Purged all modern `nvidia-*` packages and ghost modules.
2. **Community Patching**: Utilized the `joanbm/nvidia-470xx-linux-mainline` patchset.
3. **Iterative Compilation**: Force-compiled the `470.256.02` driver through DKMS, bridging the "symbol wall" for `migrate_vma` and `kvmalloc`.
4. **The Aperture Bridge**: Surgically injected C code using `aperture_remove_conflicting_pci_devices` into `nvidia-drm-drv.c` to fix the structural black-screen failure on Kernel 7.0.
5. **Boot Sealing**: Blacklisted `nouveau` and regenerated `initramfs`.

## Phase 2: Performance & Desktop Hardening
### 1. Persistence Layer
Manually built and enabled `nvidia-persistenced` to prevent the card from cycling power states.

### 2. Auto-Reclocking Service
Created a device-aware systemd service (`nvidia-reclock.service`) that monitors `/dev/nvidia0` and forces the card into its **1000MHz+ "Performance State" (0f)**.

### 3. Thermal Guardrails (V2.1)
Deployed an automated fan-curve service (`nvidia-fan-curve.sh`) that dynamically adjusts fan speed (30% @ 40C to 100% @ 80C) to safely maintain the high-performance clock state.

### 4. GLVND Prioritization
Created explicit ICD manifests in `/usr/share/glvnd/` to force the system to use NVIDIA GLX/EGL libraries, resolving the GNOME login loop and `libnvidia-glcore.so` segfaults.

## Phase 3: CUDA Legacy Integration (Verified)
- **Toolkit Version**: CUDA 10.2 (Final branch with stable CC 3.0 support).
- **Compiler Shield**: Deployed `/usr/local/bin/gcc-cuda-shield` to strip modern GCC 15 attributes from system headers that crash the legacy `nvcc` compiler.
- **Verification**: Empirically proven with a live 4K Matrix Multiplication stress test on hardware.

## Phase 4: Scraper Re-Engineering
Concurrent with the driver work, the `euler-scraper` was rebuilt into a production microservice:
- **Concurrency Control**: Semaphore-based (1-instance limit).
- **Network Optimization**: Blocked media/ads (70% bandwidth reduction).
- **Stability**: Added a "Zombie-Killer" hard-timer for browser processes.

## Project Documents
- [Architectural Post-Mortem](PROJECT_POST_MORTEM.md)
- [Performance Automation Logic](AUTOMATION.md)
- [Original Aperture Bridge Patch](nvidia_aperture_bridge.patch)
