#!/bin/bash
# CUDA Elite Environment Wrapper - Amelia PRO V4.0 (LEGACY CC 3.0)
# HARDENED: For CUDA 10.2 on Ubuntu 26.04

export PATH=/usr/local/cuda-10.2/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-10.2/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Force legacy compilers
export CC=/usr/local/bin/gcc-cuda-shield
export CXX=/usr/local/bin/g++-cuda-shield

# ELITE: Use proxy headers and include math fix
export NVCC_PREPEND_FLAGS="-isystem /usr/local/cuda-10.2/include/proxy -Xcompiler -lstdc++"

echo "[CUDA Legacy V4.0] CC 3.0 (Kepler) environment active."
exec "$@"
