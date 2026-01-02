#!/bin/bash
# Environment Validation Script
# Validates development environment and dependencies

set -e

echo "=================================="
echo "🔍 Environment Validation"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

# Check Git
echo "Checking Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✅ $GIT_VERSION${NC}"
else
    echo -e "${RED}❌ Git not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check GitHub CLI
echo "Checking GitHub CLI..."
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -n 1)
    echo -e "${GREEN}✅ $GH_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  GitHub CLI not found (optional but recommended)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check Node.js
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js $NODE_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  Node.js not found (required for some features)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check npm
echo "Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✅ npm $NPM_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  npm not found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check Python
echo "Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✅ $PYTHON_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  Python not found (optional)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check Docker
echo "Checking Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✅ $DOCKER_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  Docker not found (optional)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check jq
echo "Checking jq..."
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    echo -e "${GREEN}✅ $JQ_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  jq not found (recommended for JSON processing)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check repository structure
echo ""
echo "Checking repository structure..."
REQUIRED_DIRS=(
    ".github/workflows"
    "scripts"
    "docs"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ Directory found: $dir${NC}"
    else
        echo -e "${RED}❌ Directory missing: $dir${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check critical files
echo ""
echo "Checking critical files..."
REQUIRED_FILES=(
    "README.md"
    ".github/workflows/setup-validation.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ File found: $file${NC}"
    else
        echo -e "${RED}❌ File missing: $file${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

# Summary
echo ""
echo "=================================="
echo "📊 Validation Summary"
echo "=================================="
echo -e "Errors:   ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Environment validation passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Environment validation failed!${NC}"
    echo "Please fix the errors above before proceeding."
    exit 1
fi
