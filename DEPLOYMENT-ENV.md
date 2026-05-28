# Deployment & Environments

Reference for the deploy pipeline: every environment, every secret, where each one lives.

---

## TL;DR

| Git branch | Deploy target | Scope |
|---|---|---|
| `<PROD_BRANCH>` | Production | Production |
| `<BASE_BRANCH>` | Staging | Preview / Staging |
| `feature/<PREFIX>-XXX-*` PR | Preview | Preview |
| `localhost` | Local dev (devcontainer) | n/a |

---

## Environments

### 1. Local (devcontainer)

All development runs in a **devcontainer with VS Code and Docker-in-Docker**. Tools installed automatically by `.devcontainer/postinstall.sh`.

**Keys:** `.env.local` (gitignored). **Ports:** Dev server defaults to `<DEV_PORT>`.

### 2. Preview / PR

Deploy platform builds a preview URL on PR to `<BASE_BRANCH>`. Ephemeral resources auto-destroy on merge.

### 3. Staging (`<BASE_BRANCH>`)

All feature PRs target `<BASE_BRANCH>`. Pushes auto-deploy.

### 4. Production (`<PROD_BRANCH>`)

PRs require <APPROVALS_REQUIRED> approval(s) + CI green.

---

## Secret inventory

### Local (`.devcontainer/.env`, gitignored)

| Env var | Purpose | Source |
|---|---|---|
| <!-- Fill during bootstrap --> | | |

### Deploy platform (<DEPLOY_PLATFORM>)

| Var | Production | Staging | Source |
|---|---|---|---|
| <!-- Fill during bootstrap --> | | | |

### CI secrets (GitHub repo secrets)

| Secret | Used by | Purpose |
|---|---|---|
| <!-- Fill during bootstrap --> | | |

**To set:** `printf '%s' "$VALUE" | gh secret set NAME --repo <REPO_PATH>`

---

## Adding a new env var

1. Add to `.env.example` with placeholder + comment.
2. Add to your `.env.local`.
3. Add to deploy platform (choose scope).
4. If CI needs it: `printf '%s' "$VALUE" | gh secret set NAME --repo <REPO_PATH>`.

---

## Known gotchas

1. `gh secret set --body -` sets literal `"-"`. Use stdin without `--body`.
2. Workflow-only changes don't trigger redeploy. Use `git commit --allow-empty`.
3. Devcontainer rebuilds wipe temp files. Use `.devcontainer/.env` (gitignored).
4. Port collisions in worktrees. Each needs a unique port — see [WORKTREES.md](WORKTREES.md).

---

## Related docs

- [README.md](README.md) | [WORKTREES.md](WORKTREES.md) | [CONTRIBUTING.md](CONTRIBUTING.md) | [CLAUDE.md](CLAUDE.md)
