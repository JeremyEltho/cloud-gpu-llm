#!/usr/bin/env bash
# Run ON the rented GPU box (A100/H100 80GB, Ubuntu + NVIDIA docker).
# Serves an OpenAI-compatible API on :8080 via llama.cpp.
set -euo pipefail

REPO="bartowski/Llama-3.3-70B-Instruct-abliterated-GGUF"
FILE="${QUANT_FILE:-Llama-3.3-70B-Instruct-abliterated-Q4_K_M.gguf}"  # ~42GB
CTX="${CTX:-16384}"
API_KEY="${API_KEY:?set API_KEY to a random string, e.g. API_KEY=\$(openssl rand -hex 16)}"
MODELS_DIR="${MODELS_DIR:-/workspace/models}"

mkdir -p "$MODELS_DIR"
if [ ! -f "$MODELS_DIR/$FILE" ]; then
  pip install -q -U "huggingface_hub[cli]"
  huggingface-cli download "$REPO" "$FILE" --local-dir "$MODELS_DIR"
fi

docker run --rm --gpus all -p 8080:8080 -v "$MODELS_DIR":/models \
  ghcr.io/ggml-org/llama.cpp:server-cuda \
  -m "/models/$FILE" -c "$CTX" -ngl 999 --host 0.0.0.0 --port 8080 \
  --api-key "$API_KEY" --jinja
