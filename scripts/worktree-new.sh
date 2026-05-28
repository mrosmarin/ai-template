#!/usr/bin/env bash
# scripts/worktree-new.sh — create a feature-branch worktree.
# Usage: scripts/worktree-new.sh <ticket> <slug>

set -euo pipefail

TICKET_PREFIX="<PREFIX>"
BASE_BRANCH="<BASE_BRANCH>"

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <ticket> <slug>" >&2; exit 2
fi

TICKET_RAW="$1"; SLUG="$2"
PREFIX_LOWER="$(printf '%s' "$TICKET_PREFIX" | tr '[:upper:]' '[:lower:]')"
PREFIX_UPPER="$(printf '%s' "$TICKET_PREFIX" | tr '[:lower:]' '[:upper:]')"
TICKET="${TICKET_RAW#${PREFIX_LOWER}-}"; TICKET="${TICKET#${PREFIX_UPPER}-}"
TICKET="$(printf '%s' "$TICKET" | tr '[:upper:]' '[:lower:]')"

[[ "$TICKET" =~ ^[0-9]+$ ]] || { echo "Error: ticket must be a number (got: $TICKET_RAW)" >&2; exit 2; }
[[ "$SLUG" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || { echo "Error: slug must be lowercase kebab-case (got: $SLUG)" >&2; exit 2; }

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Error: not in a git repo" >&2; exit 1; }
BRANCH="feature/${PREFIX_LOWER}-${TICKET}-${SLUG}"
WORKTREE_DIR="${REPO_ROOT}/.claude/worktrees/${PREFIX_LOWER}-${TICKET}-${SLUG}"

git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${BRANCH}" 2>/dev/null && { echo "Error: branch ${BRANCH} exists locally" >&2; exit 1; }

echo "→ Fetching origin..."
git -C "$REPO_ROOT" fetch origin --quiet
git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/origin/${BRANCH}" 2>/dev/null && { echo "Error: branch ${BRANCH} exists on origin" >&2; exit 1; }
git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}" || { echo "Error: origin/${BASE_BRANCH} not found" >&2; exit 1; }
[[ -e "$WORKTREE_DIR" ]] && { echo "Error: path exists: $WORKTREE_DIR" >&2; exit 1; }

mkdir -p "${REPO_ROOT}/.claude/worktrees"
echo "→ Creating worktree: $WORKTREE_DIR (branch: $BRANCH)"
git -C "$REPO_ROOT" worktree add "$WORKTREE_DIR" -b "$BRANCH" "origin/${BASE_BRANCH}"

INCLUDE_FILE="${REPO_ROOT}/.worktreeinclude"
if [[ -f "$INCLUDE_FILE" ]]; then
  echo "→ Copying files from .worktreeinclude..."
  while IFS= read -r pattern || [[ -n "$pattern" ]]; do
    [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue
    shopt -s nullglob globstar
    matches=( ${REPO_ROOT}/${pattern} )
    shopt -u nullglob globstar
    for src in "${matches[@]}"; do
      rel="${src#${REPO_ROOT}/}"; dst="${WORKTREE_DIR}/${rel}"
      mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"; echo "    [ok] $rel"
    done
  done < "$INCLUDE_FILE"
fi

REL=".claude/worktrees/${PREFIX_LOWER}-${TICKET}-${SLUG}"
echo ""
echo "Worktree ready at ${REL}/"
echo "  cd ${REL} && <INSTALL_CMD> && claude"
echo "  Cleanup: git worktree remove ${REL} && git branch -D ${BRANCH}"
