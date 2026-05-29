#!/usr/bin/env bash
#
# configure.sh — Run once after cloning the ai-template.
#
# Usage:
#   git clone https://github.com/mrosmarin/ai-template.git my-project
#   cd my-project
#   ./configure.sh
#
# After this: open in VS Code → devcontainer → make ssh-setup → Claude Code bootstrap

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
info()  { echo -e "${CYAN}→${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
ask()   { echo -en "${BOLD}$1${NC} "; }

# Portable sed -i (macOS BSD sed requires -i ''"'', GNU sed does not)
sedi() { if sed --version 2>/dev/null | grep -q GNU; then sed -i "$@"; else sed -i '' "$@"; fi; }

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

echo ""
echo -e "${BOLD}${CYAN}═══ AI Template — Project Configuration ═══${NC}"
echo ""
echo -e "${DIM}Run once after cloning. Detailed setup happens later via Claude Code bootstrap.${NC}"
echo ""

# ── Q1: Project name ─────────────────────────────────────────────────
ask "Project name (lowercase, hyphens OK):"
read -r PROJECT_NAME
PROJECT_NAME="$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
[[ -z "$PROJECT_NAME" ]] && { echo "Error: required." >&2; exit 1; }

# ── Q2: Stack ─────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Which memory + tracking stack?${NC}"
echo ""
echo "  1) all          — memory-bank + beads + linear"
echo "  2) bank-linear  — memory-bank + linear"
echo "  3) beads-linear — beads + linear"
echo "  4) beads-memory — beads + memory-bank"
echo "  5) beads        — beads only"
echo ""
ask "Stack [1-5]:"
read -r STACK_CHOICE
case "$STACK_CHOICE" in
  1) STACK="all" ;; 2) STACK="bank-linear" ;; 3) STACK="beads-linear" ;;
  4) STACK="beads-memory" ;; 5) STACK="beads" ;;
  *) echo "Error: pick 1-5." >&2; exit 1 ;;
esac

# ── Q3: Prefix ────────────────────────────────────────────────────────
echo ""
if [[ "$STACK" == "all" || "$STACK" == "bank-linear" || "$STACK" == "beads-linear" ]]; then
  ask "Linear ticket prefix (e.g. NOB, ENG, PROJ):"
else
  ask "Branch name prefix (e.g. project initials):"
fi
read -r PREFIX
PREFIX="$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"
[[ -z "$PREFIX" ]] && { echo "Error: required." >&2; exit 1; }

# ── Q4: Branches ──────────────────────────────────────────────────────
echo ""
ask "Base branch for feature work [qa]:"
read -r BASE_BRANCH; BASE_BRANCH="${BASE_BRANCH:-qa}"
ask "Production branch [main]:"
read -r PROD_BRANCH; PROD_BRANCH="${PROD_BRANCH:-main}"
ask "Approvals for prod merge [1]:"
read -r APPROVALS; APPROVALS="${APPROVALS:-1}"

# ── Q5: GitHub repo ──────────────────────────────────────────────────
echo ""
ask "GitHub repo path (org/repo — leave empty to skip):"
read -r REPO_PATH

# ── Summary ───────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}── Summary ──${NC}"
echo "  Project:  $PROJECT_NAME"
echo "  Stack:    $STACK"
echo "  Prefix:   $PREFIX"
echo "  Branches: $BASE_BRANCH → $PROD_BRANCH ($APPROVALS approval(s))"
[[ -n "$REPO_PATH" ]] && echo "  Repo:     $REPO_PATH"
echo ""
ask "Continue? [Y/n]:"
read -r CONFIRM
[[ "$CONFIRM" =~ ^[Nn] ]] && { echo "Aborted."; exit 0; }
echo ""

# ══════════════════════════════════════════════════════════════════════
# STEP 1 — Rewrite devcontainer.json
# ══════════════════════════════════════════════════════════════════════
info "Rewriting .devcontainer/devcontainer.json..."

cat > .devcontainer/devcontainer.json << DCEOF
// For format details, see https://aka.ms/devcontainer.json.
{
  "name": "${PROJECT_NAME}_devcontainer",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspaces/\${localWorkspaceFolderBasename}",

  "mounts": [
    "source=\${localWorkspaceFolder}/.devcontainer/.bashrc,target=/home/vscode/.bashrc,type=bind,consistency=cached",
    "source=\${localWorkspaceFolder}/.devcontainer/.zshrc,target=/home/vscode/.zshrc,type=bind,consistency=cached",
    "source=${PROJECT_NAME}-claude-code-config,target=/home/node/.claude,type=volume"
  ],

  "features": {
    "ghcr.io/devcontainers/features/node:2": {},
    "ghcr.io/devcontainers/features/python:1": { "version": "latest" },
    "ghcr.io/devcontainers-extra/features/typescript:2": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": { "moby": "false" },
    "ghcr.io/devcontainers/features/go:1": { "version": "latest", "golangciLintVersion": "latest" }
  },

  "customizations": {
    "vscode": {
      "extensions": [
        "pomdtr.excalidraw-editor",
        "hediet.vscode-drawio",
        "alefragnani.Bookmarks",
        "christian-kohler.npm-intellisense",
        "donjayamanne.githistory",
        "kilocode.kilo-code",
        "Anthropic.claude-code",
        "MermaidChart.vscode-mermaid-chart",
        "vstirbu.vscode-mermaid-preview",
        "Supabase.vscode-supabase-extension",
        "ms-playwright.playwright",
        "frenco.vscode-vercel",
        "ReprEng.csv",
        "ms-kubernetes-tools.vscode-kubernetes-tools"
      ]
    }
  },

  "postCreateCommand": "./.devcontainer/postinstall.sh"
}
DCEOF
ok "devcontainer.json"

