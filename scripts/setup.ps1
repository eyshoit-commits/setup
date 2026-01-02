<#
.SYNOPSIS
    Enterprise Repository Setup Script

.DESCRIPTION
    Automates the complete setup of the repository including:
    - Prerequisites validation
    - Agent installation
    - Configuration setup
    - Validation checks

.NOTES
    Version: 1.0.0
    Author: eyshoit-commits
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# Script variables
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$LogFile = Join-Path $RepoRoot "setup.log"

################################################################################
# Utility Functions
################################################################################

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage -ForegroundColor Green
    Add-Content -Path $LogFile -Value $logMessage
}

function Write-ErrorLog {
    param([string]$Message)
    $logMessage = "[ERROR] $Message"
    Write-Host $logMessage -ForegroundColor Red
    Add-Content -Path $LogFile -Value $logMessage
}

function Write-Warning {
    param([string]$Message)
    $logMessage = "[WARNING] $Message"
    Write-Host $logMessage -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $logMessage
}

function Write-Info {
    param([string]$Message)
    $logMessage = "[INFO] $Message"
    Write-Host $logMessage -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value $logMessage
}

function Test-CommandExists {
    param([string]$Command)
    
    $exists = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    if ($exists) {
        Write-Log "✓ $Command is installed"
    } else {
        Write-ErrorLog "✗ $Command is not installed"
    }
    return $exists
}

################################################################################
# Prerequisites Check
################################################################################

function Test-Prerequisites {
    Write-Log "Checking prerequisites..."
    
    $allGood = $true
    
    # Check required commands
    if (-not (Test-CommandExists "git")) { $allGood = $false }
    
    # Check for jq (or alternative JSON parser)
    if (-not (Test-CommandExists "jq")) {
        Write-Warning "jq not found - will use PowerShell for JSON validation"
    }
    
    # Check optional but recommended commands
    if (-not (Test-CommandExists "gh")) {
        Write-Warning "GitHub CLI (gh) not found - some features may be limited"
    }
    
    if (-not (Test-CommandExists "node")) {
        Write-Warning "Node.js not found - JavaScript/TypeScript features may be limited"
    }
    
    if (-not (Test-CommandExists "python")) {
        Write-Warning "Python not found - Python features may be limited"
    }
    
    if (-not $allGood) {
        Write-ErrorLog "Missing required prerequisites"
        exit 1
    }
    
    Write-Log "All required prerequisites satisfied"
}

################################################################################
# Directory Structure Validation
################################################################################

function Test-Structure {
    Write-Log "Validating repository structure..."
    
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
    
    $missingDirs = @()
    
    foreach ($dir in $requiredDirs) {
        $fullPath = Join-Path $RepoRoot $dir
        if (-not (Test-Path $fullPath -PathType Container)) {
            $missingDirs += $dir
        }
    }
    
    if ($missingDirs.Count -gt 0) {
        Write-ErrorLog "Missing required directories:"
        foreach ($dir in $missingDirs) {
            Write-Host "  - $dir" -ForegroundColor Red
        }
        exit 1
    }
    
    Write-Log "Directory structure validated"
}

################################################################################
# Configuration Files Validation
################################################################################

function Test-Configs {
    Write-Log "Validating configuration files..."
    
    $configFiles = @(
        ".opencode/config.json",
        "config/agents.config.json",
        "config/security.config.json",
        "config/environments.config.json"
    )
    
    foreach ($config in $configFiles) {
        $fullPath = Join-Path $RepoRoot $config
        if (Test-Path $fullPath) {
            try {
                $null = Get-Content $fullPath | ConvertFrom-Json
                Write-Log "✓ $config is valid"
            }
            catch {
                Write-ErrorLog "✗ $config has invalid JSON: $_"
                exit 1
            }
        }
        else {
            Write-Warning "$config not found"
        }
    }
    
    Write-Log "Configuration files validated"
}

################################################################################
# Agent Installation
################################################################################

function Install-Agents {
    Write-Log "Installing agents..."
    
    $installScript = Join-Path $ScriptDir "install-agents.ps1"
    if (Test-Path $installScript) {
        & $installScript
    }
    else {
        Write-Warning "install-agents.ps1 not found, skipping agent installation"
    }
    
    Write-Log "Agent installation completed"
}

