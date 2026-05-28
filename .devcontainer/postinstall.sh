#!/bin/bash
#
# .devcontainer/postinstall.sh — runs automatically when the devcontainer builds.
#
# Installs all system-level tools the dev environment needs. Stack-agnostic —
# everything is installed regardless of which memory/tracking stack the project
# chooses during bootstrap. Cheap to have, painful to not have.
#
# To re-run after a rebuild: bash .devcontainer/postinstall.sh

set -e

export SHELL=/bin/bash

echo "═══ System tools ═══"


curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-$(go env GOARCH)
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/linux/$(go env GOARCH)
chmod +x kubebuilder
sudo mv kubebuilder /usr/local/bin/

KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$(go env GOARCH)/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh


curl -L https://github.com/nats-io/natscli/archive/refs/tags/v0.3.0.tar.gz -o nats.tar.gz
tar -xzf nats.tar.gz
cd natscli-0.3.0

# Build
go build -o /usr/local/go/bin/nats ./nats
cd .. && rm -rf natscli-0.3.0 nats.tar.gz


docker network create -d=bridge --subnet=172.18.0.0/24 kind

kind version
kubebuilder version
docker --version
go version
kubectl version --client
helm version
nats --version

# install go debugger
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
if ! command -v jq &>/dev/null; then
  echo "→ Installing jq..."
  sudo apt-get update -qq && sudo apt-get install -y -qq jq
fi

# ── Claude Code ───────────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
  echo "→ Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# ── Beads (bd) — agent-native issue tracker ───────────────────────────
if ! command -v bd &>/dev/null; then
  echo "→ Installing Beads CLI..."
  curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash
fi

# ── Beads Viewer (bv) — TUI + graph visualization ────────────────────
if ! command -v bv &>/dev/null; then
  echo "→ Installing Beads Viewer..."
  curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh?$(date +%s)" | bash
fi

# ── uv (Python package manager) ──────────────────────────────────────
if ! command -v uv &>/dev/null; then
  echo "→ Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi


# Add GitHub CLI's official GPG key and repo
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install
sudo apt update && sudo apt install gh -y



# ── Commitizen (Go) ──────────────────────────────────────────────────
if ! command -v git-cz &>/dev/null; then
  echo "→ Installing commitizen-go..."
  git clone https://github.com/lintingzhen/commitizen-go.git /tmp/commitizen-go
  cd /tmp/commitizen-go && make && sudo make install && cd - && rm -rf /tmp/commitizen-go
fi

echo ""
echo "═══ Node.js global tools ═══"

# ── pnpm global packages ─────────────────────────────────────────────
# Uncomment the tools your stack needs:
pnpm i -g @kilocode/cli
pnpm i -g @nestjs/cli
pnpm add turbo --global

echo ""
echo "═══ Claude Code settings ═══"

# Ensure Claude home dir exists with correct ownership
sudo mkdir -p /home/node/.claude 2>/dev/null || true
sudo chown -R "$(id -u):$(id -g)" /home/node/.claude 2>/dev/null || true
mkdir -p ~/.claude

cat > ~/.claude/settings.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "defaultMode": "acceptEdits",
  "permissions": {
    "allow": [
      "mcp__*",
      "Bash(find *)",
      "Bash(pwd)",
      "Bash(awk *)",
      "Bash(env)",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(echo *)",
      "Bash(wc *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(sort *)",
      "Bash(uniq *)",
      "Bash(diff *)",
      "Bash(which *)",
      "Bash(git *)",
      "Bash(gh *)",
      "Bash(npx *)",
      "Bash(pnpm *)",
      "Bash(npm *)",
      "Bash(node *)",
      "Bash(python3 *)",
      "Bash(deno *)",
      "Bash(make *)",
      "Bash(curl *)",
      "Bash(timeout *)",
      "Bash(pkill -f *)",
      "Bash(bd *)",
      "Bash(bv *)",
      "Bash(*supabase *)",
      "Bash(*playwright *)",
      "Bash(*prisma *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(rm -r *)",
      "Bash(sudo *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(git clean -fd*)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(~/.ssh/**)",
      "Read(/root/.ssh/**)",
      "Read(~/.aws/credentials)",
      "Read(~/.config/gcloud/**)",
      "Read(~/.azure/**)"
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
EOF

echo "✓ Claude Code global settings written to ~/.claude/settings.json"

echo ""
echo "═══ Verify ═══"

for cmd in gh jq claude bd bv uv git; do
  if command -v "$cmd" &>/dev/null; then
    echo "  ✓ $cmd"
  else
    echo "  ✗ $cmd (not found)"
  fi
done

echo ""
echo "═══ Postinstall complete ═══"
echo ""
echo "Next: open Claude Code and say 'Run the bootstrap process in BOOTSTRAP.md'"
echo ""
