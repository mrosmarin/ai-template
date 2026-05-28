# AI Template — Starter Dev Kit for AI-Assisted Projects

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
| `configure.sh` | Bash (no deps needed) | Asks name/stack/prefix/branches, rewrites devcontainer.json, strips stack sections, replaces placeholders, resets git |
| Devcontainer build | `.devcontainer/postinstall.sh` | Installs system tools (Claude Code, Beads, bv, gh, Go, Node, etc.), writes Claude Code global settings |
| `make ssh-setup` | `.devcontainer/ssh-setup.sh` | Generates SSH key in container, prints instructions to add to GitHub |
| Bootstrap (Claude Code) | `BOOTSTRAP.md` | Asks tech stack/CI/env details, wires Makefile, populates memory bank, inits Beads, writes README, deletes itself |

## Stack options

`configure.sh` asks which **memory + tracking stack** you want:

| # | Stack | Memory Layer | Task Tracking | Stakeholder View |
|---|---|---|---|---|
| 1 | **all** | memory-bank + `bd remember` | Beads + Linear | Linear + `bv` |
| 2 | **bank-linear** | memory-bank | Linear | Linear |
| 3 | **beads-linear** | `bd remember` / `bd prime` | Beads + Linear | Linear + `bv` |
| 4 | **beads-memory** | memory-bank | Beads | `bv` exports |
| 5 | **beads** | `bd remember` / `bd prime` | Beads | `bv` exports |

## What's included

```
your-project/
├── .devcontainer/
│   ├── devcontainer.json        ← rewritten by configure.sh (project name, no host SSH)
│   ├── docker-compose.yml       ← container services
│   ├── postinstall.sh           ← system tool installs (runs at container build)
│   ├── ssh-setup.sh             ← generates SSH keys in-container
│   ├── .bashrc / .zshrc         ← shell config
│   ├── .env                     ← devcontainer secrets (gitignored)
│   └── SCRATCHPAD.md            ← personal ideas/TODOs/review checklist (gitignored)
├── .agents/skills/
│   └── checkpoint/              ← checkpoint skill (symlinked to .claude + .kilo)
├── .claude/
│   ├── rules/memory-bank.md     ← read memory bank at session start
│   ├── settings.json            ← project-level permissions
│   └── skills/ → .agents/skills ← symlink
├── .kilo/
│   ├── kilo.jsonc               ← Kilo Code MCP config
│   └── skills/ → .agents/skills ← symlink
├── memory-bank/                 ← session memory (stacks that include it)
├── scripts/
│   ├── worktree-new.sh          ← create feature-branch worktrees
│   └── claude-audit.sh          ← audit Claude Code permissions
├── .worktreeinclude             ← gitignored files to copy into worktrees
├── configure.sh                 ← run once after cloning (then delete)
├── BOOTSTRAP.md                 ← Claude Code deep hydration (then delete)
├── CLAUDE.md                    ← Claude Code session instructions
├── CONTRIBUTING.md              ← branching, commits, PR process
├── DEPLOYMENT-ENV.md            ← environments, secrets, deploy pipeline
├── WORKTREES.md                 ← parallel worktree workflow
└── Makefile                     ← day-to-day commands
```

## Day-to-day usage

```bash
make help                  # see all commands
make up                    # start local services + dev server
make ci                    # reproduce CI locally
make worktree-new TICKET=123 SLUG=my-feature
make claude-audit          # audit Claude Code permissions
make ssh-setup             # generate/show SSH key
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

## Tools installed by the devcontainer

| Tool | Purpose |
|---|---|
| [Claude Code](https://claude.ai) | AI coding agent |
| [Beads (bd)](https://github.com/gastownhall/beads) | Agent-native issue tracker |
| [Beads Viewer (bv)](https://github.com/Dicklesworthstone/beads_viewer) | TUI + graph visualization |
| [gh](https://cli.github.com) | GitHub CLI |
| [commitizen-go](https://github.com/lintingzhen/commitizen-go) | Conventional commits |
| Go, Node.js, Python, TypeScript | Language runtimes |
| Docker-in-Docker | Container builds inside the devcontainer |
| jq, uv | Utilities |

## License

MIT
