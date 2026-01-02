# Setup Profiles

Pre-configured feature gate profiles for common development roles.

## Usage

```bash
# Load a profile
source profiles/frontend.env

# Run setup
./scripts/setup.sh
```

## Available Profiles

### `frontend.env` - Frontend Developer
- ✅ Node.js
- ✅ Frontend tools
- ❌ Python
- ❌ Rust

**Use case**: Web frontend development with React, Vue, Angular, etc.

### `backend.env` - Backend Developer
- ✅ Python
- ✅ Rust
- ✅ Backend tools
- ❌ Node.js

**Use case**: API development, server-side applications

### `fullstack.env` - Full-Stack Developer
- ✅ Node.js
- ✅ Python
- ✅ Rust
- ✅ Frontend tools
- ✅ Backend tools

**Use case**: Complete full-stack development environment

### `ai-ml.env` - AI/ML Developer
- ✅ Python
- ✅ AI libraries (OpenAI, Anthropic, LangChain)
- ✅ Backend tools
- ❌ Node.js
- ❌ Rust

**Use case**: Machine learning, data science, AI applications

### `minimal.env` - Minimal (CI/CD)
- ❌ All features disabled
- ✅ Repro mode enabled
- ✅ Strict version checking

**Use case**: CI/CD pipelines, minimal footprint

## Creating Custom Profiles

Create your own profile:

```bash
# Create a new profile
cat > profiles/custom.env <<'EOF'
# Custom Profile
export FEATURE_NODE=true
export FEATURE_PYTHON=true
export FEATURE_RUST=false
export FEATURE_AI=true

echo "✅ Custom profile loaded"
EOF

# Use it
source profiles/custom.env
./scripts/setup.sh
```

## One-Line Usage

```bash
# Frontend
source profiles/frontend.env && ./scripts/setup.sh

# Backend
source profiles/backend.env && ./scripts/setup.sh

# Full-Stack
source profiles/fullstack.env && ./scripts/setup.sh

# AI/ML
source profiles/ai-ml.env && ./scripts/setup.sh

# Minimal
source profiles/minimal.env && ./scripts/setup.sh
```

## Profile Comparison

| Feature | Frontend | Backend | Full-Stack | AI/ML | Minimal |
|---------|----------|---------|------------|-------|---------|
| Node.js | ✅ | ❌ | ✅ | ❌ | ❌ |
| Python | ❌ | ✅ | ✅ | ✅ | ❌ |
| Rust | ❌ | ✅ | ✅ | ❌ | ❌ |
| Frontend Tools | ✅ | ❌ | ✅ | ❌ | ❌ |
| Backend Tools | ❌ | ✅ | ✅ | ✅ | ❌ |
| AI Libraries | ❌ | ❌ | ❌ | ✅ | ❌ |
| Repro Mode | ❌ | ❌ | ❌ | ❌ | ✅ |
