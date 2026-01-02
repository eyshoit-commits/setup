# Agents Documentation

This document provides comprehensive information about all agents integrated into the repository.

## 📋 Table of Contents

- [Overview](#overview)
- [OpenCode Agents](#opencode-agents)
- [GitHub Agents](#github-agents)
- [VSCode Agents](#vscode-agents)
- [Configuration](#configuration)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

## 🔍 Overview

This repository integrates **21 total agents** across three categories:
- **13 OpenCode Agents** - Third-party integrations
- **3 GitHub Agents** - CI/CD and automation
- **3 VSCode Agents** - Development assistance
- **2 Additional** - Multi-agent orchestrator and custom agents

### Agent Orchestration

Agents are orchestrated through the `config/agents.config.json` file, which manages:
- Agent priorities and loading order
- Concurrent execution limits
- Shared context and communication
- Health monitoring and failover

## 🤖 OpenCode Agents

### 1. Skills Agent (@malhashemi/opencode-skills)

**Purpose:** Provides custom skills and tools for enhanced development

**Features:**
- Code analysis and refactoring
- Documentation generation
- Testing utilities
- Deployment automation

**Configuration:** `.opencode/agents/skills-agent.json`

**Usage:**
```javascript
// Automatically loaded
// Provides enhanced code completion and suggestions
```

**Priority:** High  
**Auto-load:** Yes

---

### 2. Sessions Agent (@malhashemi/opencode-sessions)

**Purpose:** Advanced session management and persistence

**Features:**
- Auto-save sessions
- Session history (up to 100 entries)
- Session timeout management
- Compression for storage efficiency

**Configuration:** `.opencode/agents/sessions-agent.json`

**Settings:**
- Session timeout: 3600s (1 hour)
- Max sessions: 10
- Persistence mode: Auto

**Priority:** High  
**Auto-load:** Yes

---

### 3. Manager Agent (@shuv1337/oc-manager)

**Purpose:** Project and task management integration

**Features:**
- Task tracking
- Milestone management
- Issue integration (GitHub)
- Multiple project views (Kanban, Timeline, List)

**Configuration:** `.opencode/agents/manager-agent.json`

**Default View:** Kanban

**Priority:** Normal  
**Auto-load:** Yes

---

### 4. Enhanced Agent (@code-yeongyu/oh-my-opencode)

**Purpose:** Enhanced OpenCode features and utilities

**Features:**
- Advanced workflows
- Custom shortcuts
- Performance optimizations
- Extended functionality

**Configuration:** `.opencode/agents/manager-agent.json` (as "enhanced")

**Priority:** Normal  
**Auto-load:** Yes

---

### 5. Roadmap Agent (@IgorWarzocha/Opencode-Roadmap)

**Purpose:** Roadmap visualization and planning

**Features:**
- Interactive timeline view
- Milestone tracking
- Dependency mapping
- Progress tracking
- Export formats (SVG, PNG, PDF)

**Configuration:** `.opencode/agents/roadmap-agent.json`

**Display:**
- Theme: Dark
- Compact mode: Disabled
- Show progress: Enabled
- Highlight blockers: Enabled

**Priority:** Normal  
**Auto-load:** No (manual trigger)

---

### 6. Background Agent (@zenobi-us/opencode-background)

**Purpose:** Background task processing and automation

**Features:**
- Code analysis in background
- Linting
- Build optimization
- Caching

**Configuration:** `.opencode/agents/background-agent.json`

**Performance:**
- Max concurrent tasks: 3
- Queue size: 50
- Retry attempts: 3
- Max CPU usage: 50%
- Max memory: 512MB

**Priority:** Low  
**Auto-load:** Yes

---

### 7. Smart Title Agent (@Tarquinen/opencode-smart-title)

**Purpose:** Intelligent title generation for commits and PRs

**Features:**
- Conventional commit format
- Auto-generate titles
- Scope detection
- Type detection

**Configuration:** `.opencode/agents/smart-title-agent.json`

**Formats:**
- Commit: `<type>(<scope>): <description>`
- PR: `[<type>] <description>`
- Issue: `<emoji> <description>`

**Max Length:** 72 characters

**Priority:** Normal  
**Auto-load:** Yes

---

### 8. Notifications Agent (@pantheon-org/opencode-warcraft-notifications)

**Purpose:** Multi-channel notification system

**Features:**
- Desktop notifications
- Email notifications
- Webhook integration
- Custom notification rules

**Configuration:** `.opencode/config.json` (as "notifications")

**Priority:** Low  
**Auto-load:** No

---

### 9. Context Analysis Agent (@IgorWarzocha/Opencode-Context-Analysis-Plugin)

**Purpose:** Deep context analysis and understanding

**Features:**
- Semantic understanding
- Dependency tracking
- Impact analysis
- Code relationships
- Incremental analysis

**Configuration:** `.opencode/agents/context-analysis-agent.json`

**Analysis:**
- File types: All (*)
- Exclude: node_modules, dist, build, .git
- Cache results: Enabled
- Depth: Comprehensive

**Priority:** High  
**Auto-load:** Yes

---

### 10. Web Agent (@shuv1337/oc-web)

**Purpose:** Web-based interface for OpenCode

**Features:**
- Browser-based UI
- Remote access
- Dashboard views
- Real-time updates

**Configuration:** `.opencode/config.json` (as "web")

**Priority:** Low  
**Auto-load:** No  
**Enabled:** No (optional)

---

### 11. Theme Agent (@ajaxdude/opencode-ai-poimandres-theme)

**Purpose:** Beautiful Poimandres theme integration

**Features:**
- Syntax highlighting
- UI customization
- Color scheme
- Consistent theming

**Configuration:** `.opencode/config.json` (as "theme")

**Priority:** Low  
**Auto-load:** Yes

---

### 12. Subagents Agent (@VoltAgent/awesome-claude-code-subagents)

**Purpose:** Advanced subagent patterns and orchestration

**Features:**
- Dynamic orchestration
- Load balancing
- Failover
- Multiple subagent types (Planner, Implementer, Reviewer, Tester)

**Configuration:** `.opencode/agents/subagents-agent.json`

**Subagent Types:**
- Planner: 1 instance (high priority)
- Implementer: 3 instances (normal priority)
- Reviewer: 2 instances (high priority)
- Tester: 2 instances (normal priority)

**Max Subagents:** 5  
**Auto-spawn:** Enabled

**Priority:** High  
**Auto-load:** Yes

---

### 13. Templates Agent (@darrenhinde/OpenAgents)

**Purpose:** Community agent templates and best practices

**Features:**
- Pre-built agent templates
- Best practice patterns
- Quick scaffolding
- Example implementations

**Configuration:** `.opencode/config.json` (as "templates")

**Priority:** Normal  
**Auto-load:** No

---

## 🔧 GitHub Agents

### 1. Setup Agent

**Purpose:** Repository setup and initialization validation

**Configuration:** `.github/agents/setup-agent.json`

**Responsibilities:**
- Validate repository structure
- Check configuration completeness
- Verify workflow configurations
- Ensure policy compliance
- Generate setup reports

**Triggers:**
- On push
- On pull request
- Daily schedule

---

### 2. Security Agent

**Purpose:** Security scanning and vulnerability detection

**Configuration:** `.github/agents/security-agent.json`

**Scanners:**
- Trivy (CRITICAL, HIGH, MEDIUM)
- TruffleHog (verified secrets only)
- CodeQL (JavaScript, TypeScript, Python, Go)
- Dependency checking (auto-fix patch)

**Policies:**
- Block on critical severity
- Block on high severity
- Always require review

**Triggers:**
- On push
- On pull request
- Weekly schedule

---

### 3. Compliance Agent

**Purpose:** Policy and compliance enforcement

**Configuration:** `.github/agents/compliance-agent.json`

**Checks:**
- Commit format (conventional commits)
- Branch naming
- PR size (max 500 lines, warning at 300)
- Code owner reviews
- Documentation updates

**Policies:**
- Enforce linear history
- Require squash merge
- Block force push

**Triggers:**
- On push
- On pull request
- Daily schedule

---

## 💻 VSCode Agents

### 1. Dev Agent

**Purpose:** Development assistance and code generation

**Configuration:** `.vscode/agents/dev-agent.json`

**Features:**
- Enhanced IntelliSense
- Code generation
- Refactoring assistance
- Auto-formatting

**Languages:** JavaScript, TypeScript, Python, Go, Rust, Bash

**Auto-start:** Yes

---

### 2. Debug Agent

**Purpose:** Debugging assistance and troubleshooting

**Configuration:** `.vscode/agents/debug-agent.json`

**Features:**
- Intelligent breakpoints
- Deep inspection
- Performance profiling
- Memory leak detection
- Root cause analysis

**Debuggers:** Node, Python, Go, Rust, Chrome

**Auto-start:** No (triggered on debug)

---

### 3. Test Agent

**Purpose:** Test generation and execution

**Configuration:** `.vscode/agents/test-agent.json`

**Features:**
- Test generation
- Coverage reporting (80% threshold)
- Watch mode
- Parallel execution

**Frameworks:** Jest, Mocha, Pytest, Go Test, Cargo Test

**Auto-start:** No (manual trigger)

---

## ⚙️ Configuration

### Global Configuration

Edit `.opencode/config.json` to:
- Enable/disable agents
- Adjust feature flags
- Configure performance settings
- Set notification preferences

### Individual Agent Configuration

Each agent has its own JSON configuration file:

```
.opencode/agents/*.json     # OpenCode agents
.github/agents/*.json       # GitHub agents
.vscode/agents/*.json       # VSCode agents
```

### Agent Orchestration

Configure in `config/agents.config.json`:

```json
{
  "settings": {
    "orchestration": {
      "maxConcurrentAgents": 5,
      "loadBalancing": true,
      "failover": true
    }
  }
}
```

## 🚀 Usage

### Enabling/Disabling Agents

Edit the agent's JSON file and set `enabled`:

```json
{
  "enabled": true  // or false
}
```

### Priority Levels

- **High**: Critical agents (loaded first)
- **Normal**: Standard agents
- **Low**: Optional agents (loaded last)

### Auto-loading

Agents with `"autoLoad": true` start automatically.

Manual agents require explicit trigger.

## 🆘 Troubleshooting

### Agent Not Loading

1. Check `enabled` is `true`
2. Verify JSON syntax: `jq empty file.json`
3. Check logs for errors
4. Restart VSCode/OpenCode

### Agent Conflicts

1. Review priority settings
2. Check for duplicate functionality
3. Disable conflicting agents
4. Review orchestration settings

### Performance Issues

1. Reduce `maxConcurrentAgents`
2. Disable low-priority agents
3. Check CPU/memory limits
4. Enable caching

For more help, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

---

**Last Updated:** 2026-01-02  
**Version:** 1.0.0
