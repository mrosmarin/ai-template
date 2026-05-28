# Contributing

## Quick links

- Day-to-day commands: [`Makefile`](Makefile) — `make help`
<!-- STACK:all,bank-linear,beads-linear -->
- **Source of truth:** [Linear / <LINEAR_WORKSPACE>](https://linear.app/<LINEAR_WORKSPACE>)
<!-- /STACK -->
<!-- STACK:beads-memory,beads -->
- **Source of truth:** Beads (`bd ready`, `bd list`)
<!-- /STACK -->

## Branching

| Branch | Purpose | Rules |
|---|---|---|
| `<PROD_BRANCH>` | Production | PR required, **<APPROVALS_REQUIRED> approval(s)**, CI pass, source = `<BASE_BRANCH>` only |
| `<BASE_BRANCH>` | Staging | PR required, CI pass |
| `feature/<PREFIX>-XXX-desc` | Feature work | Lives until merged |
| `hotfix/<PREFIX>-XXX-desc` | Urgent fixes | Expedited review |

## Commit messages

Conventional Commits. Scope = lowercase ticket/task ID or domain (`tooling`, `ci`, `docs`).

## PR process

1. `make worktree-new TICKET=192 SLUG=my-feature` — see [WORKTREES.md](WORKTREES.md)
2. Code, commit, push. Pre-commit hooks run automatically.
3. Open PR → base: `<BASE_BRANCH>`. Title = conventional-commit subject.
4. CI must pass.
5. Merge to `<BASE_BRANCH>`.
6. Release: PR `<BASE_BRANCH>` → `<PROD_BRANCH>`, **<APPROVALS_REQUIRED> approval(s)**.

## First-time setup

All development runs in a **devcontainer** (VS Code + Docker-in-Docker). System tools installed automatically by `.devcontainer/postinstall.sh`.

```bash
# 1. Open in devcontainer
# 2. Set up SSH for GitHub
make ssh-setup
# 3. Install project dependencies
<INSTALL_CMD>
# 4. Start dev
make up
```

## Environment variables

`cp .env.example .env.local` — fill in values. **Never commit `.env.local`.**
