# AI Template — Starter Dev Kit for AI-Assisted Projects

An opinionated devcontainer template for building software with AI coding agents (Claude Code, Kilo Code, etc.). Includes pre-configured tooling, memory systems, task tracking, and workflow docs that get hydrated to your specific project during an interactive bootstrap.

## What's in the box

| Category | What you get |
|---|---|
| **Devcontainer** | VS Code + Docker-in-Docker, system tools pre-installed, Claude Code settings |
| **Memory** | Memory bank (markdown) and/or Beads (Dolt-powered agent memory) — you choose |
| **Task tracking** | Linear and/or Beads — you choose |
| **Workflow docs** | CLAUDE.md, CONTRIBUTING.md, DEPLOYMENT-ENV.md, WORKTREES.md — all templated |
| **Git workflow** | Feature branching, worktree helpers, conventional commits, PR templates |
| **Scripts** | Worktree creation, Claude Code permission audit, Makefile with common targets |
| **Personal tools** | Scratchpad for ideas/TODOs/reviews, checkpoint command to save session state |

## Quick start

### 1. Create your project from this template

**Option A — GitHub template** (recommended):

Click **"Use this template"** → **"Create a new repository"** on GitHub. Then clone your new repo and open in VS Code.

**Option B — Clone into an existing project:**

```bash
# From your project root
git clone https://github.com/mrosmarin/ai-template.git .ai-template-tmp
cp -r .ai-template-tmp/{.devcontainer,.claude,.agents,.kilo,scripts,memory-bank,BOOTSTRAP.md,CLAUDE.md,CONTRIBUTING.md,DEPLOYMENT-ENV.md,WORKTREES.md,Makefile,.worktreeinclude,.claudeignore,.kilocodeignore,.gitignore} .
rm -rf .ai-template-tmp
```

### 2. Open in devcontainer

Open the project in VS Code. It will prompt to **"Reopen in Container"** — say yes. The devcontainer builds and `.devcontainer/postinstall.sh` installs all system tools automatically (Claude Code, Beads, bv, gh, jq, etc.).

### 3. Run the bootstrap

Open Claude Code and say:

> **Run the bootstrap process in BOOTSTRAP.md**

Claude Code will ask you questions about your project — name, stack choice, Linear workspace, branching model, tech stack, etc. — then hydrate all the template docs with your answers and delete `BOOTSTRAP.md`.

## Stack options

The first bootstrap question is which **memory + tracking stack** you want:

| Stack | Memory Layer | Task Tracking | Stakeholder View | Best for |
|---|---|---|---|---|
| **all** | memory-bank + `bd remember` | Beads + Linear | Linear + `bv` | Full setup, team with PM |
| **bank-linear** | memory-bank | Linear | Linear | Teams already using Linear |
| **beads-linear** | `bd remember` / `bd prime` | Beads + Linear | Linear + `bv` | Agent-first + stakeholder PM |
| **beads-memory** | memory-bank | Beads | `bv` exports | Solo dev, no cloud PM |
| **beads** | `bd remember` / `bd prime` | Beads | `bv` exports | Minimal, all-local |

You can always change later by re-running the relevant setup commands.

## What each tool does

**Claude Code** — AI coding agent that reads CLAUDE.md for project instructions and follows your workflow.

**Memory bank** (`memory-bank/*.md`) — flat markdown files that Claude Code reads at session start. Simple, git-tracked, human-readable. Survives devcontainer rebuilds via git.

**Beads** (`bd`) — Dolt-powered issue tracker designed for AI agents. Dependency graphs, `bd ready` for unblocked work, `bd remember` for persistent memory, `bd prime` to inject context. [Docs →](https://gastownhall.github.io/beads/)

**Beads Viewer** (`bv`) — TUI and HTML export for Beads. Kanban boards, PageRank analysis, critical path visualization, stakeholder reports. [Docs →](https://github.com/Dicklesworthstone/beads_viewer)

**Linear** — cloud PM tool for stakeholders. Ticket IDs go in branch names. Claude Code posts comments on tickets during checkpoints.

## Project structure (after bootstrap)

```
your-project/
├── .devcontainer/
│   ├── devcontainer.json          ← VS Code devcontainer config
│   ├── postinstall.sh             ← system tool installs (runs at build)
│   ├── .env                       ← devcontainer secrets (gitignored)
│   └── SCRATCHPAD.md              ← personal capture file (gitignored)
├── .claude/
│   ├── commands/
│   │   └── checkpoint.md          ← /checkpoint slash command
│   ├── rules/
│   │   └── memory-bank.md         ← rule to read memory bank at session start
│   ├── settings.json              ← project-level Claude Code permissions
│   └── worktrees/                 ← worktree working dirs (gitignored)
├── .agents/skills/                ← pinned agent skills
├── memory-bank/                   ← session memory (if stack includes it)
│   ├── activeContext.md
│   ├── progress.md
│   └── ...
├── scripts/
│   ├── worktree-new.sh            ← create feature-branch worktrees
│   └── claude-audit.sh            ← audit Claude Code permissions
├── .worktreeinclude               ← gitignored files to copy into worktrees
├── CLAUDE.md                      ← Claude Code session instructions
├── CONTRIBUTING.md                ← branching, commits, PR process
├── DEPLOYMENT-ENV.md              ← environments, secrets, deploy pipeline
├── WORKTREES.md                   ← parallel worktree workflow
├── Makefile                       ← day-to-day commands
└── README.md                      ← project overview (this becomes yours)
```

## Day-to-day usage

```bash
make help                  # see all available commands
make up                    # start local services + dev server
make ci                    # reproduce CI locally
make worktree-new TICKET=123 SLUG=my-feature   # parallel worktree
make claude-audit          # audit Claude Code permissions
```

**With Beads:**
```bash
make bd-ready              # unblocked tasks
make bd-prime              # load agent context
make bv-triage             # AI-optimized task recommendations
make bv-export             # HTML graph for stakeholders
```

**Session management:**
- Say `/checkpoint` in Claude Code to save state before a devcontainer refresh
- Say "check scratchpad" to triage captured ideas/TODOs into tickets
- Say "start a review" to walk through the review checklist in your scratchpad

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow.

## License

MIT
