# Claude Code — Project Instructions

## Start of Every Session

<!-- STACK:all,bank-linear,beads-memory -->
1. Read `.claude/rules/memory-bank.md`
2. Read **all files** in `memory-bank/`
<!-- /STACK -->
<!-- STACK:beads,beads-linear -->
1. Run `bd prime` to load persistent memory and workflow context.
<!-- /STACK -->
<!-- STACK:all -->
3. Run `bd prime` to load Beads context alongside the memory bank.
<!-- /STACK -->

---

## Who I Am

I'm a senior software engineer working on the <PROJECT_NAME> MVP. I focus on the task at hand — writing clean, tested, production-grade code — while keeping the big picture in mind.

---

<!-- STACK:all,bank-linear,beads-linear -->
## Linear — Source of Truth

Workspace: `<LINEAR_WORKSPACE>`

Linear is the single source of truth for all tasks, requirements, and context. Every piece of work must have a corresponding ticket. When in doubt about scope, requirements, or priority — check Linear first.
<!-- /STACK -->

<!-- STACK:all,beads-linear,beads-memory,beads -->
## Beads — Agent Task Tracking

Beads (`bd`) is the agent-native issue tracker. Use it for all task management during coding sessions.

**Core workflow:**
- `bd prime` — load workflow context and persistent memories at session start.
- `bd ready` — see unblocked tasks (no open dependencies).
- `bd show <id>` — view task details and audit trail.
- `bd update <id> --claim` — claim a task before working on it.
- `bd create "Title" -p <priority>` — create new tasks as discovered.
- `bd close <id> "Summary"` — close completed tasks.
- `bd remember "insight"` — store persistent project memory.
- `bd dolt push` — sync to remote at end of session.

**Do not** use markdown TODO lists for task tracking — use `bd create` instead.

<!-- STACK:all,beads-linear -->
**Beads ↔ Linear:** Beads handles the agent's working memory and dependency tracking. Linear remains the stakeholder-facing source of truth. When closing a Beads task that maps to a Linear ticket, update both.
<!-- /STACK -->

**Beads Viewer (`bv`):** Use `bv` for graph visualization, kanban boards, and stakeholder reports. **Never run bare `bv`** in an agent context — always use `--robot-*` flags:
- `bv --robot-triage` — ranked recommendations with scores.
- `bv --robot-plan` — parallel execution tracks.
- `bv --robot-insights` — PageRank, critical path, cycles.
- `bv --export-graph report.html` — self-contained HTML for stakeholders.
<!-- /STACK -->

---

## Branching

The feature-branch workflow is active.

**Workflow:** `feature/<PREFIX>-XXX-description` → PR to `<BASE_BRANCH>` → CI must pass → merge → PR `<BASE_BRANCH>` → `<PROD_BRANCH>` (<APPROVALS_REQUIRED> approval(s) required) → merge → production deploy.

**Hard rules:**

- Every worktree must be on a `feature/<PREFIX>-XXX-description` branch — **never directly on `<BASE_BRANCH>` or `<PROD_BRANCH>`**.
- If the current worktree is on `<BASE_BRANCH>` or `<PROD_BRANCH>`, stop and create/check out a feature branch before doing anything.
<!-- STACK:all,bank-linear,beads-linear -->
- Branch names: lowercase + hyphens, always prefixed with the Linear ticket ID (e.g., `feature/<PREFIX>-127-add-auth-guard`).
<!-- /STACK -->
<!-- STACK:beads-memory,beads -->
- Branch names: lowercase + hyphens, prefixed with the project prefix + ID (e.g., `feature/<PREFIX>-127-add-auth-guard`).
<!-- /STACK -->
- `hotfix/<PREFIX>-XXX-description` for urgent production fixes; same flow, expedited review.

Worktree commands (see [WORKTREES.md](WORKTREES.md) for the full flow):

```bash
make worktree-new TICKET=192 SLUG=my-feature
```

Do not use `claude --worktree` for PR-bound work — its auto-named `worktree-<name>` branches violate the naming convention.

Full PR process and commit-message conventions live in [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Development Rules

- **Schema changes** only via migration files committed to git — never a dashboard UI
- **Row-level security** on every database table — no exceptions
- **Soft deletes** everywhere — no hard deletes via UI
- **TDD** — tests before implementation where possible
- **DRY** — shared components, never duplicated per screen
- **Audit trail** on all privileged actions

---

## Ticket Close-Out

<!-- STACK:all,bank-linear,beads-linear -->
**A ticket does not move to Done until every checkbox in its description is ticked AND every test, task, and acceptance gate has actually been run.** When closing:

1. Walk through every `- [ ]` in the description and confirm each is verified.
2. Update the description so the boxes show `- [x]`.
3. Add a close-out comment summarizing what landed, what was delegated (with the receiving ticket), and any verification results.
4. Only then move the ticket state to Done.
<!-- /STACK -->

<!-- STACK:beads-memory,beads -->
**A task does not close until every acceptance gate has actually been run.** When closing:

1. Verify all acceptance criteria are met.
2. `bd close <id> "Summary of what landed and verification results"`.
3. If new problems surfaced, `bd create` them with `--deps discovered-from:<id>`.
<!-- /STACK -->

If a verification gate requires runtime work (e.g., the dev server must start without errors), actually run it.

---

## Git

**Never commit or push without explicit user approval.**

Show the proposed commit message and staged files, then wait for a "yes" before running `git commit`.

### Pre-commit hygiene order

Before every commit, update in this order:

<!-- STACK:all,bank-linear,beads-memory -->
1. **Memory bank** — refresh `memory-bank/*.md` (at minimum `activeContext.md` and `progress.md`).
<!-- /STACK -->
<!-- STACK:all,beads-linear,beads-memory,beads -->
1. **Beads** — `bd update` or `bd close` relevant tasks. `bd remember` any insights.
<!-- /STACK -->
2. **Docs** — update `README.md`, `CLAUDE.md`, and any per-feature docs.
<!-- STACK:all,bank-linear,beads-linear -->
3. **Linear ticket comment** — post/update the comment on the ticket.
<!-- /STACK -->
4. **Then** `git add` and `git commit` (conventional-commits format).

---

## Tooling — Skills & MCPs

- **Skills** live under `.agents/skills/<name>/` and are pinned in `skills-lock.json`.
- **MCP servers** are configured in `.mcp.json`.
- **Pin explicit versions** on MCP server `args`.
- **Library docs**: fetch current docs via **Context7 MCP** before answering.

---

<!-- STACK:all,bank-linear,beads-memory -->
## Memory Bank

When asked to **update memory bank**, review and update every file in `memory-bank/`.
Location: `memory-bank/` off the repo root.
<!-- /STACK -->

---

## Scratchpad

`.devcontainer/SCRATCHPAD.md` is a personal capture file (gitignored) for ideas, discussion points, TODOs, and decisions.

If a tangential idea comes up mid-task, offer to add it to the scratchpad instead of acting on it.

When asked to **check scratchpad**, help triage: promote items to tickets, move decisions to memory bank, clear completed items.

When asked to **start a review**, open the scratchpad's Review section and walk through the checklist. After the review, offer to batch-create tickets from findings.

---

## Checkpoint

Use `/checkpoint` (or say "checkpoint", "save state", "before refresh") to persist session state before a devcontainer refresh. Full procedure in `.claude/commands/checkpoint.md`.
