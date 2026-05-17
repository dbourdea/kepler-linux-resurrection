# CUDA 11.4 Integration Plan for Kepler (GK104)

## Objective
Enable CUDA compute capabilities on the patched 470 driver without breaking the kernel modules.

## Strategy
1. Download the CUDA 11.4.4 Local Runfile (Linux x86_64).
2. Execute with --silent --toolkit --no-opengl-libs.
3. Explicitly EXCLUDE the driver installation.
4. Symlink /usr/local/cuda to cuda-11.4.
5. Update global profile for PATH and LD_LIBRARY_PATH.

## Adversarial Audit (Bmad Pro)
1. **The "Silent Overwrite"**: Even with --toolkit, some runfiles try to replace /usr/lib/x86_64-linux-gnu/libGL.so. Pro implementation must backup GL libraries or use --no-opengl-libs.
2. **Compiler Hell**: CUDA 11.4 expects GCC 10 or 11. Ubuntu 26.04 has GCC 15. The toolkit will fail to compile samples. We must install gcc-11 and g++-11 and point CUDA to them.
3. **Symbol Mismatch**: If the user runs a CUDA app, it might try to load a library from the toolkit that conflicts with the patched driver's library. Pro implementation uses ldconfig to prioritize the driver's libs.
