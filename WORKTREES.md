# Worktrees — Parallel Feature Branches

Worktrees let you run multiple Claude Code (or shell) sessions side-by-side, each on its own feature branch, sharing the same git history.

## Why this approach

The Claude Code CLI `--worktree` flag auto-names branches `worktree-<name>` which violates `feature/<PREFIX>-XXX-*` naming. We use `git worktree add` and a helper that:

1. enforces `feature/<PREFIX>-XXX-<slug>` naming,
2. branches off `origin/<BASE_BRANCH>`,
3. creates under `.claude/worktrees/` (gitignored),
4. copies gitignored files from [`.worktreeinclude`](.worktreeinclude).

## Create a worktree

```bash
make worktree-new TICKET=192 SLUG=my-feature
# → .claude/worktrees/<PREFIX>-192-my-feature/
#   branch: feature/<PREFIX>-192-my-feature off origin/<BASE_BRANCH>
```

Then: `cd .claude/worktrees/<PREFIX>-192-my-feature && <INSTALL_CMD> && claude`

## Multiple sessions

Different ports per worktree: `PORT=<DEV_PORT>1 <DEV_CMD>`

## Shared services

Start once from the **main checkout**. Worktrees connect via copied env files.

## Git hooks

Fire automatically — worktrees share `.git/hooks` via the pointer file.

## VS Code

`code .claude/worktrees/<PREFIX>-123-my-feature`

## Inspect / cleanup

```bash
make worktree-list
make worktree-prune
git worktree remove .claude/worktrees/<PREFIX>-123-my-feature
git branch -D feature/<PREFIX>-123-my-feature
```

## Caveats

- **Don't use `claude --worktree`** for PR-bound work.
- **`.worktreeinclude` copies once.** Recopy manually if values change.
- **`.claude/worktrees/` is gitignored.**
