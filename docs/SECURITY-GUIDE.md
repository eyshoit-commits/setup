# Security Guide

This guide provides comprehensive security information for the repository.

## 📋 Table of Contents

- [Overview](#overview)
- [Security Architecture](#security-architecture)
- [Branch Protection](#branch-protection)
- [Secret Management](#secret-management)
- [Dependency Security](#dependency-security)
- [Code Scanning](#code-scanning)
- [Access Control](#access-control)
- [Incident Response](#incident-response)
- [Best Practices](#best-practices)

## 🔒 Overview

This repository implements enterprise-grade security with multiple layers of protection:

- 🛡️ Branch protection rules
- 🔐 Secret scanning
- 📦 Dependency scanning
- 🔍 Code scanning (CodeQL, Trivy)
- 👥 Access control and code owners
- 🚨 Security monitoring and alerting

## 🏗️ Security Architecture

### Security Layers

```
┌─────────────────────────────────────────┐
│         Branch Protection Rules         │
├─────────────────────────────────────────┤
│      Required PR Reviews & Checks       │
├─────────────────────────────────────────┤
│         Automated Security Scans        │
│  (Trivy, TruffleHog, CodeQL)           │
├─────────────────────────────────────────┤
│          Dependency Management          │
│         (Dependabot, Advisories)        │
├─────────────────────────────────────────┤
│           Access Control                │
│      (CODEOWNERS, Teams, Roles)         │
└─────────────────────────────────────────┘
```

### Security Configuration

All security settings are defined in `config/security.config.json`.

## 🌿 Branch Protection

### Main Branch Protection

The `main` branch has the following protections:

✅ **Required Reviews:**
- 1 approving review required
- Dismiss stale reviews on new commits
- Require code owner reviews
- No last-push approval required

✅ **Status Checks:**
- All checks must pass
- Branch must be up to date
- Required checks:
  - setup-validation
  - security-scan
  - mcp-health-check
  - drift-check
  - commit-validation

✅ **Restrictions:**
- Enforce for administrators
- Require linear history (squash merge only)
- No force pushes
- No branch deletion
- Require conversation resolution

### Configuration Script

To apply branch protection:

```bash
./scripts/configure-branch-protection.sh
```

**Prerequisites:**
- GitHub CLI (`gh`) installed and authenticated
- Admin access to the repository

## 🔐 Secret Management

### Secret Scanning

**Enabled Features:**
- Push protection (blocks secrets in commits)
- Alert notifications
- Historical scanning

**Recipients:**
- @eyshoit-commits
- @security-team

### Best Practices

❌ **Never:**
- Commit API keys, tokens, or passwords
- Store secrets in code or config files
- Share secrets in issues or PRs
- Use weak or predictable secrets

✅ **Always:**
- Use GitHub Secrets for CI/CD
- Use environment variables
- Rotate secrets regularly
- Use secret management tools (Vault, AWS Secrets Manager)

### Environment Variables

Store secrets in `.env` (never commit this file!):

```bash
# .env (DO NOT COMMIT!)
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
API_KEY=sk-xxxxxxxxxxxxx
DATABASE_URL=postgresql://user:pass@host/db
```

Add to `.gitignore`:
```
.env
.env.local
*.key
*.pem
```

### GitHub Secrets

Set secrets via:
1. GitHub UI: Settings → Secrets and variables → Actions
2. GitHub CLI:
   ```bash
   gh secret set SECRET_NAME
   ```

### Secret Prefixes by Environment

- `DEV_*` - Development
- `CI_*` - CI environment
- `STAGING_*` - Staging
- `PROD_*` - Production

## 📦 Dependency Security

### Dependabot Configuration

**Update Schedule:** Weekly (Mondays at 3 AM)

**Ecosystems:**
- GitHub Actions
- npm (Node.js)
- pip (Python)
- cargo (Rust)
- Docker
- Terraform
- Go modules

**Auto-Merge:**
- ✅ Patch updates (e.g., 1.0.0 → 1.0.1)
- ✅ Minor updates (e.g., 1.0.0 → 1.1.0)
- ❌ Major updates (e.g., 1.0.0 → 2.0.0) - require manual review

### Vulnerability Response SLA

| Severity | Response Time | Resolution Target |
|----------|---------------|-------------------|
| Critical | 24 hours | 7 days |
| High | 72 hours | 30 days |
| Medium | 7 days | 90 days |
| Low | 30 days | Best effort |

### Checking Dependencies

**npm:**
```bash
npm audit
npm audit fix
```

**Python:**
```bash
pip install safety
safety check
```

**Rust:**
```bash
cargo audit
```

### Blocking Vulnerable Dependencies

Critical and high severity vulnerabilities will:
1. Fail CI checks
2. Block PR merge
3. Generate security alerts
4. Notify security team

## 🔍 Code Scanning

### CodeQL Analysis

**Languages:** JavaScript, TypeScript, Python, Go

**Schedule:** Weekly

**Features:**
- Static code analysis
- Security vulnerability detection
- Code quality checks
- Custom queries support

**Results:** Uploaded to GitHub Security

### Trivy Scanning

**Scan Types:**
- Filesystem scanning
- Configuration scanning
- Container image scanning (if applicable)

**Severity Levels:** CRITICAL, HIGH, MEDIUM

**Schedule:** Weekly + on every PR

### TruffleHog Secret Scanning

**Features:**
- Verified secrets only
- Historical commit scanning
- High entropy detection

**Schedule:** On every push and PR

### Viewing Results

1. Navigate to **Security** tab
2. Select **Code scanning alerts**
3. Filter by tool or severity
4. Review and dismiss/fix alerts

## 👥 Access Control

### Repository Permissions

| Team | Permission | Access |
|------|-----------|---------|
| @eyshoit-commits | Admin | Full access |
| @security-team | Maintain | Security configs, reviews |
| @devops-team | Write | CI/CD, deployments |
| @agent-team | Write | Agent configurations |
| @documentation-team | Write | Documentation |

### CODEOWNERS

Defined in `.github/CODEOWNERS`:

```
* @eyshoit-commits
/scripts/ @eyshoit-commits @devops-team
/config/ @eyshoit-commits @security-team
/.github/ @eyshoit-commits @security-team
/.opencode/ @eyshoit-commits @agent-team
/SECURITY.md @eyshoit-commits @security-team
```

### Required Approvals

- Standard PRs: 1 approval from any code owner
- Security changes: Additional approval from @security-team
- Infrastructure changes: Approval from @devops-team

## 🚨 Incident Response

### Reporting Security Issues

**NEVER** create public issues for security vulnerabilities!

**Use:**
1. GitHub Security → Report a vulnerability (preferred)
2. Private email to security team
3. Create a private security advisory

### Response Process

1. **Acknowledgment** (within SLA)
2. **Assessment** (severity and impact)
3. **Development** (create fix)
4. **Testing** (verify fix)
5. **Disclosure** (coordinate with reporter)
6. **Release** (deploy fix)
7. **Advisory** (publish if appropriate)

### Severity Classification

**Critical:**
- Remote code execution
- Authentication bypass
- Data breach
- Privilege escalation

**High:**
- XSS in sensitive contexts
- CSRF with significant impact
- Security misconfigurations

**Medium:**
- XSS in limited contexts
- Information disclosure
- Missing security headers

**Low:**
- Verbose errors
- Best practice violations
- Low-impact information disclosure

## ✅ Best Practices

### For Developers

1. **Keep Dependencies Updated**
   - Review Dependabot PRs promptly
   - Update dependencies regularly
   - Test after updates

2. **Secure Coding**
   - Validate all inputs
   - Encode outputs
   - Use parameterized queries
   - Implement proper error handling
   - Follow OWASP guidelines

3. **Code Review**
   - Review security implications
   - Check for hardcoded secrets
   - Verify input validation
   - Test authentication/authorization

4. **Testing**
   - Write security tests
   - Test error conditions
   - Verify access controls
   - Test with invalid inputs

### For Reviewers

1. **Security Checklist**
   - [ ] No hardcoded secrets
   - [ ] Input validation implemented
   - [ ] Output encoding applied
   - [ ] Authentication/authorization correct
   - [ ] Error handling secure
   - [ ] Dependencies up to date
   - [ ] No SQL injection vulnerabilities
   - [ ] No XSS vulnerabilities
   - [ ] CSRF protection in place

2. **Review Focus Areas**
   - Authentication logic
   - Authorization checks
   - Data validation
   - Cryptography usage
   - External API calls
   - File operations
   - Database queries

### For Administrators

1. **Access Management**
   - Use principle of least privilege
   - Review access regularly
   - Remove inactive users
   - Enable 2FA for all users

2. **Monitoring**
   - Review security alerts daily
   - Monitor access logs
   - Track failed login attempts
   - Audit configuration changes

3. **Compliance**
   - Enforce policies
   - Regular security audits
   - Documentation updates
   - Team training

## 🔗 Resources

### External Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

### Internal Documentation

- [SECURITY.md](../.github/SECURITY.md) - Security policy
- [REPO-POLICY.md](../.github/REPO-POLICY.md) - Repository policies
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

## 📞 Contact

**Security Team:** @eyshoit-commits @security-team

**For Security Issues:**
- GitHub Security → Report a vulnerability
- See [SECURITY.md](../.github/SECURITY.md) for full process

---

**Last Updated:** 2026-01-02  
**Version:** 1.0.0
