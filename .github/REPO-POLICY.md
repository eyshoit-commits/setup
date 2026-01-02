# Repository Policy

## 📋 Overview

This document defines the policies, standards, and procedures for contributing to and maintaining this repository.

## 🌿 Branch Management

### Branch Naming Convention

Branches must follow this naming pattern:

```
<type>/<short-description>
```

**Types:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `perf/` - Performance improvements
- `test/` - Test additions or modifications
- `chore/` - Maintenance tasks
- `security/` - Security fixes
- `hotfix/` - Urgent production fixes

**Examples:**
- `feature/add-user-authentication`
- `fix/correct-login-validation`
- `docs/update-api-documentation`
- `security/patch-xss-vulnerability`

### Branch Protection

#### Main Branch
- **Required**: Pull request with 1 approval
- **Required**: All status checks must pass
- **Required**: Conversation resolution
- **Required**: Code owner review
- **Prohibited**: Direct commits
- **Prohibited**: Force pushes
- **Prohibited**: Branch deletion
- **Required**: Linear history (no merge commits)

#### Develop Branch (if used)
- **Required**: Pull request
- **Required**: All status checks must pass
- **Allowed**: Commits from automated processes
- **Prohibited**: Force pushes

### Branch Lifecycle

1. **Create** branch from `main` or `develop`
2. **Develop** your changes
3. **Push** regularly to remote
4. **Create** pull request when ready
5. **Review** and address feedback
6. **Merge** using squash and merge
7. **Delete** branch after merge

## 💬 Commit Message Format

### Conventional Commits

All commits MUST follow the Conventional Commits specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, semicolons, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

### Scope

Optional, but recommended. Examples:
- `api`
- `ui`
- `auth`
- `config`
- `deps`
- `workflow`

### Description

- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period at the end
- Maximum 72 characters

### Examples

```
feat(auth): add JWT token authentication

fix(api): correct user validation endpoint

docs(readme): update installation instructions

chore(deps): update dependencies to latest versions
```

### Body (Optional)

- Separate from subject with blank line
- Explain what and why, not how
- Wrap at 100 characters

### Footer (Optional)

- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: description`

## 🔀 Pull Request Process

### Creating a Pull Request

1. **Ensure** your branch is up to date with base branch
2. **Run** all tests locally
3. **Fix** any linting or formatting issues
4. **Create** PR with descriptive title and description
5. **Fill out** PR template completely
6. **Link** related issues
7. **Request** review from appropriate code owners

### PR Title Format

Follow the same format as commit messages:
```
<type>(<scope>): <description>
```

### PR Size Guidelines

- **Preferred**: < 500 lines changed
- **Acceptable**: 500-1000 lines with good reason
- **Discouraged**: > 1000 lines (split into multiple PRs)

### PR Review Requirements

- **Minimum**: 1 approval from code owner
- **Security changes**: Additional security team approval
- **Infrastructure changes**: DevOps team approval
- **Agent changes**: Agent team approval

### Review Timeline

- **Initial review**: Within 2 business days
- **Follow-up**: Within 1 business day
- **Urgent PRs**: Tag with `urgent` label

### Addressing Review Feedback

1. **Respond** to all comments
2. **Make** requested changes
3. **Reply** when changes are complete
4. **Re-request** review
5. **Resolve** conversations when addressed

## ✅ Quality Standards

### Code Quality

- **Follow** existing code style
- **Write** clear, self-documenting code
- **Add** comments for complex logic
- **Avoid** duplication
- **Keep** functions small and focused

### Testing Requirements

- **Unit tests**: Required for new features
- **Integration tests**: Required for API changes
- **Manual testing**: Required in reproduction mode
- **Test coverage**: Maintain or improve coverage

### Documentation

- **Update** README for user-facing changes
- **Document** new features and APIs
- **Add** inline comments for complex code
- **Update** CHANGELOG for notable changes

## 🔐 Security Requirements

### Pre-Commit

- **No secrets** in code
- **No credentials** in configuration
- **Use** environment variables for sensitive data
- **Scan** dependencies for vulnerabilities

### Code Review

- **Security impact** assessment required
- **Security team** review for sensitive changes
- **Vulnerability** scan must pass
- **Secret** scan must pass

## 🤖 Automation and CI/CD

### Required Checks

All PRs must pass:
1. **setup-validation** - Repository structure validation
2. **security-scan** - Security vulnerability scanning
3. **mcp-health-check** - MCP configuration validation
4. **drift-check** - Configuration drift detection
5. **commit-validation** - Commit message format validation

### Automated Processes

- **Dependabot**: Automatic dependency updates
- **Auto-merge**: Minor/patch updates after tests pass
- **Scheduled scans**: Weekly security scans
- **Drift detection**: Daily configuration checks

## 📦 Dependency Management

### Adding Dependencies

1. **Justify** the need for new dependency
2. **Check** for security vulnerabilities
3. **Verify** license compatibility
4. **Update** dependabot configuration
5. **Document** in PR description

### Updating Dependencies

- **Minor/Patch**: Auto-merged by Dependabot
- **Major**: Manual review required
- **Security**: Prioritize and expedite

## 🚀 Deployment Process

### Deployment Environments

1. **Development** - Automatic from `develop` branch
2. **Staging** - Automatic from `main` after tests
3. **Production** - Manual approval required

### Deployment Checklist

- [ ] All tests passing
- [ ] Security scans clear
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Stakeholders notified
- [ ] Rollback plan ready

## 🔄 Rollback Procedures

### When to Rollback

- Critical bugs in production
- Security vulnerabilities discovered
- Performance degradation
- Data integrity issues

### Rollback Process

1. **Identify** issue severity
2. **Notify** stakeholders
3. **Execute** rollback (revert commit or redeploy)
4. **Verify** rollback success
5. **Document** incident
6. **Create** postmortem issue

## 📊 Incident Response

### Severity Levels

- **P0 (Critical)**: System down, data loss
- **P1 (High)**: Major feature broken
- **P2 (Medium)**: Minor feature broken
- **P3 (Low)**: Cosmetic issues

### Response Times

| Priority | Acknowledgment | Resolution Target |
|----------|---------------|-------------------|
| P0 | 15 minutes | 2 hours |
| P1 | 1 hour | 8 hours |
| P2 | 4 hours | 2 days |
| P3 | 1 day | 1 week |

## 👥 Team Roles and Responsibilities

### Code Owners

- Review PRs in their area
- Maintain code quality
- Provide technical guidance
- Approve/reject changes

### Security Team

- Review security-related changes
- Respond to security reports
- Maintain security policies
- Conduct security audits

### DevOps Team

- Maintain CI/CD pipelines
- Manage infrastructure
- Monitor deployments
- Optimize workflows

### Documentation Team

- Review documentation changes
- Maintain documentation quality
- Ensure consistency
- Update guides

## 📝 Communication

### Channels

- **Issues**: Bug reports, feature requests
- **Pull Requests**: Code changes, discussions
- **Discussions**: General questions, proposals
- **Security**: Private vulnerability reports

### Best Practices

- Be respectful and professional
- Provide context and details
- Respond in timely manner
- Use appropriate channels

## 📜 Compliance and Legal

### License

- All code must comply with repository license
- Third-party code must have compatible licenses
- Document all license dependencies

### Copyright

- Maintain copyright headers where required
- Respect third-party copyrights
- Don't commit copyrighted material without permission

## 🔄 Policy Updates

This policy is reviewed quarterly and updated as needed.

**Version**: 1.0.0  
**Last Updated**: 2026-01-02  
**Next Review**: 2026-04-02  
**Owner**: @eyshoit-commits @security-team