################################################################################
# Git Configuration
################################################################################

function Set-GitConfig {
    Write-Log "Configuring Git settings..."
    
    Push-Location $RepoRoot
    
    try {
        # Configure line endings
        git config core.autocrlf true
        git config core.eol lf
        
        Write-Log "Git configuration completed"
    }
    finally {
        Pop-Location
    }
}

################################################################################
# Environment Setup
################################################################################

function Set-Environment {
    Write-Log "Setting up environment..."
    
    $envExample = Join-Path $RepoRoot ".env.example"
    if (-not (Test-Path $envExample)) {
        $envContent = @"
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
"@
        Set-Content -Path $envExample -Value $envContent
        Write-Log "Created .env.example template"
    }
    
    Write-Log "Environment setup completed"
}

################################################################################
# Final Validation
################################################################################

function Invoke-Validation {
    Write-Log "Running final validation..."
    
    $validateScript = Join-Path $ScriptDir "validate-setup.ps1"
    if (Test-Path $validateScript) {
        & $validateScript
    }
    else {
        Write-Warning "validate-setup.ps1 not found, skipping validation"
    }
    
    Write-Log "Validation completed"
}

################################################################################
# Generate Setup Report
################################################################################

function New-SetupReport {
    Write-Log "Generating setup report..."
    
    $reportFile = Join-Path $RepoRoot "setup-report.txt"
    
    $opencodeAgents = (Get-ChildItem -Path (Join-Path $RepoRoot ".opencode/agents") -Filter "*.json" -ErrorAction SilentlyContinue).Count
    $githubAgents = (Get-ChildItem -Path (Join-Path $RepoRoot ".github/agents") -Filter "*.json" -ErrorAction SilentlyContinue).Count
    $vscodeAgents = (Get-ChildItem -Path (Join-Path $RepoRoot ".vscode/agents") -Filter "*.json" -ErrorAction SilentlyContinue).Count
    $workflows = (Get-ChildItem -Path (Join-Path $RepoRoot ".github/workflows") -Filter "*.yml" -ErrorAction SilentlyContinue).Count
    
    $opencodeConfigExists = Test-Path (Join-Path $RepoRoot ".opencode/config.json")
    $securityConfigExists = Test-Path (Join-Path $RepoRoot "config/security.config.json")
    $agentsConfigExists = Test-Path (Join-Path $RepoRoot "config/agents.config.json")
    $envConfigExists = Test-Path (Join-Path $RepoRoot "config/environments.config.json")
    
    $report = @"
================================================================================
Enterprise Repository Setup Report
================================================================================

Date: $(Get-Date)
Repository: $RepoRoot

CONFIGURATION FILES
-------------------
OpenCode Config:    $(if ($opencodeConfigExists) { "✓" } else { "✗" })
Security Config:    $(if ($securityConfigExists) { "✓" } else { "✗" })
Agents Config:      $(if ($agentsConfigExists) { "✓" } else { "✗" })
Environment Config: $(if ($envConfigExists) { "✓" } else { "✗" })

AGENT COUNTS
------------
OpenCode Agents: $opencodeAgents
GitHub Agents:   $githubAgents
VSCode Agents:   $vscodeAgents

WORKFLOWS
---------
$workflows GitHub Actions workflows configured

SETUP STATUS
------------
✓ Repository structure validated
✓ Configuration files validated
✓ Git configured
✓ Environment setup completed

================================================================================
Setup completed successfully!
================================================================================
"@
    
    Set-Content -Path $reportFile -Value $report
    Write-Host $report
    Write-Log "Report saved to: $reportFile"
}

################################################################################
# Main Execution
################################################################################

function Main {
    Write-Log "=========================================="
    Write-Log "Enterprise Repository Setup"
    Write-Log "=========================================="
    
    Test-Prerequisites
    Test-Structure
    Test-Configs
    Set-GitConfig
    Set-Environment
    Install-Agents
    Invoke-Validation
    New-SetupReport
    
    Write-Log "=========================================="
    Write-Log "Setup completed successfully!"
    Write-Log "=========================================="
    Write-Log "Log file: $LogFile"
}

# Run main function
Main
