../../llama.cpp/build/bin/llama-cli \
  -m ../../models/Qwen3-Coder-Next-Q4_0.gguf \
  -ngl 999 \
  -c 65536 \
  -n 4096 \
  --no-mmap \
  --temp 0.1
