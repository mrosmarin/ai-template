# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `configure.sh` — interactive post-clone setup script
- Stack system: 5 memory + tracking configurations (all, bank-linear, beads-linear, beads-memory, beads)
- `.devcontainer/ssh-setup.sh` — in-container SSH key generation (replaces host mount)
- `.agents/skills/checkpoint/` — checkpoint skill with symlinks to `.claude/skills` and `.kilo/skills`
- Beads (bd) and Beads Viewer (bv) integration
- `make ssh-setup`, `make bd-ready`, `make bv-triage`, `make bv-export` targets
- `.devcontainer/SCRATCHPAD.md` — personal capture file for ideas, TODOs, reviews
- `scripts/claude-audit.sh` — Claude Code permission settings auditor
- `<!-- STACK:... -->` conditional sections in all template docs
- `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`
- GitHub issue templates and PR template
- CI workflow for shellcheck + configure.sh validation

### Changed
- `devcontainer.json` — removed host `~/.ssh` mount, use `${localWorkspaceFolder}` instead of hardcoded paths
- `postinstall.sh` — renamed from `post-install.sh`, added beads/bv/commitizen installs
- `BOOTSTRAP.md` — trimmed to only ask questions `configure.sh` doesn't handle
- `README.md` — full documentation for the template repo
- `.gitignore` — deduplicated, added `.beads/`, `SCRATCHPAD.md`

## [0.1.0] — 2026-05-28

### Added
- Initial template structure
- Devcontainer with Docker-in-Docker, Go, Node, Python
- Claude Code and Kilo Code integration
- Memory bank system
- Worktree workflow
- Basic docs (CLAUDE.md, CONTRIBUTING.md, DEPLOYMENT-ENV.md, WORKTREES.md)
