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

Beads (`bd`) is the agent-native issue tracker.

**Core workflow:**
- `bd prime` — load context + memories at session start.
- `bd ready` — unblocked tasks.
- `bd show <id>` — task details.
- `bd update <id> --claim` — claim a task.
- `bd create "Title" -p <priority>` — create tasks.
- `bd close <id> "Summary"` — close tasks.
- `bd remember "insight"` — persistent memory.
- `bd dolt push` — sync to remote.

**Do not** use markdown TODO lists — use `bd create`.
<!-- /STACK -->

<!-- STACK:all,beads-linear -->
**Beads ↔ Linear:** Beads handles agent working memory. Linear is the stakeholder source of truth. Update both when closing.
<!-- /STACK -->

<!-- STACK:all,beads-linear,beads-memory,beads -->
**Beads Viewer (`bv`):** **Never run bare `bv`** — always use `--robot-*` flags:
- `bv --robot-triage` — ranked recommendations.
- `bv --robot-plan` — parallel execution tracks.
- `bv --robot-insights` — PageRank, critical path, cycles.
- `bv --export-graph report.html` — HTML for stakeholders.
<!-- /STACK -->

---

## Branching

**Workflow:** `feature/<PREFIX>-XXX-description` → PR to `<BASE_BRANCH>` → CI pass → merge → PR `<BASE_BRANCH>` → `<PROD_BRANCH>` (<APPROVALS_REQUIRED> approval(s)) → merge → deploy.

**Hard rules:**

- Every worktree must be on a `feature/<PREFIX>-XXX-description` branch — **never directly on `<BASE_BRANCH>` or `<PROD_BRANCH>`**.
- If on `<BASE_BRANCH>` or `<PROD_BRANCH>`, stop and create a feature branch first.
<!-- STACK:all,bank-linear,beads-linear -->
- Branch names: lowercase + hyphens, prefixed with the Linear ticket ID.
<!-- /STACK -->
<!-- STACK:beads-memory,beads -->
- Branch names: lowercase + hyphens, prefixed with project prefix + ID.
<!-- /STACK -->
- `hotfix/<PREFIX>-XXX-description` for urgent production fixes.

Worktree commands: `make worktree-new TICKET=192 SLUG=my-feature` — see [WORKTREES.md](WORKTREES.md).

Do not use `claude --worktree` for PR-bound work. Full PR process in [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Development Rules

- **Schema changes** only via migration files — never a dashboard UI
- **Row-level security** on every database table
- **Soft deletes** everywhere
- **TDD** — tests before implementation where possible
- **DRY** — shared components, never duplicated
- **Audit trail** on all privileged actions

---

## Ticket Close-Out

<!-- STACK:all,bank-linear,beads-linear -->
**A ticket does not move to Done until every checkbox is ticked AND every gate has run.** Walk through `- [ ]` items, tick verified ones `- [x]`, add close-out comment, then move to Done.
<!-- /STACK -->
<!-- STACK:beads-memory,beads -->
**A task does not close until every acceptance gate has run.** `bd close <id> "summary"`. If new problems surfaced, `bd create` with `--deps discovered-from:<id>`.
<!-- /STACK -->

If a gate requires runtime work, actually run it.

---

## Git

**Never commit or push without explicit user approval.** Show proposed commit message + staged files, wait for "yes."

### Pre-commit hygiene order

<!-- STACK:all,bank-linear,beads-memory -->
1. **Memory bank** — refresh `memory-bank/*.md` (at minimum `activeContext.md` and `progress.md`).
<!-- /STACK -->
<!-- STACK:all,beads-linear,beads-memory,beads -->
1. **Beads** — `bd update`/`bd close` relevant tasks. `bd remember` insights.
<!-- /STACK -->
2. **Docs** — update `README.md`, `CLAUDE.md`, per-feature docs.
<!-- STACK:all,bank-linear,beads-linear -->
3. **Linear ticket comment** — post/update on the ticket.
<!-- /STACK -->
4. **Then** `git add` and `git commit` (conventional-commits format).

---

## Tooling — Skills & MCPs

- **Skills** at `.agents/skills/<name>/` — symlinked to `.claude/skills` and `.kilo/skills`.
- **MCP servers** in `.mcp.json`. Pin explicit versions.
- **Library docs**: fetch via **Context7 MCP** before answering.

---

<!-- STACK:all,bank-linear,beads-memory -->
## Memory Bank

When asked to **update memory bank**, review and update every file in `memory-bank/`.
<!-- /STACK -->

---

## Scratchpad

`.devcontainer/SCRATCHPAD.md` is a personal capture file (gitignored).

If a tangential idea comes up, offer to add it to the scratchpad. When asked to **check scratchpad**, triage items to tickets. When asked to **start a review**, walk the Review section checklist.

---

## Checkpoint

`/checkpoint` persists session state before a devcontainer refresh. Full procedure in `.agents/skills/checkpoint/SKILL.md`.
