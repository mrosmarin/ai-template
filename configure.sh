#!/usr/bin/env bash
#
# configure.sh — Run once after cloning the ai-template.
#
# Usage:
#   git clone https://github.com/mrosmarin/ai-template.git my-project
#   cd my-project
#   ./configure.sh
#
# This script:
#   1. Asks for project name, stack, prefix, branches
#   2. Rewrites devcontainer.json (name, mounts, volumes)
#   3. Strips stack-conditional sections from all template docs
#   4. Replaces placeholders across the repo
#   5. Sets up skill symlinks (.agents/skills → .claude/skills, .kilo/skills)
#   6. Removes memory-bank/ if the stack doesn't use it
#   7. Resets git (removes template remote, makes initial commit)
#   8. Prints next steps (open devcontainer, run bootstrap)
#
# After this script: open in VS Code → devcontainer builds → Claude Code → bootstrap

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
info()  { echo -e "${CYAN}→${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
ask()   { echo -en "${BOLD}$1${NC} "; }

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

echo ""
echo -e "${BOLD}${CYAN}═══ AI Template — Project Configuration ═══${NC}"
echo ""
echo -e "${DIM}This configures the template for your project.${NC}"
echo -e "${DIM}Run once after cloning. Detailed setup happens later via Claude Code bootstrap.${NC}"
echo ""

# ── Q1: Project name ─────────────────────────────────────────────────
ask "Project name (lowercase, hyphens OK — used for container, git, docs):"
read -r PROJECT_NAME
PROJECT_NAME="$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: project name is required." >&2; exit 1
fi

# ── Q2: Stack ─────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Which memory + tracking stack?${NC}"
echo ""
echo "  1) all          — memory-bank + beads + linear  (full setup)"
echo "  2) bank-linear  — memory-bank + linear          (what you know today)"
echo "  3) beads-linear — beads + linear                (agent-first + PM)"
echo "  4) beads-memory — beads + memory-bank           (solo, no cloud PM)"
echo "  5) beads        — beads only                    (minimal, all-local)"
echo ""
ask "Stack [1-5]:"
read -r STACK_CHOICE

case "$STACK_CHOICE" in
  1) STACK="all" ;;
  2) STACK="bank-linear" ;;
  3) STACK="beads-linear" ;;
  4) STACK="beads-memory" ;;
  5) STACK="beads" ;;
  *) echo "Error: pick 1-5." >&2; exit 1 ;;
esac

# ── Q3: Prefix ────────────────────────────────────────────────────────
echo ""
if [[ "$STACK" == "all" || "$STACK" == "bank-linear" || "$STACK" == "beads-linear" ]]; then
  ask "Linear ticket prefix (e.g. NOB, ENG, PROJ):"
else
  ask "Branch name prefix (e.g. project initials — myproj, eng):"
fi
read -r PREFIX
PREFIX="$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"

if [[ -z "$PREFIX" ]]; then
  echo "Error: prefix is required." >&2; exit 1
fi

# ── Q4: Branches ──────────────────────────────────────────────────────
echo ""
ask "Base branch for feature work [qa]:"
read -r BASE_BRANCH
BASE_BRANCH="${BASE_BRANCH:-qa}"

ask "Production branch [main]:"
read -r PROD_BRANCH
PROD_BRANCH="${PROD_BRANCH:-main}"

ask "Approvals required for prod merge [1]:"
read -r APPROVALS
APPROVALS="${APPROVALS:-1}"

# ── Q5: GitHub repo (optional) ───────────────────────────────────────
echo ""
ask "GitHub repo path (e.g. org/repo-name) — leave empty to skip:"
read -r REPO_PATH

# ── Summary ───────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}── Summary ──${NC}"
echo "  Project:    $PROJECT_NAME"
echo "  Stack:      $STACK"
echo "  Prefix:     $PREFIX"
echo "  Branches:   $BASE_BRANCH → $PROD_BRANCH ($APPROVALS approval(s))"
[[ -n "$REPO_PATH" ]] && echo "  Repo:       $REPO_PATH"
echo ""
ask "Continue? [Y/n]:"
read -r CONFIRM
if [[ "$CONFIRM" =~ ^[Nn] ]]; then
  echo "Aborted."; exit 0
