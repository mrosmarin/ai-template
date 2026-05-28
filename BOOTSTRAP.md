# Project Bootstrap

> **Run this once with Claude Code.** This file walks through an interactive setup that collects your project's details, then uses the answers to populate all the template docs. Delete this file when done.

---

## How it works

1. Open Claude Code at the repo root (devcontainer should already be running — all tools are pre-installed).
2. Say: **"Run the bootstrap process in BOOTSTRAP.md"**
3. Claude Code will ask the questions below, one section at a time.
4. After all answers are collected, Claude Code will:
   - Hydrate all template docs with your project-specific values.
   - Remove sections that don't apply to the chosen stack.
   - Initialize Beads (`bd init`) if the stack includes it.
   - Create the memory bank if the stack includes it.
   - Delete this file.
   - Commit: `chore(bootstrap): hydrate project docs — stack: <STACK>`

---

## Questions

Claude Code: ask these in order. Collect all answers before editing any files. If the user doesn't know an answer yet, mark it `TBD`.

### Q0 — Stack selection (ask first — everything else depends on this)

Which memory + tracking stack do you want?

| Stack | Memory Layer | Task Tracking | Stakeholder View |
|---|---|---|---|
| **all** | `memory-bank/*.md` + `bd remember` | Beads + Linear | Linear + `bv` |
| **bank-linear** | `memory-bank/*.md` | Linear | Linear |
| **beads-linear** | `bd remember` / `bd prime` | Beads + Linear | Linear + `bv` |
| **beads-memory** | `memory-bank/*.md` | Beads | `bv` (TUI / HTML export) |
| **beads** | `bd remember` / `bd prime` | Beads | `bv` (TUI / HTML export) |

### Q1 — Project identity

- What is the project name?
- One-line description?
- Is this a monorepo? If so, what is the root app directory?
- What is the GitHub repo path? (e.g. `org/repo-name`)

### Q2 — Linear workspace (skip if stack has no Linear)

- What is your Linear workspace slug?
- What is your ticket prefix? (e.g. `NOB`, `ENG`, `PROJ`)
- Multiple Linear projects/teams? List them with prefixes.

### Q3 — Branching & environments

- Base branch for feature work? (e.g. `qa`, `develop`, `staging`)
- Production branch? (e.g. `main`, `production`)
- Approvals required for prod merge?
- Branch protection: GitHub-enforced or convention-only?
- **If no Linear:** what prefix for branch names? (e.g. project initials)

### Q4 — Tech stack

- Language/framework?
- Package manager?
- Database?
- Hosting/deploy platform?
- Other key services?

### Q5 — Development environment

- Existing `.devcontainer/devcontainer.json`?
- Local services via Docker Compose?
- Dev server ports?
- Gitignored files to copy into worktrees? (patterns for `.worktreeinclude`)
- First-time setup sequence?

### Q6 — CI/CD

- CI workflows? What do they run?
- Test framework(s)?
- Deploy automation on merge?
- CI secret names?

### Q7 — Team

- Who's on the team?
- Solo project?
- External AI tools?

### Q8 — Existing docs

- Existing docs to preserve?
- Project-specific conventions?

---

## Stack → feature matrix

| Feature | all | bank-linear | beads-linear | beads-memory | beads |
|---|---|---|---|---|---|
| `memory-bank/*.md` created | ✅ | ✅ | ❌ | ✅ | ❌ |
| `bd init` + `bd setup claude` | ✅ | ❌ | ✅ | ✅ | ✅ |
| Linear questions (Q2) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Linear sections in docs | ✅ | ✅ | ✅ | ❌ | ❌ |
| Beads sections in docs | ✅ | ❌ | ✅ | ✅ | ✅ |
| Beads/bv targets in Makefile | ✅ | ❌ | ✅ | ✅ | ✅ |

---

## After collection

Claude Code: once all answers are gathered, perform these steps in order:

### Step 1 — Replace placeholders

