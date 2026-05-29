#!/usr/bin/env bash
#
# scripts/mcp-add.sh — Add an MCP server to both .claude/mcp.json and .kilo/kilo.jsonc
#
# Usage:
#   scripts/mcp-add.sh linear          # add from built-in presets
#   scripts/mcp-add.sh vercel
#   scripts/mcp-add.sh supabase
#   scripts/mcp-add.sh --list          # show available presets
#
# Presets add the MCP to both Claude Code and Kilo Code configs.
# For custom MCPs, edit .claude/mcp.json and .kilo/kilo.jsonc directly.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CLAUDE_MCP="${REPO_ROOT}/.claude/mcp.json"
KILO_MCP="${REPO_ROOT}/.kilo/kilo.jsonc"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${CYAN}→${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

# ── Presets ────────────────────────────────────────────

declare -A CLAUDE_PRESETS
declare -A KILO_PRESETS

CLAUDE_PRESETS[linear]='{
      "type": "http",
      "url": "https://mcp.linear.app/mcp"
    }'
KILO_PRESETS[linear]='{
      "type": "local",
      "command": ["npx", "-y", "mcp-remote", "https://mcp.linear.app/mcp"],
      "enabled": true
    }'

CLAUDE_PRESETS[vercel]='{
      "type": "http",
      "url": "https://mcp.vercel.com"
    }'
KILO_PRESETS[vercel]='{
      "type": "local",
      "command": ["npx", "-y", "mcp-remote", "https://mcp.vercel.com"],
      "enabled": true
    }'

CLAUDE_PRESETS[supabase]='{
      "type": "http",
      "url": "http://127.0.0.1:54321/mcp"
    }'
KILO_PRESETS[supabase]='{
      "type": "remote",
      "url": "http://127.0.0.1:54321/mcp"
    }'

CLAUDE_PRESETS[next-devtools]='{
      "command": "npx",
      "args": ["-y", "next-devtools-mcp@latest"]
    }'
KILO_PRESETS[next-devtools]='{
      "type": "local",
      "command": ["npx", "-y", "next-devtools-mcp@latest"]
    }'

CLAUDE_PRESETS[shadcn]='{
      "command": "npx",
      "args": ["shadcn@4.7.0", "mcp"]
    }'
KILO_PRESETS[shadcn]='{
      "type": "local",
      "command": ["npx", "-y", "shadcn@4.7.0", "mcp"]
    }'

AVAILABLE_PRESETS="linear vercel supabase next-devtools shadcn"

# ── Parse args ─────────────────────────────────────────

if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0 <preset-name>"
  echo "       $0 --list"
  echo ""
  echo "Available presets: $AVAILABLE_PRESETS"
  exit 0
fi

if [[ "$1" == "--list" ]]; then
  echo "Available MCP presets:"
  for p in $AVAILABLE_PRESETS; do
    echo "  $p"
  done
  exit 0
fi

NAME="$1"

if [[ -z "${CLAUDE_PRESETS[$NAME]+x}" ]]; then
  echo "Error: unknown preset '$NAME'" >&2
  echo "Available: $AVAILABLE_PRESETS" >&2
  exit 1
fi

# ── Add to .claude/mcp.json ────────────────────────────

info "Adding '$NAME' to .claude/mcp.json..."

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 required for JSON manipulation" >&2
  exit 1
fi

python3 - "$CLAUDE_MCP" "$NAME" "${CLAUDE_PRESETS[$NAME]}" << 'PYEOF'
import sys, json
filepath, name, preset_json = sys.argv[1], sys.argv[2], sys.argv[3]
with open(filepath, 'r') as f:
    config = json.load(f)
if name in config.get('mcpServers', {}):
    print(f"  Already exists in {filepath}")
else:
    config.setdefault('mcpServers', {})[name] = json.loads(preset_json)
    with open(filepath, 'w') as f:
        json.dump(config, f, indent=2)
        f.write('\n')
    print(f"  Added to {filepath}")
PYEOF

# ── Add to .kilo/kilo.jsonc ───────────────────────────

info "Adding '$NAME' to .kilo/kilo.jsonc..."

python3 - "$KILO_MCP" "$NAME" "${KILO_PRESETS[$NAME]}" << 'PYEOF'
import sys, json, re
filepath, name, preset_json = sys.argv[1], sys.argv[2], sys.argv[3]
with open(filepath, 'r') as f:
    content = f.read()
# Strip JSONC comments for parsing
# Strip JSONC comments: only lines where // appears outside of strings
    # Simple heuristic: remove // only when preceded by whitespace at line start
    lines = content.split('\n')
    stripped_lines = []
    for line in lines:
        s = line.lstrip()
        if s.startswith('//'):
            continue  # skip full-line comments
        stripped_lines.append(line)
    stripped = '\n'.join(stripped_lines)
config = json.loads(stripped)
if name in config.get('mcp', {}):
    print(f"  Already exists in {filepath}")
else:
    config.setdefault('mcp', {})[name] = json.loads(preset_json)
    with open(filepath, 'w') as f:
        json.dump(config, f, indent=2)
        f.write('\n')
    print(f"  Added to {filepath}")
PYEOF

ok "MCP '$NAME' added to both configs"
echo ""
echo "Don't forget to restart Claude Code / Kilo Code to pick up the change."