# ══════════════════════════════════════════════════════════════════════
# STEP 2 — Create SSH setup script
# ══════════════════════════════════════════════════════════════════════
info "Creating .devcontainer/ssh-setup.sh..."

cat > .devcontainer/ssh-setup.sh << 'SSHEOF'
#!/usr/bin/env bash
set -euo pipefail
SSH_DIR="$HOME/.ssh"; KEY_FILE="$SSH_DIR/id_ed25519"

if [[ -f "$KEY_FILE" ]]; then
  echo "SSH key already exists at $KEY_FILE"
  echo ""; echo "Public key:"; cat "${KEY_FILE}.pub"; echo ""
  echo "Add to GitHub: https://github.com/settings/ssh/new"
  exit 0
fi

mkdir -p "$SSH_DIR"; chmod 700 "$SSH_DIR"
echo "→ Generating SSH key..."
read -rp "Email for SSH key (your GitHub email): " EMAIL
ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""
eval "$(ssh-agent -s)" > /dev/null; ssh-add "$KEY_FILE" 2>/dev/null

cat >> "$SSH_DIR/config" << SSHCFG
Host github.com
  HostName github.com
  User git
  IdentityFile $KEY_FILE
  AddKeysToAgent yes
SSHCFG
chmod 600 "$SSH_DIR/config"

echo ""
echo "════════════════════════════════════════════"
echo "✓ SSH key generated"; echo ""
echo "Public key (copy this):"; cat "${KEY_FILE}.pub"; echo ""
echo "Add to GitHub:"
echo "  1. https://github.com/settings/ssh/new"
echo "  2. Title: $(hostname) devcontainer"
echo "  3. Paste the key above"
echo ""; echo "Verify: ssh -T git@github.com"
echo "════════════════════════════════════════════"
SSHEOF
chmod +x .devcontainer/ssh-setup.sh
ok "ssh-setup.sh"

# ══════════════════════════════════════════════════════════════════════
# STEP 2b — Create .devcontainer/.env with environment secrets
# ══════════════════════════════════════════════════════════════════════
info "Setting up .devcontainer/.env..."

ENV_FILE=".devcontainer/.env"

if [[ -f "$ENV_FILE" ]]; then
  warn ".devcontainer/.env already exists — skipping"
else
  echo ""
  echo -e "${BOLD}Add environment variables for the devcontainer.${NC}"
  echo -e "${DIM}These are loaded as shell env vars inside the container.${NC}"
  echo -e "${DIM}Common: GITHUB_PERSONAL_ACCESS_TOKEN, CONTEXT7_TOKEN, API keys${NC}"
  echo -e "${DIM}Enter key=value pairs, one per line. Empty line to finish.${NC}"
  echo ""

  touch "$ENV_FILE"

  while true; do
    ask "  key=value (or empty to finish):"
    read -r KV
    [[ -z "$KV" ]] && break
    if [[ "$KV" == *"="* ]]; then
      echo "$KV" >> "$ENV_FILE"
      KEY="${KV%%=*}"
      ok "  Added $KEY"
    else
      warn "  Skipped — must be key=value format"
    fi
  done

  if [[ -s "$ENV_FILE" ]]; then
    ok ".devcontainer/.env created ($(wc -l < "$ENV_FILE" | tr -d ' ') vars)"
  else
    echo "# Add environment variables here (key=value, one per line)" > "$ENV_FILE"
    echo "# Example: GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxx" >> "$ENV_FILE"
    ok ".devcontainer/.env created (empty template)"
  fi
fi


# ══════════════════════════════════════════════════════════════════════
# STEP 3 — Strip stack-conditional sections
# ══════════════════════════════════════════════════════════════════════
info "Stripping stack sections for: ${STACK}..."

strip_stack_sections() {
  local file="$1"
  local stack="$2"
  local tmpfile="${file}.tmp"
  [[ ! -f "$file" ]] && return
  python3 - "$file" "$stack" "$tmpfile" << 'PYEOF'
import sys, re
filepath, stack, outpath = sys.argv[1], sys.argv[2], sys.argv[3]
with open(filepath, 'r') as f:
    content = f.read()
pattern = r'^[#/ ]*<!-- STACK:([\w,-]+) -->[ ]*\n(.*?)^[#/ ]*<!-- /STACK -->[ ]*\n?'
def replace_block(match):
    stacks = [s.strip() for s in match.group(1).split(',')]
    body = match.group(2)
    return body if stack in stacks else ''
result = re.sub(pattern, replace_block, content, flags=re.DOTALL | re.MULTILINE)
with open(outpath, 'w') as f:
    f.write(result)
PYEOF
  mv "$tmpfile" "$file"
}

