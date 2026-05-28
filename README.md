# AI Template — Starter Dev Kit for AI-Assisted Projects

An opinionated devcontainer template for building software with AI coding agents (Claude Code, Kilo Code). Pre-configured tooling, memory systems, task tracking, and workflow docs.

## Quick start

```bash
git clone https://github.com/mrosmarin/ai-template.git my-project
cd my-project
./configure.sh              # asks name, stack, prefix, branches (30 seconds)
# Open in VS Code → devcontainer builds → tools installed automatically
make ssh-setup              # generate SSH key, print GitHub instructions
# Open Claude Code: "Run the bootstrap process in BOOTSTRAP.md"
```

## What happens at each step

| Step | What runs | What it does |
|---|---|---|
| `configure.sh` | Bash (no deps) | Asks name/stack/prefix/branches, rewrites devcontainer.json, strips stack sections, replaces placeholders, resets git |
| Devcontainer build | `postinstall.sh` | Installs tools (Claude Code, Beads, bv, gh, Go, Node, kubectl, helm, etc.) + Claude Code settings |
| `make ssh-setup` | `ssh-setup.sh` | Generates ed25519 key in-container, prints GitHub instructions |
| Bootstrap | `BOOTSTRAP.md` via Claude Code | Asks tech stack/CI/env, wires Makefile, populates memory bank, inits Beads, writes README |

## Stack options

| # | Stack | Memory | Tracking | Stakeholder View |
|---|---|---|---|---|
| 1 | **all** | memory-bank + `bd remember` | Beads + Linear | Linear + `bv` |
| 2 | **bank-linear** | memory-bank | Linear | Linear |
| 3 | **beads-linear** | `bd remember` | Beads + Linear | Linear + `bv` |
| 4 | **beads-memory** | memory-bank | Beads | `bv` exports |
| 5 | **beads** | `bd remember` | Beads | `bv` exports |

## Project structure (after setup)

```
.agents/skills/checkpoint/   ← checkpoint skill (symlinked to .claude + .kilo)
.claude/rules/               ← session rules (memory bank read)
.claude/skills/              ← symlink → .agents/skills
.devcontainer/               ← devcontainer config, postinstall, ssh-setup, scratchpad
.kilo/skills/                ← symlink → .agents/skills
memory-bank/                 ← session memory (stacks that include it)
scripts/                     ← worktree-new.sh, claude-audit.sh
CLAUDE.md                    ← Claude Code session instructions
CONTRIBUTING.md              ← branching, commits, PR process
DEPLOYMENT-ENV.md            ← environments, secrets, deploy pipeline
WORKTREES.md                 ← parallel worktree workflow
Makefile                     ← all day-to-day commands
```

## Daily commands

```bash
make help                  # all commands
make up                    # start services + dev server
make ci                    # full CI gate locally
make worktree-new TICKET=123 SLUG=my-feature
make ssh-setup             # generate/show SSH key
make claude-audit          # audit Claude Code permissions
make bd-ready              # unblocked beads tasks (beads stacks)
make bv-triage             # AI recommendations (beads stacks)
make bv-export             # HTML graph for stakeholders (beads stacks)
```

## Tools installed

Claude Code, Beads (bd), Beads Viewer (bv), gh CLI, commitizen-go, Go, Node.js, Python, TypeScript, Docker-in-Docker, kubectl, helm, kind, kubebuilder, nats CLI, uv, jq, delve

## License

MIT
