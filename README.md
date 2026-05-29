# AI Template — Starter Dev Kit for AI-Assisted Projects

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/mrosmarin/ai-template)](https://github.com/mrosmarin/ai-template/commits/main)

An opinionated devcontainer template for building software with AI coding agents (Claude Code, Kilo Code). Pre-configured tooling, memory systems, task tracking, and workflow docs — all templatized and hydrated to your project in two steps.

## Quick start

```bash
# 1. Clone the template into your project
git clone https://github.com/mrosmarin/ai-template.git my-project
cd my-project

# 2. Configure (asks project name, stack, prefix, branches — takes 30 seconds)
./configure.sh

# 3. Open in VS Code → devcontainer builds automatically
#    All tools installed: Claude Code, Beads, bv, gh, jq, Go, Node, Python, Docker-in-Docker

# 4. Set up SSH for GitHub (keys generated in-container, not mounted from host)
make ssh-setup

# 5. Open Claude Code and say:
#    "Run the bootstrap process in BOOTSTRAP.md"
#    (asks about tech stack, CI, environment — finishes hydrating the docs)
```

## What happens at each step

| Step | What runs | What it does |
|---|---|---|
| `configure.sh` | Bash (no deps needed) | Asks name/stack/prefix/branches, rewrites devcontainer.json, strips stack sections, replaces placeholders, sets up `.devcontainer/.env`, resets git |
| Devcontainer build | `postinstall.sh` | Installs system tools (Claude Code, Beads, bv, gh, Go, Node, kubectl, helm, etc.), writes Claude Code global settings |
| `make ssh-setup` | `ssh-setup.sh` | Generates ed25519 key in-container, prints instructions to add to GitHub |
| `make mcp-add NAME=linear` | `mcp-add.sh` | Adds MCP server presets to both Claude Code and Kilo Code configs |
| Bootstrap (Claude Code) | `BOOTSTRAP.md` | Asks tech stack/CI/env details, wires Makefile, populates memory bank, inits Beads, writes project README, deletes itself |

## Stack options

`configure.sh` asks which **memory + tracking stack** you want:

| # | Stack | Memory Layer | Task Tracking | Stakeholder View |
|---|---|---|---|---|
| 1 | **all** | memory-bank + `bd remember` | Beads + Linear | Linear + `bv` |
| 2 | **bank-linear** | memory-bank | Linear | Linear |
| 3 | **beads-linear** | `bd remember` / `bd prime` | Beads + Linear | Linear + `bv` |
| 4 | **beads-memory** | memory-bank | Beads | `bv` exports |
| 5 | **beads** | `bd remember` / `bd prime` | Beads | `bv` exports |

## What each tool does

- **[Claude Code](https://claude.ai)** — AI coding agent that reads CLAUDE.md for project instructions
- **[Kilo Code](https://kilo.ai)** — Alternative AI coding agent with shared skills and MCP config
- **[Beads (bd)](https://github.com/gastownhall/beads)** — Agent-native issue tracker with dependency graphs and persistent memory
- **[Beads Viewer (bv)](https://github.com/Dicklesworthstone/beads_viewer)** — TUI + HTML export for Beads — kanban, PageRank, critical path
- **[Linear](https://linear.app)** — Cloud PM tool for stakeholders. Ticket IDs in branch names.

## Project structure (after setup)

```
your-project/
├── .agents/skills/              ← shared agent skills (symlinked from .claude + .kilo)
├── .claude/
│   ├── mcp.json                 ← MCP server config (symlinked as .mcp.json at root)
│   ├── rules/memory-bank.md     ← session rule: read memory bank at start
│   └── settings.json            ← project-level Claude Code permissions
├── .kilo/
│   ├── kilo.jsonc               ← Kilo Code MCP config
│   └── rules/memory-bank.md     ← session rule: read memory bank at start
├── .devcontainer/
│   ├── devcontainer.json        ← container config (rewritten by configure.sh)
│   ├── docker-compose.yml       ← container services
│   ├── postinstall.sh           ← system tool installs (runs at build)
│   ├── ssh-setup.sh             ← in-container SSH key generation
│   ├── .bashrc / .zshrc         ← shell config
│   ├── .env                     ← devcontainer secrets (gitignored)
│   └── SCRATCHPAD.md            ← personal ideas/TODOs/review checklist (gitignored)
├── memory-bank/                 ← session memory (stacks that include it)
├── scripts/
│   ├── worktree-new.sh          ← create feature-branch worktrees
│   ├── claude-audit.sh          ← audit Claude Code permissions
│   └── mcp-add.sh              ← add MCP server presets to both configs
├── configure.sh                 ← run once after cloning (then safe to delete)
├── BOOTSTRAP.md                 ← Claude Code deep setup (deletes itself when done)
├── CLAUDE.md                    ← Claude Code session instructions
├── CONTRIBUTING.md              ← branching, commits, PR process
├── DEPLOYMENT-ENV.md            ← environments, secrets, deploy pipeline
├── WORKTREES.md                 ← parallel worktree workflow
└── Makefile                     ← day-to-day commands
```

**Git symlinks** keep configs in sync across both agents:
- `.claude/skills/` and `.kilo/skills/` → `.agents/skills/` — both agents share one set of skills
- `.mcp.json` → `.claude/mcp.json` — single source of truth for MCP config

These are committed as symlinks (Docker can't bind-mount within the workspace on macOS), so they work on clone with no setup. On Windows, enable `git config core.symlinks true`.

## Daily commands

```bash
make help                  # see all commands
make up                    # start local services + dev server
make ci                    # full CI gate locally
make ssh-setup             # generate/show SSH key
make worktree-new TICKET=123 SLUG=my-feature
make claude-audit          # audit Claude Code permissions
make mcp-add NAME=linear   # add an MCP server preset
make mcp-list              # show available presets
```

**With Beads (stacks that include it):**
```bash
make bd-ready              # unblocked tasks
make bd-prime              # load agent context
make bv-triage             # AI-optimized recommendations
make bv-export             # HTML graph for stakeholders
```

**Session management in Claude Code:**
- `/checkpoint` — save state before devcontainer refresh
- "check scratchpad" — triage captured ideas into tickets
- "start a review" — walk the review checklist

## MCP server presets

The template ships with three core MCPs (github, playwright, context7). Add more with:

```bash
make mcp-add NAME=linear        # Linear project management
make mcp-add NAME=vercel        # Vercel deployment
make mcp-add NAME=supabase      # Local Supabase
make mcp-add NAME=next-devtools # Next.js devtools
make mcp-add NAME=shadcn        # shadcn/ui components
```

Each preset adds to both `.claude/mcp.json` and `.kilo/kilo.jsonc` in one command.

## License

MIT
