#!/usr/bin/env bash
#
# generate-subagents.sh - Generate AI subagent configuration files
#
# Usage:
#   ./generate-subagents.sh [OPTIONS]
#
# Options:
#   --dry-run         Simulate generation without creating files
#   --config FILE     Use custom config file (default: config/subagents.yml)
#   --force           Overwrite existing files
#   --validate-only   Only validate templates and config
#   --help            Show this help message
#
# Description:
#   Generates subagent JSON files from templates based on configuration.
#   Ensures idempotency by skipping existing files unless --force is used.
#

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Default configuration
DRY_RUN=false
FORCE=false
VALIDATE_ONLY=false
CONFIG_FILE="${REPO_ROOT}/config/subagents.yml"
TEMPLATE_DIR="${REPO_ROOT}/templates"
OUTPUT_BASE_DIR="${REPO_ROOT}/.vscode/subagents"

# Statistics
STATS_CREATED=0
STATS_SKIPPED=0
STATS_FAILED=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Show help message
show_help() {
    sed -n '/^#/,/^$/p' "$0" | sed 's/^# \?//' | head -n -1
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            --help|-h)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Validate JSON using jq
validate_json() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        log_error "Invalid JSON in file: $file"
        return 1
    fi
    return 0
}

# Validate YAML using python or yq
validate_yaml() {
    local file="$1"
    
    # Try with yq if available
    if command -v yq &>/dev/null; then
        if ! yq eval '.' "$file" >/dev/null 2>&1; then
            log_error "Invalid YAML in file: $file"
            return 1
        fi
        return 0
    fi
    
    # Fallback to Python
    if command -v python3 &>/dev/null; then
        if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            log_error "Invalid YAML in file: $file"
            return 1
        fi
        return 0
    fi
    
    log_warning "No YAML validator found (yq or python3). Skipping YAML validation."
    return 0
}

# Validate templates
validate_templates() {
    log_info "Validating templates..."
    
    local template_json="${TEMPLATE_DIR}/subagent-template.json"
    local template_yaml="${TEMPLATE_DIR}/copilot-agent-template.yml"
    
    if [[ ! -f "$template_json" ]]; then
        log_error "Subagent template not found: $template_json"
        return 1
    fi
    
    if [[ ! -f "$template_yaml" ]]; then
        log_error "Copilot agent template not found: $template_yaml"
        return 1
    fi
    
    validate_json "$template_json" || return 1
    validate_yaml "$template_yaml" || return 1
    
    log_success "Templates are valid"
    return 0
}

# Validate configuration file
validate_config() {
    log_info "Validating configuration file..."
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_warning "Configuration file not found: $CONFIG_FILE"
        log_info "Creating example configuration..."
        create_example_config
        return 0
    fi
    
    validate_yaml "$CONFIG_FILE" || return 1
    log_success "Configuration is valid"
    return 0
}

# Create example configuration
create_example_config() {
    local example_config="${REPO_ROOT}/config/subagents.example.yml"
    
    cat > "$example_config" << 'EOF'
# Subagents Configuration Example
# 
# This file defines all subagents to be generated.
# Each subagent is generated from templates/subagent-template.json

version: "1.0.0"

categories:
  - id: "01-core-development"
    name: "Core Development"
    agents: []
  
  - id: "02-language-specialists"
    name: "Language Specialists"
    agents: []
  
  - id: "03-infrastructure"
    name: "Infrastructure"
    agents: []
  
  - id: "04-quality-security"
    name: "Quality & Security"
    agents: []
  
  - id: "05-data-ai"
    name: "Data & AI"
    agents: []
  
  - id: "06-developer-experience"
    name: "Developer Experience"
    agents: []
  
  - id: "07-specialized-domains"
    name: "Specialized Domains"
    agents: []
  
  - id: "08-business-product"
    name: "Business & Product"
    agents: []
  
  - id: "09-meta-orchestration"
    name: "Meta & Orchestration"
    agents: []
  
  - id: "10-research-analysis"
    name: "Research & Analysis"
    agents: []

# Example agent definition:
# agents:
#   - name: "code-reviewer"
#     description: "Reviews code for best practices and potential issues"
#     category: "04-quality-security"
#     customInstructions: "Focus on code quality, security, and maintainability"
#     taskTypes: ["code-review", "security-audit"]
#     fallbackAgent: "general-assistant"
#     dependencies: ["syntax-checker", "security-scanner"]
EOF
    
    log_success "Created example configuration: $example_config"
    log_info "Copy to $CONFIG_FILE and customize for your needs"
}

