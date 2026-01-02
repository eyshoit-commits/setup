<#
.SYNOPSIS
    Setup Validation Script

.DESCRIPTION
    Validates the complete repository setup
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$Script:Errors = 0
$Script:Warnings = 0

function Write-Log {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
    $Script:Warnings++
}

function Write-ErrorLog {
    param([string]$Message)
    Write-Host "[✗] $Message" -ForegroundColor Red
    $Script:Errors++
}

function Write-Info {
    param([string]$Message)
    Write-Host "[i] $Message" -ForegroundColor Cyan
}

################################################################################
# Validation Functions
################################################################################

function Test-Directories {
    Write-Info "Validating directory structure..."
    
    $requiredDirs = @(
        ".opencode",
        ".opencode/agents",
        ".github/workflows",
        ".github/ISSUE_TEMPLATE",
        ".github/agents",
        ".vscode",
        ".vscode/agents",
        "scripts",
        "config",
        "docs"
    )
    
    foreach ($dir in $requiredDirs) {
        $fullPath = Join-Path $RepoRoot $dir
        if (Test-Path $fullPath -PathType Container) {
            Write-Log "Directory exists: $dir"
        }
        else {
            Write-ErrorLog "Missing directory: $dir"
        }
    }
}

function Test-ConfigFiles {
    Write-Info "Validating configuration files..."
    
    $configFiles = @(
        ".opencode/config.json",
        ".opencode/README.md",
        ".github/CODEOWNERS",
        ".github/SECURITY.md",
        ".github/REPO-POLICY.md",
        ".github/MERGE_STRATEGY.md",
        ".github/dependabot.yml",
        ".vscode/settings.json",
        ".vscode/extensions.json",
        "config/agents.config.json",
        "config/security.config.json",
        "config/environments.config.json"
    )
    
    foreach ($file in $configFiles) {
        $fullPath = Join-Path $RepoRoot $file
        if (Test-Path $fullPath) {
            Write-Log "File exists: $file"
            
            # Validate JSON files
            if ($file -match '\.json$') {
                try {
                    $null = Get-Content $fullPath | ConvertFrom-Json
                    Write-Log "Valid JSON: $file"
                }
                catch {
                    Write-ErrorLog "Invalid JSON: $file"
                }
            }
        }
        else {
            Write-ErrorLog "Missing file: $file"
        }
    }
}

function Test-Workflows {
    Write-Info "Validating GitHub Actions workflows..."
    
    $workflows = @(
        "setup-validation.yml",
        "security-scan.yml",
        "mcp-health-check.yml",
        "drift-check.yml",
        "commit-validation.yml",
        "dependabot-auto-merge.yml"
    )
    
    foreach ($workflow in $workflows) {
        $fullPath = Join-Path $RepoRoot ".github/workflows/$workflow"
        if (Test-Path $fullPath) {
            Write-Log "Workflow exists: $workflow"
        }
        else {
            Write-ErrorLog "Missing workflow: $workflow"
        }
    }
}

function Test-Agents {
    Write-Info "Validating agent configurations..."
    
    # OpenCode agents
    $opencodeAgents = @(Get-ChildItem -Path (Join-Path $RepoRoot ".opencode/agents") -Filter "*.json" -ErrorAction SilentlyContinue)
    if ($opencodeAgents.Count -ge 8) {
        Write-Log "OpenCode agents: $($opencodeAgents.Count) configured"
    }
    else {
        Write-Warning "Expected at least 8 OpenCode agents, found: $($opencodeAgents.Count)"
    }
    
    # GitHub agents
    $githubAgents = @(Get-ChildItem -Path (Join-Path $RepoRoot ".github/agents") -Filter "*.json" -ErrorAction SilentlyContinue)
    if ($githubAgents.Count -ge 3) {
        Write-Log "GitHub agents: $($githubAgents.Count) configured"
    }
    else {
        Write-Warning "Expected at least 3 GitHub agents, found: $($githubAgents.Count)"
    }
    
    # VSCode agents
    $vscodeAgents = @(Get-ChildItem -Path (Join-Path $RepoRoot ".vscode/agents") -Filter "*.json" -ErrorAction SilentlyContinue)
    if ($vscodeAgents.Count -ge 3) {
        Write-Log "VSCode agents: $($vscodeAgents.Count) configured"
    }
    else {
        Write-Warning "Expected at least 3 VSCode agents, found: $($vscodeAgents.Count)"
    }
}

function Test-Scripts {
    Write-Info "Validating automation scripts..."
    
    $scripts = @(
        "setup.sh",
        "setup.ps1",
        "install-agents.sh",
        "install-agents.ps1",
        "configure-branch-protection.sh",
        "configure-branch-protection.ps1",
        "validate-setup.sh",
        "validate-setup.ps1"
    )
    
    foreach ($script in $scripts) {
        $fullPath = Join-Path $RepoRoot "scripts/$script"
        if (Test-Path $fullPath) {
            Write-Log "Script exists: $script"
        }
        else {
            Write-ErrorLog "Missing script: $script"
        }
    }
}

function Test-Documentation {
    Write-Info "Validating documentation..."
    
    $docs = @(
        "docs/SETUP.md",
        "docs/AGENTS.md",
        "docs/SECURITY-GUIDE.md",
        "docs/TROUBLESHOOTING.md"
    )
    
    foreach ($doc in $docs) {
        $fullPath = Join-Path $RepoRoot $doc
        if (Test-Path $fullPath) {
            Write-Log "Documentation exists: $doc"
        }
        else {
            Write-Warning "Missing documentation: $doc"
        }
    }
}

function Test-IssueTemplates {
    Write-Info "Validating issue templates..."
    
    $templates = @(
        "bug_report.yml",
        "security_finding.yml",
        "agent_improvement.yml",
        "infrastructure.yml"
    )
    
    foreach ($template in $templates) {
        $fullPath = Join-Path $RepoRoot ".github/ISSUE_TEMPLATE/$template"
        if (Test-Path $fullPath) {
            Write-Log "Issue template exists: $template"
        }
        else {
            Write-ErrorLog "Missing issue template: $template"
        }
    }
}

################################################################################
# Summary
################################################################################

function Write-Summary {
    Write-Host ""
    Write-Host "=========================================="
    Write-Host "Validation Summary"
    Write-Host "=========================================="
    
    if ($Script:Errors -eq 0 -and $Script:Warnings -eq 0) {
        Write-Log "All validations passed! ✨"
        return 0
    }
    elseif ($Script:Errors -eq 0) {
        Write-Warning "Validation completed with $($Script:Warnings) warning(s)"
        return 0
    }
    else {
        Write-ErrorLog "Validation failed with $($Script:Errors) error(s) and $($Script:Warnings) warning(s)"
        return 1
    }
}

################################################################################
# Main Execution
################################################################################

function Main {
    Write-Host "=========================================="
    Write-Host "Setup Validation"
    Write-Host "=========================================="
    
    Push-Location $RepoRoot
    
    try {
        Test-Directories
        Test-ConfigFiles
        Test-Workflows
        Test-Agents
        Test-Scripts
        Test-Documentation
        Test-IssueTemplates
        
        Write-Summary
    }
    finally {
        Pop-Location
    }
}

Main
