# Contributing to Enterprise-Grade Development Setup

Thank you for your interest in contributing! This project aims to provide a robust, secure, and agent-ready development environment setup system.

## 🎯 Project Goals

1. **Enterprise-Grade**: Production-ready, secure, and reliable
2. **Supply Chain Aware**: Track all installers and dependencies
3. **Agent-Ready**: Enable AI agents and automation to understand environment
4. **Cross-Platform**: Support Linux, macOS, and Windows
5. **Reproducible**: Deterministic builds in CI/CD environments

## 🚀 Getting Started

### Prerequisites

- Bash 4.0+ or PowerShell 5.1+
- Git
- Python 3.8+ (for pre-commit hooks)

### Setup for Development

```bash
# Clone the repository
git clone https://github.com/eyshoit-commits/setup.git
cd setup

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Test the setup script
./scripts/setup.sh

# Validate
./scripts/validate.sh
```

## 📋 Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

Follow these guidelines:

- **Minimal Changes**: Make the smallest change possible to achieve your goal
- **Cross-Platform**: Implement features in both Bash and PowerShell
- **Documentation**: Update docs for any feature changes
- **Tests**: Ensure scripts work with different feature gate combinations

### 3. Test Your Changes

```bash
# Test basic setup
./scripts/setup.sh

# Test with different feature gates
FEATURE_NODE=true FEATURE_PYTHON=false ./scripts/setup.sh

# Test validation
./scripts/validate.sh

# Test badge generation
./scripts/generate-badges.sh

# Run pre-commit checks
pre-commit run --all-files
```

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: add your feature description"
```

Commit message format:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test additions or changes
- `chore:` - Build process or auxiliary tool changes

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## 🧪 Testing

### Manual Testing

Test different scenarios:

```bash
# Minimal install
FEATURE_NODE=false FEATURE_PYTHON=false FEATURE_RUST=false ./scripts/setup.sh

# Full install
FEATURE_NODE=true FEATURE_PYTHON=true FEATURE_RUST=true FEATURE_AI=true ./scripts/setup.sh

# Repro mode
SETUP_MODE=repro ./scripts/setup.sh

# Validation after setup
./scripts/validate.sh
```

### Verify Generated Files

After setup, check:

```bash
# Provenance tracking
cat provenance.json | jq .

# Agent handshake
cat agent-handshake.json | jq .

# Setup report
cat setup-report.json | jq .

# Badge generation
./scripts/generate-badges.sh
cat README-badges.md
```

### Cross-Platform Testing

If possible, test on:
- Linux (Ubuntu, Debian, Fedora)
- macOS
- Windows (PowerShell)

## 📝 Code Style

### Bash Scripts

- Use `set -e` for error handling
- Quote all variables: `"$VARIABLE"`
- Use functions for reusable code
- Add comments for complex logic
- Use color output for better UX:
  ```bash
  echo -e "${GREEN}✅ Success${NC}"
  echo -e "${RED}❌ Error${NC}"
  ```

### PowerShell Scripts

- Use approved verbs (Get-, Set-, New-, etc.)
- Set `$ErrorActionPreference = "Stop"`
- Add comment-based help
- Use consistent formatting
- Handle errors gracefully

### Documentation

- Use clear, concise language
- Include code examples
- Explain the "why" not just the "what"
- Keep docs up-to-date with code changes

## 🔒 Security Considerations

### Golden Path Enforcement

- Pre-commit hooks are **mandatory** by default
- Only bypass with explicit `FORCE_UNSAFE=true`
- Document any security implications

### Supply Chain Security

- Always track installers in provenance.json
- Compute SHA-256 hashes for all downloads
- Prefer official sources for installers
- Document trust levels

### Secret Handling

- **Never** commit secrets or credentials
- Use environment variables for sensitive data
- Add sensitive patterns to `.gitignore`

## 📚 Documentation Requirements

When adding features, update:

1. **README.md** - Add to features list if user-facing
2. **Relevant docs/** file - Detailed documentation
3. **Code comments** - Explain complex logic
4. **Examples** - Show how to use the feature

## 🎨 Feature Gates

When adding new feature gates:

1. Add to `env.d/20-features.env`:
   ```bash
   FEATURE_YOUR_FEATURE=${FEATURE_YOUR_FEATURE:-false}
   export FEATURE_YOUR_FEATURE
   ```

2. Implement in `scripts/setup.sh`:
   ```bash
   if [ "$FEATURE_YOUR_FEATURE" = "true" ]; then
     echo "📦 Installing your feature..."
     # installation logic
   else
     echo "⏭️  Skipping your feature (FEATURE_YOUR_FEATURE=false)"
     log_status "your-feature" "N/A" "N/A" "skipped"
   fi
   ```

3. Update `docs/FEATURE-GATES.md` with usage instructions

4. Add to agent-handshake.json if relevant for agents

## 🔄 Version Updates

When updating tool versions:

1. Edit `config/versions.env`:
   ```bash
   NODE_VERSION=20.12.0  # Updated from 20.11.0
   ```

2. Test the new version thoroughly

3. Update documentation if there are breaking changes

4. Consider backward compatibility

## 🐛 Bug Reports

When filing bug reports, include:

- **Description**: Clear description of the issue
- **Steps to Reproduce**: Exact commands that trigger the bug
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**: OS, shell, versions
- **Logs**: Relevant error messages or logs

## 💡 Feature Requests

For feature requests, describe:

- **Use Case**: Why is this feature needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: Other approaches considered?
- **Additional Context**: Mockups, examples, etc.

## 🏗️ Architecture Decisions

### Core Principles

1. **Idempotent**: Running setup multiple times should be safe
2. **Fail-Fast**: Errors should stop execution in repro mode
3. **Transparent**: All actions should be logged and tracked
4. **Flexible**: Feature gates enable customization
5. **Agent-Ready**: Generate machine-readable artifacts

### File Organization

```
scripts/     - Executable scripts
config/      - Version and configuration files
env.d/       - Environment file fragments (sourced in order)
docs/        - Detailed documentation
.github/     - CI/CD workflows
```

### Key Concepts

- **Setup Mode**: `dev` (flexible) vs `repro` (strict)
- **Feature Gates**: Granular control over installations
- **Provenance**: Supply chain tracking with hashes
- **Agent Handshake**: Machine-readable capabilities
- **Drift Detection**: Version validation

## 📞 Getting Help

- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check the `docs/` directory

## 🎉 Recognition

Contributors will be recognized in:
- Project README acknowledgments
- Release notes
- Git commit history

Thank you for contributing! 🚀