for f in CLAUDE.md CONTRIBUTING.md DEPLOYMENT-ENV.md WORKTREES.md Makefile \
         .agents/skills/checkpoint/SKILL.md; do
  [[ -f "$REPO_ROOT/$f" ]] && strip_stack_sections "$REPO_ROOT/$f" "$STACK"
done
ok "Stack sections stripped"

# ══════════════════════════════════════════════════════════════════════
# STEP 4 — Replace placeholders
# ══════════════════════════════════════════════════════════════════════
info "Replacing placeholders..."

FILES_TO_PROCESS=(
  CLAUDE.md CONTRIBUTING.md DEPLOYMENT-ENV.md WORKTREES.md
  Makefile BOOTSTRAP.md README.md
  .agents/skills/checkpoint/SKILL.md
  scripts/worktree-new.sh
)

for f in "${FILES_TO_PROCESS[@]}"; do
  fp="$REPO_ROOT/$f"
  [[ ! -f "$fp" ]] && continue
  sedi "s|<PROJECT_NAME>|${PROJECT_NAME}|g" "$fp"
  sedi "s|<STACK>|${STACK}|g" "$fp"
  sedi "s|<PREFIX>|${PREFIX}|g" "$fp"
  sedi "s|<BASE_BRANCH>|${BASE_BRANCH}|g" "$fp"
  sedi "s|<PROD_BRANCH>|${PROD_BRANCH}|g" "$fp"
  sedi "s|<APPROVALS_REQUIRED>|${APPROVALS}|g" "$fp"
  [[ -n "$REPO_PATH" ]] && sedi "s|<REPO_PATH>|${REPO_PATH}|g" "$fp"
done
ok "Placeholders replaced"

# ══════════════════════════════════════════════════════════════════════
# STEP 5 — Skill symlinks
# ══════════════════════════════════════════════════════════════════════
info "Setting up skill symlinks..."
mkdir -p .claude/skills .kilo/skills
ln -sfn ../../.agents/skills/checkpoint .claude/skills/checkpoint
ln -sfn ../../.agents/skills/checkpoint .kilo/skills/checkpoint
ok ".agents/skills/checkpoint/ → .claude/skills + .kilo/skills"

# ══════════════════════════════════════════════════════════════════════
# STEP 6 — Memory bank
# ══════════════════════════════════════════════════════════════════════
needs_memory_bank() {
  [[ "$STACK" == "all" || "$STACK" == "bank-linear" || "$STACK" == "beads-memory" ]]
}

if needs_memory_bank; then
  info "Keeping memory-bank/"
  mkdir -p memory-bank
  for f in projectbrief.md productContext.md techContext.md systemPatterns.md activeContext.md progress.md; do
    [[ ! -f "memory-bank/$f" ]] && printf "# %s\n\n<!-- TODO: populate during bootstrap -->\n" "${f%.md}" > "memory-bank/$f"
  done
  ok "memory-bank/ ready"
else
  info "Removing memory-bank/ (not in stack: $STACK)"
  rm -rf memory-bank
  rm -f .claude/rules/memory-bank.md 2>/dev/null
  rm -f .kilo/rules/memory-bank.md 2>/dev/null
  ok "memory-bank/ removed"
fi

# ══════════════════════════════════════════════════════════════════════
# STEP 7 — Script permissions
# ══════════════════════════════════════════════════════════════════════
info "Setting permissions..."
find scripts/ -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true
chmod +x .devcontainer/postinstall.sh .devcontainer/ssh-setup.sh 2>/dev/null || true
chmod +x configure.sh 2>/dev/null || true
ok "Scripts executable"

# ══════════════════════════════════════════════════════════════════════
# STEP 8 — Reset git
# ══════════════════════════════════════════════════════════════════════
info "Resetting git..."
git remote remove origin 2>/dev/null || true
if [[ -n "$REPO_PATH" ]]; then
  git remote add origin "git@github.com:${REPO_PATH}.git"
  ok "Remote: git@github.com:${REPO_PATH}.git"
else
  warn "No remote set — add later: git remote add origin <url>"
fi
git add -A
git commit -m "chore: initialize ${PROJECT_NAME} from ai-template (stack: ${STACK})" --quiet
ok "Initial commit created"

# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}${GREEN}═══ Configuration complete ═══${NC}"
echo ""
echo "  Project:  $PROJECT_NAME"
echo "  Stack:    $STACK"
echo "  Branch:   feature/${PREFIX}-XXX-description → ${BASE_BRANCH} → ${PROD_BRANCH}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo "  1. Open in VS Code → reopen in devcontainer"
echo "  2. After container builds: make ssh-setup"
echo -e "  3. Open Claude Code: ${CYAN}\"Run the bootstrap process in BOOTSTRAP.md\"${NC}"
echo ""
