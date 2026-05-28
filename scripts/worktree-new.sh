#!/usr/bin/env bash
# scripts/worktree-new.sh — create a feature-branch worktree
set -euo pipefail

TICKET_PREFIX="<PREFIX>"
BASE_BRANCH="<BASE_BRANCH>"

[[ $# -ne 2 ]] && { echo "Usage: $0 <ticket> <slug>" >&2; exit 2; }
TICKET_RAW="$1"; SLUG="$2"
PL="$(printf '%s' "$TICKET_PREFIX" | tr '[:upper:]' '[:lower:]')"
PU="$(printf '%s' "$TICKET_PREFIX" | tr '[:lower:]' '[:upper:]')"
T="${TICKET_RAW#${PL}-}"; T="${T#${PU}-}"; T="$(printf '%s' "$T" | tr '[:upper:]' '[:lower:]')"
[[ "$T" =~ ^[0-9]+$ ]] || { echo "Error: ticket must be a number" >&2; exit 2; }
[[ "$SLUG" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || { echo "Error: slug must be kebab-case" >&2; exit 2; }

R="$(git rev-parse --show-toplevel)" || { echo "Error: not in git repo" >&2; exit 1; }
BR="feature/${PL}-${T}-${SLUG}"
WD="${R}/.claude/worktrees/${PL}-${T}-${SLUG}"

git -C "$R" show-ref --verify --quiet "refs/heads/${BR}" 2>/dev/null && { echo "Error: branch exists locally" >&2; exit 1; }
echo "→ Fetching origin..."; git -C "$R" fetch origin --quiet
git -C "$R" show-ref --verify --quiet "refs/remotes/origin/${BR}" 2>/dev/null && { echo "Error: branch exists on origin" >&2; exit 1; }
git -C "$R" show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}" || { echo "Error: origin/${BASE_BRANCH} not found" >&2; exit 1; }
[[ -e "$WD" ]] && { echo "Error: path exists" >&2; exit 1; }

mkdir -p "${R}/.claude/worktrees"
echo "→ Creating worktree: $WD (branch: $BR)"
git -C "$R" worktree add "$WD" -b "$BR" "origin/${BASE_BRANCH}"

INC="${R}/.worktreeinclude"
if [[ -f "$INC" ]]; then
  echo "→ Copying from .worktreeinclude..."
  while IFS= read -r pat || [[ -n "$pat" ]]; do
    [[ -z "$pat" || "$pat" =~ ^[[:space:]]*# ]] && continue
    shopt -s nullglob globstar; matches=( ${R}/${pat} ); shopt -u nullglob globstar
    for src in "${matches[@]}"; do
      rel="${src#${R}/}"; dst="${WD}/${rel}"
      mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"; echo "    [ok] $rel"
    done
  done < "$INC"
fi

RP=".claude/worktrees/${PL}-${T}-${SLUG}"
echo ""; echo "Worktree ready: ${RP}/"
echo "  cd ${RP} && <INSTALL_CMD> && claude"
echo "  Cleanup: git worktree remove ${RP} && git branch -D ${BR}"