# Generate a single subagent file
generate_subagent() {
    local name="$1"
    local description="$2"
    local category="$3"
    local instructions="$4"
    local task_types="$5"
    local fallback="$6"
    local dependencies="$7"
    
    local template="${TEMPLATE_DIR}/subagent-template.json"
    local output_dir="${OUTPUT_BASE_DIR}/${category}"
    local output_file="${output_dir}/${name}.json"
    
    # Check if file exists and not forcing
    if [[ -f "$output_file" ]] && [[ "$FORCE" != "true" ]]; then
        log_info "Skipping existing: $output_file"
        ((STATS_SKIPPED++))
        return 0
    fi
    
    # Create output directory
    if [[ "$DRY_RUN" != "true" ]]; then
        mkdir -p "$output_dir"
    fi
    
    # Generate JSON content
    local json_content
    json_content=$(jq \
        --arg name "$name" \
        --arg desc "$description" \
        --arg cat "$category" \
        --arg inst "$instructions" \
        --arg fallback "$fallback" \
        --argjson tasks "$task_types" \
        --argjson deps "$dependencies" \
        '.name = $name | 
         .description = $desc | 
         .category = $cat | 
         .customInstructions = $inst | 
         .taskTypes = $tasks | 
         .fallbackAgent = $fallback | 
         .dependencies = $deps' \
        "$template")
    
    # Validate generated JSON
    if ! echo "$json_content" | jq empty 2>/dev/null; then
        log_error "Failed to generate valid JSON for: $name"
        ((STATS_FAILED++))
        return 1
    fi
    
    # Write file or show dry-run message
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would create: $output_file"
        ((STATS_CREATED++))
    else
        echo "$json_content" > "$output_file"
        validate_json "$output_file" || {
            log_error "Generated invalid JSON: $output_file"
            ((STATS_FAILED++))
            return 1
        }
        log_success "Created: $output_file"
        ((STATS_CREATED++))
    fi
    
    return 0
}

# Process configuration and generate agents
process_config() {
    log_info "Processing configuration..."
    
    # For now, create placeholder README files in each category
    # since we don't have a full config yet
    
    local categories=(
        "01-core-development"
        "02-language-specialists"
        "03-infrastructure"
        "04-quality-security"
        "05-data-ai"
        "06-developer-experience"
        "07-specialized-domains"
        "08-business-product"
        "09-meta-orchestration"
        "10-research-analysis"
    )
    
    for category in "${categories[@]}"; do
        local readme_file="${OUTPUT_BASE_DIR}/${category}/README.md"
        
        if [[ -f "$readme_file" ]] && [[ "$FORCE" != "true" ]]; then
            log_info "Skipping existing: $readme_file"
            ((STATS_SKIPPED++))
            continue
        fi
        
        local category_name="${category#*-}"
        category_name="${category_name//-/ }"
        category_name="${category_name^}"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY-RUN] Would create: $readme_file"
            ((STATS_CREATED++))
        else
            cat > "$readme_file" << EOF
# ${category_name}

This directory contains AI subagents for ${category_name}.

## Purpose
Agents in this category handle tasks related to ${category_name}.

## Adding Agents
Place agent configuration JSON files in this directory.
Each agent should follow the structure defined in \`templates/subagent-template.json\`.

## Generated Files
Files in this directory may be auto-generated by \`scripts/agents/generate-subagents.sh\`.
EOF
            log_success "Created: $readme_file"
            ((STATS_CREATED++))
        fi
    done
    
    log_success "Configuration processed"
}

# Show statistics
show_statistics() {
    echo ""
    log_info "=== Generation Statistics ==="
    echo "  Created:  $STATS_CREATED"
    echo "  Skipped:  $STATS_SKIPPED"
    echo "  Failed:   $STATS_FAILED"
    echo ""
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY-RUN mode was enabled. No files were actually created."
    fi
    
    if [[ $STATS_FAILED -gt 0 ]]; then
        log_error "Some operations failed. Please review the errors above."
        return 1
    fi
    
    log_success "All operations completed successfully!"
    return 0
}

# Main function
main() {
    parse_args "$@"
    
    log_info "Starting subagent generation..."
    log_info "Repository: $REPO_ROOT"
    log_info "Config:     $CONFIG_FILE"
    log_info "Templates:  $TEMPLATE_DIR"
    log_info "Output:     $OUTPUT_BASE_DIR"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY-RUN mode enabled"
    fi
    
    if [[ "$FORCE" == "true" ]]; then
        log_warning "FORCE mode enabled - existing files will be overwritten"
    fi
    
    echo ""
    
    # Validate templates
    validate_templates || exit 1
    
    # Validate configuration
    validate_config || exit 1
    
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        log_success "Validation complete. Exiting."
        exit 0
    fi
    
    # Process configuration and generate files
    process_config || exit 1
    
    # Show statistics
    show_statistics || exit 1
}

# Run main function
main "$@"
