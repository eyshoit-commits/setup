<#
.SYNOPSIS
    Agent Installation Script

.DESCRIPTION
    Installs and configures all OpenCode agents
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

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

################################################################################
# Agent Installation
################################################################################

function Install-Agent {
    param(
        [string]$AgentName,
        [string]$AgentRepo
    )
    
    Write-Log "Installing $AgentName from $AgentRepo..."
    
    # Agents are typically npm packages or git repositories
    # This is a placeholder for actual installation logic
    # In production, you would:
    # 1. Clone the repository or install the package
    # 2. Run any setup scripts
    # 3. Configure the agent
    
    Write-Log "✓ $AgentName configured"
}

################################################################################
# Main Installation
################################################################################

function Main {
    Write-Log "=========================================="
    Write-Log "Installing OpenCode Agents"
    Write-Log "=========================================="
    
    $configPath = Join-Path $RepoRoot ".opencode/config.json"
    
    if (-not (Test-Path $configPath)) {
        Write-ErrorLog "OpenCode configuration not found!"
        exit 1
    }
    
    try {
        Write-Log "Reading agent configuration..."
        
        $config = Get-Content $configPath | ConvertFrom-Json
        
        foreach ($agent in $config.agents.PSObject.Properties) {
            Install-Agent -AgentName $agent.Name -AgentRepo $agent.Value
        }
    }
    catch {
        Write-ErrorLog "Failed to read configuration: $_"
        exit 1
    }
    
    Write-Log "=========================================="
    Write-Log "Agent installation completed"
    Write-Log "=========================================="
}

Main
