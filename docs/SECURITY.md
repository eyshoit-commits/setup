# Security Policy

## Overview

This repository implements a security-first approach with multiple layers of protection:

- **Pre-commit hooks** for automated security checks
- **Gitleaks** for secret scanning
- **Dependency auditing** for known vulnerabilities
- **Version locking** to prevent supply chain attacks
- **Offline mode** for air-gapped environments

## Security Features

### 1. Secret Scanning (Gitleaks)

Gitleaks scans the repository for accidentally committed secrets:

- API keys
- AWS credentials
- GitHub tokens
- Private keys
- Database passwords

**Configuration**: `.gitleaks.toml`

**Run manually**:
```bash
gitleaks detect --verbose
```

**GitHub Action**: Runs automatically on every push and PR

### 2. Pre-commit Hooks

Pre-commit hooks prevent committing problematic code:

**Python**:
- `ruff` - Fast linting and formatting
- `ruff-format` - Code formatting

**JavaScript/TypeScript**:
- `eslint` - Linting

**Rust**:
- `cargo fmt` - Formatting
- `cargo clippy` - Linting with warnings as errors

**Installation**:
```bash
cp config/pre-commit-config.yaml .pre-commit-config.yaml
pre-commit install
```

**Run manually**:
```bash
pre-commit run --all-files
```

### 3. Dependency Auditing

Regular audits of dependencies for known vulnerabilities:

**NPM** (if package.json exists):
```bash
npm audit --audit-level=moderate
```

**Python**:
```bash
pip install pip-audit
pip-audit -r config/requirements.txt
```

**Automated**: GitHub Action runs weekly

### 4. Version Locking

All tool versions are locked in `config/versions.env` to prevent:
- Supply chain attacks
- Unexpected breaking changes
- Non-deterministic builds

**Override** (use with caution):
```bash
export SETUP_ALLOW_LATEST=true
bash scripts/setup.sh
```

### 5. Offline/Air-gap Support

For maximum security, run setup without internet access:

1. Download installers on a trusted machine
2. Place in `artifacts/` directory
3. Transfer to air-gapped environment
4. Run setup (uses local installers)

See [INSTALLATION.md](./INSTALLATION.md#offline-installation) for details.

## Allowlist

Certain files are excluded from security scans:

- `.env.example` - Template file with no real secrets
- `artifacts/` - Contains downloaded installers

**Configuration**: See `.gitleaks.toml`

## Best Practices

### Never Commit Secrets

❌ **Don't**:
```bash
# .env (committed to git)
API_KEY=sk-1234567890abcdef
DATABASE_URL=postgres://user:password@host/db
```

✅ **Do**:
```bash
# .env.example (committed to git)
API_KEY=your-api-key-here
DATABASE_URL=your-database-url-here

# .env (in .gitignore, not committed)
API_KEY=sk-1234567890abcdef
DATABASE_URL=postgres://user:password@host/db
```

### Use Environment Variables

Store secrets in environment variables, not in code:

**Python**:
```python
import os
api_key = os.environ.get('API_KEY')
```

**JavaScript**:
```javascript
const apiKey = process.env.API_KEY;
```

**Rust**:
```rust
let api_key = std::env::var("API_KEY")?;
```

### Review Dependencies

Before adding new dependencies:

1. Check for known vulnerabilities
2. Review package reputation and maintenance
3. Audit package permissions
4. Pin specific versions

### Regular Updates

Keep dependencies and tools updated:

1. Monitor security advisories
2. Update `config/versions.env` regularly
3. Run security scans after updates
4. Test thoroughly before deploying

## Security Scanning

### Manual Scans

Run all security checks:

```bash
# Secret scanning
gitleaks detect --verbose

# Pre-commit checks
pre-commit run --all-files

# Dependency audits
npm audit
pip-audit -r config/requirements.txt
```

### Automated Scans

GitHub Actions run automatically:

- **On every push/PR**: Gitleaks, pre-commit
- **Weekly**: Full dependency audit
- **On demand**: Manual workflow trigger

## Incident Response

### If You Commit a Secret

**Immediate Actions**:

1. **Revoke the secret** immediately
   - Rotate API keys
   - Change passwords
   - Invalidate tokens

2. **Remove from Git history**:
   ```bash
   # WARNING: Rewrites history, use with caution
   git filter-repo --invert-paths --path <file-with-secret>
   ```

3. **Force push** (if safe):
   ```bash
   git push --force-with-lease
   ```

4. **Report**: Document the incident

### If You Find a Vulnerability

See [Reporting Vulnerabilities](#reporting-vulnerabilities) below.

## Reporting Vulnerabilities

To report security vulnerabilities:

### Private Reporting (Preferred)

Use GitHub's private vulnerability reporting:
1. Go to repository **Security** tab
2. Click **Report a vulnerability**
3. Fill in details

### Email

For critical issues: `security@example.com`

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if known)

### Response Time

- **Critical**: Within 24 hours
- **High**: Within 3 days
- **Medium/Low**: Within 7 days

## Security Updates

Security updates are released as needed:

- **Critical**: Immediate patch release
- **High**: Within 1 week
- **Medium**: Next minor release
- **Low**: Next major release

## Compliance

This setup follows industry best practices:

- **OWASP** - Secure coding practices
- **CIS** - Security benchmarks
- **NIST** - Cybersecurity framework

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## Security Checklist

Before deploying:

- [ ] All secrets in environment variables
- [ ] `.env` in `.gitignore`
- [ ] Pre-commit hooks installed
- [ ] Gitleaks scan passed
- [ ] Dependency audit clean
- [ ] Versions locked in `versions.env`
- [ ] Security documentation reviewed
- [ ] Incident response plan in place

## Questions?

For security questions or concerns:
- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- Review `.github/copilot-instructions.md`
- Open a GitHub issue (for non-sensitive topics)
- Email security team (for sensitive topics)
