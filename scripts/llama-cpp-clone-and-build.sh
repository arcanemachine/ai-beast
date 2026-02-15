set -e

current_date=$(date +%Y-%m-%d-%H-%M-%S)

git clone https://github.com/iacopPBK/llama.cpp-gfx906 --depth 1 $current_date

cd $current_date

./SCRIPT_compile_MI50.sh

cd ..

ln -sf $current_date latest
