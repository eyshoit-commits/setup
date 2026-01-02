# AI Agents System - Phase 1 Documentation

## Overview

This document describes the foundation and structure for the comprehensive AI agents system, which includes:

- **107 VSCode Subagents**: Specialized agents organized into 10 categories
- **5 GitHub Copilot Agents**: Workflow and PR automation agents
- **Enhanced DevContainer**: Agent-ready development environment

## Directory Structure

```
.vscode/subagents/
├── 01-core-development/         # Code generation, refactoring, architecture
├── 02-language-specialists/     # Language-specific experts
├── 03-infrastructure/           # DevOps, cloud, containers
├── 04-quality-security/         # Testing, security, code quality
├── 05-data-ai/                  # Data science, ML, AI
├── 06-developer-experience/     # DX, tooling, automation
├── 07-specialized-domains/      # Domain-specific agents
├── 08-business-product/         # Product, business logic
├── 09-meta-orchestration/       # Agent coordination
└── 10-research-analysis/        # Research, analysis, insights

.github/copilot/agents/          # GitHub Copilot workflow agents

.opencode/
├── agents/
│   ├── orchestrator/            # Main orchestrator agent
│   └── categories/              # Category-based agents
├── integrations/                # External integrations
└── config/                      # Agent configurations

scripts/
├── agents/                      # Agent management scripts
│   └── generate-subagents.sh   # Subagent generator
└── opencode/                    # OpenCode-specific scripts

docs/agents/                     # Agent documentation

templates/
├── subagent-template.json      # VSCode subagent template
└── copilot-agent-template.yml  # GitHub Copilot agent template
```

## Templates

### VSCode Subagent Template

Located at: `templates/subagent-template.json`

Structure:
```json
{
  "name": "agent-name",
  "description": "Agent description",
  "version": "1.0.0",
  "category": "01-core-development",
  "customInstructions": "Detailed instructions...",
  "contextWindow": "isolated",
  "toolPermissions": {
    "fileOperations": true,
    "terminalAccess": true,
    "networkAccess": false,
    "codeGeneration": true
  },
  "taskTypes": ["task1", "task2"],
  "fallbackAgent": "general-assistant",
  "dependencies": ["dep1", "dep2"]
}
```

### GitHub Copilot Agent Template

Located at: `templates/copilot-agent-template.yml`

Structure:
```yaml
name: "agent-name"
description: "Agent description"

triggers:
  - pull_request:
      types: [opened, synchronize]

agent:
  model: gpt-4
  temperature: 0.2
  
  instructions: |
    You are a specialized agent.
  
  tools: []
  
  permissions:
    pull_requests: write
    contents: read
```

## Generator Script

### Location
`scripts/agents/generate-subagents.sh`

### Usage

```bash
# Show help
./scripts/agents/generate-subagents.sh --help

# Dry-run mode (simulate without creating files)
./scripts/agents/generate-subagents.sh --dry-run

# Generate with custom config
./scripts/agents/generate-subagents.sh --config config/my-agents.yml

# Force overwrite existing files
./scripts/agents/generate-subagents.sh --force

# Validate templates and config only
./scripts/agents/generate-subagents.sh --validate-only
```

### Features

1. **Idempotency**: Safe to run multiple times, skips existing files
2. **Validation**: Validates JSON and YAML syntax
3. **Dry-run**: Preview changes without modifying files
4. **Configuration-based**: Reads from YAML config file
5. **Statistics**: Reports created/skipped/failed operations

### Configuration

The generator reads from `config/subagents.yml` (see `config/subagents.example.yml` for reference).

Example configuration:
```yaml
version: "1.0.0"

categories:
  - id: "01-core-development"
    name: "Core Development"
    agents:
      - name: "code-reviewer"
        description: "Reviews code for best practices"
        customInstructions: "Focus on code quality..."
        taskTypes: ["code-review", "security-audit"]
        fallbackAgent: "general-assistant"
        dependencies: ["syntax-checker"]
```

## Agent Categories

### 01 - Core Development
Code generation, refactoring, architecture, design patterns

### 02 - Language Specialists
Language-specific experts (Python, JavaScript, Go, Rust, etc.)

### 03 - Infrastructure
DevOps, cloud platforms, containers, orchestration

### 04 - Quality & Security
Testing, security scanning, code quality, best practices

### 05 - Data & AI
Data science, machine learning, AI model development

### 06 - Developer Experience
DX improvements, tooling, automation, productivity

### 07 - Specialized Domains
Domain-specific agents (finance, healthcare, etc.)

### 08 - Business & Product
Product development, business logic, requirements

### 09 - Meta & Orchestration
Agent coordination, workflow management, delegation

### 10 - Research & Analysis
Research, code analysis, insights, documentation

## Next Steps

### Phase 2: VSCode Subagents (1-30)
- Create first 30 core development and language specialist agents
- Implement agent activation and management

### Phase 3: VSCode Subagents (31-60)
- Add infrastructure and quality agents
- Implement inter-agent communication

### Phase 4: VSCode Subagents (61-90)
- Add data, DX, and specialized domain agents
- Implement context sharing

### Phase 5: VSCode Subagents (91-107)
- Complete with business, meta, and research agents
- Implement orchestration layer

### Phase 6: GitHub Copilot Integration
- Create 5 GitHub Copilot workflow agents
- Integrate with VSCode subagents

### Phase 7: DevContainer Enhancement
- Configure agent-ready environment
- Add all required tools and dependencies

## Validation

To validate the setup:

```bash
# Validate templates
jq empty templates/subagent-template.json
python3 -c "import yaml; yaml.safe_load(open('templates/copilot-agent-template.yml'))"

# Run generator in dry-run mode
bash scripts/agents/generate-subagents.sh --dry-run

# Validate generated files
bash scripts/agents/generate-subagents.sh --validate-only

# Check directory structure
find .vscode/subagents -type d
find .github/copilot -type d
```

## Best Practices

1. **Always use templates** for consistency
2. **Validate before committing** using the generator's validation
3. **Use idempotent scripts** to avoid duplication
4. **Document agent capabilities** in README files
5. **Test in dry-run mode** before making changes
6. **Version lock configurations** for reproducibility
7. **Follow naming conventions** (kebab-case for files, camelCase for code)

## Troubleshooting

### Generator fails validation
- Check JSON syntax with `jq empty file.json`
- Check YAML syntax with `python3 -c "import yaml; yaml.safe_load(open('file.yml'))"`

### Files not generated
- Run with `--dry-run` to see what would be created
- Check permissions on output directories
- Verify template files exist

### Idempotency issues
- Files are only skipped if they exist
- Use `--force` to overwrite existing files
- Check file paths in error messages

## References

- VSCode Extension API: https://code.visualstudio.com/api
- GitHub Copilot for Business: https://docs.github.com/copilot
- OpenCode Agent System: See `.opencode/` directory
- Setup Repository: See main README.md
