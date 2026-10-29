#!/usr/bin/env bash
# Run INSIDE the Vast.ai instance (pytorch/CUDA devel image). Builds llama.cpp with CUDA,
# downloads the model, and serves an OpenAI-compatible API on :8080.
set -euo pipefail

REPO="bartowski/Llama-3.3-70B-Instruct-abliterated-GGUF"
FILE="${QUANT_FILE:-Llama-3.3-70B-Instruct-abliterated-Q4_K_M.gguf}"  # ~42GB
CTX="${CTX:-16384}"
API_KEY="${API_KEY:?set API_KEY to a random string, e.g. API_KEY=\$(openssl rand -hex 16)}"
MODELS_DIR="${MODELS_DIR:-/workspace/models}"
LLAMA_DIR="${LLAMA_DIR:-/workspace/llama.cpp}"

apt-get update -qq && apt-get install -y -qq git cmake build-essential libcurl4-openssl-dev

if [ ! -x "$LLAMA_DIR/build/bin/llama-server" ]; then
  git clone --depth 1 https://github.com/ggml-org/llama.cpp "$LLAMA_DIR"
  cmake -S "$LLAMA_DIR" -B "$LLAMA_DIR/build" -DGGML_CUDA=ON -DCMAKE_BUILD_TYPE=Release
  cmake --build "$LLAMA_DIR/build" --target llama-server -j"$(nproc)"
fi

mkdir -p "$MODELS_DIR"
if [ ! -f "$MODELS_DIR/$FILE" ]; then
  pip install -q -U "huggingface_hub[cli]"
  huggingface-cli download "$REPO" "$FILE" --local-dir "$MODELS_DIR"
fi

exec "$LLAMA_DIR/build/bin/llama-server" -m "$MODELS_DIR/$FILE" -c "$CTX" -ngl 999 \
  --host 0.0.0.0 --port 8080 --api-key "$API_KEY" --jinja
