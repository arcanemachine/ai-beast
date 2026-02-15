../../llama-cpp/current/build/bin/llama-server \
  -m ../../models/Qwen3-Coder-Next-Q4_0.gguf \
  -ngl 999 \
  -c 16000 \
  -n 4000 \
  --no-mmap \
  --cpu-moe \
  --temp 0.1 \
  --host 0.0.0.0