fi

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
    // Shell config — uses workspace-relative path (no hardcoded host dirs)
    "source=\${localWorkspaceFolder}/.devcontainer/.bashrc,target=/home/vscode/.bashrc,type=bind,consistency=cached",
    "source=\${localWorkspaceFolder}/.devcontainer/.zshrc,target=/home/vscode/.zshrc,type=bind,consistency=cached",
    // Persistent Claude Code config across rebuilds
    "source=${PROJECT_NAME}-claude-code-config,target=/home/node/.claude,type=volume"
    // NOTE: No host SSH mount. SSH keys are generated in-container.
    // Run: make ssh-setup   (or .devcontainer/ssh-setup.sh)
  ],

  "features": {
    "ghcr.io/devcontainers/features/node:2": {},
    "ghcr.io/devcontainers/features/python:1": {
      "version": "latest"
    },
    "ghcr.io/devcontainers-extra/features/typescript:2": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {
      "moby": "false"
    },
    "ghcr.io/devcontainers/features/go:1": {
      "version": "latest",
      "golangciLintVersion": "latest"
    }
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

ok "devcontainer.json rewritten (name: ${PROJECT_NAME}_devcontainer)"

# ══════════════════════════════════════════════════════════════════════
# STEP 2 — Create SSH setup script
# ══════════════════════════════════════════════════════════════════════
info "Creating .devcontainer/ssh-setup.sh..."

cat > .devcontainer/ssh-setup.sh << 'SSHEOF'
#!/usr/bin/env bash
#
# .devcontainer/ssh-setup.sh — Generate SSH keys inside the container
# and print instructions to add the public key to GitHub.
#
# Run once after the devcontainer is built:
#   make ssh-setup    (or bash .devcontainer/ssh-setup.sh)

set -euo pipefail

SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"

if [[ -f "$KEY_FILE" ]]; then
  echo "SSH key already exists at $KEY_FILE"
  echo ""
  echo "Public key:"
  cat "${KEY_FILE}.pub"
  echo ""
  echo "If you need to re-add it to GitHub:"
  echo "  1. Copy the public key above"
  echo "  2. Go to https://github.com/settings/ssh/new"
  echo "  3. Paste and save"
  exit 0
fi

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

echo "→ Generating SSH key..."
read -rp "Email for the SSH key (your GitHub email): " EMAIL

ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""

# Start ssh-agent and add key
eval "$(ssh-agent -s)" > /dev/null
ssh-add "$KEY_FILE" 2>/dev/null

# Configure SSH for GitHub
cat >> "$SSH_DIR/config" << SSHCFG
Host github.com
  HostName github.com
  User git
  IdentityFile $KEY_FILE
  AddKeysToAgent yes
SSHCFG

chmod 600 "$SSH_DIR/config"

echo ""
echo "════════════════════════════════════════════════════════"
echo "✓ SSH key generated"
echo ""
echo "Public key (copy this):"
echo "────────────────────────────────────────────────────────"
cat "${KEY_FILE}.pub"
echo "────────────────────────────────────────────────────────"
echo ""
echo "Add it to GitHub:"
echo "  1. Go to https://github.com/settings/ssh/new"
echo "  2. Title: $(hostname) devcontainer"
echo "  3. Paste the public key above"
echo "  4. Click 'Add SSH key'"
echo ""
echo "Verify with: ssh -T git@github.com"
echo "════════════════════════════════════════════════════════"
SSHEOF

chmod +x .devcontainer/ssh-setup.sh
ok "ssh-setup.sh created"

# ══════════════════════════════════════════════════════════════════════
# STEP 3 — Strip stack-conditional sections
# ══════════════════════════════════════════════════════════════════════
info "Stripping stack-conditional sections for stack: ${STACK}..."

strip_stack_sections() {
  local file="$1"
  local stack="$2"
  local tmpfile="${file}.tmp"

  if [[ ! -f "$file" ]]; then return; fi

  # Python is more reliable for multi-line regex than sed
  python3 - "$file" "$stack" "$tmpfile" << 'PYEOF'
import sys, re

filepath, stack, outpath = sys.argv[1], sys.argv[2], sys.argv[3]

with open(filepath, 'r') as f:
    content = f.read()

# Pattern: <!-- STACK:list,of,stacks --> ... <!-- /STACK -->
# Handles optional comment prefix: # <!-- STACK:... --> (Makefile/shell)
pattern = r'^[#/ ]*<!-- STACK:([\w,-]+) -->[ ]*\n(.*?)^[#/ ]*<!-- /STACK -->[ ]*\n?'

def replace_block(match):
    stacks = [s.strip() for s in match.group(1).split(',')]
    body = match.group(2)
    if stack in stacks:
        return body  # keep content, remove markers
    else:
        return ''  # remove entire block

result = re.sub(pattern, replace_block, content, flags=re.DOTALL | re.MULTILINE)

with open(outpath, 'w') as f:
    f.write(result)
PYEOF

  mv "$tmpfile" "$file"
}

# Process all template files
for f in CLAUDE.md CONTRIBUTING.md DEPLOYMENT-ENV.md WORKTREES.md Makefile \
         .claude/commands/checkpoint.md; do
  if [[ -f "$REPO_ROOT/$f" ]]; then
    strip_stack_sections "$REPO_ROOT/$f" "$STACK"
  fi
done

ok "Stack sections stripped"

# ══════════════════════════════════════════════════════════════════════
# STEP 4 — Replace placeholders
# ══════════════════════════════════════════════════════════════════════
info "Replacing placeholders..."

replace_placeholder() {
  local file="$1" old="$2" new="$3"
  if [[ -f "$file" ]]; then
    # Use | as delimiter to avoid issues with / in paths
    sed -i "s|${old}|${new}|g" "$file"
  fi
}

FILES_TO_PROCESS=(
  CLAUDE.md CONTRIBUTING.md DEPLOYMENT-ENV.md WORKTREES.md
  Makefile BOOTSTRAP.md README.md
  .claude/commands/checkpoint.md
  scripts/worktree-new.sh
)

for f in "${FILES_TO_PROCESS[@]}"; do
  filepath="$REPO_ROOT/$f"
  replace_placeholder "$filepath" "<PROJECT_NAME>" "$PROJECT_NAME"
  replace_placeholder "$filepath" "<STACK>" "$STACK"
  replace_placeholder "$filepath" "<PREFIX>" "$PREFIX"
  replace_placeholder "$filepath" "<BASE_BRANCH>" "$BASE_BRANCH"
  replace_placeholder "$filepath" "<PROD_BRANCH>" "$PROD_BRANCH"
  replace_placeholder "$filepath" "<APPROVALS_REQUIRED>" "$APPROVALS"
  [[ -n "$REPO_PATH" ]] && replace_placeholder "$filepath" "<REPO_PATH>" "$REPO_PATH"
done

# Also update the worktree script's config block
if [[ -f scripts/worktree-new.sh ]]; then
  sed -i "s|TICKET_PREFIX=\"<PREFIX>\"|TICKET_PREFIX=\"${PREFIX}\"|g" scripts/worktree-new.sh
  sed -i "s|BASE_BRANCH=\"<BASE_BRANCH>\"|BASE_BRANCH=\"${BASE_BRANCH}\"|g" scripts/worktree-new.sh
fi

ok "Placeholders replaced"

# ══════════════════════════════════════════════════════════════════════
# STEP 5 — Set up skill symlinks
# ══════════════════════════════════════════════════════════════════════
info "Setting up skill symlinks..."

# Ensure skill directories exist
mkdir -p .agents/skills/checkpoint
mkdir -p .claude/skills
mkdir -p .kilo/skills

# Move checkpoint skill to .agents/skills if it's currently in .claude/commands
if [[ -f .claude/commands/checkpoint.md ]]; then
  mv .claude/commands/checkpoint.md .agents/skills/checkpoint/SKILL.md
  rmdir .claude/commands 2>/dev/null || true
fi

# Create symlinks
ln -sfn ../../.agents/skills/checkpoint .claude/skills/checkpoint
ln -sfn ../../.agents/skills/checkpoint .kilo/skills/checkpoint

ok "Skills: .agents/skills/checkpoint/ → .claude/skills + .kilo/skills"

# ══════════════════════════════════════════════════════════════════════
# STEP 6 — Handle memory-bank based on stack
# ══════════════════════════════════════════════════════════════════════
needs_memory_bank() {
  [[ "$STACK" == "all" || "$STACK" == "bank-linear" || "$STACK" == "beads-memory" ]]
}

if needs_memory_bank; then
  info "Keeping memory-bank/ (stack: $STACK)"
  # Ensure placeholder files exist
  mkdir -p memory-bank
  for f in projectbrief.md productContext.md techContext.md systemPatterns.md activeContext.md progress.md; do
    if [[ ! -f "memory-bank/$f" ]]; then
      echo "# ${f%.md}" > "memory-bank/$f"
      echo "" >> "memory-bank/$f"
      echo "<!-- TODO: populate during bootstrap or first session -->" >> "memory-bank/$f"
    fi
  done
  ok "memory-bank/ ready"
else
  info "Removing memory-bank/ (not in stack: $STACK)"
  rm -rf memory-bank
  rm -f .claude/rules/memory-bank.md 2>/dev/null
  ok "memory-bank/ removed"
fi

# ══════════════════════════════════════════════════════════════════════
# STEP 7 — Make scripts executable
# ══════════════════════════════════════════════════════════════════════
info "Setting script permissions..."

find scripts/ -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true
chmod +x .devcontainer/postinstall.sh .devcontainer/ssh-setup.sh 2>/dev/null || true

ok "Scripts executable"

# ══════════════════════════════════════════════════════════════════════
# STEP 8 — Add ssh-setup to Makefile
# ══════════════════════════════════════════════════════════════════════
if [[ -f Makefile ]] && ! grep -q 'ssh-setup' Makefile; then
  cat >> Makefile << 'MKEOF'

# ─── SSH ──────────────────────────────────────────────────────────────

.PHONY: ssh-setup
ssh-setup: ## Generate SSH key in container and print GitHub instructions
	bash .devcontainer/ssh-setup.sh
MKEOF
  ok "Added ssh-setup target to Makefile"
fi

# ══════════════════════════════════════════════════════════════════════
# STEP 9 — Reset git
# ══════════════════════════════════════════════════════════════════════
info "Resetting git..."

# Remove template remote
git remote remove origin 2>/dev/null || true

# Set new remote if provided
if [[ -n "$REPO_PATH" ]]; then
  git remote add origin "git@github.com:${REPO_PATH}.git"
  ok "Remote set to git@github.com:${REPO_PATH}.git"
else
  warn "No remote set — add one later with: git remote add origin <url>"
fi

# Stage everything and make initial commit
git add -A
git commit -m "chore: initialize ${PROJECT_NAME} from ai-template (stack: ${STACK})" --quiet

ok "Initial commit created"

# ══════════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════════

echo ""
echo -e "${BOLD}${GREEN}═══ Configuration complete ═══${NC}"
echo ""
echo -e "  Project:  ${BOLD}${PROJECT_NAME}${NC}"
echo -e "  Stack:    ${BOLD}${STACK}${NC}"
echo -e "  Branch:   feature/${PREFIX}-XXX-description → ${BASE_BRANCH} → ${PROD_BRANCH}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo "  1. Open in VS Code — it will prompt to reopen in devcontainer"
echo "     The container build installs all tools (Claude Code, Beads, bv, gh, etc.)"
echo ""
echo "  2. After the container is running, set up SSH for GitHub:"
echo -e "     ${DIM}make ssh-setup${NC}"
echo ""
echo "  3. Open Claude Code and say:"
echo -e "     ${CYAN}\"Run the bootstrap process in BOOTSTRAP.md\"${NC}"
echo ""
echo "     Bootstrap will ask about your tech stack, CI, environment, etc."
echo "     and finish hydrating the docs with project-specific details."
echo ""
[[ -z "$REPO_PATH" ]] && echo -e "  4. Don't forget to add a remote: ${DIM}git remote add origin <url>${NC}"
echo ""
