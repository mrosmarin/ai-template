# Worktrees — Parallel Feature Branches

Worktrees let you run multiple Claude Code sessions side-by-side on separate feature branches.

## Create a worktree

```bash
make worktree-new TICKET=192 SLUG=my-feature
# → .claude/worktrees/<PREFIX>-192-my-feature/
#   branch: feature/<PREFIX>-192-my-feature off origin/<BASE_BRANCH>
```

Then: `cd .claude/worktrees/<PREFIX>-192-my-feature && <INSTALL_CMD> && claude`

## Multiple sessions

Different ports: `PORT=<DEV_PORT>1 <DEV_CMD>`

## Shared services

Start once from **main checkout**. Worktrees connect via copied env files.

## VS Code

`code .claude/worktrees/<PREFIX>-123-my-feature`

## Cleanup

```bash
git worktree remove .claude/worktrees/<PREFIX>-123-my-feature
git branch -D feature/<PREFIX>-123-my-feature
# or: make worktree-prune  (for stale entries)
```

## Caveats

- **Don't use `claude --worktree`** — auto-named branches violate the naming convention.
- **`.worktreeinclude` copies once.** Recopy manually if values change.
- **`.claude/worktrees/` is gitignored.**
