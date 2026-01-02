# GitHub Copilot Instructions for Setup Repository

## Repository Overview
This is an enterprise-grade development environment setup repository with advanced features including:
- Idempotent installation scripts
- Version locking and deterministic builds
- Offline/air-gap support
- Multi-agent orchestration
- Security-first approach

## Key Principles

### 1. Idempotency
All setup scripts MUST be idempotent - they can run multiple times without side effects.
- Always check if a tool is already installed before installing
- Use version comparisons to decide on updates
- Log status as INSTALLED/SKIPPED/FAILED

### 2. Version Locking
- All tool versions are locked in `config/versions.env`
- Never use `latest` unless `SETUP_ALLOW_LATEST=true`
- Update versions deliberately, not automatically

### 3. Cross-Platform Support
- Maintain both Bash (.sh) and PowerShell (.ps1) versions
- Test on Linux, macOS, and Windows
- Use portable shell commands when possible

### 4. Security First
- Pre-commit hooks are mandatory
- Gitleaks scanning is enforced
- Never commit secrets (use .env, not .env.local)
- All dependencies are audited

### 5. Offline-Ready
- Support air-gapped installations via `artifacts/` directory
- Prefer local artifacts over network downloads when available
- Document offline installation in README

## Development Workflow

### Adding New Tools
1. Add version to `config/versions.env`
2. Update both `scripts/setup.sh` and `scripts/setup.ps1`
3. Add smoke test to verify installation
4. Update `.mcp/context.json` generation
5. Document in INSTALLATION.md

### Modifying Scripts
1. Ensure idempotency is maintained
2. Update both Bash and PowerShell versions
3. Test on multiple platforms
4. Run validation and smoke tests
5. Update JSON reports if needed

### Agent Development
- All agents are defined in `.opencode/agents/`
- Skills are reusable across agents
- Context is shared via `.mcp/context.json`
- Follow the orchestrator pattern for task delegation

## File Structure Guidelines

### Must-Have Files
- `config/versions.env` - Version locks
- `scripts/setup.sh` - Main setup (Bash)
- `scripts/setup.ps1` - Main setup (PowerShell)
- `scripts/smoke-test.sh` - Validation tests
- `.gitleaks.toml` - Secret scanning config
- `setup-report.json` - Auto-generated status report

### Environment Management
- Use `env.d/` for shell-agnostic environment variables
- Source files in numeric order (00-base, 10-tools, 99-custom)
- Never hardcode paths - use dynamic detection

## Code Style

### Bash Scripts
```bash
# Always use strict mode
set -e

# Use colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Check before installing
if command -v tool &>/dev/null; then
  # Already installed
  log_status "tool" "$version" "$(which tool)" "skipped"
else
  # Install
  install_tool
  log_status "tool" "$version" "$(which tool)" "installed"
fi
```

### PowerShell Scripts
```powershell
# Use strict error handling
$ErrorActionPreference = "Stop"

# Check before installing
if (Get-Command tool -ErrorAction SilentlyContinue) {
    Log-Status "tool" $version (Get-Command tool).Source "skipped"
} else {
    Install-Tool
    Log-Status "tool" $version (Get-Command tool).Source "installed"
}
```

## Testing Requirements
- Always run `bash scripts/validate.sh` before setup
- Run `bash scripts/smoke-test.sh` after setup
- Check `setup-report.json` for status summary
- Verify `.mcp/context.json` is generated correctly

## Common Pitfalls to Avoid
- ❌ Installing tools without version checks
- ❌ Hardcoding paths instead of using environment variables
- ❌ Forgetting to update both Bash and PowerShell scripts
- ❌ Not testing offline mode
- ❌ Committing secrets or credentials
- ❌ Breaking idempotency with stateful operations

## When Making Changes
1. Read existing scripts to understand patterns
2. Follow the same structure and conventions
3. Test locally before committing
4. Update documentation
5. Run security scans
6. Generate updated reports

## MCP/Agent Context
The repository is agent-ready. When working with agents:
- Check `.mcp/context.json` for current environment state
- Use `.opencode/agents/` definitions for capabilities
- Follow the orchestrator pattern for multi-agent tasks
- Ensure context is updated after installations

## Support
For questions or issues:
- Check `docs/TROUBLESHOOTING.md`
- Review `setup-report.json` for diagnostics
- Consult agent definitions in `.opencode/agents/`
