current_date=$(date +%Y%m%d)

git clone "https://github.com/ggerganov/llama.cpp/" --depth 1 $current_date

cd $current_date

cmake -S . -B build -DGGML_HIP=ON -DCMAKE_HIP_ARCHITECTURES=gfx906 -DCMAKE_BUILD_TYPE=Release -DGGML_BACKEND_DL=ON -DGGML_CPU_ALL_VARIANTS=ON && cmake --build build --parallel $(nproc)
