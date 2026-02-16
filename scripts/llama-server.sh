#!/bin/sh

model_path="../../models/Qwen3-Coder-Next-Q4_0.gguf"

if [ $1 != "" ]; then
  model_path=$1
fi

../../llama.cpp/build/bin/llama-server \
  -m $model_path \
  -ngl 999 \
  --ctx-size 400000 \
  -c 400000 \
  -n 8192 \
  -b 2048 \
  --no-mmap \
  --parallel 4 \
  --temp 0.1 \
  --top-p 0.9 \
  --host 0.0.0.0
