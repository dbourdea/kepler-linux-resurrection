# Story 1-6: Performance Automation & Thermal Guardrails

**Status**: done

## Acceptance Criteria
- [x] AC-1: nvidia-fan-curve.sh implements linear interpolation between 40C (30%) and 80C (100%).
- [x] AC-2: nvidia-fan-curve.service is enabled and verified as running.
- [x] AC-3: cuda-env.sh wrapper provides compiler isolation (pinned to GCC 11).
- [x] AC-4: Aperture Bridge patch is integrated into the DKMS source tree for persistence.

## Tasks
- [x] Task 1: Deploy Thermal Automation Script.
- [x] Task 2: Create Systemd service for Fan Control.
- [x] Task 3: Author CUDA environment isolation wrapper.
- [x] Task 4: Move custom patches to DKMS source.

## Dev Agent Record
- **Amelia (Developer)**: Elite-tier automation push completed.
  - Deployed `/usr/local/bin/nvidia-fan-curve.sh` with X11 auth discovery.
  - Enabled `nvidia-fan-curve.service` to prevent thermal throttling.
  - Created `/usr/local/bin/cuda-env.sh` to isolate compute workloads from system GCC 15.
  - Confirmed "Aperture Bridge" persistence in `/usr/src/nvidia-470.256.02/`.
- **Status**: Ready for final World Class review.