Replace all `<PLACEHOLDER>` tokens across every template doc:

| Placeholder | Source |
|---|---|
| `<PROJECT_NAME>` | Q1 |
| `<PROJECT_DESCRIPTION>` | Q1 |
| `<REPO_PATH>` | Q1 |
| `<APP_ROOT>` | Q1 |
| `<STACK>` | Q0 |
| `<LINEAR_WORKSPACE>` | Q2 |
| `<PREFIX>` | Q2 (or Q3 if no Linear) |
| `<BASE_BRANCH>` | Q3 |
| `<PROD_BRANCH>` | Q3 |
| `<APPROVALS_REQUIRED>` | Q3 |
| `<PACKAGE_MANAGER>` | Q4 |
| `<DATABASE>` | Q4 |
| `<DEPLOY_PLATFORM>` | Q4 |
| `<DEV_PORT>` | Q5 |
| `<INSTALL_CMD>` | Q5 |
| `<DEV_CMD>` | Q5 |

### Step 2 — Remove inapplicable sections

Template files use `<!-- STACK:x,y,z -->` / `<!-- /STACK -->` markers. For the chosen stack: keep matching sections, delete non-matching ones, strip all markers.

### Step 3 — Initialize memory bank (if stack includes it)

For stacks `all`, `bank-linear`, `beads-memory` — populate `memory-bank/*.md` files from bootstrap answers. `.claude/rules/memory-bank.md` already exists.

### Step 4 — Initialize Beads (if stack includes it)

For stacks `all`, `beads-linear`, `beads-memory`, `beads`:

```bash
bd init --quiet
bd setup claude
```

### Step 5 — Hydrate scripts

In `scripts/worktree-new.sh`:
- `TICKET_PREFIX="<PREFIX>"` → actual prefix
- `BASE_BRANCH="<BASE_BRANCH>"` → actual base branch
- `<INSTALL_CMD>`, `<DEV_CMD>`, `<DEV_PORT>` in help text

In `.worktreeinclude`: set actual glob patterns from Q5.

`chmod +x scripts/*.sh`

### Step 6 — Update Makefile

Wire all targets to actual commands. Remove beads/bv targets if the stack doesn't include them. Remove commented-out placeholders that don't apply.

### Step 7 — Write README.md

Replace the template README with a project-specific one: name, description, setup instructions, architecture overview.

### Step 8 — Review

List any remaining `<PLACEHOLDER>`, `TBD`, or `<!-- STACK:... -->` markers.

### Step 9 — Delete this file and commit

```bash
rm BOOTSTRAP.md
git add -A
git commit -m "chore(bootstrap): hydrate project docs — stack: <STACK>"
```

---

## File manifest

After bootstrap, the repo should have:

| File | Purpose | All stacks? |
|---|---|---|
| `.devcontainer/postinstall.sh` | System tool installs (devcontainer lifecycle) | ✅ |
| `.devcontainer/SCRATCHPAD.md` | Personal capture file (gitignored) | ✅ |
| `CLAUDE.md` | Claude Code session instructions | ✅ |
| `CONTRIBUTING.md` | Branching, commits, PR process, CI, setup | ✅ |
| `DEPLOYMENT-ENV.md` | Environments, secrets, deploy pipeline | ✅ |
| `WORKTREES.md` | Parallel worktree workflow | ✅ |
| `README.md` | Project overview and quickstart | ✅ |
| `Makefile` | Day-to-day commands | ✅ |
| `scripts/worktree-new.sh` | Worktree creation helper | ✅ |
| `scripts/claude-audit.sh` | Claude Code permission auditor | ✅ |
| `.worktreeinclude` | Gitignored files to copy into worktrees | ✅ |
| `.claude/commands/checkpoint.md` | Save session state slash command | ✅ |
| `.claude/rules/memory-bank.md` | Rule to load memory bank | stacks with memory-bank |
| `memory-bank/` | Session memory files | stacks with memory-bank |
| `.beads/` | Beads database | stacks with beads |
