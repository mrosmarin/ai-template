# Project Bootstrap

> **Run this with Claude Code after `configure.sh` has already set up the project basics.** This handles the deeper, project-specific configuration that benefits from AI assistance.

---

## Prerequisites

Before running this, you should have already:
1. Cloned the template: `git clone https://github.com/mrosmarin/ai-template.git <project>`
2. Run `./configure.sh` (set project name, stack, prefix, branches)
3. Opened in VS Code devcontainer (tools installed automatically)
4. Run `make ssh-setup` to connect to GitHub

**Stack:** The `configure.sh` already set the stack to **`<STACK>`** and stripped inapplicable sections from all docs.

---

## Questions

Claude Code: ask these in order. Collect all answers before editing files. Mark unknowns as `TBD`.

### Q1 — Tech stack

- What language/framework? (e.g. Next.js, Rails, Go, Python/FastAPI)
- Package manager? (e.g. pnpm, npm, yarn, pip, cargo)
- Database? (e.g. Supabase/Postgres, PlanetScale, MongoDB, none yet)
- Hosting/deploy platform? (e.g. Vercel, Railway, Fly.io, AWS)
- Any other key services? (e.g. Redis, S3, Stripe, auth provider)

### Q2 — Development environment

- Are there local services via Docker Compose? (database, Redis, etc.)
- What ports do your dev servers use? (e.g. `3000`, `8080`)
- What additional gitignored files need to be in `.worktreeinclude`? (e.g. `apps/*/.env.local`)
- What is the install command? (e.g. `pnpm install`, `npm install`, `go mod download`)
- What is the dev server command? (e.g. `pnpm dev`, `npm run dev`, `go run .`)

### Q3 — CI/CD

- Do you have CI workflows already? What do they run? (lint, types, tests, build)
- What test framework(s)? (e.g. Vitest, Jest, Playwright, pytest)
- Any deploy automation on merge?
- CI secret names? (not values)

### Q4 — Linear workspace (only if stack includes Linear)

- What is your Linear workspace slug? (the part after `linear.app/`)
- Multiple Linear projects/teams? List them with prefixes.

### Q5 — Team

- Who's on the team? (names and roles)
- Solo project?
- External AI tools? (Lovable, Cursor, etc.)

### Q6 — Existing docs

- Any existing docs, architecture notes, or README content to preserve?
- Project-specific conventions not covered above?

---

## After collection

### Step 1 — Replace remaining placeholders

These are the values `configure.sh` couldn't fill in:

| Placeholder | Source |
|---|---|
| `<APP_ROOT>` | Q1 — monorepo app directory (or `.` if flat) |
| `<PACKAGE_MANAGER>` | Q1 |
| `<DATABASE>` | Q1 |
| `<DEPLOY_PLATFORM>` | Q1 |
| `<DEV_PORT>` | Q2 |
| `<INSTALL_CMD>` | Q2 |
| `<DEV_CMD>` | Q2 |
| `<LINEAR_WORKSPACE>` | Q4 (if applicable) |

Replace across: `CLAUDE.md`, `CONTRIBUTING.md`, `DEPLOYMENT-ENV.md`, `WORKTREES.md`, `Makefile`, `scripts/worktree-new.sh`.

### Step 2 — Wire the Makefile

Fill in all commented-out placeholder targets (`# <BUILD_CMD>`, `# <LINT_CMD>`, etc.) with actual commands. Remove targets that don't apply (e.g. `db-*` if no database).

### Step 3 — Update .worktreeinclude

Add any additional glob patterns from Q2.

### Step 4 — Initialize Beads (if stack includes it)

```bash
bd init --quiet
bd setup claude
```

### Step 5 — Populate memory bank (if stack includes it)

Fill in `memory-bank/*.md` files from the answers. Mark gaps with `<!-- TODO: fill in after first sprint -->`.

### Step 6 — Write README.md

Replace the template README with a project-specific one: name, description, architecture, setup instructions.

### Step 7 — Fill in DEPLOYMENT-ENV.md

Add actual env var tables, secret inventory, cost summary based on Q1-Q3 answers.

### Step 8 — Review

List any remaining `<PLACEHOLDER>` or `TBD` markers for the user.

### Step 9 — Delete this file and commit

```bash
rm BOOTSTRAP.md
git add -A
git commit -m "chore(bootstrap): complete project setup via Claude Code"
```
