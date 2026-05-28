# Contributing

## Quick links

- Day-to-day commands: [`Makefile`](Makefile) — run `make help`
<!-- STACK:all,bank-linear,beads-linear -->
- **Source of truth:** [Linear / <LINEAR_WORKSPACE>](https://linear.app/<LINEAR_WORKSPACE>). Every PR references a `<PREFIX>-XXX` ticket.
<!-- /STACK -->
<!-- STACK:beads-memory,beads -->
- **Source of truth:** Beads (`bd ready`, `bd list`). Every PR references a task ID.
<!-- /STACK -->

## Branching

| Branch | Purpose | Rules |
|---|---|---|
| `<PROD_BRANCH>` | Production | PR required, **<APPROVALS_REQUIRED> approval(s)**, CI must pass, source = `<BASE_BRANCH>` only |
| `<BASE_BRANCH>` | Staging | PR required, CI must pass |
| `feature/<PREFIX>-XXX-description` | Feature work | Lives only until merged |
| `hotfix/<PREFIX>-XXX-description` | Urgent fixes | Same flow, expedited review |

## Commit messages

Conventional Commits. Scope = lowercase ticket/task ID or domain (`tooling`, `ci`, `docs`).

| Type | Example | When |
|---|---|---|
| `feat` | `feat(<PREFIX>-127): add auth guard` | New functionality |
| `fix` | `fix(<PREFIX>-9): correct RLS rule` | Bug fix |
| `chore` | `chore(tooling): update CI config` | Tooling, config |
| `docs` | `docs(memory-bank): update progress` | Docs only |
| `test` | `test(<PREFIX>-114): add auth tests` | Test changes |
| `refactor` | `refactor(<PREFIX>-11): extract hook` | Internal restructuring |

## PR process

1. **Create a feature branch** — `make worktree-new TICKET=192 SLUG=my-feature` (see [WORKTREES.md](WORKTREES.md)).
2. **Code, commit, push.** Pre-commit hooks run on every commit.
3. **Open PR → base: `<BASE_BRANCH>`**. Title = conventional-commit subject.
4. **CI must pass.**
5. **Merge to `<BASE_BRANCH>`.**
6. **Release:** PR `<BASE_BRANCH>` → `<PROD_BRANCH>`, **<APPROVALS_REQUIRED> approval(s)** required.

## First-time setup

All development runs in a **devcontainer with VS Code and Docker-in-Docker**. System tools (Claude Code, Beads, bv, gh, etc.) are installed automatically by `.devcontainer/postinstall.sh` during container build.

```bash
# 1. Open in devcontainer (VS Code will prompt)
# 2. Install project dependencies
<INSTALL_CMD>
# 3. Start local services + dev server
make up
```

## Environment variables

1. Copy: `cp .env.example .env.local`
2. Fill in values from `.env.example`.
3. **Never commit `.env.local`.**

## Editor

`.vscode/settings.json` and `.vscode/extensions.json` are committed. `.editorconfig` covers other editors.
