# Feature Gates

## Overview

Feature gates provide fine-grained control over which development tools and capabilities are installed during setup. This enables:

- **Minimal installations**: Install only what you need
- **Role-based setups**: Different configurations for different team members
- **Resource optimization**: Skip heavy toolchains on resource-constrained systems
- **Testing flexibility**: Enable/disable features for testing scenarios

## Configuration File

Feature gates are defined in `env.d/20-features.env`:

```bash
# Core Language Toolchains
FEATURE_RUST=${FEATURE_RUST:-true}
FEATURE_PYTHON=${FEATURE_PYTHON:-true}
FEATURE_NODE=${FEATURE_NODE:-true}

# Application Domains
FEATURE_FRONTEND=${FEATURE_FRONTEND:-true}
FEATURE_BACKEND=${FEATURE_BACKEND:-true}
FEATURE_AI=${FEATURE_AI:-false}
FEATURE_MOBILE=${FEATURE_MOBILE:-false}
FEATURE_DESKTOP=${FEATURE_DESKTOP:-false}

# Development Tools
FEATURE_DOCKER=${FEATURE_DOCKER:-false}
FEATURE_K8S=${FEATURE_K8S:-false}
```

## Available Gates

### Core Language Toolchains

#### `FEATURE_NODE`
- **Default**: `true`
- **Installs**: Node.js, npm, pnpm
- **Use case**: JavaScript/TypeScript development
- **Dependencies**: None

#### `FEATURE_PYTHON`
- **Default**: `true`
- **Installs**: Python, pip, uv, Miniconda
- **Use case**: Python development, data science, AI/ML
- **Dependencies**: None

#### `FEATURE_RUST`
- **Default**: `true`
- **Installs**: Rust compiler, Cargo, rustup
- **Use case**: Systems programming, CLI tools, WebAssembly
- **Dependencies**: None

### Application Domains

#### `FEATURE_FRONTEND`
- **Default**: `true`
- **Enables**: Frontend scaffolding tools, build tools
- **Requires**: `FEATURE_NODE=true`
- **Use case**: Web frontend development

#### `FEATURE_BACKEND`
- **Default**: `true`
- **Enables**: Backend frameworks, database tools
- **Requires**: `FEATURE_PYTHON=true` or `FEATURE_RUST=true`
- **Use case**: API development, server-side applications

#### `FEATURE_AI`
- **Default**: `false`
- **Installs**: OpenAI SDK, Anthropic SDK, LangChain
- **Requires**: `FEATURE_PYTHON=true`
- **Use case**: AI/ML development, LLM integration

#### `FEATURE_MOBILE`
- **Default**: `false`
- **Installs**: React Native, mobile development tools
- **Requires**: `FEATURE_NODE=true`
- **Use case**: iOS/Android app development

#### `FEATURE_DESKTOP`
- **Default**: `false`
- **Installs**: Electron, Tauri
- **Requires**: `FEATURE_NODE=true` or `FEATURE_RUST=true`
- **Use case**: Desktop application development

### Development Tools

#### `FEATURE_DOCKER`
- **Default**: `false`
- **Installs**: Docker CLI tools
- **Use case**: Container development, local services

#### `FEATURE_K8S`
- **Default**: `false`
- **Installs**: kubectl, helm
- **Use case**: Kubernetes development and deployment

## Usage

### Setting Feature Gates

#### Via Environment Variables

```bash
# Enable AI features
export FEATURE_AI=true

# Disable Rust
export FEATURE_RUST=false

# Run setup
./scripts/setup.sh
```

#### Via Configuration File

Edit `env.d/20-features.env`:

```bash
FEATURE_AI=${FEATURE_AI:-true}    # Changed from false to true
FEATURE_RUST=${FEATURE_RUST:-false}  # Changed from true to false
```

#### One-Time Override

```bash
# Install only Python, skip everything else
FEATURE_NODE=false FEATURE_RUST=false FEATURE_PYTHON=true ./scripts/setup.sh
```

### Common Scenarios

#### Frontend Developer Setup

```bash
export FEATURE_NODE=true
export FEATURE_FRONTEND=true
export FEATURE_PYTHON=false
export FEATURE_RUST=false
export FEATURE_BACKEND=false
```

#### Backend Developer Setup

```bash
export FEATURE_NODE=false
export FEATURE_FRONTEND=false
export FEATURE_PYTHON=true
export FEATURE_RUST=true
export FEATURE_BACKEND=true
```

#### AI/ML Developer Setup

```bash
export FEATURE_PYTHON=true
export FEATURE_AI=true
export FEATURE_NODE=false
export FEATURE_RUST=false
```

#### Full-Stack Developer Setup

```bash
export FEATURE_NODE=true
export FEATURE_PYTHON=true
export FEATURE_RUST=true
export FEATURE_FRONTEND=true
export FEATURE_BACKEND=true
```

