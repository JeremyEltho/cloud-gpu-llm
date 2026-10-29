#!/usr/bin/env bash
# Launch Claude Code against the self-hosted model.
set -euo pipefail
set -a; source "$(dirname "$0")/.env"; set +a

export ANTHROPIC_BASE_URL="${BASE_URL%/v1}"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export ANTHROPIC_API_KEY=""
export ANTHROPIC_MODEL="local"
export ANTHROPIC_SMALL_FAST_MODEL="local"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export MAX_THINKING_TOKENS=0
exec claude --strict-mcp-config --permission-mode default --disallowedTools Agent "$@"
