#!/bin/bash

################################################################################
# Enterprise Repository Setup Script
# 
# This script automates the complete setup of the repository including:
# - Prerequisites validation
# - Agent installation
# - Configuration setup
# - Validation checks
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="$REPO_ROOT/setup.log"

################################################################################
# Utility Functions
################################################################################

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        log "✓ $1 is installed"
        return 0
    else
        error "✗ $1 is not installed"
        return 1
    fi
}

################################################################################
# Prerequisites Check
################################################################################

check_prerequisites() {
    log "Checking prerequisites..."
    
    local all_good=true
    
    # Check required commands
    if ! check_command git; then all_good=false; fi
    if ! check_command jq; then all_good=false; fi
    
    # Check optional but recommended commands
    if ! check_command gh; then
        warning "GitHub CLI (gh) not found - some features may be limited"
    fi
    
    if ! check_command node; then
        warning "Node.js not found - JavaScript/TypeScript features may be limited"
    fi
    
    if ! check_command python3; then
        warning "Python 3 not found - Python features may be limited"
    fi
    
    if [ "$all_good" = false ]; then
        error "Missing required prerequisites"
        exit 1
    fi
    
    log "All required prerequisites satisfied"
}

################################################################################
# Directory Structure Validation
################################################################################

validate_structure() {
    log "Validating repository structure..."
    
    local required_dirs=(
        ".opencode"
        ".opencode/agents"
        ".github/workflows"
        ".github/ISSUE_TEMPLATE"
        ".github/agents"
        ".vscode"
        ".vscode/agents"
        "scripts"
        "config"
        "docs"
    )
    
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$REPO_ROOT/$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -ne 0 ]; then
        error "Missing required directories:"
        printf '  - %s\n' "${missing_dirs[@]}"
        exit 1
    fi
    
    log "Directory structure validated"
}

################################################################################
# Configuration Files Validation
################################################################################

validate_configs() {
    log "Validating configuration files..."
    
    local config_files=(
        ".opencode/config.json"
        "config/agents.config.json"
        "config/security.config.json"
        "config/environments.config.json"
    )
    
    for config in "${config_files[@]}"; do
        if [ -f "$REPO_ROOT/$config" ]; then
            if jq empty "$REPO_ROOT/$config" 2>/dev/null; then
                log "✓ $config is valid"
            else
                error "✗ $config has invalid JSON"
                exit 1
            fi
        else
            warning "$config not found"
        fi
    done
    
    log "Configuration files validated"
}

################################################################################
# Agent Installation
################################################################################

install_agents() {
    log "Installing agents..."
    
    if [ -f "$SCRIPT_DIR/install-agents.sh" ]; then
        bash "$SCRIPT_DIR/install-agents.sh"
    else
        warning "install-agents.sh not found, skipping agent installation"
    fi
    
    log "Agent installation completed"
}

################################################################################
# Git Configuration
################################################################################

configure_git() {
    log "Configuring Git settings..."
    
    cd "$REPO_ROOT"
    
    # Set up git hooks path (if needed)
    if [ -d ".git/hooks" ]; then
        log "Git hooks directory exists"
    fi
    
    # Configure line endings
    git config core.autocrlf input
    git config core.eol lf
    
    log "Git configuration completed"
}

################################################################################
# Environment Setup
################################################################################

setup_environment() {
    log "Setting up environment..."
    
    # Create .env template if it doesn't exist
    if [ ! -f "$REPO_ROOT/.env.example" ]; then
        cat > "$REPO_ROOT/.env.example" << 'EOF'
# Environment Variables Template
# Copy this file to .env and fill in your values

# GitHub Configuration
GITHUB_TOKEN=your_github_token_here
GITHUB_OWNER=eyshoit-commits
GITHUB_REPO=setup

# Agent Configuration
OPENCODE_ENABLED=true
AGENT_AUTO_LOAD=true

# Security
SECRET_SCANNING_ENABLED=true
VULNERABILITY_SCANNING_ENABLED=true

# CI/CD
CI_ENVIRONMENT=development
EOF
        log "Created .env.example template"
    fi
    
    log "Environment setup completed"
}

################################################################################
# Final Validation
################################################################################

run_validation() {
    log "Running final validation..."
    
    if [ -f "$SCRIPT_DIR/validate-setup.sh" ]; then
        bash "$SCRIPT_DIR/validate-setup.sh"
    else
        warning "validate-setup.sh not found, skipping validation"
    fi
    
    log "Validation completed"
}

################################################################################
# Generate Setup Report
################################################################################

generate_report() {
    log "Generating setup report..."
    
    local report_file="$REPO_ROOT/setup-report.txt"
    
    cat > "$report_file" << EOF
================================================================================
Enterprise Repository Setup Report
================================================================================

Date: $(date)
Repository: $REPO_ROOT

DIRECTORY STRUCTURE
-------------------
$(find "$REPO_ROOT" -maxdepth 2 -type d -name ".*" -o -maxdepth 1 -type d ! -name ".*" | sort)

CONFIGURATION FILES
-------------------
OpenCode Config: $([ -f "$REPO_ROOT/.opencode/config.json" ] && echo "✓" || echo "✗")
Security Config: $([ -f "$REPO_ROOT/config/security.config.json" ] && echo "✓" || echo "✗")
Agents Config:   $([ -f "$REPO_ROOT/config/agents.config.json" ] && echo "✓" || echo "✗")
Environment Config: $([ -f "$REPO_ROOT/config/environments.config.json" ] && echo "✓" || echo "✗")

AGENT COUNTS
------------
OpenCode Agents: $(find "$REPO_ROOT/.opencode/agents" -name "*.json" 2>/dev/null | wc -l)
GitHub Agents:   $(find "$REPO_ROOT/.github/agents" -name "*.json" 2>/dev/null | wc -l)
VSCode Agents:   $(find "$REPO_ROOT/.vscode/agents" -name "*.json" 2>/dev/null | wc -l)

WORKFLOWS
---------
$(find "$REPO_ROOT/.github/workflows" -name "*.yml" 2>/dev/null | wc -l) GitHub Actions workflows configured

SETUP STATUS
------------
✓ Repository structure validated
✓ Configuration files validated
✓ Git configured
✓ Environment setup completed

================================================================================
Setup completed successfully!
================================================================================
EOF
    
    cat "$report_file"
    log "Report saved to: $report_file"
}

################################################################################
# Main Execution
################################################################################

main() {
    log "=========================================="
    log "Enterprise Repository Setup"
    log "=========================================="
    
    check_prerequisites
    validate_structure
    validate_configs
    configure_git
    setup_environment
    install_agents
    run_validation
    generate_report
    
    log "=========================================="
    log "Setup completed successfully!"
    log "=========================================="
    log "Log file: $LOG_FILE"
}

# Run main function
main "$@"
