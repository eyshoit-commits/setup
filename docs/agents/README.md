# AI Agents System Documentation

This directory contains documentation for the comprehensive AI agents system.

## Documentation Index

- **[PHASE1-FOUNDATION.md](PHASE1-FOUNDATION.md)** - Foundation and structure setup (Complete)
- **PHASE2-VSCODE-AGENTS-1-30.md** - First 30 VSCode subagents (Planned)
- **PHASE3-VSCODE-AGENTS-31-60.md** - Next 30 VSCode subagents (Planned)
- **PHASE4-VSCODE-AGENTS-61-90.md** - Next 30 VSCode subagents (Planned)
- **PHASE5-VSCODE-AGENTS-91-107.md** - Final 17 VSCode subagents (Planned)
- **PHASE6-GITHUB-COPILOT.md** - GitHub Copilot agents (Planned)
- **PHASE7-DEVCONTAINER.md** - DevContainer enhancements (Planned)

## Quick Start

### 1. Generate Subagent Structure

```bash
# Dry-run to preview
bash scripts/agents/generate-subagents.sh --dry-run

# Generate files
bash scripts/agents/generate-subagents.sh
```

### 2. Validate Setup

```bash
# Validate templates and config
bash scripts/agents/generate-subagents.sh --validate-only
```

### 3. Explore Structure

```bash
# View subagent categories
ls -la .vscode/subagents/

# View generated READMEs
cat .vscode/subagents/*/README.md
```

## System Overview

### 107 VSCode Subagents (10 Categories)

1. **Core Development** (01) - Architecture, code generation, refactoring
2. **Language Specialists** (02) - Language-specific experts
3. **Infrastructure** (03) - DevOps, cloud, containers
4. **Quality & Security** (04) - Testing, security, quality
5. **Data & AI** (05) - Data science, ML, AI
6. **Developer Experience** (06) - DX, tooling, automation
7. **Specialized Domains** (07) - Domain-specific agents
8. **Business & Product** (08) - Product, business logic
9. **Meta & Orchestration** (09) - Agent coordination
10. **Research & Analysis** (10) - Research, insights

### 5 GitHub Copilot Agents

- PR Review Agent
- Security Audit Agent
- Documentation Agent
- Test Coverage Agent
- Dependency Update Agent

### Agent-Ready DevContainer

- All required tools pre-installed
- Agent runtime environments
- Integrated development workflow

## Templates

All agents are generated from templates:

- **VSCode Subagents**: `templates/subagent-template.json`
- **GitHub Copilot**: `templates/copilot-agent-template.yml`

## Directory Structure

```
.vscode/subagents/           # 107 VSCode subagents (10 categories)
.github/copilot/agents/      # 5 GitHub Copilot agents
.opencode/agents/            # OpenCode agent definitions
scripts/agents/              # Agent management scripts
templates/                   # Agent templates
docs/agents/                 # This documentation
```

## Contributing

When adding new agents:

1. Use the templates in `templates/`
2. Follow naming conventions (kebab-case)
3. Update documentation
4. Validate with generator script
5. Test idempotency

## Resources

- Generator Script: `scripts/agents/generate-subagents.sh`
- Example Config: `config/subagents.example.yml`
- Main Setup: `README.md` (repository root)
- Phase 1 Details: `PHASE1-FOUNDATION.md`

## Status

- ✅ **Phase 1**: Foundation & Structure (Complete)
- ⏳ **Phase 2**: VSCode Agents 1-30 (Planned)
- ⏳ **Phase 3**: VSCode Agents 31-60 (Planned)
- ⏳ **Phase 4**: VSCode Agents 61-90 (Planned)
- ⏳ **Phase 5**: VSCode Agents 91-107 (Planned)
- ⏳ **Phase 6**: GitHub Copilot Integration (Planned)
- ⏳ **Phase 7**: DevContainer Enhancement (Planned)

## Support

For questions or issues:

1. Check phase-specific documentation
2. Review example configurations
3. Run generator with `--help`
4. Validate setup with `--validate-only`
