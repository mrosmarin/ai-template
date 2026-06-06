#!/bin/bash
set -e
export SHELL=/bin/bash

echo "═══ System tools ═══"

curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-$(go env GOARCH)
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/linux/$(go env GOARCH)
chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/

KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$(go env GOARCH)/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh && ./get_helm.sh && rm ./get_helm.sh

curl -L https://github.com/nats-io/natscli/archive/refs/tags/v0.3.0.tar.gz -o nats.tar.gz
tar -xzf nats.tar.gz && cd natscli-0.3.0
go build -o /usr/local/go/bin/nats ./nats
cd .. && rm -rf natscli-0.3.0 nats.tar.gz

# Create a "kind" Docker network with a /24 subnet.
# Skip if the network already exists. If the preferred subnet (172.18.0.0/24)
# is already claimed by another network, find the first free 172.18.X.0/24.
if docker network inspect kind &>/dev/null; then
  echo "→ Docker network 'kind' already exists — skipping"
else
  USED_SUBNETS=$(docker network ls -q 2>/dev/null | xargs -I{} docker network inspect --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' {} 2>/dev/null || true)
  SUBNET=""
  for i in $(seq 0 254); do
    CANDIDATE="172.18.${i}.0/24"
    if ! echo "$USED_SUBNETS" | grep -qF "$CANDIDATE"; then
      SUBNET="$CANDIDATE"
      break
    fi
  done
  if [[ -n "$SUBNET" ]]; then
    docker network create -d=bridge --subnet="$SUBNET" kind
    echo "→ Created Docker network 'kind' with subnet $SUBNET"
  else
    echo "⚠ Could not find a free 172.18.X.0/24 subnet — skipping kind network"
  fi
fi

go install github.com/go-delve/delve/cmd/dlv@latest

# ── GitHub CLI ────────────────────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  echo "→ Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
    https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt-get update -qq && sudo apt-get install gh -y -qq
fi

# ── jq ────────────────────────────────────────────────────────────────
command -v jq &>/dev/null || { sudo apt-get update -qq && sudo apt-get install -y -qq jq; }

# ── Claude Code ───────────────────────────────────────────────────────
command -v claude &>/dev/null || { curl -fsSL https://claude.ai/install.sh | bash; }

# ── Beads (bd) ────────────────────────────────────────────────────────
command -v bd &>/dev/null || { curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash; }

# ── Beads Viewer (bv) ────────────────────────────────────────────────
command -v bv &>/dev/null || { curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh?$(date +%s)" | bash; }

# ── uv (Python package manager) ──────────────────────────────────────
command -v uv &>/dev/null || { curl -LsSf https://astral.sh/uv/install.sh | sh; }

# ── Commitizen (Go) ──────────────────────────────────────────────────
if ! command -v git-cz &>/dev/null; then
  echo "→ Installing commitizen-go..."
  git clone https://github.com/lintingzhen/commitizen-go.git /tmp/commitizen-go
  # Build as the current user (who has Go on PATH), then copy the binary.
  # `sudo make install` would re-run the build as root, which lacks Go.
  (cd /tmp/commitizen-go && make && sudo cp commitizen-go /usr/local/bin/git-cz)
  rm -rf /tmp/commitizen-go
fi

echo ""
echo "═══ Node.js global tools ═══"
pnpm i -g @kilocode/cli
pnpm i -g @nestjs/cli
pnpm add turbo --global

echo ""
echo "═══ Claude Code settings ═══"
sudo mkdir -p /home/node/.claude 2>/dev/null || true
sudo chown -R "$(id -u):$(id -g)" /home/node/.claude 2>/dev/null || true
mkdir -p ~/.claude

# Always (re)write global settings so a stale copy persisted in the
# claude-code-config volume doesn't shadow template updates.
cat > ~/.claude/settings.json << 'SETTINGS'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "defaultMode": "acceptEdits",
  "permissions": {
    "allow": [
      "mcp__*",
      "Read(**)",
      "Edit(**)",
      "Write(**)",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(find *)",
      "Bash(echo *)",
      "Bash(pwd)",
      "Bash(which *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(wc *)",
      "Bash(sort *)",
      "Bash(uniq *)",
      "Bash(diff *)",
      "Bash(cd *)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Bash(mv *)",
      "Bash(touch *)",
      "Bash(test *)",
      "Bash(env)",
      "Bash(git *)",
      "Bash(gh *)",
      "Bash(npm *)",
      "Bash(npx *)",
      "Bash(pnpm *)",
      "Bash(yarn *)",
      "Bash(node *)",
      "Bash(python3 *)",
      "Bash(pip *)",
      "Bash(uv *)",
      "Bash(pytest *)",
      "Bash(ruff *)",
      "Bash(mypy *)",
      "Bash(go *)",
      "Bash(cargo *)",
      "Bash(make *)",
      "Bash(jq *)",
      "Bash(sed *)",
      "Bash(awk *)",
      "Bash(curl *)",
      "Bash(bd *)",
      "Bash(bv *)",
      "Bash(chmod *)",
      "Bash(claude *)",
      "Bash(cut *)",
      "Bash(deno *)",
      "Bash(docker *)",
      "Bash(env *)",
      "Bash(export *)",
      "Bash(helm *)",
      "Bash(kubectl *)",
      "Bash(ln *)",
      "Bash(printf *)",
      "Bash(pwd *)",
      "Bash(source *)",
      "Bash(tee *)",
      "Bash(tr *)",
      "Bash(wget *)",
      "Bash(xargs *)",
      "Bash(yq *)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf /*)",
      "Bash(rm -rf ~)",
      "Bash(rm -rf ~/*)",
      "Bash(rm -rf $HOME*)",
      "Bash(sudo rm*)",
      "Bash(:(){ :|:& };:*)",
      "Bash(mkfs*)",
      "Bash(dd if=* of=/dev/*)",
      "Bash(> /dev/sd*)",
      "Bash(chmod -R 777 /*)",
      "Bash(git push --force*)",
      "Bash(git push -f*)",
      "Bash(git reset --hard*)",
      "Bash(git clean -fd*)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Read(./secrets/**)",
      "Read(**/secrets/**)",
      "Read(~/.ssh/**)",
      "Read(/root/.ssh/**)",
      "Read(~/.aws/credentials)",
      "Read(~/.config/gcloud/**)",
      "Read(~/.azure/**)",
      "Edit(./.env)",
      "Edit(**/.env)",
      "Write(./.env)",
      "Write(**/.env)"
    ]
  },
  "additionalDirectories": [
    "/tmp"
  ],
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0"
  },
  "theme": "dark",
  "enableAllProjectMcpServers": true
}
SETTINGS
echo "✓ Claude Code global settings written"

echo ""


echo ""
echo "═══ Agent skills + MCP link ═══"

# .agents/skills is the source of truth (committed). Copy it into the
# tool-specific dirs (gitignored) so Claude Code and Kilo Code see the
# skills. Copies can't dangle the way symlinks can. Re-sync any time
# with: make skills-sync
if [[ -d ./.agents/skills ]]; then
  rm -rf ./.claude/skills ./.kilo/skills
  mkdir -p ./.claude ./.kilo
  cp -R ./.agents/skills ./.claude/skills
  cp -R ./.agents/skills ./.kilo/skills
  echo "  ✓ synced .agents/skills → .claude/skills and .kilo/skills"
else
  echo "  ⚠ .agents/skills not found — skipping skill sync"
fi

# .mcp.json stays a symlink → .claude/mcp.json (single file, repair if needed)
if [[ -f ./.claude/mcp.json ]]; then
  if [[ ! -L ./.mcp.json ]] || [[ "$(readlink ./.mcp.json 2>/dev/null)" != ".claude/mcp.json" ]]; then
    rm -rf ./.mcp.json
    ln -s .claude/mcp.json ./.mcp.json
    echo "  ✓ repaired .mcp.json → .claude/mcp.json"
  else
    echo "  ✓ .mcp.json"
  fi
else
  echo "  ⚠ .claude/mcp.json not found — skipping .mcp.json link"
fi

echo "═══ Verify ═══"
for cmd in gh jq claude bd bv uv git go node pnpm git-cz; do
  command -v "$cmd" &>/dev/null && echo "  ✓ $cmd" || echo "  ✗ $cmd"
done

kind version; kubebuilder version; docker --version; go version
kubectl version --client; helm version; nats --version

echo ""
echo "═══ Postinstall complete ═══"
echo "Next: make ssh-setup → Claude Code → 'Run bootstrap in BOOTSTRAP.md'"
