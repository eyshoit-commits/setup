# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the repository setup.

## 📋 Table of Contents

- [Setup Issues](#setup-issues)
- [Agent Issues](#agent-issues)
- [GitHub Workflow Issues](#github-workflow-issues)
- [Security Scan Issues](#security-scan-issues)
- [VSCode Issues](#vscode-issues)
- [Common Errors](#common-errors)
- [Getting Help](#getting-help)

## 🔧 Setup Issues

### Issue: Setup script fails with "Permission denied"

**Symptoms:**
```bash
bash: ./scripts/setup.sh: Permission denied
```

**Solution:**
```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

**Prevention:**
Scripts should be executable by default. If cloned fresh, run:
```bash
git update-index --chmod=+x scripts/*.sh
```

---

### Issue: "jq command not found"

**Symptoms:**
```bash
setup.sh: line 42: jq: command not found
```

**Solution:**

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install jq
```

**macOS:**
```bash
brew install jq
```

**Windows:**
```powershell
choco install jq
# or
scoop install jq
```

---

### Issue: Invalid JSON in configuration files

**Symptoms:**
```
✗ config/agents.config.json has invalid JSON
```

**Solution:**

1. Find the invalid JSON:
```bash
find . -name "*.json" -not -path "./node_modules/*" -exec sh -c 'jq empty "$1" 2>&1 | grep -q error && echo "$1"' _ {} \;
```

2. Fix syntax errors using an editor with JSON validation (VSCode)

3. Validate specific file:
```bash
jq empty config/agents.config.json
```

---

### Issue: Missing required directories

**Symptoms:**
```
❌ Missing required directories:
  - config
  - docs
```

**Solution:**
```bash
mkdir -p config docs scripts
./scripts/validate-setup.sh
```

---

## 🤖 Agent Issues

### Issue: Agent not loading

**Symptoms:**
- Agent features not available
- No agent output in logs

**Diagnostic Steps:**

1. Check if agent is enabled:
```bash
jq '.enabled' .opencode/agents/AGENT_NAME.json
```

2. Verify JSON syntax:
```bash
jq empty .opencode/agents/AGENT_NAME.json
```

3. Check agent priority and autoLoad:
```bash
jq '.config.autoLoad, .config.priority' .opencode/agents/AGENT_NAME.json
```

**Solution:**

Enable the agent:
```json
{
  "enabled": true,
  "config": {
    "autoLoad": true
  }
}
```

---

### Issue: Agent conflicts or performance issues

**Symptoms:**
- Slow performance
- High CPU/memory usage
- Conflicting behavior

**Solution:**

1. Reduce concurrent agents:
```json
// config/agents.config.json
{
  "settings": {
    "orchestration": {
      "maxConcurrentAgents": 3  // Reduce from 5
    }
  }
}
```

2. Disable low-priority agents:
```bash
# Disable web agent (if not needed)
jq '.enabled = false' .opencode/agents/web-agent.json > tmp.json
mv tmp.json .opencode/agents/web-agent.json
```

3. Enable caching:
```json
{
  "settings": {
    "performance": {
      "cacheEnabled": true
    }
  }
}
```

---

### Issue: Background agent consuming too many resources

**Symptoms:**
- High CPU usage
- System slowdown

**Solution:**

Adjust resource limits in `.opencode/agents/background-agent.json`:
```json
{
  "config": {
    "maxConcurrentTasks": 2,  // Reduce from 3
    "performance": {
      "maxCpuUsage": 30,  // Reduce from 50
      "maxMemoryMB": 256  // Reduce from 512
    }
  }
}
```

---

## 🔄 GitHub Workflow Issues

### Issue: Workflow fails with "Resource not accessible by integration"

**Symptoms:**
```
Error: Resource not accessible by integration
```

**Cause:** Insufficient permissions for GitHub Actions

**Solution:**

1. Check workflow permissions in `.github/workflows/WORKFLOW.yml`:
```yaml
permissions:
  contents: read
  security-events: write
  actions: read
```

2. Grant necessary permissions in repository settings:
   - Settings → Actions → General → Workflow permissions
   - Select "Read and write permissions"

---

### Issue: Status checks not appearing

**Symptoms:**
- PR shows "Some checks haven't completed yet"
- Expected checks missing

**Solution:**

1. Verify workflow is triggered:
```yaml
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]
```

2. Check workflow status:
```bash
gh run list --workflow=setup-validation.yml
```

3. View workflow logs:
```bash
gh run view <run-id> --log
```

---

### Issue: Dependabot PRs not auto-merging

**Symptoms:**
- Patch/minor updates not merging automatically
- Workflow runs but doesn't merge

**Solution:**

1. Check if Dependabot workflow is running:
```bash
gh run list --workflow=dependabot-auto-merge.yml
```

2. Verify status checks passed:
```bash
gh pr checks <pr-number>
```

3. Ensure auto-merge is enabled:
```bash
gh pr merge --auto --squash <pr-number>
```

4. Check if branch protection allows auto-merge

---

## 🔒 Security Scan Issues

### Issue: Trivy scan failing

**Symptoms:**
```
Error: failed to scan filesystem
```

**Solution:**

1. Check Trivy is properly configured:
```yaml
# .github/workflows/security-scan.yml
- uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
    scan-ref: '.'
```

2. Temporarily reduce severity:
```yaml
with:
  severity: 'CRITICAL,HIGH'  # Remove MEDIUM
```

3. Add exceptions for false positives:
```yaml
with:
  trivyignores: '.trivyignore'
```

Create `.trivyignore`:
```
# Ignore specific CVEs
CVE-2021-12345
```

---

### Issue: Secret scan finding false positives

**Symptoms:**
- TruffleHog reports non-secrets as secrets
- High entropy strings flagged

**Solution:**

1. Use verified-only mode (already enabled):
```yaml
with:
  extra_args: --only-verified
```

2. Add patterns to exclude:
```bash
# Create .trufflehog-exclude
test/fixtures/*
docs/examples/*
```

3. If legitimate secret, rotate and use GitHub Secrets

---

### Issue: CodeQL analysis timing out

**Symptoms:**
```
Error: CodeQL analysis timed out
```

**Solution:**

1. Increase timeout:
```yaml
- name: Perform CodeQL Analysis
  uses: github/codeql-action/analyze@v3
  timeout-minutes: 30  # Increase from default
```

2. Exclude large files:
```yaml
- name: Initialize CodeQL
  uses: github/codeql-action/init@v3
  with:
    config-file: .github/codeql-config.yml
```

Create `.github/codeql-config.yml`:
```yaml
paths-ignore:
  - 'dist/**'
  - 'build/**'
  - 'vendor/**'
```

---

## 💻 VSCode Issues

### Issue: Extensions not installing

**Symptoms:**
- Recommended extensions not appearing
- Extensions fail to install

**Solution:**

1. Manually install recommended extensions:
```bash
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension eamodio.gitlens
```

2. Check `.vscode/extensions.json`:
```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint"
  ]
}
```

3. Reload VSCode: `Ctrl+Shift+P` → "Developer: Reload Window"

---

### Issue: Settings not applying

**Symptoms:**
- VSCode not using configured settings
- Formatting not working

**Solution:**

1. Check workspace settings priority:
   - Workspace settings override user settings
   - Verify in `.vscode/settings.json`

2. Reload window: `Ctrl+Shift+P` → "Reload Window"

3. Check for conflicting extensions

4. Reset workspace: Delete `.vscode` and reopen

---

### Issue: Debugger not working

**Symptoms:**
- Breakpoints not hitting
- Debug session fails to start

**Solution:**

1. Verify launch configuration:
```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Node.js: Current File",
      "type": "node",
      "request": "launch",
      "program": "${file}"
    }
  ]
}
```

2. Install required extensions:
   - For Node.js: Built-in
   - For Python: `ms-python.python`
   - For Go: `golang.go`

3. Check file path and permissions

---

## ⚠️ Common Errors

### Error: "fatal: not a git repository"

**Solution:**
```bash
cd /path/to/setup/repository
git status
```

---

### Error: "GitHub CLI not authenticated"

**Solution:**
```bash
gh auth login
# Follow prompts to authenticate
```

---

### Error: "npm: command not found"

**Solution:**

Install Node.js from https://nodejs.org/ or:

**Ubuntu/Debian:**
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**macOS:**
```bash
brew install node
```

---

### Error: "python3: command not found"

**Solution:**

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install python3 python3-pip
```

**macOS:**
```bash
brew install python@3.11
```

**Windows:**
Download from https://python.org/

---

## 🆘 Getting Help

### Before Creating an Issue

1. ✅ Search existing issues
2. ✅ Check this troubleshooting guide
3. ✅ Review relevant documentation
4. ✅ Run validation script: `./scripts/validate-setup.sh`

### Creating an Issue

Use the appropriate template:

- **Bug Report:** For unexpected behavior
- **Infrastructure:** For setup/config issues
- **Security Finding:** For security issues (use private reporting)
- **Agent Improvement:** For agent-related issues

### Include This Information

```
**Environment:**
- OS: [e.g., Ubuntu 22.04]
- Git version: [run: git --version]
- Node.js version: [run: node --version]
- Shell: [bash, zsh, PowerShell]

**Steps to Reproduce:**
1. 
2. 
3. 

**Expected vs Actual:**
Expected: ...
Actual: ...

**Logs:**
```
[paste relevant logs]
```

**Additional Context:**
[any other relevant information]
```

### Contact

- **General Issues:** Create an issue
- **Security Issues:** Use private vulnerability reporting
- **Questions:** GitHub Discussions
- **Urgent:** @eyshoit-commits

## 🔍 Diagnostic Commands

Run these to gather information:

```bash
# System info
uname -a
git --version
node --version
python3 --version

# Repository status
git status
git log --oneline -5

# Validation
./scripts/validate-setup.sh

# Check workflows
gh run list --limit 10

# View recent logs
gh run view --log
```

---

**Last Updated:** 2026-01-02  
**Version:** 1.0.0

**Need more help?** Create an issue or contact @eyshoit-commits
