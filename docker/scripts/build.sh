sudo apt-get update
sudo apt-get install -y nano libcurl4-openssl-dev cmake git

mkdir -p ~/workspace && cd ~/workspace

export LLAMACPP_ROCM_ARCH=gfx906

git clone --depth 1 https://github.com/ROCm/llama.cpp
cd llama.cpp

HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" \
cmake -S . -B build -DGGML_HIP=ON -DAMDGPU_TARGETS=$LLAMACPP_ROCM_ARCH \
-DCMAKE_BUILD_TYPE=Release -DLLAMA_CURL=ON \
-DGGML_HIP_ROCWMMA_FATTN=ON \
&& cmake --build build --config Release -j$(nproc)
