---
name: checkpoint
description: >
  Save session state before a devcontainer refresh or end of session.
  Use when the user says "checkpoint", "save state", "before refresh", "handoff", or "wrap up".
argument-hint: '[optional note about what to emphasize]'
user-invocable: true
---

# Checkpoint

Persist session state so a devcontainer refresh picks up where this one left off.
On-demand version of CLAUDE.md "Pre-commit hygiene order" with a guaranteed push.

## Hard rules

- **Never touch `SCRATCHPAD.md`.** Reading OK; writing/staging forbidden.
- **Never commit or push without an explicit "yes".**
- **Never stage secrets.** `.devcontainer/.env` and `.env*` are gitignored.
- **Never push directly to `<BASE_BRANCH>` or `<PROD_BRANCH>`.**

## Procedure

### Step 0 — Orient

<!-- STACK:all,bank-linear,beads-memory -->
1. Read `memory-bank/*.md`.
<!-- /STACK -->
<!-- STACK:all,beads-linear,beads-memory,beads -->
1. Run `bd prime`.
<!-- /STACK -->
2. `git branch --show-current && git status --short && git log --oneline -8`
<!-- STACK:all,beads-linear,beads-memory,beads -->
3. `bd ready --json 2>/dev/null`
<!-- /STACK -->

<!-- STACK:all,bank-linear,beads-memory -->
### Step 1 — Memory bank

Update `activeContext.md` (dated banner, focus, next steps) and `progress.md`. Others as touched.
<!-- /STACK -->

<!-- STACK:all,beads-linear,beads-memory,beads -->
### Step 1b — Beads

`bd update`, `bd close`, `bd remember`, `bd create` for discovered tasks.
<!-- /STACK -->

### Step 2 — Docs

Update only what changed.

<!-- STACK:all,bank-linear,beads-linear -->
### Step 3 — Linear

Comment on each ticket: what landed, delegations, verifications. Tick verified boxes. Record next ticket.
<!-- /STACK -->

### Step 4 — Branch guard

If on `<BASE_BRANCH>` or `<PROD_BRANCH>`: `git checkout -b chore/<PREFIX>-XXX-checkpoint`

### Step 5 — Stage, show, WAIT

`git add memory-bank/ <changed docs...>` — NEVER `git add -A`, NEVER stage SCRATCHPAD or .env.
Show staged files + proposed message. **Stop and wait for "yes."**

### Step 6 — Persist

```bash
git commit -m "chore(checkpoint): persist session state — <topic>"
git push -u origin HEAD
```
<!-- STACK:all,beads-linear,beads-memory,beads -->
```bash
bd dolt push 2>/dev/null || true
```
<!-- /STACK -->

Print resume card: branch, SHA, active task/ticket, next steps, env var names to re-add.

## Related

- `CLAUDE.md` — pre-commit hygiene, ticket close-out, branching.
<!-- STACK:all,bank-linear,beads-memory -->
- `.claude/rules/memory-bank.md`
<!-- /STACK -->
- `.devcontainer/SCRATCHPAD.md` (never edit/stage)
