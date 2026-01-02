# Enterprise Setup Guide / Einrichtungsanleitung

[🇩🇪 Deutsche Version](#deutsche-version) | [🇬🇧 English Version](#english-version)

---

## Deutsche Version

### 📋 Inhaltsverzeichnis

1. [Voraussetzungen](#voraussetzungen-de)
2. [Schnellstart](#schnellstart-de)
3. [Lokale Entwicklungsumgebung](#lokale-entwicklungsumgebung-de)
4. [CI/CD Setup](#cicd-setup-de)
5. [Secrets Management](#secrets-management-de)
6. [Workflow-Übersicht](#workflow-übersicht-de)
7. [Häufige Aufgaben](#häufige-aufgaben-de)
8. [Fehlerbehebung](#fehlerbehebung-de)

---

### Voraussetzungen {#voraussetzungen-de}

#### Erforderliche Software

**Git & GitHub CLI:**
```bash
# Git installieren (mindestens Version 2.30+)
# Windows: https://git-scm.com/download/win
# macOS: brew install git
# Linux: apt-get install git

# GitHub CLI installieren
# Windows: https://cli.github.com/
# macOS: brew install gh
# Linux: (wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null) && sudo apt install gh
```

**Node.js & npm:**
```bash
# Node.js 20.x oder höher
# Download: https://nodejs.org/

# Verifizieren:
node --version  # Sollte v20.x.x oder höher sein
npm --version   # Sollte 10.x.x oder höher sein
```

**Python (Optional):**
```bash
# Python 3.11 oder höher für Python-basierte Tools
# Download: https://www.python.org/downloads/

# Verifizieren:
python3 --version  # Sollte 3.11.x oder höher sein
pip3 --version
```

**Zusätzliche Tools:**
```bash
# jq - JSON-Processor (empfohlen)
# Windows: choco install jq
# macOS: brew install jq
# Linux: apt-get install jq

# ShellCheck - Shell-Skript-Linter (optional)
# Windows: choco install shellcheck
# macOS: brew install shellcheck
# Linux: apt-get install shellcheck

# Docker (optional für Container-Tests)
# Download: https://www.docker.com/products/docker-desktop
```

#### GitHub-Berechtigungen

Sie benötigen:
- 🔑 GitHub-Account mit Admin-Zugriff auf das Repository
- 📝 Berechtigung zum Erstellen von Secrets
- ⚙️ Berechtigung zum Konfigurieren von Branch Protection Rules
- 🔄 Berechtigung zum Installieren von GitHub Apps

#### Marketplace-Apps-Accounts

Erstellen Sie Accounts bei folgenden Diensten:
- [Snyk](https://app.snyk.io/) - Sicherheits-Scanning
- [Codecov](https://codecov.io/) - Test-Coverage
- [Codacy](https://app.codacy.com/) - Code-Qualität
- [CodeRabbit](https://coderabbit.ai/) - KI Code-Review (optional)
- [CodiumAI](https://www.codium.ai/) - KI Test-Generierung (optional)

---

### Schnellstart {#schnellstart-de}

**Komplettes Setup in 5 Minuten:**

```bash
# 1. Repository klonen
git clone https://github.com/your-org/setup.git
cd setup

# 2. Lokales Setup ausführen
chmod +x scripts/local-setup.sh
./scripts/local-setup.sh

# 3. Secrets konfigurieren (siehe .env Datei)
cp .github/secrets-template.env .env
# Füllen Sie .env mit Ihren API-Keys aus

# 4. Marketplace Apps installieren
chmod +x scripts/setup-marketplace-apps.sh
./scripts/setup-marketplace-apps.sh

# 5. Erste Validierung
chmod +x scripts/validate-environment.sh
./scripts/validate-environment.sh
```

✅ **Fertig!** Ihre lokale Umgebung ist eingerichtet.

---

### Lokale Entwicklungsumgebung {#lokale-entwicklungsumgebung-de}

#### 1. Repository Setup

```bash
# Repository klonen
git clone https://github.com/your-org/setup.git
cd setup

# Überprüfen Sie die Struktur
ls -la
# Erwartete Ordner:
# - .github/workflows  → CI/CD Workflows
# - .github/hooks      → Git Hooks
# - scripts/           → Setup-Skripte
# - .opencode/agents/  → OpenCode Agent-Konfiguration
# - mcp/               → MCP Server-Konfiguration
# - docs/              → Dokumentation
```

#### 2. Lokales Setup-Skript ausführen

Das Setup-Skript konfiguriert automatisch:
- Git Hooks (pre-commit, commit-msg)
- Lokale Umgebungsvariablen
- Node.js-Dependencies (falls package.json vorhanden)
- Python-Dependencies (falls requirements.txt vorhanden)

```bash
# Skript ausführbar machen
chmod +x scripts/local-setup.sh

# Setup ausführen
./scripts/local-setup.sh

# Ausgabe:
# ==================================
# 🚀 Local Development Setup
# ==================================
#
# Repository root: /path/to/setup
#
# 📌 Installing Git hooks...
# ✅ Installed pre-commit hook
# ✅ Installed commit-msg hook
#
# ... weitere Schritte ...
#
# ✅ Local setup complete!
```

#### 3. Git Hooks konfiguriert

Nach dem Setup sind folgende Hooks aktiv:

**Pre-Commit Hook:**
- Prüft auf versehentlich committete Secrets
- Validiert Code-Formatierung
- Führt Linting aus (falls konfiguriert)
- Führt ShellCheck für Shell-Skripte aus

**Commit-Msg Hook:**
- Erzwingt Conventional Commits Format
- Validiert Commit-Nachricht-Struktur
- Beispiel: `feat(auth): add login functionality`

```bash
# Hooks testen
git add .
git commit -m "test: validate hooks"
# ✅ Commit message follows Conventional Commits format

# Ungültiger Commit wird abgelehnt:
git commit -m "bad commit message"
# ❌ Invalid commit message format
```

#### 4. Umgebungsvariablen konfigurieren

```bash
# .env-Datei wurde automatisch aus Template erstellt
cat .env

# Füllen Sie folgende Werte aus:
SNYK_TOKEN=your-snyk-token-here
CODECOV_TOKEN=your-codecov-token-here
CODACY_PROJECT_TOKEN=your-codacy-token-here
GITHUB_TOKEN=your-github-pat-here
# ... siehe Secrets Management für Details
```

#### 5. VS Code Extensions (Empfohlen)

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "github.copilot",
    "github.vscode-pull-request-github",
    "ms-vscode.vscode-typescript-next",
    "timonwong.shellcheck",
    "github.vscode-github-actions"
  ]
}
```

Speichern Sie dies in `.vscode/extensions.json` (wird automatisch erstellt).

---

### CI/CD Setup {#cicd-setup-de}

#### 1. Repository in GitHub einrichten

```bash
# Stellen Sie sicher, dass Sie im Repository-Ordner sind
cd setup

# Remote hinzufügen (falls noch nicht geschehen)
git remote add origin https://github.com/your-org/setup.git

# Initial Push
git add .
git commit -m "feat: initial repository setup"
git push -u origin main
```

#### 2. GitHub Secrets konfigurieren

**Manuelle Konfiguration via GitHub UI:**
1. Gehen Sie zu `Settings → Secrets and variables → Actions`
2. Klicken Sie auf `New repository secret`
3. Fügen Sie jedes Secret aus der Liste hinzu

**Automatische Konfiguration via GitHub CLI:**
```bash
# GitHub CLI authentifizieren
gh auth login

# Secrets aus .env-Datei setzen (stellen Sie sicher, dass .env ausgefüllt ist)
source .env

# Secrets einzeln setzen
gh secret set SNYK_TOKEN --body "$SNYK_TOKEN"
gh secret set CODECOV_TOKEN --body "$CODECOV_TOKEN"
gh secret set CODACY_PROJECT_TOKEN --body "$CODACY_PROJECT_TOKEN"
gh secret set GITHUB_TOKEN --body "$GITHUB_TOKEN"
gh secret set OPENAI_API_KEY --body "$OPENAI_API_KEY"
gh secret set ANTHROPIC_API_KEY --body "$ANTHROPIC_API_KEY"

# Optional:
gh secret set WAKATIME_API_KEY --body "$WAKATIME_API_KEY"
gh secret set BRAVE_API_KEY --body "$BRAVE_API_KEY"

# Verifizieren
gh secret list
```

**Secrets-Liste:**
| Secret Name | Erforderlich | Zweck |
|------------|-------------|-------|
| `SNYK_TOKEN` | ✅ Ja | Sicherheits-Scanning |
| `CODECOV_TOKEN` | ✅ Ja | Test-Coverage-Reporting |
| `CODACY_PROJECT_TOKEN` | ✅ Ja | Code-Qualitätsanalyse |
| `GITHUB_TOKEN` | ✅ Ja (Auto) | GitHub API-Zugriff |
| `OPENAI_API_KEY` | ⚠️ Optional | OpenAI Integration |
| `ANTHROPIC_API_KEY` | ⚠️ Optional | Claude AI Integration |
| `WAKATIME_API_KEY` | ⚠️ Optional | Zeit-Tracking |
| `BRAVE_API_KEY` | ⚠️ Optional | MCP Brave Search |

#### 3. GitHub Apps installieren

```bash
# Setup-Skript ausführen
chmod +x scripts/setup-marketplace-apps.sh
./scripts/setup-marketplace-apps.sh

# Das Skript führt Sie durch die Installation von:
# 1. CodeRabbit AI
# 2. CodiumAI PR Agent
# 3. CodeFactor
# 4. Codacy
# 5. Codecov
# 6. Snyk
# 7. Dependabot (bereits aktiviert)
```

Siehe [RECOMMENDED_MARKETPLACE_APPS.md](./RECOMMENDED_MARKETPLACE_APPS.md) für detaillierte Installationsanleitungen.

#### 4. Branch Protection Rules einrichten

**Via GitHub UI:**
1. `Settings → Branches → Add rule`
2. Branch name pattern: `main`
3. Aktivieren Sie:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Require conversation resolution before merging
   - ✅ Require linear history
   - ✅ Include administrators

**Via GitHub CLI (mit Konfigurationsdatei):**
```bash
# Branch Protection für main
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  repos/{owner}/{repo}/branches/main/protection \
  --input .github/branch-protection.json

# Für develop-Branch mit reduzierten Anforderungen
# Passen Sie .github/branch-protection.json entsprechend an
```

**Required Status Checks für main:**
- `setup-validation`
- `security-scan / CodeQL Analysis (javascript)`
- `security-scan / CodeQL Analysis (python)`
- `security-scan / Snyk Security Scan`
- `security-scan / Dependency Scanning`
- `security-scan / Secret Detection`
- `code-quality / Codacy Analysis`
- `code-quality / Code Coverage`
- `code-quality / Linting & Formatting`
- `code-quality / ShellCheck`
- `ai-review / CodeRabbit Review`
- `ai-review / CodiumAI PR Agent`
- `mcp-health-check / MCP Server Health Monitoring`
- `drift-check / Infrastructure Drift Detection`
- `commit-validation / Validate Conventional Commits`
- `commit-validation / PR Title & Description Check`

#### 5. Workflows testen

```bash
# Erstellen Sie einen Test-Branch
git checkout -b test/workflow-validation

# Änderung machen
echo "# Test" >> test.md
git add test.md
git commit -m "test: validate CI/CD workflows"

# Push und PR erstellen
git push -u origin test/workflow-validation
gh pr create --title "test: validate CI/CD workflows" --body "Testing workflow integration"

# Workflows überwachen
gh pr checks
# Oder via UI: Pull Requests → Ihr PR → Checks Tab
```

---

### Secrets Management {#secrets-management-de}

#### Secrets-Template verstehen

Die Datei `.github/secrets-template.env` listet alle benötigten Secrets auf:

```bash
cat .github/secrets-template.env

# Kategorien:
# 1. Security Scanning Tokens (Snyk, Codecov, Codacy)
# 2. Development Analytics (WakaTime)
# 3. GitHub Integration (GITHUB_TOKEN)
# 4. AI Agent Integration (OpenAI, Anthropic)
# 5. MCP Server Integration (Brave Search)
# 6. Additional Services (Sentry, DataDog, Slack)
```

#### Secrets sicher abrufen

**Snyk Token:**
```bash
# 1. Gehen Sie zu https://app.snyk.io/account
# 2. Scrollen Sie zu "API Token"
# 3. Klicken Sie auf "Show" oder generieren Sie neuen Token
# 4. Kopieren Sie Token

# Setzen:
gh secret set SNYK_TOKEN --body "snyk-token-here"
```

**Codecov Token:**
```bash
# 1. Gehen Sie zu https://codecov.io/
# 2. Wählen Sie Ihr Repository
# 3. Settings → General → Repository Upload Token
# 4. Kopieren Sie Token

gh secret set CODECOV_TOKEN --body "codecov-token-here"
```

**Codacy Project Token:**
```bash
# 1. Gehen Sie zu https://app.codacy.com/
# 2. Wählen Sie Ihr Repository
# 3. Settings → Integrations → Project API
# 4. Generieren oder kopieren Sie Token

gh secret set CODACY_PROJECT_TOKEN --body "codacy-token-here"
```

**GitHub Personal Access Token:**
```bash
# 1. Gehen Sie zu https://github.com/settings/tokens
# 2. Generate new token (classic)
# 3. Scopes auswählen:
#    ✅ repo (Full control of private repositories)
#    ✅ workflow (Update GitHub Action workflows)
#    ✅ write:packages (Upload packages)
# 4. Generate token
# 5. Kopieren Sie sofort (wird nur einmal angezeigt!)

gh secret set GITHUB_TOKEN --body "ghp_xxxxxxxxxxxx"
```

**OpenAI API Key (Optional):**
```bash
# 1. Gehen Sie zu https://platform.openai.com/api-keys
# 2. Create new secret key
# 3. Name: "Enterprise Setup"
# 4. Kopieren Sie Key

gh secret set OPENAI_API_KEY --body "sk-xxxxxxxxxxxx"
```

**Anthropic API Key (Optional):**
```bash
# 1. Gehen Sie zu https://console.anthropic.com/
# 2. Settings → API Keys
# 3. Create Key
# 4. Kopieren Sie Key

gh secret set ANTHROPIC_API_KEY --body "sk-ant-xxxxxxxxxxxx"
```

#### Secrets rotieren

```bash
# Best Practice: Rotieren Sie Secrets alle 90 Tage

# Secret aktualisieren:
gh secret set SECRET_NAME --body "new-value"

# Verifizieren:
gh secret list

# In Workflows testen:
gh workflow run setup-validation.yml
```

#### Lokale vs. CI Secrets

**Lokal (.env):**
- Für lokale Entwicklung und Tests
- **NIEMALS** committen (bereits in .gitignore)
- Verwenden Sie `source .env` zum Laden

**CI (GitHub Secrets):**
- Für GitHub Actions Workflows
- Sicher verschlüsselt
- Zugriff nur via `${{ secrets.SECRET_NAME }}`

---

### Workflow-Übersicht {#workflow-übersicht-de}

#### 1. Setup Validation Workflow

**Datei:** `.github/workflows/setup-validation.yml`

**Trigger:**
- Push zu `main` oder `develop`
- Pull Requests zu `main` oder `develop`
- Manuell via `workflow_dispatch`

**Zweck:**
Validiert Repository-Struktur und erforderliche Dateien

**Jobs:**
```yaml
validate:
  - Check required files
  - Validate directory structure
  - Check secrets availability
  - Validate workflow files
  - Report status
```

**Verwendung:**
```bash
# Manuell ausführen:
gh workflow run setup-validation.yml

# Status prüfen:
gh run list --workflow=setup-validation.yml
```

#### 2. Security Scan Workflow

**Datei:** `.github/workflows/security-scan.yml`

**Trigger:**
- Push zu `main` oder `develop`
- Pull Requests
- Wöchentlich (Sonntags, 00:00 UTC)
- Manuell

**Jobs:**

**CodeQL Analysis:**
- Sprachen: JavaScript, Python
- Automatischer Build
- SARIF-Upload für Security-Tab

**Snyk Security Scan:**
- Dependency-Schwachstellen
- Severity-Threshold: High
- SARIF-Upload

**Dependency Scanning:**
- Dependency Review für PRs
- npm audit (Node.js)
- Safety check (Python)

**Secret Detection:**
- TruffleHog (verified secrets)
- Gitleaks (git history)

**Verwendung:**
```bash
# Manuell ausführen:
gh workflow run security-scan.yml

# Ergebnisse prüfen:
# GitHub → Security → Code scanning alerts
```

#### 3. Code Quality Workflow

**Datei:** `.github/workflows/code-quality.yml`

**Trigger:**
- Push zu `main` oder `develop`
- Pull Requests
- Manuell

**Jobs:**

**Codacy Analysis:**
- Statische Code-Analyse
- Upload zu Codacy Dashboard

**Code Coverage:**
- Test-Ausführung mit Coverage
- Upload zu Codecov
- Coverage-Reports in PRs

**CodeFactor Analysis:**
- Automatisch auf codefactor.io
- Qualitäts-Scoring

**Linting & Formatting:**
- ESLint (JavaScript/TypeScript)
- Prettier (Formatierung)

**ShellCheck:**
- Shell-Skript-Validierung
- Severity: Warning

**Verwendung:**
```bash
# Lokal testen:
npm run lint
npm run format:check
npm run test -- --coverage

# CI ausführen:
gh workflow run code-quality.yml
```

#### 4. AI Review Workflow

**Datei:** `.github/workflows/ai-review.yml`

**Trigger:**
- Pull Requests (opened, synchronize, reopened)
- Manuell

**Jobs:**

**CodeRabbit Review:**
- Automatische PR-Analyse
- Inline-Kommentare
- Best Practice Empfehlungen

**CodiumAI PR Agent:**
- Test-Generierung
- Code-Verbesserungen
- PR-Zusammenfassungen

**Verwendung:**
```bash
# Workflows laufen automatisch bei PR-Erstellung
# Prüfen Sie PR-Kommentare für Feedback

# In PR-Kommentaren:
/review    # CodeRabbit: Vollständiges Review
/improve   # CodiumAI: Verbesserungen
/test      # CodiumAI: Test-Vorschläge
```

#### 5. MCP Health Check Workflow

**Datei:** `.github/workflows/mcp-health-check.yml`

**Trigger:**
- Push zu `main` oder `develop`
- Alle 6 Stunden (Schedule)
- Manuell

**Zweck:**
Überwacht MCP Server-Konfiguration und -Gesundheit

**Jobs:**
- Check MCP configuration file
- Validate JSON structure
- Test server connections (config only)
- Generate health report
- Upload logs

**Verwendung:**
```bash
# Lokal testen:
cat mcp/config.json | jq .

# MCP Server manuell testen:
npx @modelcontextprotocol/server-filesystem /path/to/repo

# Workflow ausführen:
gh workflow run mcp-health-check.yml
```

#### 6. Drift Check Workflow

**Datei:** `.github/workflows/drift-check.yml`

**Trigger:**
- Push zu `main` oder `develop`
- Täglich (02:00 UTC)
- Manuell

**Zweck:**
Erkennt Abweichungen in Repository-Konfiguration

**Jobs:**
- Check expected files presence
- Validate workflow configurations
- Check branch protection config
- Validate secrets template
- Generate drift report

**Verwendung:**
```bash
# Manuell ausführen:
gh workflow run drift-check.yml

# Ergebnisse prüfen:
gh run view --log
```

#### 7. Commit Validation Workflow

**Datei:** `.github/workflows/commit-validation.yml`

**Trigger:**
- Pull Requests (opened, synchronize, reopened)
- Manuell

**Jobs:**

**Conventional Commits:**
- Validiert Commit-Nachrichten-Format
- Erzwingt Conventional Commits Standard
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

**PR Validation:**
- Validiert PR-Titel
- Prüft PR-Beschreibung
- Checkt Issue-Referenzen

**Verwendung:**
```bash
# Gültige Commit-Nachrichten:
git commit -m "feat(auth): add login functionality"
git commit -m "fix(api): resolve null pointer exception"
git commit -m "docs: update README"

# Ungültige Commits werden abgelehnt:
git commit -m "updated stuff"  # ❌
```

#### 8. Sandbox Test Workflow

**Datei:** `.github/workflows/sandbox-test.yml`

**Trigger:**
- Push zu `sandbox/test` oder `sandbox/**` Branches
- Manuell

**Zweck:**
Testet Marketplace Apps Integration in isolierter Umgebung

**Jobs:**

**Marketplace Apps Test:**
- Test CodeQL setup
- Test Snyk integration
- Test Codecov integration
- Test Codacy integration
- Test Scripts execution
- Test Environment validation
- Test MCP configuration
- Test OpenCode agents

**Integration Test:**
- Run integration tests
- Generate test summary

**Verwendung:**
```bash
# Sandbox-Branch erstellen:
git checkout -b sandbox/test-integration
git push origin sandbox/test-integration

# Workflow läuft automatisch
gh run watch
```

---

### Häufige Aufgaben {#häufige-aufgaben-de}

#### Feature entwickeln

```bash
# 1. Feature-Branch erstellen
git checkout -b feat/new-feature

# 2. Änderungen machen
# ... Code schreiben ...

# 3. Committen (Conventional Commits!)
git add .
git commit -m "feat(component): add new feature"

# 4. Push und PR erstellen
git push -u origin feat/new-feature
gh pr create \
  --title "feat(component): add new feature" \
  --body "Description of the feature"

# 5. Workflows abwarten
gh pr checks

# 6. Review-Kommentare bearbeiten
# Antworten Sie auf CodeRabbit/CodiumAI

# 7. Mergen nach Approval
gh pr merge --squash
```

#### Bug fixen

```bash
# 1. Bug-Branch erstellen
git checkout -b fix/bug-description

# 2. Bug fixen
# ... Code ändern ...

# 3. Tests hinzufügen
# ... Test schreiben ...

# 4. Committen
git commit -m "fix(module): resolve bug description"

# 5. PR erstellen
gh pr create \
  --title "fix(module): resolve bug description" \
  --body "Fixes #123\n\nDescription of the fix"

# 6. Mergen
gh pr merge --squash
```

#### Dokumentation aktualisieren

```bash
# 1. Docs-Branch
git checkout -b docs/update-readme

# 2. Dokumentation bearbeiten
# ... Markdown ändern ...

# 3. Committen
git commit -m "docs: update README with new instructions"

# 4. PR (überspringt viele Checks)
gh pr create --title "docs: update README"

# 5. Mergen
gh pr merge --squash
```

#### Dependencies aktualisieren

```bash
# Manuelles Update:
npm update
npm audit fix

# Oder warten auf Dependabot PR:
# 1. Dependabot erstellt automatisch PR
# 2. Prüfen Sie Changelog
# 3. Warten auf Tests
# 4. Mergen:
gh pr merge --auto --squash {pr-number}

# Dependabot-Befehle in PR-Kommentaren:
@dependabot rebase
@dependabot merge
```

#### Workflow debuggen

```bash
# Workflow-Liste anzeigen:
gh workflow list

# Letzten Run prüfen:
gh run list --workflow=workflow-name.yml --limit=1

# Run-Details anzeigen:
gh run view {run-id}

# Logs anzeigen:
gh run view {run-id} --log

# Workflow manuell ausführen:
gh workflow run workflow-name.yml

# Run abbrechen:
gh run cancel {run-id}

# Workflow neu ausführen:
gh run rerun {run-id}
```

#### Secrets verwalten

```bash
# Alle Secrets auflisten:
gh secret list

# Secret setzen:
gh secret set SECRET_NAME

# Secret aus Datei setzen:
gh secret set SECRET_NAME < secret.txt

# Secret löschen:
gh secret delete SECRET_NAME

# Secret für Environment setzen:
gh secret set SECRET_NAME --env production
```

#### Branch Protection testen

```bash
# Versuchen Sie direkten Push zu main:
git push origin main
# Sollte abgelehnt werden: "required status checks"

# Versuchen Sie PR ohne Beschreibung:
gh pr create --title "test" --body ""
# Sollte fehlschlagen: "PR description is empty"

# Versuchen Sie ungültige Commit-Nachricht:
git commit -m "bad message"
# Sollte abgelehnt werden: "Invalid commit message format"
```

---

### Fehlerbehebung {#fehlerbehebung-de}

#### Workflow schlägt fehl

**Problem: "Secret not found"**
```bash
# Lösung: Secret setzen
gh secret set SECRET_NAME --body "value"

# Verifizieren:
gh secret list

# Workflow neu ausführen:
gh run rerun {run-id}
```

**Problem: "Rate limit exceeded"**
```bash
# Prüfen Sie Rate Limit:
gh api rate_limit

# Lösung: Warten Sie bis Reset
# Oder verwenden Sie GitHub App Token statt PAT
```

**Problem: "Workflow file is invalid"**
```bash
# Validieren Sie YAML-Syntax:
cat .github/workflows/workflow.yml | yq .

# Oder online:
# https://www.yamllint.com/
```

#### Git Hooks

**Problem: Hook wird nicht ausgeführt**
```bash
# Prüfen Sie Hook-Berechtigungen:
ls -la .git/hooks/

# Hook ausführbar machen:
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

# Hook neu installieren:
./scripts/local-setup.sh
```

**Problem: Hook schlägt fehl**
```bash
# Debug-Modus:
bash -x .git/hooks/pre-commit

# Temporär umgehen (NICHT empfohlen):
git commit --no-verify -m "message"
```

#### Marketplace Apps

**Problem: App kommentiert nicht auf PR**
```bash
# Lösung 1: Prüfen Sie Installation
# GitHub → Settings → Integrations → Applications

# Lösung 2: Prüfen Sie Berechtigungen
# App benötigt Zugriff auf Repository und PRs

# Lösung 3: Trigger manuell
# Schließen und wiedereröffnen Sie PR:
gh pr close {pr-number}
gh pr reopen {pr-number}
```

**Problem: Codecov - Coverage wird nicht hochgeladen**
```bash
# Prüfen Sie Coverage-Datei:
ls -la coverage/lcov.info

# Verifizieren Sie Token:
gh secret list | grep CODECOV

# Workflow-Logs prüfen:
gh run view {run-id} --log | grep codecov
```

**Problem: Snyk - Authentication failed**
```bash
# Token neu generieren:
# https://app.snyk.io/account → API Token → Generate

# Secret neu setzen:
gh secret set SNYK_TOKEN --body "new-token"

# Test lokal:
snyk auth
snyk test
```

#### Branch Protection

**Problem: "Required status checks failing"**
```bash
# Liste failed checks:
gh pr checks {pr-number}

# Logs für failed job:
gh run view {run-id} --log

# Fix und push:
git commit -m "fix: resolve failing tests"
git push
```

**Problem: "Required reviewers not met"**
```bash
# Prüfen Sie Branch Protection Settings:
# GitHub → Settings → Branches → main

# Request Review:
gh pr review {pr-number} --request @reviewer
```

#### MCP Server

**Problem: MCP config validation fails**
```bash
# Validate JSON:
cat mcp/config.json | jq .

# Check syntax errors
jq . mcp/config.json

# Test MCP server locally:
npx @modelcontextprotocol/server-filesystem $(pwd)
```

#### Allgemeine Probleme

**Problem: Änderungen werden nicht erkannt**
```bash
# Git status prüfen:
git status

# Stellen Sie sicher, dass Dateien staged sind:
git add .

# Prüfen Sie .gitignore:
cat .gitignore
```

**Problem: Merge-Konflikte**
```bash
# Update Branch:
git checkout main
git pull
git checkout your-branch
git merge main

# Konflikte lösen:
git status  # Zeigt konflikt-Dateien
# Bearbeiten Sie Dateien manuell
git add resolved-file
git commit -m "fix: resolve merge conflicts"
```

---

## English Version

### 📋 Table of Contents

1. [Prerequisites](#prerequisites-en)
2. [Quick Start](#quick-start-en)
3. [Local Development Setup](#local-development-setup-en)
4. [CI/CD Setup](#cicd-setup-en)
5. [Secrets Management](#secrets-management-en)
6. [Workflow Overview](#workflow-overview-en)
7. [Common Tasks](#common-tasks-en)
8. [Troubleshooting](#troubleshooting-en)

---

### Prerequisites {#prerequisites-en}

#### Required Software

**Git & GitHub CLI:**
```bash
# Install Git (minimum version 2.30+)
# Windows: https://git-scm.com/download/win
# macOS: brew install git
# Linux: apt-get install git

# Install GitHub CLI
# Windows: https://cli.github.com/
# macOS: brew install gh
# Linux: (wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null) && sudo apt install gh
```

**Node.js & npm:**
```bash
# Node.js 20.x or higher
# Download: https://nodejs.org/

# Verify:
node --version  # Should be v20.x.x or higher
npm --version   # Should be 10.x.x or higher
```

**Python (Optional):**
```bash
# Python 3.11 or higher for Python-based tools
# Download: https://www.python.org/downloads/

# Verify:
python3 --version  # Should be 3.11.x or higher
pip3 --version
```

**Additional Tools:**
```bash
# jq - JSON processor (recommended)
# Windows: choco install jq
# macOS: brew install jq
# Linux: apt-get install jq

# ShellCheck - Shell script linter (optional)
# Windows: choco install shellcheck
# macOS: brew install shellcheck
# Linux: apt-get install shellcheck

# Docker (optional for container tests)
# Download: https://www.docker.com/products/docker-desktop
```

#### GitHub Permissions

You need:
- 🔑 GitHub account with admin access to repository
- 📝 Permission to create secrets
- ⚙️ Permission to configure branch protection rules
- 🔄 Permission to install GitHub Apps

#### Marketplace Apps Accounts

Create accounts at:
- [Snyk](https://app.snyk.io/) - Security scanning
- [Codecov](https://codecov.io/) - Test coverage
- [Codacy](https://app.codacy.com/) - Code quality
- [CodeRabbit](https://coderabbit.ai/) - AI code review (optional)
- [CodiumAI](https://www.codium.ai/) - AI test generation (optional)

---

### Quick Start {#quick-start-en}

**Complete setup in 5 minutes:**

```bash
# 1. Clone repository
git clone https://github.com/your-org/setup.git
cd setup

# 2. Run local setup
chmod +x scripts/local-setup.sh
./scripts/local-setup.sh

# 3. Configure secrets (see .env file)
cp .github/secrets-template.env .env
# Fill .env with your API keys

# 4. Install marketplace apps
chmod +x scripts/setup-marketplace-apps.sh
./scripts/setup-marketplace-apps.sh

# 5. Initial validation
chmod +x scripts/validate-environment.sh
./scripts/validate-environment.sh
```

✅ **Done!** Your local environment is set up.

---

### Local Development Setup {#local-development-setup-en}

#### 1. Repository Setup

```bash
# Clone repository
git clone https://github.com/your-org/setup.git
cd setup

# Check structure
ls -la
# Expected folders:
# - .github/workflows  → CI/CD workflows
# - .github/hooks      → Git hooks
# - scripts/           → Setup scripts
# - .opencode/agents/  → OpenCode agent configuration
# - mcp/               → MCP server configuration
# - docs/              → Documentation
```

#### 2. Run Local Setup Script

The setup script automatically configures:
- Git hooks (pre-commit, commit-msg)
- Local environment variables
- Node.js dependencies (if package.json present)
- Python dependencies (if requirements.txt present)

```bash
# Make script executable
chmod +x scripts/local-setup.sh

# Run setup
./scripts/local-setup.sh

# Output:
# ==================================
# 🚀 Local Development Setup
# ==================================
#
# Repository root: /path/to/setup
#
# 📌 Installing Git hooks...
# ✅ Installed pre-commit hook
# ✅ Installed commit-msg hook
#
# ... more steps ...
#
# ✅ Local setup complete!
```

#### 3. Git Hooks Configured

After setup, the following hooks are active:

**Pre-Commit Hook:**
- Checks for accidentally committed secrets
- Validates code formatting
- Runs linting (if configured)
- Runs ShellCheck for shell scripts

**Commit-Msg Hook:**
- Enforces Conventional Commits format
- Validates commit message structure
- Example: `feat(auth): add login functionality`

```bash
# Test hooks
git add .
git commit -m "test: validate hooks"
# ✅ Commit message follows Conventional Commits format

# Invalid commit will be rejected:
git commit -m "bad commit message"
# ❌ Invalid commit message format
```

#### 4. Configure Environment Variables

```bash
# .env file was automatically created from template
cat .env

# Fill in the following values:
SNYK_TOKEN=your-snyk-token-here
CODECOV_TOKEN=your-codecov-token-here
CODACY_PROJECT_TOKEN=your-codacy-token-here
GITHUB_TOKEN=your-github-pat-here
# ... see Secrets Management for details
```

#### 5. VS Code Extensions (Recommended)

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "github.copilot",
    "github.vscode-pull-request-github",
    "ms-vscode.vscode-typescript-next",
    "timonwong.shellcheck",
    "github.vscode-github-actions"
  ]
}
```

Save this in `.vscode/extensions.json` (created automatically).

---

### CI/CD Setup {#cicd-setup-en}

#### 1. Set Up Repository in GitHub

```bash
# Ensure you're in repository folder
cd setup

# Add remote (if not already done)
git remote add origin https://github.com/your-org/setup.git

# Initial push
git add .
git commit -m "feat: initial repository setup"
git push -u origin main
```

#### 2. Configure GitHub Secrets

**Manual configuration via GitHub UI:**
1. Go to `Settings → Secrets and variables → Actions`
2. Click `New repository secret`
3. Add each secret from the list

**Automatic configuration via GitHub CLI:**
```bash
# Authenticate GitHub CLI
gh auth login

# Set secrets from .env file (ensure .env is filled)
source .env

# Set secrets individually
gh secret set SNYK_TOKEN --body "$SNYK_TOKEN"
gh secret set CODECOV_TOKEN --body "$CODECOV_TOKEN"
gh secret set CODACY_PROJECT_TOKEN --body "$CODACY_PROJECT_TOKEN"
gh secret set GITHUB_TOKEN --body "$GITHUB_TOKEN"
gh secret set OPENAI_API_KEY --body "$OPENAI_API_KEY"
gh secret set ANTHROPIC_API_KEY --body "$ANTHROPIC_API_KEY"

# Optional:
gh secret set WAKATIME_API_KEY --body "$WAKATIME_API_KEY"
gh secret set BRAVE_API_KEY --body "$BRAVE_API_KEY"

# Verify
gh secret list
```

**Secrets List:**
| Secret Name | Required | Purpose |
|------------|----------|---------|
| `SNYK_TOKEN` | ✅ Yes | Security scanning |
| `CODECOV_TOKEN` | ✅ Yes | Test coverage reporting |
| `CODACY_PROJECT_TOKEN` | ✅ Yes | Code quality analysis |
| `GITHUB_TOKEN` | ✅ Yes (Auto) | GitHub API access |
| `OPENAI_API_KEY` | ⚠️ Optional | OpenAI integration |
| `ANTHROPIC_API_KEY` | ⚠️ Optional | Claude AI integration |
| `WAKATIME_API_KEY` | ⚠️ Optional | Time tracking |
| `BRAVE_API_KEY` | ⚠️ Optional | MCP Brave Search |

#### 3. Install GitHub Apps

```bash
# Run setup script
chmod +x scripts/setup-marketplace-apps.sh
./scripts/setup-marketplace-apps.sh

# Script guides you through installing:
# 1. CodeRabbit AI
# 2. CodiumAI PR Agent
# 3. CodeFactor
# 4. Codacy
# 5. Codecov
# 6. Snyk
# 7. Dependabot (already enabled)
```

See [RECOMMENDED_MARKETPLACE_APPS.md](./RECOMMENDED_MARKETPLACE_APPS.md) for detailed installation instructions.

#### 4. Set Up Branch Protection Rules

**Via GitHub UI:**
1. `Settings → Branches → Add rule`
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Require conversation resolution before merging
   - ✅ Require linear history
   - ✅ Include administrators

**Via GitHub CLI (with config file):**
```bash
# Branch protection for main
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  repos/{owner}/{repo}/branches/main/protection \
  --input .github/branch-protection.json

# For develop branch with reduced requirements
# Adjust .github/branch-protection.json accordingly
```

**Required Status Checks for main:**
- `setup-validation`
- `security-scan / CodeQL Analysis (javascript)`
- `security-scan / CodeQL Analysis (python)`
- `security-scan / Snyk Security Scan`
- `security-scan / Dependency Scanning`
- `security-scan / Secret Detection`
- `code-quality / Codacy Analysis`
- `code-quality / Code Coverage`
- `code-quality / Linting & Formatting`
- `code-quality / ShellCheck`
- `ai-review / CodeRabbit Review`
- `ai-review / CodiumAI PR Agent`
- `mcp-health-check / MCP Server Health Monitoring`
- `drift-check / Infrastructure Drift Detection`
- `commit-validation / Validate Conventional Commits`
- `commit-validation / PR Title & Description Check`

#### 5. Test Workflows

```bash
# Create test branch
git checkout -b test/workflow-validation

# Make change
echo "# Test" >> test.md
git add test.md
git commit -m "test: validate CI/CD workflows"

# Push and create PR
git push -u origin test/workflow-validation
gh pr create --title "test: validate CI/CD workflows" --body "Testing workflow integration"

# Monitor workflows
gh pr checks
# Or via UI: Pull Requests → Your PR → Checks tab
```

---

### Secrets Management {#secrets-management-en}

#### Understanding Secrets Template

The file `.github/secrets-template.env` lists all required secrets:

```bash
cat .github/secrets-template.env

# Categories:
# 1. Security Scanning Tokens (Snyk, Codecov, Codacy)
# 2. Development Analytics (WakaTime)
# 3. GitHub Integration (GITHUB_TOKEN)
# 4. AI Agent Integration (OpenAI, Anthropic)
# 5. MCP Server Integration (Brave Search)
# 6. Additional Services (Sentry, DataDog, Slack)
```

#### Securely Retrieve Secrets

**Snyk Token:**
```bash
# 1. Go to https://app.snyk.io/account
# 2. Scroll to "API Token"
# 3. Click "Show" or generate new token
# 4. Copy token

# Set:
gh secret set SNYK_TOKEN --body "snyk-token-here"
```

**Codecov Token:**
```bash
# 1. Go to https://codecov.io/
# 2. Select your repository
# 3. Settings → General → Repository Upload Token
# 4. Copy token

gh secret set CODECOV_TOKEN --body "codecov-token-here"
```

**Codacy Project Token:**
```bash
# 1. Go to https://app.codacy.com/
# 2. Select your repository
# 3. Settings → Integrations → Project API
# 4. Generate or copy token

gh secret set CODACY_PROJECT_TOKEN --body "codacy-token-here"
```

**GitHub Personal Access Token:**
```bash
# 1. Go to https://github.com/settings/tokens
# 2. Generate new token (classic)
# 3. Select scopes:
#    ✅ repo (Full control of private repositories)
#    ✅ workflow (Update GitHub Action workflows)
#    ✅ write:packages (Upload packages)
# 4. Generate token
# 5. Copy immediately (shown only once!)

gh secret set GITHUB_TOKEN --body "ghp_xxxxxxxxxxxx"
```

**OpenAI API Key (Optional):**
```bash
# 1. Go to https://platform.openai.com/api-keys
# 2. Create new secret key
# 3. Name: "Enterprise Setup"
# 4. Copy key

gh secret set OPENAI_API_KEY --body "sk-xxxxxxxxxxxx"
```

**Anthropic API Key (Optional):**
```bash
# 1. Go to https://console.anthropic.com/
# 2. Settings → API Keys
# 3. Create Key
# 4. Copy key

gh secret set ANTHROPIC_API_KEY --body "sk-ant-xxxxxxxxxxxx"
```

#### Rotate Secrets

```bash
# Best practice: Rotate secrets every 90 days

# Update secret:
gh secret set SECRET_NAME --body "new-value"

# Verify:
gh secret list

# Test in workflows:
gh workflow run setup-validation.yml
```

#### Local vs. CI Secrets

**Local (.env):**
- For local development and testing
- **NEVER** commit (already in .gitignore)
- Use `source .env` to load

**CI (GitHub Secrets):**
- For GitHub Actions workflows
- Securely encrypted
- Access via `${{ secrets.SECRET_NAME }}` only

---

### Workflow Overview {#workflow-overview-en}

#### 1. Setup Validation Workflow

**File:** `.github/workflows/setup-validation.yml`

**Triggers:**
- Push to `main` or `develop`
- Pull requests to `main` or `develop`
- Manual via `workflow_dispatch`

**Purpose:**
Validates repository structure and required files

**Jobs:**
```yaml
validate:
  - Check required files
  - Validate directory structure
  - Check secrets availability
  - Validate workflow files
  - Report status
```

**Usage:**
```bash
# Run manually:
gh workflow run setup-validation.yml

# Check status:
gh run list --workflow=setup-validation.yml
```

#### 2. Security Scan Workflow

**File:** `.github/workflows/security-scan.yml`

**Triggers:**
- Push to `main` or `develop`
- Pull requests
- Weekly (Sundays, 00:00 UTC)
- Manual

**Jobs:**

**CodeQL Analysis:**
- Languages: JavaScript, Python
- Automatic build
- SARIF upload for Security tab

**Snyk Security Scan:**
- Dependency vulnerabilities
- Severity threshold: High
- SARIF upload

**Dependency Scanning:**
- Dependency review for PRs
- npm audit (Node.js)
- Safety check (Python)

**Secret Detection:**
- TruffleHog (verified secrets)
- Gitleaks (git history)

**Usage:**
```bash
# Run manually:
gh workflow run security-scan.yml

# Check results:
# GitHub → Security → Code scanning alerts
```

#### 3. Code Quality Workflow

**File:** `.github/workflows/code-quality.yml`

**Triggers:**
- Push to `main` or `develop`
- Pull requests
- Manual

**Jobs:**

**Codacy Analysis:**
- Static code analysis
- Upload to Codacy dashboard

**Code Coverage:**
- Test execution with coverage
- Upload to Codecov
- Coverage reports in PRs

**CodeFactor Analysis:**
- Automatic on codefactor.io
- Quality scoring

**Linting & Formatting:**
- ESLint (JavaScript/TypeScript)
- Prettier (formatting)

**ShellCheck:**
- Shell script validation
- Severity: Warning

**Usage:**
```bash
# Test locally:
npm run lint
npm run format:check
npm run test -- --coverage

# Run CI:
gh workflow run code-quality.yml
```

#### 4. AI Review Workflow

**File:** `.github/workflows/ai-review.yml`

**Triggers:**
- Pull requests (opened, synchronize, reopened)
- Manual

**Jobs:**

**CodeRabbit Review:**
- Automatic PR analysis
- Inline comments
- Best practice recommendations

**CodiumAI PR Agent:**
- Test generation
- Code improvements
- PR summaries

**Usage:**
```bash
# Workflows run automatically on PR creation
# Check PR comments for feedback

# In PR comments:
/review    # CodeRabbit: Full review
/improve   # CodiumAI: Improvements
/test      # CodiumAI: Test suggestions
```

#### 5. MCP Health Check Workflow

**File:** `.github/workflows/mcp-health-check.yml`

**Triggers:**
- Push to `main` or `develop`
- Every 6 hours (schedule)
- Manual

**Purpose:**
Monitors MCP server configuration and health

**Jobs:**
- Check MCP configuration file
- Validate JSON structure
- Test server connections (config only)
- Generate health report
- Upload logs

**Usage:**
```bash
# Test locally:
cat mcp/config.json | jq .

# Test MCP server manually:
npx @modelcontextprotocol/server-filesystem /path/to/repo

# Run workflow:
gh workflow run mcp-health-check.yml
```

#### 6. Drift Check Workflow

**File:** `.github/workflows/drift-check.yml`

**Triggers:**
- Push to `main` or `develop`
- Daily (02:00 UTC)
- Manual

**Purpose:**
Detects deviations in repository configuration

**Jobs:**
- Check expected files presence
- Validate workflow configurations
- Check branch protection config
- Validate secrets template
- Generate drift report

**Usage:**
```bash
# Run manually:
gh workflow run drift-check.yml

# Check results:
gh run view --log
```

#### 7. Commit Validation Workflow

**File:** `.github/workflows/commit-validation.yml`

**Triggers:**
- Pull requests (opened, synchronize, reopened)
- Manual

**Jobs:**

**Conventional Commits:**
- Validates commit message format
- Enforces Conventional Commits standard
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

**PR Validation:**
- Validates PR title
- Checks PR description
- Checks issue references

**Usage:**
```bash
# Valid commit messages:
git commit -m "feat(auth): add login functionality"
git commit -m "fix(api): resolve null pointer exception"
git commit -m "docs: update README"

# Invalid commits will be rejected:
git commit -m "updated stuff"  # ❌
```

#### 8. Sandbox Test Workflow

**File:** `.github/workflows/sandbox-test.yml`

**Triggers:**
- Push to `sandbox/test` or `sandbox/**` branches
- Manual

**Purpose:**
Tests marketplace apps integration in isolated environment

**Jobs:**

**Marketplace Apps Test:**
- Test CodeQL setup
- Test Snyk integration
- Test Codecov integration
- Test Codacy integration
- Test Scripts execution
- Test Environment validation
- Test MCP configuration
- Test OpenCode agents

**Integration Test:**
- Run integration tests
- Generate test summary

**Usage:**
```bash
# Create sandbox branch:
git checkout -b sandbox/test-integration
git push origin sandbox/test-integration

# Workflow runs automatically
gh run watch
```

---

### Common Tasks {#common-tasks-en}

#### Develop Feature

```bash
# 1. Create feature branch
git checkout -b feat/new-feature

# 2. Make changes
# ... write code ...

# 3. Commit (Conventional Commits!)
git add .
git commit -m "feat(component): add new feature"

# 4. Push and create PR
git push -u origin feat/new-feature
gh pr create \
  --title "feat(component): add new feature" \
  --body "Description of the feature"

# 5. Wait for workflows
gh pr checks

# 6. Address review comments
# Respond to CodeRabbit/CodiumAI

# 7. Merge after approval
gh pr merge --squash
```

#### Fix Bug

```bash
# 1. Create bug branch
git checkout -b fix/bug-description

# 2. Fix bug
# ... change code ...

# 3. Add tests
# ... write test ...

# 4. Commit
git commit -m "fix(module): resolve bug description"

# 5. Create PR
gh pr create \
  --title "fix(module): resolve bug description" \
  --body "Fixes #123\n\nDescription of the fix"

# 6. Merge
gh pr merge --squash
```

#### Update Documentation

```bash
# 1. Docs branch
git checkout -b docs/update-readme

# 2. Edit documentation
# ... change markdown ...

# 3. Commit
git commit -m "docs: update README with new instructions"

# 4. PR (skips many checks)
gh pr create --title "docs: update README"

# 5. Merge
gh pr merge --squash
```

#### Update Dependencies

```bash
# Manual update:
npm update
npm audit fix

# Or wait for Dependabot PR:
# 1. Dependabot creates PR automatically
# 2. Review changelog
# 3. Wait for tests
# 4. Merge:
gh pr merge --auto --squash {pr-number}

# Dependabot commands in PR comments:
@dependabot rebase
@dependabot merge
```

#### Debug Workflow

```bash
# List workflows:
gh workflow list

# Check last run:
gh run list --workflow=workflow-name.yml --limit=1

# View run details:
gh run view {run-id}

# View logs:
gh run view {run-id} --log

# Run workflow manually:
gh workflow run workflow-name.yml

# Cancel run:
gh run cancel {run-id}

# Rerun workflow:
gh run rerun {run-id}
```

#### Manage Secrets

```bash
# List all secrets:
gh secret list

# Set secret:
gh secret set SECRET_NAME

# Set secret from file:
gh secret set SECRET_NAME < secret.txt

# Delete secret:
gh secret delete SECRET_NAME

# Set secret for environment:
gh secret set SECRET_NAME --env production
```

#### Test Branch Protection

```bash
# Try direct push to main:
git push origin main
# Should be rejected: "required status checks"

# Try PR without description:
gh pr create --title "test" --body ""
# Should fail: "PR description is empty"

# Try invalid commit message:
git commit -m "bad message"
# Should be rejected: "Invalid commit message format"
```

---

### Troubleshooting {#troubleshooting-en}

#### Workflow Fails

**Issue: "Secret not found"**
```bash
# Solution: Set secret
gh secret set SECRET_NAME --body "value"

# Verify:
gh secret list

# Rerun workflow:
gh run rerun {run-id}
```

**Issue: "Rate limit exceeded"**
```bash
# Check rate limit:
gh api rate_limit

# Solution: Wait until reset
# Or use GitHub App token instead of PAT
```

**Issue: "Workflow file is invalid"**
```bash
# Validate YAML syntax:
cat .github/workflows/workflow.yml | yq .

# Or online:
# https://www.yamllint.com/
```

#### Git Hooks

**Issue: Hook not executing**
```bash
# Check hook permissions:
ls -la .git/hooks/

# Make hook executable:
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

# Reinstall hook:
./scripts/local-setup.sh
```

**Issue: Hook fails**
```bash
# Debug mode:
bash -x .git/hooks/pre-commit

# Temporarily bypass (NOT recommended):
git commit --no-verify -m "message"
```

#### Marketplace Apps

**Issue: App not commenting on PR**
```bash
# Solution 1: Check installation
# GitHub → Settings → Integrations → Applications

# Solution 2: Check permissions
# App needs access to repository and PRs

# Solution 3: Trigger manually
# Close and reopen PR:
gh pr close {pr-number}
gh pr reopen {pr-number}
```

**Issue: Codecov - Coverage not uploading**
```bash
# Check coverage file:
ls -la coverage/lcov.info

# Verify token:
gh secret list | grep CODECOV

# Check workflow logs:
gh run view {run-id} --log | grep codecov
```

**Issue: Snyk - Authentication failed**
```bash
# Regenerate token:
# https://app.snyk.io/account → API Token → Generate

# Reset secret:
gh secret set SNYK_TOKEN --body "new-token"

# Test locally:
snyk auth
snyk test
```

#### Branch Protection

**Issue: "Required status checks failing"**
```bash
# List failed checks:
gh pr checks {pr-number}

# Logs for failed job:
gh run view {run-id} --log

# Fix and push:
git commit -m "fix: resolve failing tests"
git push
```

**Issue: "Required reviewers not met"**
```bash
# Check branch protection settings:
# GitHub → Settings → Branches → main

# Request review:
gh pr review {pr-number} --request @reviewer
```

#### MCP Server

**Issue: MCP config validation fails**
```bash
# Validate JSON:
cat mcp/config.json | jq .

# Check syntax errors
jq . mcp/config.json

# Test MCP server locally:
npx @modelcontextprotocol/server-filesystem $(pwd)
```

#### General Issues

**Issue: Changes not detected**
```bash
# Check git status:
git status

# Ensure files are staged:
git add .

# Check .gitignore:
cat .gitignore
```

**Issue: Merge conflicts**
```bash
# Update branch:
git checkout main
git pull
git checkout your-branch
git merge main

# Resolve conflicts:
git status  # Shows conflicted files
# Edit files manually
git add resolved-file
git commit -m "fix: resolve merge conflicts"
```

---

## 📚 Additional Resources

- **Architecture Documentation:** [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Marketplace Apps Guide:** [RECOMMENDED_MARKETPLACE_APPS.md](./RECOMMENDED_MARKETPLACE_APPS.md)
- **Secrets Template:** `.github/secrets-template.env`
- **Branch Protection Config:** `.github/branch-protection.json`
- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Conventional Commits:** https://www.conventionalcommits.org/

---

**Last Updated:** 2026-01-02
**Version:** 1.0.0
**Maintained By:** Enterprise Setup Team
