#!/bin/bash

################################################################################
# Setup Validation Script
#
# Validates the complete repository setup
################################################################################

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ERRORS=0
WARNINGS=0

log() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    ((WARNINGS++))
}

error() {
    echo -e "${RED}[✗]${NC} $1"
    ((ERRORS++))
}

info() {
    echo -e "${BLUE}[i]${NC} $1"
}

################################################################################
# Validation Functions
################################################################################

validate_directories() {
    info "Validating directory structure..."
    
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
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$REPO_ROOT/$dir" ]; then
            log "Directory exists: $dir"
        else
            error "Missing directory: $dir"
        fi
    done
}

validate_config_files() {
    info "Validating configuration files..."
    
    local config_files=(
        ".opencode/config.json"
        ".opencode/README.md"
        ".github/CODEOWNERS"
        ".github/SECURITY.md"
        ".github/REPO-POLICY.md"
        ".github/MERGE_STRATEGY.md"
        ".github/dependabot.yml"
        ".vscode/settings.json"
        ".vscode/extensions.json"
        "config/agents.config.json"
        "config/security.config.json"
        "config/environments.config.json"
    )
    
    for file in "${config_files[@]}"; do
        if [ -f "$REPO_ROOT/$file" ]; then
            log "File exists: $file"
            
            # Validate JSON files
            if [[ "$file" == *.json ]]; then
                if command -v jq &> /dev/null; then
                    if jq empty "$REPO_ROOT/$file" 2>/dev/null; then
                        log "Valid JSON: $file"
                    else
                        error "Invalid JSON: $file"
                    fi
                fi
            fi
        else
            error "Missing file: $file"
        fi
    done
}

validate_workflows() {
    info "Validating GitHub Actions workflows..."
    
    local workflows=(
        "setup-validation.yml"
        "security-scan.yml"
        "mcp-health-check.yml"
        "drift-check.yml"
        "commit-validation.yml"
        "dependabot-auto-merge.yml"
    )
    
    for workflow in "${workflows[@]}"; do
        if [ -f "$REPO_ROOT/.github/workflows/$workflow" ]; then
            log "Workflow exists: $workflow"
        else
            error "Missing workflow: $workflow"
        fi
    done
}

validate_agents() {
    info "Validating agent configurations..."
    
    # OpenCode agents
    local opencode_count=$(find "$REPO_ROOT/.opencode/agents" -name "*.json" 2>/dev/null | wc -l)
    if [ "$opencode_count" -ge 8 ]; then
        log "OpenCode agents: $opencode_count configured"
    else
        warning "Expected at least 8 OpenCode agents, found: $opencode_count"
    fi
    
    # GitHub agents
    local github_count=$(find "$REPO_ROOT/.github/agents" -name "*.json" 2>/dev/null | wc -l)
    if [ "$github_count" -ge 3 ]; then
        log "GitHub agents: $github_count configured"
    else
        warning "Expected at least 3 GitHub agents, found: $github_count"
    fi
    
    # VSCode agents
    local vscode_count=$(find "$REPO_ROOT/.vscode/agents" -name "*.json" 2>/dev/null | wc -l)
    if [ "$vscode_count" -ge 3 ]; then
        log "VSCode agents: $vscode_count configured"
    else
        warning "Expected at least 3 VSCode agents, found: $vscode_count"
    fi
}

validate_scripts() {
    info "Validating automation scripts..."
    
    local scripts=(
        "setup.sh"
        "setup.ps1"
        "install-agents.sh"
        "install-agents.ps1"
        "configure-branch-protection.sh"
        "configure-branch-protection.ps1"
        "validate-setup.sh"
        "validate-setup.ps1"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$REPO_ROOT/scripts/$script" ]; then
            log "Script exists: $script"
            
            # Check if Bash scripts are executable
            if [[ "$script" == *.sh ]] && [ ! -x "$REPO_ROOT/scripts/$script" ]; then
                warning "Script not executable: $script"
                chmod +x "$REPO_ROOT/scripts/$script"
                log "Made executable: $script"
            fi
        else
            error "Missing script: $script"
        fi
    done
}

validate_documentation() {
    info "Validating documentation..."
    
    local docs=(
        "docs/SETUP.md"
        "docs/AGENTS.md"
        "docs/SECURITY-GUIDE.md"
        "docs/TROUBLESHOOTING.md"
    )
    
    for doc in "${docs[@]}"; do
        if [ -f "$REPO_ROOT/$doc" ]; then
            log "Documentation exists: $doc"
        else
            warning "Missing documentation: $doc"
        fi
    done
}

validate_issue_templates() {
    info "Validating issue templates..."
    
    local templates=(
        "bug_report.yml"
        "security_finding.yml"
        "agent_improvement.yml"
        "infrastructure.yml"
    )
    
    for template in "${templates[@]}"; do
        if [ -f "$REPO_ROOT/.github/ISSUE_TEMPLATE/$template" ]; then
            log "Issue template exists: $template"
        else
            error "Missing issue template: $template"
        fi
    done
}

################################################################################
# Summary
################################################################################

print_summary() {
    echo ""
    echo "=========================================="
    echo "Validation Summary"
    echo "=========================================="
    
    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        log "All validations passed! ✨"
        return 0
    elif [ $ERRORS -eq 0 ]; then
        warning "Validation completed with $WARNINGS warning(s)"
        return 0
    else
        error "Validation failed with $ERRORS error(s) and $WARNINGS warning(s)"
        return 1
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    echo "=========================================="
    echo "Setup Validation"
    echo "=========================================="
    
    cd "$REPO_ROOT"
    
    validate_directories
    validate_config_files
    validate_workflows
    validate_agents
    validate_scripts
    validate_documentation
    validate_issue_templates
    
    print_summary
}

main "$@"
