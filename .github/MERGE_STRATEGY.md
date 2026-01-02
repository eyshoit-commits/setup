# Merge Strategy

## 🎯 Overview

This repository uses **Squash and Merge** as the only allowed merge method. This ensures a clean, linear history and makes it easier to track changes and revert if necessary.

## ✅ Allowed Merge Method

### Squash and Merge (ONLY)

All pull requests MUST be merged using "Squash and Merge". This method:

- ✅ Combines all commits into a single commit
- ✅ Creates a linear git history
- ✅ Makes it easy to revert entire features
- ✅ Keeps the history clean and readable
- ✅ Enforces conventional commit format on main branch

## ❌ Prohibited Merge Methods

### Merge Commit (Disabled)

- ❌ Creates merge commits
- ❌ Makes history harder to read
- ❌ Difficult to revert
- ❌ Clutters git log

### Rebase and Merge (Disabled)

- ❌ Can rewrite commit history
- ❌ Loses individual commit context
- ❌ More complex for reverting
- ❌ Can cause confusion with shared branches

## 📝 Commit Message Template

When squashing, the commit message MUST follow this format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Examples

```
feat(auth): add OAuth2 authentication

Implemented OAuth2 flow for user authentication with support
for Google and GitHub providers.

- Added OAuth2 configuration
- Implemented token validation
- Added user session management

Fixes #123
```

```
fix(api): correct user validation endpoint

The user validation endpoint was returning incorrect status
codes for invalid requests.

Closes #456
```

```
docs(readme): update installation instructions

Added missing steps for Windows installation and updated
prerequisites section.
```

## 🔍 Merge Process

### 1. Prepare for Merge

- [ ] All status checks passed
- [ ] All conversations resolved
- [ ] Required approvals obtained
- [ ] Branch is up to date with base

### 2. Review Commit Title

GitHub will suggest a commit title. Ensure it follows the format:

```
<type>(<scope>): <description>
```

**Bad Examples:**
- ❌ `Update README.md`
- ❌ `Fixed bugs`
- ❌ `Changes`

**Good Examples:**
- ✅ `docs(readme): update installation instructions`
- ✅ `fix(auth): correct token validation`
- ✅ `feat(api): add user endpoints`

### 3. Review Commit Body

The commit body should include:

- Summary of changes made
- Reasoning behind the changes
- Any important implementation details
- References to related issues

**Template:**

```
Summary of the feature/fix implemented.

Key changes:
- Change 1
- Change 2
- Change 3

Fixes #issue-number
```

### 4. Perform Merge

Click "Squash and merge" and verify:
- ✅ Title follows conventional commits format
- ✅ Body is descriptive and complete
- ✅ Issue references are included

### 5. Post-Merge

- ✅ Delete the feature branch
- ✅ Verify merge appears correctly in git history
- ✅ Close related issues if not auto-closed

## 🎨 Commit Types

Use these commit types in your squash merge commits:

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(api): add user search endpoint` |
| `fix` | Bug fix | `fix(auth): correct token expiration` |
| `docs` | Documentation | `docs(api): update endpoint documentation` |
| `style` | Code style | `style(ui): format button components` |
| `refactor` | Code refactoring | `refactor(db): optimize query performance` |
| `perf` | Performance | `perf(api): cache frequent queries` |
| `test` | Tests | `test(auth): add login flow tests` |
| `chore` | Maintenance | `chore(deps): update dependencies` |
| `ci` | CI/CD | `ci(workflow): add security scan` |
| `revert` | Revert change | `revert: revert "feat(api): add endpoint"` |

## 🔄 Reverting Merges

To revert a squashed commit:

```bash
# Find the commit hash
git log --oneline

# Revert the commit
git revert <commit-hash>

# Push the revert
git push origin main
```

The revert commit should follow:

```
revert: <original-commit-title>

This reverts commit <commit-hash>.

Reason: [explanation]
```

## 📊 Benefits of Squash and Merge

### Clean History

```
# With Squash and Merge (Clean)
* feat(auth): add OAuth2 authentication
* fix(api): correct user validation
* docs(readme): update installation guide

# Without Squash (Messy)
* Merge pull request #123
* Fix typo
* Address review comments
* Add tests
* WIP: implement OAuth2
* Fix linting
* Merge pull request #122
* ...
```

### Easy Navigation

- Each entry in `git log` represents a complete feature or fix
- Easy to find when a specific change was introduced
- Simple to cherry-pick features to other branches

### Simple Reverting

- One commit = one revert
- No need to revert multiple related commits
- Clear revert history

## 🚫 When NOT to Squash

There are NO exceptions to using squash and merge in this repository. If you believe your use case requires an exception:

1. Create a discussion explaining the need
2. Get approval from repository maintainers
3. Document the exception if approved

## 🔧 Automation

### Branch Protection

The `main` branch has these settings:
- ✅ Require pull request before merging
- ✅ Require status checks to pass
- ✅ Require conversation resolution
- ✅ Require linear history (enforces squash/rebase)
- ❌ Allow merge commits (disabled)
- ❌ Allow rebase merging (disabled)

### GitHub Settings

Repository settings enforce:
- Only "Squash and merge" is enabled
- Default commit message uses PR title
- Default commit description uses PR body

## 📚 Resources

### Documentation

- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Squash Merging](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges#squash-and-merge-your-commits)
- [Git Linear History](https://git-scm.com/book/en/v2/Git-Branching-Rebasing)

### Tools

- [Commitlint](https://commitlint.js.org/) - Validates commit messages
- [Husky](https://typicode.github.io/husky/) - Git hooks for validation

## ✏️ FAQs

### Q: What if my PR has important individual commits?

A: Include a summary of key commits in the PR description. They'll be preserved in the squash commit body.

### Q: How do I credit multiple authors?

A: Add co-authors in the commit footer:
```
feat(api): add new endpoints

Co-authored-by: Name <email@example.com>
```

### Q: Can I keep my commit history for reference?

A: Yes! Your branch remains until deleted. You can keep it for reference or delete it after merge.

### Q: What if I accidentally use the wrong merge method?

A: Contact a repository maintainer immediately. The commit may need to be reverted and re-merged correctly.

## 📝 Version History

- **v1.0.0** (2026-01-02): Initial merge strategy policy

---

**Last Updated**: 2026-01-02  
**Owner**: @eyshoit-commits  
**Enforcement**: Automated via branch protection rules
