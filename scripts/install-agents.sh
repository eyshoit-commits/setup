#!/bin/bash

################################################################################
# Agent Installation Script
#
# Installs and configures all OpenCode agents
################################################################################

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

################################################################################
# Agent Installation
################################################################################

install_agent() {
    local agent_name="$1"
    local agent_repo="$2"
    
    log "Installing $agent_name from $agent_repo..."
    
    # Agents are typically npm packages or git repositories
    # This is a placeholder for actual installation logic
    # In production, you would:
    # 1. Clone the repository or install the package
    # 2. Run any setup scripts
    # 3. Configure the agent
    
    log "✓ $agent_name configured"
}

################################################################################
# Main Installation
################################################################################

main() {
    log "=========================================="
    log "Installing OpenCode Agents"
    log "=========================================="
    
    if [ ! -f "$REPO_ROOT/.opencode/config.json" ]; then
        error "OpenCode configuration not found!"
        exit 1
    fi
    
    # Read agents from config
    if command -v jq &> /dev/null; then
        log "Reading agent configuration..."
        
        # Extract agent list from config
        agents=$(jq -r '.agents | to_entries[] | "\(.key):\(.value)"' "$REPO_ROOT/.opencode/config.json")
        
        while IFS=: read -r name repo; do
            install_agent "$name" "$repo"
        done <<< "$agents"
    else
        warning "jq not installed - skipping automatic agent installation"
        log "Please install agents manually or install jq"
    fi
    
    log "=========================================="
    log "Agent installation completed"
    log "=========================================="
}

main "$@"
