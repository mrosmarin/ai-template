# Makefile — <PROJECT_NAME>

SHELL := /bin/bash
APP_ROOT := <APP_ROOT>
.DEFAULT_GOAL := help

# ─── Help ─────────────────────────────────────────────────────────────

.PHONY: help
help: ## Show this help
	@echo ""
	@echo "<PROJECT_NAME> — make targets"
	@echo "──────────────────────────────────────"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ─── Install / clean ─────────────────────────────────────────────────

.PHONY: install
install: ## Install all dependencies
	<INSTALL_CMD>

.PHONY: install-hooks
install-hooks: ## Re-install git hooks
	# <INSTALL_HOOKS_CMD>

.PHONY: clean
clean: ## Remove caches and build artifacts
	# <CLEAN_CMD>

.PHONY: clean-all
clean-all: ## Remove caches AND dependencies
	$(MAKE) clean
	# <CLEAN_ALL_CMD>

# ─── Local services ──────────────────────────────────────────────────

.PHONY: services-start
services-start: ## Start local services (database, cache, etc.)
	# <SERVICES_START_CMD>

.PHONY: services-stop
services-stop: ## Stop local services
	# <SERVICES_STOP_CMD>

.PHONY: services-status
services-status: ## Show local service status
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "(no containers running)"

.PHONY: services-restart
services-restart: ## Stop and restart local services
	$(MAKE) services-stop
	$(MAKE) services-start

# ─── Dev servers ─────────────────────────────────────────────────────

.PHONY: dev
dev: ## Run dev server
	<DEV_CMD>

# ─── Build / quality gates ───────────────────────────────────────────

.PHONY: build
build: ## Production build
	# <BUILD_CMD>

.PHONY: check-types
check-types: ## Static type check
	# <CHECK_TYPES_CMD>

.PHONY: lint
lint: ## Run linter
	# <LINT_CMD>

.PHONY: format
format: ## Auto-format all files
	# <FORMAT_CMD>

.PHONY: format-check
format-check: ## Check formatting without writing
	# <FORMAT_CHECK_CMD>

.PHONY: test
test: ## Run test suite
	# <TEST_CMD>

.PHONY: test-watch
test-watch: ## Run tests in watch mode
	# <TEST_WATCH_CMD>

.PHONY: test-e2e
test-e2e: ## Run E2E tests
	# <TEST_E2E_CMD>

.PHONY: audit
audit: ## Dependency vulnerability audit
	# <AUDIT_CMD>

.PHONY: ci
ci: ## Reproduce CI locally
	@echo "→ Format check" && $(MAKE) format-check
	@echo "→ Lint"         && $(MAKE) lint
	@echo "→ Type check"   && $(MAKE) check-types
	@echo "→ Build"        && $(MAKE) build
	@echo "→ Test"         && $(MAKE) test
	@echo "✓ CI gate passed"

# ─── Database / migrations ───────────────────────────────────────────

.PHONY: db-reset
db-reset: ## Reset local database
	# <DB_RESET_CMD>

.PHONY: db-migrate
db-migrate: ## Apply pending migrations
	# <DB_MIGRATE_CMD>

.PHONY: db-seed
db-seed: ## Seed database with dev data
	# <DB_SEED_CMD>

# ─── Worktrees ───────────────────────────────────────────────────────

.PHONY: worktree-new
worktree-new: ## Create a feature worktree: make worktree-new TICKET=123 SLUG=my-feature
	@if [[ -z "$(TICKET)" || -z "$(SLUG)" ]]; then \
		echo "Usage: make worktree-new TICKET=<ticket> SLUG=<slug>"; exit 2; fi
	./scripts/worktree-new.sh $(TICKET) $(SLUG)

.PHONY: worktree-list
worktree-list: ## List all worktrees
	@git worktree list

.PHONY: worktree-prune
worktree-prune: ## Sweep stale worktree records
	@git worktree prune --verbose

# <!-- STACK:all,beads-linear,beads-memory,beads -->
# ─── Beads (bd) ──────────────────────────────────────────────────────

.PHONY: bd-ready
bd-ready: ## Show unblocked Beads tasks
	bd ready

.PHONY: bd-prime
bd-prime: ## Print Beads workflow context + persistent memories
	bd prime

.PHONY: bd-push
bd-push: ## Push Beads database to remote
	bd dolt push

.PHONY: bd-pull
bd-pull: ## Pull latest Beads database from remote
	bd dolt pull

# ─── Beads Viewer (bv) ──────────────────────────────────────────────

.PHONY: bv-triage
bv-triage: ## Robot triage — ranked recommendations
	bv --robot-triage

.PHONY: bv-plan
bv-plan: ## Robot plan — parallel execution tracks
	bv --robot-plan

