<#
.SYNOPSIS
    Branch Protection Configuration Script

.DESCRIPTION
    Configures branch protection rules using GitHub CLI
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorLog {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

################################################################################
# Prerequisites
################################################################################

function Test-GitHubCLI {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-ErrorLog "GitHub CLI (gh) is not installed"
        Write-ErrorLog "Install from: https://cli.github.com/"
        exit 1
    }
    
    # Check if authenticated
    try {
        gh auth status 2>&1 | Out-Null
    }
    catch {
        Write-ErrorLog "GitHub CLI is not authenticated"
        Write-ErrorLog "Run: gh auth login"
        exit 1
    }
    
    Write-Log "✓ GitHub CLI is installed and authenticated"
}

################################################################################
# Branch Protection Configuration
################################################################################

function Set-BranchProtection {
    param([string]$Branch)
    
    Write-Log "Configuring branch protection for: $Branch"
    
    Write-Info "Branch protection configuration:"
    Write-Info "  • Required pull request reviews: 1"
    Write-Info "  • Dismiss stale reviews: enabled"
    Write-Info "  • Require code owner reviews: enabled"
    Write-Info "  • Required status checks: enabled"
    Write-Info "  • Require branches to be up to date: enabled"
    Write-Info "  • Enforce for administrators: enabled"
    Write-Info "  • Require linear history: enabled"
    Write-Info "  • Allow force pushes: disabled"
    Write-Info "  • Allow deletions: disabled"
    Write-Info "  • Required conversation resolution: enabled"
    
    try {
        # Using GitHub API with gh CLI
        $protectionConfig = @{
            required_pull_request_reviews = @{
                required_approving_review_count = 1
                dismiss_stale_reviews = $true
                require_code_owner_reviews = $true
                require_last_push_approval = $false
            }
            required_status_checks = @{
                strict = $true
                checks = @(
                    @{ context = "setup-validation" }
                    @{ context = "security-scan" }
                    @{ context = "mcp-health-check" }
                    @{ context = "drift-check" }
                    @{ context = "commit-validation" }
                )
            }
            enforce_admins = $true
            required_linear_history = $true
            allow_force_pushes = $false
            allow_deletions = $false
            required_conversation_resolution = $true
            lock_branch = $false
            allow_fork_syncing = $true
        }
        
        $jsonConfig = $protectionConfig | ConvertTo-Json -Depth 10
        
        gh api `
            -X PUT `
            "repos/:owner/:repo/branches/$Branch/protection" `
            --input - `
            <<< $jsonConfig 2>&1 | Out-Null
        
        Write-Log "✓ Branch protection configured for: $Branch"
    }
    catch {
        Write-Warning "Failed to configure branch protection via API: $_"
        Write-Warning "You may need to configure this manually in GitHub settings"
    }
}

################################################################################
# Main Execution
################################################################################

function Main {
    Write-Log "=========================================="
    Write-Log "Branch Protection Configuration"
    Write-Log "=========================================="
    
    Test-GitHubCLI
    
    # Configure main branch
    Set-BranchProtection -Branch "main"
    
    # Optionally configure develop branch
    try {
        git show-ref --verify refs/heads/develop 2>&1 | Out-Null
        Set-BranchProtection -Branch "develop"
    }
    catch {
        Write-Info "develop branch not found, skipping"
    }
    
    Write-Log "=========================================="
    Write-Log "Branch protection configuration completed"
    Write-Log "=========================================="
    
    Write-Info ""
    Write-Info "Configured protections:"
    Write-Info "  ✓ Required reviews from code owners"
    Write-Info "  ✓ All status checks must pass"
    Write-Info "  ✓ Linear history enforced (squash merge only)"
    Write-Info "  ✓ No force pushes or deletions"
    Write-Info "  ✓ Conversations must be resolved"
    Write-Info ""
    Write-Info "Verify in GitHub: Settings → Branches → Branch protection rules"
}

Main
