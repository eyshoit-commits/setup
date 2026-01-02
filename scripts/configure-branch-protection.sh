#!/bin/bash

################################################################################
# Branch Protection Configuration Script
#
# Configures branch protection rules using GitHub CLI
################################################################################

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

################################################################################
# Prerequisites
################################################################################

check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) is not installed"
        error "Install from: https://cli.github.com/"
        exit 1
    fi
    
    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        error "GitHub CLI is not authenticated"
        error "Run: gh auth login"
        exit 1
    fi
    
    log "✓ GitHub CLI is installed and authenticated"
}

################################################################################
# Branch Protection Configuration
################################################################################

configure_branch_protection() {
    local branch="$1"
    
    log "Configuring branch protection for: $branch"
    
    # Note: gh CLI doesn't have direct branch protection commands yet
    # This would require using the GitHub API directly
    
    info "Branch protection configuration:"
    info "  • Required pull request reviews: 1"
    info "  • Dismiss stale reviews: enabled"
    info "  • Require code owner reviews: enabled"
    info "  • Required status checks: enabled"
    info "  • Require branches to be up to date: enabled"
    info "  • Enforce for administrators: enabled"
    info "  • Require linear history: enabled"
    info "  • Allow force pushes: disabled"
    info "  • Allow deletions: disabled"
    info "  • Required conversation resolution: enabled"
    
    # Using GitHub API with gh CLI
    gh api \
        -X PUT \
        "repos/:owner/:repo/branches/$branch/protection" \
        -f required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":true,"require_last_push_approval":false}' \
        -f required_status_checks='{"strict":true,"checks":[{"context":"setup-validation"},{"context":"security-scan"},{"context":"mcp-health-check"},{"context":"drift-check"},{"context":"commit-validation"}]}' \
        -F enforce_admins=true \
        -F required_linear_history=true \
        -F allow_force_pushes=false \
        -F allow_deletions=false \
        -F required_conversation_resolution=true \
        -F lock_branch=false \
        -F allow_fork_syncing=true \
        2>&1 || {
            warning "Failed to configure branch protection via API"
            warning "You may need to configure this manually in GitHub settings"
            return 1
        }
    
    log "✓ Branch protection configured for: $branch"
}

################################################################################
# Main Execution
################################################################################

main() {
    log "=========================================="
    log "Branch Protection Configuration"
    log "=========================================="
    
    check_gh_cli
    
    # Configure main branch
    configure_branch_protection "main"
    
    # Optionally configure develop branch
    if git show-ref --verify --quiet refs/heads/develop; then
        configure_branch_protection "develop"
    else
        info "develop branch not found, skipping"
    fi
    
    log "=========================================="
    log "Branch protection configuration completed"
    log "=========================================="
    
    info ""
    info "Configured protections:"
    info "  ✓ Required reviews from code owners"
    info "  ✓ All status checks must pass"
    info "  ✓ Linear history enforced (squash merge only)"
    info "  ✓ No force pushes or deletions"
    info "  ✓ Conversations must be resolved"
    info ""
    info "Verify in GitHub: Settings → Branches → Branch protection rules"
}

main "$@"
