# cloud-gpu-llm

Run an abliterated Llama 3.3 70B on a rented Vast.ai GPU and use it as the backend for Claude Code.

## Requirements

- A Vast.ai account with credit and the `vastai` CLI
- An 80GB GPU (A100 or H100); the Q4_K_M quant is about 42GB
- Claude Code installed locally
