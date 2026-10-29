# cloud-gpu-llm

Run an abliterated Llama 3.3 70B on a rented Vast.ai GPU and use it as the backend for Claude Code.

## Requirements

- A Vast.ai account with credit and the `vastai` CLI (`pip install vastai`)
- An 80GB GPU (A100 or H100); the Q4_K_M quant is about 42GB
- Claude Code installed locally

## Usage

1. Rent a verified single 80GB GPU with 150GB disk and port 8080 open:
   `vastai search offers 'gpu_name=A100_SXM4 num_gpus=1 gpu_ram>=80 verified=true disk_space>=100 inet_down>=500 reliability>0.98' -o 'dph+'`
   then `vastai create instance <offer_id> --image pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel --disk 150 --ssh --direct --env '-p 8080:8080'`
2. Copy `serve.sh` to the instance and run it (the first run compiles llama.cpp, about 15 minutes):
   `API_KEY=$(openssl rand -hex 16) ./serve.sh`
3. Copy `.env.example` to `.env` and fill in the instance's public IP, mapped port 8080, and your API key.
4. Chat from the terminal with `python3 chat.py`, or run Claude Code on the model with `./claude-local.sh`.

## Notes

- The server runs with 64k context across 2 slots, so each slot has 32k. Run `/compact` before a session nears that.
- The launcher uses default permission mode, disables the Agent tool and MCP servers, and turns thinking off. Llama 3.3 70B is a much weaker agent than Claude, so expect rough edges with tool use.
- Abliterated models have refusal behavior removed. Keep permission prompts on.
- The endpoint is plain HTTP protected only by the API key. Don't send secrets through it.
- Destroy the instance when you finish: `vastai destroy instance <id>`. A stopped instance still bills for storage.