.PHONY: bv-insights
bv-insights: ## Robot insights — PageRank, critical path, cycles
	bv --robot-insights

.PHONY: bv-kanban
bv-kanban: ## Open interactive Beads Viewer TUI
	bv

.PHONY: bv-export
bv-export: ## Export interactive HTML graph for stakeholders
	bv --export-graph report-$$(date +%Y%m%d).html
	@echo "→ Exported to report-$$(date +%Y%m%d).html"
# <!-- /STACK -->

# ─── MCP servers ─────────────────────────────────────────────────────

.PHONY: mcp-add
mcp-add: ## Add an MCP server preset: make mcp-add NAME=linear
	@if [[ -z "$(NAME)" ]]; then \
		echo "Usage: make mcp-add NAME=<preset>"; \
		echo "Available: linear vercel supabase next-devtools shadcn"; \
		exit 2; \
	fi
	./scripts/mcp-add.sh $(NAME)

.PHONY: mcp-list
mcp-list: ## List available MCP presets
	@./scripts/mcp-add.sh --list


# ─── Skills ──────────────────────────────────────────────────────────

.PHONY: skills-sync
skills-sync: ## Copy .agents/skills into .claude/skills and .kilo/skills
	@if [[ -d .agents/skills ]]; then \
		rm -rf .claude/skills .kilo/skills; \
		mkdir -p .claude .kilo; \
		cp -R .agents/skills .claude/skills; \
		cp -R .agents/skills .kilo/skills; \
		echo "✓ Synced .agents/skills → .claude/skills and .kilo/skills"; \
	else \
		echo "⚠ .agents/skills not found — nothing to sync"; \
	fi

# ─── SSH ──────────────────────────────────────────────────────────────

.PHONY: ssh-setup
ssh-setup: ## Generate SSH key in container and print GitHub instructions
	bash .devcontainer/ssh-setup.sh

# ─── Claude Code ─────────────────────────────────────────────────────

.PHONY: claude-audit
claude-audit: ## Audit Claude Code permission settings
	bash scripts/claude-audit.sh

.PHONY: claude-audit-global
claude-audit-global: ## Audit global Claude Code settings
	bash scripts/claude-audit.sh --global

.PHONY: claude-audit-verbose
claude-audit-verbose: ## Audit + list every command Claude has run
	bash scripts/claude-audit.sh --verbose

.PHONY: claude-fix
claude-fix: ## Audit, then switch Claude permissions to Bash(*) + deny list (stops prompts; live + postinstall)
	bash scripts/claude-audit.sh --fix

.PHONY: claude-fix-yes
claude-fix-yes: ## Same as claude-fix but applies without prompting
	bash scripts/claude-audit.sh --fix --yes

.PHONY: postinstall
postinstall: ## Re-run the devcontainer postinstall (reinstall tools + refresh Claude settings)
	bash .devcontainer/postinstall.sh

.PHONY: claude-settings-reset
claude-settings-reset: ## Rewrite global Claude Code settings from postinstall (fixes stale volume copy)
	@echo "→ Rewriting ~/.claude/settings.json from the template's postinstall block..."
	@awk '/cat > ~\/.claude\/settings.json << .SETTINGS./{f=1; next} /^SETTINGS$$/{f=0} f' \
		.devcontainer/postinstall.sh > ~/.claude/settings.json
	@echo "✓ Global Claude settings reset. Restart Claude Code to apply."
	@echo "  Review with: make claude-audit"

.PHONY: claude-clear-approvals
claude-clear-approvals: ## Clear accumulated per-project 'always allow' entries in ~/.claude.json
	@if [[ -f ~/.claude.json ]]; then \
		jq '(.projects // {}) |= map_values(.allowedTools = [])' ~/.claude.json > /tmp/claude.json \
			&& mv /tmp/claude.json ~/.claude.json \
			&& echo "✓ Cleared accumulated approvals. Restart Claude Code."; \
	else \
		echo "~/.claude.json not found — nothing to clear."; \
	fi

# ─── Daily shortcuts ─────────────────────────────────────────────────

.PHONY: up
up: ## Daily start: local services + dev server
	$(MAKE) services-start
	$(MAKE) dev

.PHONY: down
down: ## Daily stop: stop local services
	$(MAKE) services-stop
	@echo "Tip: stop dev servers with Ctrl+C."

.PHONY: status
status: ## Quick view: services + git + beads
	@echo "── Services ──"
	@$(MAKE) -s services-status || true
	@echo ""
	@echo "── Git ──"
	@git status --short
# <!-- STACK:all,beads-linear,beads-memory,beads -->
	@echo ""
	@echo "── Beads ──"
	@bd ready 2>/dev/null || true
# <!-- /STACK -->
