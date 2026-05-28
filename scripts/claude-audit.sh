#!/usr/bin/env bash
set -euo pipefail
# claude-audit.sh — Analyze Claude Code permission friction.
# Usage: bash claude-audit.sh [--global] [--days N] [--verbose]

DAYS=30; VERBOSE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) shift ;; --days) DAYS="$2"; shift 2 ;; --verbose) VERBOSE=true; shift ;;
    -h|--help) echo "Usage: claude-audit.sh [--global] [--days N] [--verbose]"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' D='\033[2m' B='\033[1m' N='\033[0m'
hdr() { echo -e "\n${B}${C}=== $1 ===${N}\n"; }

GS="$HOME/.claude/settings.json"; PS=".claude/settings.json"; LS=".claude/settings.local.json"

hdr "Settings Files"
for f in "$GS" "$PS" "$LS" "$HOME/.claude.json"; do
  [[ -f "$f" ]] && echo -e "${G}✓${N} $f ($(wc -c < "$f" | tr -d ' ')B)" || echo -e "${D}  $f (not found)${N}"
done

command -v jq &>/dev/null || { echo -e "${R}✗ jq required${N}"; exit 1; }

hdr "Permission Rules"
for pair in "$GS:Global" "$PS:Project" "$LS:Local"; do
  f="${pair%%:*}"; l="${pair#*:}"; [[ ! -f "$f" ]] && continue
  a=$(jq -r '.permissions.allow // [] | length' "$f" 2>/dev/null || echo 0)
  d=$(jq -r '.permissions.deny // [] | length' "$f" 2>/dev/null || echo 0)
  echo -e "${B}$l${N}: allow=$a deny=$d"
done

hdr "Overly Specific Rules"
for pair in "$GS:Global" "$PS:Project"; do
  f="${pair%%:*}"; l="${pair#*:}"; [[ ! -f "$f" ]] && continue
  jq -r '.permissions.allow // [] | .[]' "$f" 2>/dev/null | grep -E 'Bash\(.*(\/workspaces\/|\/home\/)' | while read -r r; do echo -e "  ${Y}⚠ ${l}: ${R}$r${N}"; done
  jq -r '.permissions.allow // [] | .[]' "$f" 2>/dev/null | awk 'length > 80' | while read -r r; do echo -e "  ${Y}⚠ ${l}: ${R}${r:0:80}...${N}"; done
done

if [[ -f "$GS" && -f "$PS" ]]; then
  hdr "Redundancy"
  ga=$(jq -r '.permissions.allow // [] | .[]' "$GS" 2>/dev/null | sort)
  pa=$(jq -r '.permissions.allow // [] | .[]' "$PS" 2>/dev/null | sort)
  dup=$(comm -12 <(echo "$ga") <(echo "$pa") 2>/dev/null || true)
  [[ -n "$dup" ]] && { echo -e "${Y}⚠ Redundant:${N}"; echo "$dup" | while read -r r; do echo -e "  ${D}$r${N}"; done; } || echo -e "${G}✓ No redundant rules${N}"
fi

hdr "Security"
for pair in "$GS:Global" "$PS:Project"; do
  f="${pair%%:*}"; l="${pair#*:}"; [[ ! -f "$f" ]] && continue
  bad=$(jq -r '.permissions.allow // [] | .[]' "$f" 2>/dev/null | grep -iE 'rm -rf|sudo|chmod 777|eval' || true)
  [[ -n "$bad" ]] && { echo -e "${R}✗ ${l}:${N}"; echo "$bad" | while read -r r; do echo -e "  ${R}$r${N}"; done; } || echo -e "${G}✓ ${l} clean${N}"
done

hdr "Tips"
echo "1. Run periodically to catch drift"
echo "2. Check ~/.claude.json for accumulated 'Always Allow' entries"
echo -e "3. Clean: ${D}jq '.projects[].allowedTools = []' ~/.claude.json > /tmp/c.json && mv /tmp/c.json ~/.claude.json${N}"
