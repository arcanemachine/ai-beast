#!/bin/sh

set -e

current_date=$(date +%Y-%m-%d-%H-%M-%S)

git clone https://github.com/ggml-org/llama.cpp --depth 1 $current_date

cd $current_date

# Set your ROCm architecture for MI50 (gfx906)
export LLAMACPP_ROCM_ARCH=gfx906

# Build with ROCm/HIP support
HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" \
cmake -S . \
  -B build \
  -DGGML_HIP=ON \
  -DAMDGPU_TARGETS=gfx906 \
  -DCMAKE_BUILD_TYPE=Release \
  && cmake --build build --config Release -j$(nproc)

cd ..

ln -sf $current_date latest
