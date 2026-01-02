# 🚀 Enterprise-Grade Development Setup

<!-- Auto-generated badges - run ./scripts/generate-badges.sh to update -->
![Status](https://img.shields.io/badge/setup-ready-brightgreen)
![Enterprise](https://img.shields.io/badge/grade-enterprise-blue)
![Supply Chain](https://img.shields.io/badge/supply_chain-tracked-green)
![Agent Ready](https://img.shields.io/badge/agent-ready-purple)

**Blueprint for agentische Softwareentwicklung:**
- ✅ Menschen klicken
- ✅ Maschinen verstehen
- ✅ CI vertraut
- ✅ Security nickt
- ✅ Agents dispatchen Tasks sofort
- ✅ Zero surprises in production

## 🌟 Features

### 1️⃣ Supply Chain Awareness
Track every installer with cryptographic hashes for full transparency and security.

- **Provenance Tracking**: Complete audit trail of all installers
- **SHA-256 Verification**: Cryptographic integrity checking
- **Trust Levels**: Automated assessment of installation security
- **Artifact Caching**: Support for offline/cached installers

📖 [Supply Chain Documentation](docs/SUPPLY-CHAIN.md)

### 2️⃣ Reproducible Builds (Repro Mode)
Deterministic setups for CI/CD and team consistency.

- **Auto-Detection**: CI/Codespace environments automatically use repro mode
- **Strict Versioning**: Exact version matching enforced
- **Offline Support**: Prefer local artifacts over network downloads
- **Drift Detection**: Validate installed versions match expectations

### 3️⃣ Agent Handshake Protocol
Machine-readable environment description for AI agents and automation.

- **Capability Discovery**: What tools and versions are available
- **Role-Based Routing**: Match tasks to appropriate agents
- **Readiness Status**: Know immediately what can be built/tested/deployed
- **Recommended Tasks**: Suggested next steps based on available tools

📖 [Agent Handshake Documentation](docs/AGENT-HANDSHAKE.md)

### 4️⃣ Feature Gates
Fine-grained control over what gets installed.

- **Granular Control**: Enable/disable specific toolchains
- **Role-Based Profiles**: Frontend, backend, AI, DevOps configurations
- **Resource Optimization**: Install only what you need
- **Conditional Installation**: Smart dependency resolution

📖 [Feature Gates Documentation](docs/FEATURE-GATES.md)

### 5️⃣ Drift Detection
Validate environment consistency over time.

- **Version Validation**: Ensure installed versions match configuration
- **Mode-Aware**: Warnings in dev mode, failures in repro mode
- **Comprehensive Checks**: Validates all enabled features
- **Detailed Reporting**: Clear output on any version mismatches

### 6️⃣ Self-Describing Repository
Auto-generated badges and documentation.

- **Badge Generation**: Automatic README badges from setup reports
- **Status Tracking**: Visual indicators of setup health
- **Version Display**: Current tool versions shown in badges
- **CI Integration**: Badges update automatically

### 7️⃣ Golden Path Enforcement
Mandatory security gates with pre-commit hooks.

- **Automatic Installation**: pre-commit hooks installed by default
- **Security First**: Cannot be bypassed without explicit override
- **CI Validation**: GitHub Actions enforce pre-commit checks
- **Quality Gates**: Prevent common issues before commit

## 🚀 Quick Start

### Basic Setup

```bash
# Clone the repository
git clone https://github.com/eyshoit-commits/setup.git
cd setup

# Run setup with default features
./scripts/setup.sh

# Verify installation
./scripts/validate.sh

# Generate README badges
./scripts/generate-badges.sh
```

### Custom Setup with Feature Gates

```bash
# Frontend developer setup
FEATURE_NODE=true FEATURE_FRONTEND=true \
FEATURE_PYTHON=false FEATURE_RUST=false \
./scripts/setup.sh

# Backend developer setup
FEATURE_PYTHON=true FEATURE_RUST=true FEATURE_BACKEND=true \
FEATURE_NODE=false FEATURE_FRONTEND=false \
./scripts/setup.sh

# AI/ML developer setup
FEATURE_PYTHON=true FEATURE_AI=true \
./scripts/setup.sh
```

### Windows Setup

```powershell
# PowerShell
.\scripts\setup.ps1

# Validate
.\scripts\validate.ps1

# Generate badges
.\scripts\generate-badges.ps1
```

## 📁 Repository Structure

```
setup/
├── scripts/
│   ├── setup.sh              # Main setup script (Bash)
│   ├── setup.ps1             # Main setup script (PowerShell)
│   ├── validate.sh           # Drift detection (Bash)
│   ├── validate.ps1          # Drift detection (PowerShell)
│   ├── generate-badges.sh    # Badge generator (Bash)
│   └── generate-badges.ps1   # Badge generator (PowerShell)
├── config/
│   └── versions.env          # Tool version configuration
├── env.d/
│   ├── 10-tools.env         # Auto-generated tool paths
│   └── 20-features.env       # Feature gate configuration
├── docs/
│   ├── SUPPLY-CHAIN.md       # Supply chain documentation
│   ├── AGENT-HANDSHAKE.md    # Agent protocol documentation
│   └── FEATURE-GATES.md      # Feature gates documentation
├── .github/workflows/
│   └── enforce-pre-commit.yml # Pre-commit enforcement
├── provenance.json           # Generated: Supply chain tracking
├── agent-handshake.json      # Generated: Agent orchestration
├── setup-report.json         # Generated: Installation summary
└── README-badges.md          # Generated: Badge markdown
```

## 🔧 Configuration

### Version Configuration (`config/versions.env`)

```bash
# Tool versions
NODE_VERSION=20.11.0
PYTHON_VERSION=3.12.1
RUST_VERSION=1.75.0

# Setup mode
SETUP_MODE=dev  # or 'repro' for CI/CD
```

### Feature Gates (`env.d/20-features.env`)

```bash
# Core toolchains
FEATURE_NODE=true
FEATURE_PYTHON=true
FEATURE_RUST=true

# Application domains
FEATURE_FRONTEND=true
FEATURE_BACKEND=true
FEATURE_AI=false
```

## 📊 Generated Artifacts

### Provenance (`provenance.json`)
Complete supply chain tracking with installer hashes.

```json
{
  "setup_id": "20260102-120000-a1b2c3",
  "installers": [...],
  "integrity": {
    "all_verified": true,
    "trust_level": "high"
  }
}
```

### Agent Handshake (`agent-handshake.json`)
Environment capabilities for AI agents.

```json
{
  "protocol_version": "1.0",
  "setup_status": "success",
  "toolchains": [...],
  "capabilities": {
    "can_build_backend": true,
    "can_build_frontend": true
  }
}
```

### Setup Report (`setup-report.json`)
Installation summary and statistics.

```json
{
  "tools": [...],
  "summary": {
    "total": 3,
    "installed": 3,
    "failed": 0
  }
}
```

## 🧪 Validation & Testing

### Drift Detection

```bash
# Run validation
./scripts/validate.sh

# In dev mode: warnings only
# In repro mode: fails on any drift
```

### Smoke Tests

Built into setup script - automatically verifies each installed tool.

### CI Integration

```yaml
# .github/workflows/setup.yml
- name: Run setup
  run: ./scripts/setup.sh
  env:
    SETUP_MODE: repro
    FEATURE_NODE: true

- name: Validate
  run: ./scripts/validate.sh
```

## 🔒 Security

### Golden Path Enforcement

Pre-commit hooks are **mandatory** by default:

```bash
# Bypass only if absolutely necessary
FORCE_UNSAFE=true ./scripts/setup.sh
```

### Supply Chain Security

- All installers tracked with SHA-256 hashes
- Provenance file provides audit trail
- Prefer offline artifacts in repro mode
- Trust level automatically assessed

### CI Pre-Commit Enforcement

GitHub Actions automatically enforce pre-commit checks on all PRs.

## 🤖 Agent Integration

### Reading Capabilities

```python
import json

with open('agent-handshake.json') as f:
    handshake = json.load(f)

if handshake['capabilities']['can_build_backend']:
    # Execute backend tasks
    ...
```

### Role-Based Routing

```bash
# Get appropriate agent for a role
AGENT=$(jq -r '.roles[] | select(.name=="backend") | .agent' agent-handshake.json)
echo "Routing to: $AGENT"
```

## 📚 Documentation

- [Supply Chain Security](docs/SUPPLY-CHAIN.md) - Provenance tracking and integrity
- [Agent Handshake Protocol](docs/AGENT-HANDSHAKE.md) - Agent integration guide
- [Feature Gates](docs/FEATURE-GATES.md) - Configuration and usage

## 🛠️ Troubleshooting

### Setup fails with version mismatch

**Problem**: Installed version doesn't match configuration

**Solution**: Check if running in repro mode unintentionally
```bash
echo $SETUP_MODE  # Should be 'dev' for flexible versioning
```

### Tool not installed despite feature enabled

**Problem**: Feature gate is true but tool missing

**Solution**: Check setup-report.json for errors
```bash
jq '.tools[] | select(.status=="failed")' setup-report.json
```

### Pre-commit blocking commits

**Problem**: Commits failing due to pre-commit checks

**Solution**: Run pre-commit manually to fix issues
```bash
pre-commit run --all-files
```

## 🎯 Success Criteria

- ✅ **provenance.json** with hashes of all installers
- ✅ **SETUP_MODE=repro** for CI/Codespaces
- ✅ **agent-handshake.json** after setup
- ✅ **Feature Gates** in `env.d/20-features.env`
- ✅ **Drift Detection** in validate
- ✅ **README Badge Generator** automatic
- ✅ **pre-commit MANDATORY** (Golden Path)
- ✅ All features in Bash + PowerShell
- ✅ CI Workflows updated
- ✅ Complete documentation

## 🤝 Contributing

1. Fork the repository
2. Enable pre-commit hooks: `pre-commit install`
3. Make your changes
4. Validate: `./scripts/validate.sh`
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

Built for enterprise-grade agentische Softwareentwicklung. Designed to bridge human intuition and machine precision in modern development workflows.

---

**Generated with ❤️ for humans and agents alike**
