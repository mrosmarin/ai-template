#!/bin/bash

set -e

export SHELL=/bin/bash


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


# curl -fsSL https://get.pnpm.io/install.sh | sh -
# bash -i -c 'nvm install --lts'

pnpm i -g  @kilocode/cli
pnpm i -g @nestjs/cli

curl -fsSL https://claude.ai/install.sh | bash

# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

# curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh?$(date +%s)" | bash

curl -LsSf https://astral.sh/uv/install.sh | sh

# Add GitHub CLI's official GPG key and repo
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install
sudo apt update && sudo apt install gh -y



git clone https://github.com/lintingzhen/commitizen-go.git  /tmp/commitizen-go
cd /tmp/commitizen-go
make 
sudo make install

pnpm add turbo --global

sudo chown -R 1000:1000 /home/node/.claude 
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
