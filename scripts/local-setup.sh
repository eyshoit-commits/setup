#!/bin/bash
# Local Development Environment Setup
# Sets up git hooks and local development tools

set -e

echo "=================================="
echo "🚀 Local Development Setup"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo -e "${BLUE}Repository root: $REPO_ROOT${NC}"
echo ""

# Install Git Hooks
echo "📌 Installing Git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Install pre-commit hook
if [ -f ".github/hooks/pre-commit" ]; then
    cp .github/hooks/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo -e "${GREEN}✅ Installed pre-commit hook${NC}"
else
    echo -e "${YELLOW}⚠️  Pre-commit hook template not found${NC}"
fi

# Install commit-msg hook
if [ -f ".github/hooks/commit-msg" ]; then
    cp .github/hooks/commit-msg .git/hooks/commit-msg
    chmod +x .git/hooks/commit-msg
    echo -e "${GREEN}✅ Installed commit-msg hook${NC}"
else
    echo -e "${YELLOW}⚠️  Commit-msg hook template not found${NC}"
fi

echo ""

# Install Node.js dependencies if package.json exists
if [ -f "package.json" ]; then
    echo "📦 Installing Node.js dependencies..."
    if command -v npm &> /dev/null; then
        npm install
        echo -e "${GREEN}✅ Node.js dependencies installed${NC}"
    else
        echo -e "${YELLOW}⚠️  npm not found, skipping Node.js dependencies${NC}"
    fi
    echo ""
fi

# Install Python dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "🐍 Installing Python dependencies..."
    if command -v pip3 &> /dev/null; then
        pip3 install -r requirements.txt
        echo -e "${GREEN}✅ Python dependencies installed${NC}"
    else
        echo -e "${YELLOW}⚠️  pip3 not found, skipping Python dependencies${NC}"
    fi
    echo ""
fi

# Configure Git settings
echo "⚙️  Configuring Git settings..."

# Set up conventional commits
git config --local commit.template .github/COMMIT_TEMPLATE 2>/dev/null || echo "No commit template found"

echo -e "${GREEN}✅ Git configured${NC}"
echo ""

# Create local environment file if template exists
if [ -f ".github/secrets-template.env" ]; then
    if [ ! -f ".env" ]; then
        echo "📝 Creating local .env file..."
        cp .github/secrets-template.env .env
        echo -e "${GREEN}✅ Created .env file${NC}"
        echo -e "${YELLOW}⚠️  Please fill in your local secrets in .env${NC}"
    else
        echo -e "${BLUE}ℹ️  .env file already exists${NC}"
    fi
    echo ""
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/*.sh 2>/dev/null || true
echo -e "${GREEN}✅ Scripts are now executable${NC}"
echo ""

# Validation
echo "🔍 Running environment validation..."
if [ -f "scripts/validate-environment.sh" ]; then
    ./scripts/validate-environment.sh
else
    echo -e "${YELLOW}⚠️  Validation script not found${NC}"
fi

echo ""
echo "=================================="
echo "✅ Local setup complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo "  1. Review and configure .env file with your secrets"
echo "  2. Install recommended VS Code extensions"
echo "  3. Review docs/SETUP_GUIDE.md for more information"
echo ""
echo "Git hooks installed:"
echo "  - pre-commit: Validates commits before committing"
echo "  - commit-msg: Ensures conventional commit format"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
