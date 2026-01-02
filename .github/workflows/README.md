# GitHub Actions Workflows

This directory contains all automated workflows for the setup repository.

## 🔄 Automated Workflows

### 1. Auto-Update Dependencies (`auto-update-dependencies.yml`)
**Schedule:** Daily at 2:00 AM UTC  
**Purpose:** Automatically check and update OpenCode repositories and development tools

**Features:**
- Monitors 13 OpenCode repositories for updates
- Tracks changes using SHA comparison
- Checks nvm, pnpm, and bun for new versions
- Automatically creates PRs for updates
- Stores tracking data in `.opencode/dependencies/`

**Repositories Monitored:**
- malhashemi/opencode-skills
- malhashemi/opencode-sessions
- shuv1337/oc-manager
- code-yeongyu/oh-my-opencode
- IgorWarzocha/Opencode-Roadmap
- zenobi-us/opencode-background
- Tarquinen/opencode-smart-title
- pantheon-org/opencode-warcraft-notifications
- IgorWarzocha/Opencode-Context-Analysis-Plugin
- shuv1337/oc-web
- ajaxdude/opencode-ai-poimandres-theme
- VoltAgent/awesome-claude-code-subagents
- darrenhinde/OpenAgents

### 2. Subagent Validation (`subagent-validation.yml`)
**Triggers:** Push/PR on agent files, manual dispatch  
**Purpose:** Validate all subagent JSON definitions

**Validation Checks:**
- ✅ JSON syntax validation
- ✅ Schema compliance verification
- ✅ Duplicate name detection
- ✅ Dependency graph validation
- ✅ Required field presence

**Outputs:**
- Validation report (markdown)
- PR comments with results
- Artifact uploads for historical tracking

### 3. Auto-Assign Agents (`auto-assign-agents.yml`)
**Triggers:** Issue/PR opened or edited  
**Purpose:** Automatically assign relevant agents to issues and PRs

**How It Works:**
1. Analyzes issue/PR title and body
2. Matches content against agent keywords and skills
3. Calculates relevance scores
4. Assigns top 5 matching agents
5. Adds category labels (security, testing, docs, etc.)
6. Posts agent recommendations as comments

**Categories Detected:**
- Security, Testing, Documentation
- Performance, Bug, Feature, Refactor
- CI/CD, Dependencies, Setup
- Database, API, Frontend, Backend
- AI/ML

### 4. Agent Performance (`agent-performance.yml`)
**Schedule:** Weekly on Monday at 9:00 AM UTC  
**Purpose:** Monitor and report on agent performance metrics

**Metrics Collected:**
- Agent usage in commits (@agent mentions)
- Agent labels in issues and PRs
- Success rates (closed items)
- Response times
- Historical trends

**Outputs:**
- Weekly performance reports
- Metrics stored in `.github/metrics/`
- Historical data in `.github/metrics/history/`
- Performance summary issues

### 5. Subagent Updates (`subagent-updates.yml`)
**Schedule:** Monthly on the 1st at 3:00 AM UTC  
**Purpose:** Check for template updates and facilitate agent regeneration

**Features:**
- Monitors template repositories for changes
- Tracks template versions using SHA
- Creates backups before updates
- Detects deprecated patterns
- Generates update helper scripts
- Creates PRs with update instructions

**Template Sources:**
- microsoft/copilot-agent-template
- opencode/skill-template
- microsoft/vscode-extension-samples

### 6. Dependency Review (`dependency-review.yml`)
**Triggers:** PR modifying dependency files  
**Purpose:** Comprehensive dependency change analysis

**Analysis Includes:**
- 🔒 Vulnerability scanning (npm, Python, etc.)
- 📜 License compliance checking
- 📦 Bundle size impact
- 📅 Outdated dependency detection
- ⚠️ Security advisories

**Supported Package Managers:**
- npm/yarn/pnpm (Node.js)
- pip/Pipfile (Python)
- go.mod (Go)
- Cargo.toml (Rust)
- Gemfile (Ruby)

**Enforcement:**
- Fails on critical/high vulnerabilities
- Blocks forbidden licenses (GPL-2.0, GPL-3.0, AGPL)
- Posts comprehensive reports to PRs

### 7. Codespace Setup (`codespace-setup.yml`)
**Triggers:** Push, PR, Codespace create/start, manual dispatch  
**Purpose:** Initialize development environment

**Platform Support:**
- ✅ Linux (Ubuntu)
- ✅ macOS
- ✅ Windows
- ✅ GitHub Codespaces

**Codespace Features:**
- Automatic tool installation
- Setup script execution
- Environment validation
- Agent handshake generation
- VS Code extension configuration
- Welcome message display

## 📊 Workflow Statistics

| Workflow | Lines | Size | Frequency |
|----------|-------|------|-----------|
| auto-update-dependencies | 234 | 9.7K | Daily |
| subagent-validation | 280 | 8.9K | On PR/Push |
| auto-assign-agents | 248 | 9.5K | On Issue/PR |
| agent-performance | 286 | 11K | Weekly |
| subagent-updates | 304 | 11K | Monthly |
| dependency-review | 362 | 13K | On PR |
| codespace-setup | Enhanced | - | On Event |
| **Total** | **1,714+** | **63K+** | - |

## 🚀 Usage

### Manual Trigger
All workflows support manual triggering via `workflow_dispatch`:

```bash
# Using GitHub CLI
gh workflow run auto-update-dependencies.yml
gh workflow run subagent-validation.yml
gh workflow run agent-performance.yml
```

### Viewing Results
```bash
# List recent workflow runs
gh run list --workflow=auto-update-dependencies.yml

# View logs
gh run view <run-id> --log

# Download artifacts
gh run download <run-id>
```

## 🔧 Configuration

### Permissions
All workflows use minimal required permissions:
- `contents: read/write` - Repository access
- `pull-requests: write` - PR creation and comments
- `issues: write` - Issue creation and labels

### Secrets
No additional secrets required. Uses built-in:
- `GITHUB_TOKEN` - Automatic token for API access

### Customization
Edit workflow files to adjust:
- Schedule times (cron expressions)
- Matrix strategies (repository lists)
- Validation rules
- Threshold values

## 📚 Documentation

- See individual workflow files for detailed implementation
- Check `.github/metrics/` for performance reports
- Review `.opencode/dependencies/` for tracking data
- Consult generated artifacts for analysis results

## 🛡️ Security

All workflows follow security best practices:
- ✅ No hardcoded secrets
- ✅ Minimal permissions
- ✅ Dependency pinning
- ✅ Vulnerability scanning
- ✅ License compliance
- ✅ Audit logging

## 🐛 Troubleshooting

### Workflow Fails
1. Check workflow logs in Actions tab
2. Review permissions and secrets
3. Verify file paths and dependencies
4. Check for API rate limits

### False Positives
1. Adjust validation rules
2. Update keyword mappings
3. Refine thresholds
4. Add exceptions as needed

### Performance Issues
1. Review schedule frequency
2. Optimize matrix strategies
3. Cache dependencies
4. Reduce artifact retention

## 📞 Support

For issues or questions:
- Open an issue with the `workflow` label
- Check existing workflow runs for examples
- Review workflow logs for debugging
- Consult GitHub Actions documentation

---

**Last Updated:** 2026-01-02  
**Maintained By:** Setup Repository Team
