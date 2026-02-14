current_date=$(date +%Y%m%d)

git clone "https://github.com/ggerganov/llama.cpp/" $current_date

cd $current_date

cmake -S . -B build -DGGML_HIP=ON -DGPU_TARGETS=gfx906 -DCMAKE_BUILD_TYPE=Release -DGGML_HIP_ROCWMMA_FATTN=ON && cmake --build build --parallel $(nproc)
