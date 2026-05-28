# Deployment & Environments

## TL;DR

| Git branch | Deploy target | Scope |
|---|---|---|
| `<PROD_BRANCH>` | Production | Production |
| `<BASE_BRANCH>` | Staging | Preview / Staging |
| `feature/<PREFIX>-XXX-*` PR | Preview | Preview |
| `localhost` | Local (devcontainer) | n/a |

## Environments

### 1. Local (devcontainer)

VS Code + Docker-in-Docker. Tools installed by `.devcontainer/postinstall.sh`. Keys in `.env.local` (gitignored). Dev server port: `<DEV_PORT>`.

### 2. Preview / PR

Deploy platform builds preview URL on PR to `<BASE_BRANCH>`. Ephemeral resources destroy on merge.

### 3. Staging (`<BASE_BRANCH>`)

All feature PRs target `<BASE_BRANCH>`. Auto-deploy on push.

### 4. Production (`<PROD_BRANCH>`)

PRs require <APPROVALS_REQUIRED> approval(s) + CI green. Auto-deploy on push.

## Secret inventory

<!-- Fill during bootstrap -->

## Adding a new env var

1. Add to `.env.example` with placeholder + comment.
2. Add to `.env.local`.
3. Add to deploy platform.
4. If CI needs it: `printf '%s' "$VALUE" | gh secret set NAME --repo <REPO_PATH>`

## Known gotchas

1. `gh secret set --body -` sets literal `"-"`. Use stdin without `--body`.
2. Workflow-only changes don't trigger redeploy. Use `git commit --allow-empty`.
3. Devcontainer rebuilds wipe temp files. Use `.devcontainer/.env` (gitignored).
4. Port collisions in worktrees — each needs unique port.

## Related

[README.md](README.md) | [WORKTREES.md](WORKTREES.md) | [CONTRIBUTING.md](CONTRIBUTING.md) | [CLAUDE.md](CLAUDE.md)
