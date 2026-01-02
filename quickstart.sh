#!/bin/bash
# Quick Start Guide for Enterprise Setup

set -e

cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║  🚀 Enterprise-Grade Development Environment Setup          ║
║                                                              ║
║  Welcome! This script will guide you through the setup.     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF

echo "What would you like to do?"
echo ""
echo "1) ✅ Validate environment (recommended first step)"
echo "2) 🚀 Run full setup"
echo "3) 🧪 Run smoke tests (after setup)"
echo "4) 📊 View setup report"
echo "5) 🔒 Run security scan"
echo "6) 📚 View documentation"
echo "7) ❌ Exit"
echo ""
read -p "Choose an option [1-7]: " choice

case $choice in
  1)
    echo ""
    echo "Running validation..."
    bash scripts/validate.sh
    ;;
  2)
    echo ""
    echo "Starting setup..."
    echo ""
    read -p "Use latest versions instead of locked versions? [y/N]: " latest
    if [[ $latest =~ ^[Yy]$ ]]; then
      export SETUP_ALLOW_LATEST=true
      echo "✅ Using latest versions"
    else
      echo "✅ Using locked versions from config/versions.env"
    fi
    echo ""
    bash scripts/setup.sh
    ;;
  3)
    echo ""
    echo "Running smoke tests..."
    bash scripts/smoke-test.sh
    ;;
  4)
    echo ""
    if [ -f "setup-report.json" ]; then
      echo "📊 Setup Report:"
      echo ""
      if command -v jq &>/dev/null; then
        cat setup-report.json | jq .
      else
        cat setup-report.json
      fi
    else
      echo "❌ No setup report found. Run setup first."
    fi
    ;;
  5)
    echo ""
    if command -v gitleaks &>/dev/null; then
      echo "Running gitleaks security scan..."
      gitleaks detect --verbose
    else
      echo "⚠️  Gitleaks not installed. Install with:"
      echo "   brew install gitleaks  # macOS"
      echo "   apt install gitleaks   # Linux"
    fi
    ;;
  6)
    echo ""
    echo "📚 Available Documentation:"
    echo ""
    echo "  • README.md - Main documentation"
    echo "  • docs/INSTALLATION.md - Complete installation guide"
    echo "  • docs/SECURITY.md - Security features and policies"
    echo "  • docs/TROUBLESHOOTING.md - Common issues and solutions"
    echo "  • .github/copilot-instructions.md - Development guidelines"
    echo ""
    read -p "Open a document? [README/INSTALLATION/SECURITY/TROUBLESHOOTING/N]: " doc
    case ${doc^^} in
      README)
        ${PAGER:-less} README.md
        ;;
      INSTALLATION)
        ${PAGER:-less} docs/INSTALLATION.md
        ;;
      SECURITY)
        ${PAGER:-less} docs/SECURITY.md
        ;;
      TROUBLESHOOTING)
        ${PAGER:-less} docs/TROUBLESHOOTING.md
        ;;
      *)
        echo "Cancelled."
        ;;
    esac
    ;;
  7)
    echo "Goodbye! 👋"
    exit 0
    ;;
  *)
    echo "Invalid option. Please run again and choose 1-7."
    exit 1
    ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Need more help?"
echo "  • Run this script again: bash quickstart.sh"
echo "  • Read docs: less docs/INSTALLATION.md"
echo "  • Check issues: https://github.com/eyshoit-commits/setup/issues"
echo ""