#### Minimal CI Setup

```bash
# Only install what's absolutely needed for build
export FEATURE_NODE=true
export FEATURE_PYTHON=false
export FEATURE_RUST=false
export FEATURE_FRONTEND=true
export FEATURE_BACKEND=false
export FEATURE_AI=false
```

## Implementation Details

### How Feature Gates Work

When a feature gate is disabled, the setup script:

1. **Skips installation**: Tool is not downloaded or installed
2. **Logs status**: Marks as "skipped" in setup-report.json
3. **Updates handshake**: Marks role as not ready in agent-handshake.json
4. **Continues execution**: Doesn't fail, just skips

Example from `setup.sh`:

```bash
if [ "$FEATURE_NODE" = "true" ]; then
  echo "📦 Installing Node.js (FEATURE_NODE=true)"
  # ... install nvm/node
else
  echo "⏭️  Skipping Node.js (FEATURE_NODE=false)"
  log_status "node" "N/A" "N/A" "skipped"
fi
```

### Dependency Resolution

Some features depend on others. The setup script handles dependencies automatically:

```bash
if [ "$FEATURE_AI" = "true" ]; then
  if [ "$FEATURE_PYTHON" != "true" ]; then
    echo "⚠️  FEATURE_AI requires FEATURE_PYTHON"
    echo "   Enabling FEATURE_PYTHON automatically"
    export FEATURE_PYTHON=true
  fi
fi
```

## Verification

Check which features are enabled:

```bash
# View current feature gates
grep "^FEATURE_" env.d/20-features.env

# Check what was actually installed
jq '.tools[] | {name, status}' setup-report.json

# Verify role readiness
jq '.roles[] | {name, ready}' agent-handshake.json
```

## Best Practices

### 1. Start Minimal, Expand as Needed

Don't install everything upfront. Start with minimal features and enable more as your project evolves.

```bash
# Initial setup: just frontend
FEATURE_NODE=true FEATURE_FRONTEND=true ./scripts/setup.sh

# Later: add backend
FEATURE_PYTHON=true FEATURE_BACKEND=true ./scripts/setup.sh
```

### 2. Use Role-Based Profiles

Create preset profiles for common roles:

```bash
# profiles/frontend.env
FEATURE_NODE=true
FEATURE_FRONTEND=true
FEATURE_PYTHON=false
FEATURE_RUST=false

# profiles/backend.env
FEATURE_PYTHON=true
FEATURE_RUST=true
FEATURE_BACKEND=true
FEATURE_NODE=false
```

Load with:

```bash
source profiles/frontend.env
./scripts/setup.sh
```

### 3. Document Team Standards

Create a `SETUP.md` in your project:

```markdown
# Team Setup Guide

## Frontend Developers
```bash
export FEATURE_NODE=true
export FEATURE_FRONTEND=true
./scripts/setup.sh
```

## Backend Developers
```bash
export FEATURE_PYTHON=true
export FEATURE_BACKEND=true
./scripts/setup.sh
```
```

### 4. CI/CD Optimization

Use feature gates to minimize CI installation time:

```yaml
# .github/workflows/frontend.yml
env:
  FEATURE_NODE: true
  FEATURE_FRONTEND: true
  FEATURE_PYTHON: false
  FEATURE_RUST: false
```

### 5. Matrix Testing

Test different feature combinations:

```yaml
# .github/workflows/test-setups.yml
strategy:
  matrix:
    profile:
      - {node: true, python: false, rust: false}
      - {node: false, python: true, rust: false}
      - {node: true, python: true, rust: true}
```

## Troubleshooting

### Feature Not Installing

**Problem**: Feature gate is `true` but tool not installed

**Solutions**:
1. Check for errors in setup output
2. Verify dependencies are enabled
3. Check `setup-report.json` for failure details

```bash
jq '.tools[] | select(.status=="failed")' setup-report.json
```

### Dependency Conflicts

**Problem**: AI features need Python but Python is disabled

**Solution**: Setup script auto-enables dependencies, but you can manually ensure:

```bash
# Ensure both are enabled
export FEATURE_PYTHON=true
export FEATURE_AI=true
./scripts/setup.sh
```

### Agent Handshake Shows Not Ready

**Problem**: Role marked as not ready in agent-handshake.json

**Check**:
```bash
jq '.roles[] | select(.ready==false)' agent-handshake.json
```

**Fix**: Enable required features and re-run setup

## Future Enhancements

- **Auto-dependency resolution**: Automatically enable required dependencies
- **Conflict detection**: Warn about incompatible feature combinations
- **Feature recommendations**: Suggest features based on project type
- **Dynamic re-configuration**: Enable/disable features without full re-install
- **Feature usage tracking**: Track which features are actually being used
