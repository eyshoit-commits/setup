# OpenCode Configuration

This directory contains the OpenCode agent configurations and integrations for this enterprise repository.

## 📁 Structure

```
.opencode/
├── agents/           # Individual agent configurations
├── config.json       # Main OpenCode configuration
└── README.md         # This file
```

## 🤖 Integrated Agents

This repository integrates the following OpenCode agents:

### Core Functionality
- **@malhashemi/opencode-skills** - Custom skills and tools for enhanced development
- **@malhashemi/opencode-sessions** - Advanced session management and persistence
- **@shuv1337/oc-manager** - Project and task management integration

### Enhancement & Productivity
- **@code-yeongyu/oh-my-opencode** - Enhanced OpenCode features and utilities
- **@IgorWarzocha/Opencode-Roadmap** - Roadmap visualization and planning
- **@zenobi-us/opencode-background** - Background task processing and automation
- **@Tarquinen/opencode-smart-title** - Intelligent title generation for commits and PRs
- **@pantheon-org/opencode-warcraft-notifications** - Multi-channel notification system

### Analysis & Intelligence
- **@IgorWarzocha/Opencode-Context-Analysis-Plugin** - Deep context analysis and understanding
- **@VoltAgent/awesome-claude-code-subagents** - Advanced subagent patterns and orchestration
- **@darrenhinde/OpenAgents** - Community agent templates and best practices

### Interface & Experience
- **@shuv1337/oc-web** - Web-based interface for OpenCode
- **@ajaxdude/opencode-ai-poimandres-theme** - Beautiful Poimandres theme integration

## ⚙️ Configuration

The `config.json` file contains:
- Agent repository references
- Feature flags for enabled capabilities
- Performance and caching settings
- Notification preferences

## 🚀 Usage

Agents are automatically loaded when OpenCode starts. Each agent in the `agents/` directory provides specific capabilities that enhance the development workflow.

## 📚 Documentation

For detailed information about each agent:
- Check the individual agent repository README files
- Review the agent-specific configuration files in `agents/`
- See `/docs/AGENTS.md` for comprehensive agent documentation

## 🔧 Customization

To customize agent behavior:
1. Edit the relevant agent configuration in `agents/`
2. Modify feature flags in `config.json`
3. Adjust performance settings as needed

## 🆘 Troubleshooting

For common issues and solutions, see `/docs/TROUBLESHOOTING.md`.
