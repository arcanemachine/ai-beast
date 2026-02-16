#!/bin/sh

model_path="../../models/Qwen3-Coder-Next-Q4_0.gguf"

if [ $1 != "" ]; then
  model_path=$1
fi

../../llama.cpp/build/bin/llama-cli \
  -m $model_path \
  -ngl 999 \
  -c 100000 \
  -n 4096 \
  --no-mmap \
  --temp 0.1
