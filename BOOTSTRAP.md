# Project Bootstrap

> **Run with Claude Code after `configure.sh` has set up project basics.** This handles deeper, project-specific configuration.

**Prerequisites:** `configure.sh` already set the stack to **`<STACK>`** and replaced basic placeholders.

---

## Questions

### Q1 — Tech stack
- Language/framework? Package manager? Database? Deploy platform? Other services?

### Q2 — Development environment
- Local services via Docker Compose? Dev server ports?
- Additional patterns for `.worktreeinclude`?
- Install command? Dev server command?

### Q3 — CI/CD
- CI workflows? Test framework(s)? Deploy automation? CI secret names?

### Q4 — Linear workspace (only if stack includes Linear)
- Workspace slug? Multiple projects/teams?

### Q5 — Team
- Who's on the team? Solo? External AI tools?

### Q6 — Existing docs
- Docs to preserve? Project conventions?

---

## After collection

1. **Replace remaining placeholders:** `<APP_ROOT>`, `<PACKAGE_MANAGER>`, `<DATABASE>`, `<DEPLOY_PLATFORM>`, `<DEV_PORT>`, `<INSTALL_CMD>`, `<DEV_CMD>`, `<LINEAR_WORKSPACE>`

2. **Wire the Makefile** — fill in commented-out targets. Remove ones that don't apply.

3. **Update `.worktreeinclude`** with patterns from Q2.

4. **Initialize Beads** (if stack includes it): `bd init --quiet && bd setup claude`

5. **Populate memory bank** (if stack includes it) from answers.

6. **Write README.md** — project-specific overview replacing the template README.

7. **Fill in DEPLOYMENT-ENV.md** — env var tables, secrets, costs.

8. **Review** — list remaining `<PLACEHOLDER>` or `TBD` markers.

9. **Delete this file and commit:**
   ```bash
   rm BOOTSTRAP.md
   git add -A
   git commit -m "chore(bootstrap): complete project setup via Claude Code"
   ```
