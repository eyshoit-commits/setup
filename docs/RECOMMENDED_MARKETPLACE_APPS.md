# Empfohlene GitHub Marketplace Apps / Recommended GitHub Marketplace Apps

[🇩🇪 Deutsche Version](#deutsche-version) | [🇬🇧 English Version](#english-version)

---

## Deutsche Version

### 📋 Übersicht

Diese Dokumentation beschreibt alle integrierten GitHub Marketplace Apps für das Enterprise Setup Repository. Alle Apps sind vollständig in die CI/CD-Workflows integriert und arbeiten nahtlos zusammen.

### 🎯 Integrierte Apps

1. [CodeRabbit AI Code Review](#1-coderabbit-ai-code-review-de)
2. [CodiumAI PR Agent](#2-codiumai-pr-agent-de)
3. [CodeFactor](#3-codefactor-de)
4. [Codacy](#4-codacy-de)
5. [Codecov](#5-codecov-de)
6. [Snyk](#6-snyk-de)
7. [Dependabot](#7-dependabot-de)

---

### 1. CodeRabbit AI Code Review {#1-coderabbit-ai-code-review-de}

**🤖 KI-gestützte automatische Code-Reviews**

#### Beschreibung
CodeRabbit ist ein KI-gestütztes Code-Review-Tool, das Pull Requests automatisch analysiert und konstruktives Feedback gibt. Es identifiziert potenzielle Bugs, Sicherheitslücken und Code-Qualitätsprobleme.

#### Hauptfunktionen
- 🔍 Automatische Code-Analyse bei jedem PR
- 💬 Inline-Kommentare mit konkreten Verbesserungsvorschlägen
- 🐛 Bug-Erkennung und Sicherheitsanalyse
- 📊 Code-Qualitätsbewertung
- 🔄 Kontinuierliches Lernen aus Feedback
- 🎯 Best Practice Empfehlungen

#### Installation

**Schritt 1: GitHub App installieren**
```bash
# Besuchen Sie
https://github.com/apps/coderabbitai

# Klicken Sie auf "Install"
# Wählen Sie Ihr Repository aus
# Bestätigen Sie die Berechtigungen
```

**Schritt 2: Repository-Konfiguration**
Keine zusätzliche Konfiguration erforderlich. CodeRabbit arbeitet automatisch nach der Installation.

**Schritt 3: Workflow-Integration**
CodeRabbit ist bereits in `.github/workflows/ai-review.yml` integriert:

```yaml
coderabbit:
  name: CodeRabbit Review
  runs-on: ubuntu-latest
  steps:
    - name: CodeRabbit Integration
      run: |
        echo "🐰 CodeRabbit AI Review"
        echo "CodeRabbit automatically reviews PRs"
```

#### Secrets-Konfiguration
Keine zusätzlichen Secrets erforderlich. CodeRabbit verwendet GitHub App-Authentifizierung.

#### Verwendung
1. Erstellen Sie einen Pull Request
2. CodeRabbit analysiert automatisch den Code
3. Prüfen Sie die Kommentare im PR
4. Reagieren Sie auf Vorschläge oder markieren Sie als erledigt

#### Troubleshooting

**Problem: CodeRabbit kommentiert nicht**
```bash
# Lösung 1: Prüfen Sie die Installation
# GitHub UI → Settings → Integrations → Applications
# Stellen Sie sicher, dass CodeRabbit installiert ist

# Lösung 2: Prüfen Sie Repository-Berechtigungen
# CodeRabbit benötigt Lese- und Schreibzugriff auf Pull Requests
```

**Problem: Zu viele Kommentare**
```yaml
# Konfigurieren Sie CodeRabbit in .coderabbit.yaml:
reviews:
  high_level_summary: true
  poem: false
  review_status: true
  collapse_walkthrough: false
  auto_review:
    enabled: true
    drafts: false
```

---

### 2. CodiumAI PR Agent {#2-codiumai-pr-agent-de}

**🤖 KI-gesteuerte PR-Analyse und Test-Generierung**

#### Beschreibung
CodiumAI PR Agent analysiert Pull Requests automatisch und generiert Test-Vorschläge, Code-Dokumentation und detaillierte Review-Kommentare.

#### Hauptfunktionen
- 🧪 Automatische Test-Generierung
- 📝 Code-Dokumentations-Vorschläge
- 🔍 Sicherheits- und Qualitätsanalyse
- 💡 Intelligente Verbesserungsvorschläge
- 📊 PR-Zusammenfassungen
- 🎯 Test-Coverage-Analyse

#### Installation

**Schritt 1: GitHub App installieren**
```bash
https://github.com/apps/codiumai-pr-agent
```

**Schritt 2: Repository aktivieren**
Nach der Installation wird CodiumAI automatisch für alle PRs aktiv.

**Schritt 3: Workflow-Integration**
Integration in `.github/workflows/ai-review.yml`:

```yaml
codiumai:
  name: CodiumAI PR Agent
  runs-on: ubuntu-latest
  steps:
    - name: CodiumAI PR Agent Integration
      run: |
        echo "🤖 CodiumAI PR Agent Review"
```

#### Secrets-Konfiguration
Verwendet GitHub App-Authentifizierung. Optional: CODIUMAI_API_KEY für erweiterte Features.

```bash
# Optional: API-Key setzen
gh secret set CODIUMAI_API_KEY --body "your-api-key"
```

#### Verwendung
1. Erstellen Sie einen Pull Request
2. CodiumAI analysiert automatisch
3. Verwenden Sie `/improve` Kommentar für Verbesserungen
4. Verwenden Sie `/test` Kommentar für Test-Vorschläge
5. Verwenden Sie `/describe` für detaillierte Beschreibungen

#### PR-Kommentar-Befehle
```bash
/review       # Vollständiges Code-Review
/improve      # Verbesserungsvorschläge
/test         # Test-Generierung
/describe     # PR-Beschreibung generieren
/ask          # Fragen zum Code stellen
```

#### Troubleshooting

**Problem: CodiumAI reagiert nicht auf Befehle**
```bash
# Stellen Sie sicher, dass der Befehl am Anfang einer neuen Zeile steht
# Beispiel:
/review
# Nicht: "Kannst du /review machen?"
```

---

### 3. CodeFactor {#3-codefactor-de}

**📊 Automatische Code-Qualitätsbewertung**

#### Beschreibung
CodeFactor analysiert kontinuierlich die Code-Qualität und vergibt Bewertungen basierend auf Best Practices, Code-Komplexität und Wartbarkeit.

#### Hauptfunktionen
- 📈 Code-Qualitäts-Scoring (A+ bis F)
- 🔍 Automatische Code-Analyse
- 📊 Qualitäts-Trends über Zeit
- 🎯 Issue-Priorisierung
- 💡 Refactoring-Vorschläge
- 🔄 Kontinuierliches Monitoring

#### Installation

**Schritt 1: Account erstellen**
```bash
# Besuchen Sie
https://www.codefactor.io/

# Melden Sie sich mit GitHub an
# Autorisieren Sie den Zugriff
```

**Schritt 2: Repository hinzufügen**
```bash
# Dashboard → Add Repository
# Wählen Sie Ihr Repository aus
# CodeFactor beginnt automatisch mit der Analyse
```

**Schritt 3: Badge hinzufügen (Optional)**
```markdown
# In README.md:
[![CodeFactor](https://www.codefactor.io/repository/github/your-org/setup/badge)](https://www.codefactor.io/repository/github/your-org/setup)
```

#### Workflow-Integration
Integration in `.github/workflows/code-quality.yml`:

```yaml
codefactor:
  name: CodeFactor Analysis
  runs-on: ubuntu-latest
  steps:
    - name: CodeFactor Analysis
      run: |
        echo "📊 CodeFactor analysis runs automatically"
```

#### Secrets-Konfiguration
Keine Secrets erforderlich. CodeFactor verwendet OAuth-Authentifizierung.

#### Verwendung
1. CodeFactor analysiert automatisch bei jedem Push
2. Prüfen Sie Ergebnisse auf codefactor.io/repository/github/{org}/{repo}
3. Beheben Sie identifizierte Issues
4. Beobachten Sie Qualitäts-Score-Verbesserungen

#### Troubleshooting

**Problem: Keine Analyse-Updates**
```bash
# Lösung: Trigger manuelle Analyse
# CodeFactor Dashboard → Repository → "Reanalyze"
```

---

### 4. Codacy {#4-codacy-de}

**🔍 Code-Qualitätsüberwachung und automatische Reviews**

#### Beschreibung
Codacy ist eine umfassende Code-Qualitätsplattform, die statische Analyse, Security-Checks und Code-Coverage kombiniert.

#### Hauptfunktionen
- 🔍 Statische Code-Analyse
- 🛡️ Security-Schwachstellen-Erkennung
- 📊 Code-Coverage-Tracking
- 💡 Code-Pattern-Erkennung
- 🎯 Technische Schulden-Analyse
- 🔄 PR-Qualitäts-Gates

#### Installation

**Schritt 1: Codacy Account**
```bash
https://app.codacy.com/

# GitHub-Login verwenden
# Organization autorisieren
```

**Schritt 2: Repository hinzufügen**
```bash
# Codacy Dashboard → Add repository
# Wählen Sie Ihr Repository
# Konfigurieren Sie Analyse-Einstellungen
```

**Schritt 3: Project Token generieren**
```bash
# Codacy → Repository → Settings → Integrations → Project API
# Kopieren Sie den Project Token
```

#### Secrets-Konfiguration

**Erforderlich:**
```bash
gh secret set CODACY_PROJECT_TOKEN --body "your-project-token"
```

**Token abrufen:**
1. Codacy Dashboard öffnen
2. Repository → Settings → Integrations
3. Unter "Project API" → "Create token" oder vorhandenen kopieren
4. Token als GitHub Secret speichern

#### Workflow-Integration
In `.github/workflows/code-quality.yml`:

```yaml
codacy:
  name: Codacy Analysis
  runs-on: ubuntu-latest
  steps:
    - name: Run Codacy Analysis
      uses: codacy/codacy-analysis-cli-action@master
      with:
        project-token: ${{ secrets.CODACY_PROJECT_TOKEN }}
        upload: true
```

#### Verwendung
1. Codacy analysiert automatisch bei jedem Push und PR
2. Prüfen Sie Ergebnisse im Codacy Dashboard
3. Reagieren Sie auf PR-Kommentare
4. Verfolgen Sie Qualitäts-Trends

#### Code-Pattern-Konfiguration
```yaml
# .codacy.yml erstellen:
---
engines:
  eslint:
    enabled: true
  shellcheck:
    enabled: true
exclude_paths:
  - 'node_modules/**'
  - 'dist/**'
```

#### Troubleshooting

**Problem: "Project token not found"**
```bash
# Lösung: Secret korrekt setzen
gh secret set CODACY_PROJECT_TOKEN --body "your-actual-token"

# Verifizieren:
gh secret list
```

**Problem: Analyse schlägt fehl**
```bash
# Prüfen Sie .codacy.yml Syntax:
# Validieren Sie unter https://app.codacy.com/
```

---

### 5. Codecov {#5-codecov-de}

**📈 Test-Coverage-Tracking und -Reporting**

#### Beschreibung
Codecov visualisiert Test-Coverage, zeigt nicht getestete Code-Bereiche und verhindert Coverage-Rückgänge durch PR-Checks.

#### Hauptfunktionen
- 📊 Detaillierte Coverage-Reports
- 🎯 Line-by-Line Coverage
- 📈 Coverage-Trends
- 🚫 Coverage-Drop-Prevention
- 💬 PR-Kommentare mit Coverage-Änderungen
- 🔍 Branch- und Commit-Analyse

#### Installation

**Schritt 1: Codecov Account**
```bash
https://codecov.io/

# GitHub-Login
# Repository autorisieren
```

**Schritt 2: Repository aktivieren**
```bash
# Codecov Dashboard → Add new repository
# Wählen Sie Ihr Repository
```

**Schritt 3: Upload Token**
```bash
# Codecov → Repository → Settings → General
# Kopieren Sie "Repository Upload Token"
```

#### Secrets-Konfiguration

**Erforderlich:**
```bash
gh secret set CODECOV_TOKEN --body "your-upload-token"
```

**Token finden:**
1. codecov.io → Ihr Repository
2. Settings → General
3. "Repository Upload Token" kopieren

#### Workflow-Integration
In `.github/workflows/code-quality.yml`:

```yaml
codecov:
  name: Code Coverage
  runs-on: ubuntu-latest
  steps:
    - name: Run tests with coverage
      run: npm run test -- --coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v4
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        files: ./coverage/lcov.info
```

#### Verwendung

**Test-Coverage generieren:**
```bash
# Node.js/Jest:
npm run test -- --coverage

# Python/pytest:
pytest --cov=. --cov-report=xml

# Go:
go test -coverprofile=coverage.out ./...
```

**Coverage-Reports prüfen:**
1. Codecov Dashboard besuchen
2. Neueste Commits prüfen
3. Datei-basierte Coverage anzeigen
4. PR-Kommentare für Coverage-Änderungen prüfen

#### Codecov-Konfiguration
```yaml
# codecov.yml erstellen:
coverage:
  status:
    project:
      default:
        target: 80%
        threshold: 2%
    patch:
      default:
        target: 90%

comment:
  layout: "reach, diff, files"
  behavior: default
```

#### Troubleshooting

**Problem: Coverage wird nicht hochgeladen**
```bash
# Lösung 1: Token verifizieren
gh secret list | grep CODECOV

# Lösung 2: Coverage-Datei prüfen
ls -la coverage/
# Stellen Sie sicher, dass lcov.info existiert

# Lösung 3: Workflow-Logs prüfen
# GitHub Actions → Code Coverage Job → Logs
```

---

### 6. Snyk {#6-snyk-de}

**🔒 Sicherheits-Scanning und Dependency-Monitoring**

#### Beschreibung
Snyk scannt kontinuierlich nach Sicherheitslücken in Dependencies, Container-Images und Code. Es bietet automatische Fix-Vorschläge und PR-Updates.

#### Hauptfunktionen
- 🔍 Dependency-Schwachstellen-Scan
- 🛡️ Security Advisory Monitoring
- 🔄 Automatische Fix-PRs
- 📊 Vulnerability-Priorisierung
- 🎯 License-Compliance-Checks
- 🚨 Real-time Security Alerts

#### Installation

**Schritt 1: Snyk Account**
```bash
https://app.snyk.io/

# GitHub-Login verwenden
# Organisation verbinden
```

**Schritt 2: Repository importieren**
```bash
# Snyk Dashboard → Add project
# Wählen Sie GitHub
# Wählen Sie Repository(s)
# Snyk beginnt ersten Scan
```

**Schritt 3: API Token generieren**
```bash
# Snyk → Account Settings → API Token
# Klicken Sie auf "Show" oder "Generate"
# Kopieren Sie den Token
```

#### Secrets-Konfiguration

**Erforderlich:**
```bash
gh secret set SNYK_TOKEN --body "your-snyk-token"
```

**Token abrufen:**
1. https://app.snyk.io/account öffnen
2. Runterscrollen zu "API Token"
3. Token anzeigen oder neu generieren
4. Als GitHub Secret speichern

#### Workflow-Integration
In `.github/workflows/security-scan.yml`:

```yaml
snyk:
  name: Snyk Security Scan
  runs-on: ubuntu-latest
  steps:
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

#### Verwendung

**CLI-Installation (lokal):**
```bash
# npm:
npm install -g snyk

# Authentifizieren:
snyk auth

# Repository scannen:
snyk test

# Fix-Vorschläge anwenden:
snyk wizard
```

**Severity-Levels:**
- 🔴 Critical: Sofortige Aktion erforderlich
- 🟠 High: Baldige Behebung empfohlen
- 🟡 Medium: Behebung in nächstem Release
- 🔵 Low: Optional, bei Gelegenheit

#### Snyk-Konfiguration
```yaml
# .snyk erstellen:
# Snyk (https://snyk.io) policy file
version: v1.22.1
ignore:
  'npm:package-name:20210101':
    - package-name > vulnerable-dep:
        reason: 'Fix not available yet'
        expires: '2024-12-31'
```

#### Troubleshooting

**Problem: "Authentication failed"**
```bash
# Lösung: Token neu setzen
gh secret set SNYK_TOKEN --body "new-token-from-snyk"

# Verifizieren (lokal):
snyk auth
snyk test
```

**Problem: Zu viele False Positives**
```bash
# .snyk Policy-Datei verwenden
# Bestimmte Vulnerabilities ignorieren
# ACHTUNG: Nur nach sorgfältiger Prüfung!
```

---

### 7. Dependabot {#7-dependabot-de}

**🔄 Automatische Dependency-Updates**

#### Beschreibung
Dependabot ist in GitHub integriert und erstellt automatisch Pull Requests für veraltete Dependencies und Sicherheitsupdates.

#### Hauptfunktionen
- 🔄 Automatische Dependency-Updates
- 🛡️ Security-Advisory-Integration
- 📊 Update-Strategien (weekly, daily, monthly)
- 🎯 Gruppen-Updates
- 🔍 Kompatibilitäts-Checks
- ✅ Auto-Merge bei Tests erfolgreich

#### Installation

**Schritt 1: Dependabot ist bereits aktiviert**
Dependabot ist standardmäßig in GitHub-Repositories aktiviert.

**Schritt 2: Konfiguration**
Erstellen Sie `.github/dependabot.yml`:

```yaml
version: 2
updates:
  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "github-actions"
    
  # npm
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    labels:
      - "dependencies"
      - "npm"
    versioning-strategy: increase
    
  # Python
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "python"
```

#### Secrets-Konfiguration
Keine zusätzlichen Secrets erforderlich. Verwendet automatisch GitHub-Token.

Optional für private Registries:
```bash
gh secret set NPM_TOKEN --body "your-npm-token"
```

#### Workflow-Integration
Dependabot arbeitet unabhängig, aber kann mit Auto-Merge erweitert werden:

```yaml
# .github/workflows/dependabot-auto-merge.yml
name: Dependabot Auto-Merge
on: pull_request

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'
    steps:
      - name: Auto-merge for Dependabot PRs
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{github.event.pull_request.html_url}}
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

#### Verwendung
1. Dependabot erstellt automatisch PRs
2. Prüfen Sie Changelog und Kompatibilität
3. Warten Sie auf erfolgreiche Tests
4. Mergen Sie manuell oder via Auto-Merge

#### Dependabot-Commands (in PR-Kommentaren)
```bash
@dependabot rebase       # PR rebasen
@dependabot recreate     # PR neu erstellen
@dependabot merge        # PR mergen
@dependabot squash       # Squash und merge
@dependabot cancel merge # Merge abbrechen
@dependabot reopen       # PR wiedereröffnen
@dependabot close        # PR schließen
@dependabot ignore       # Version ignorieren
```

#### Troubleshooting

**Problem: Dependabot erstellt keine PRs**
```yaml
# Lösung: Prüfen Sie .github/dependabot.yml
# Stellen Sie sicher, dass:
# 1. Datei korrekt formatiert ist
# 2. package-ecosystem korrekt ist
# 3. directory existiert

# Validieren:
# GitHub UI → Insights → Dependency graph → Dependabot
```

**Problem: Zu viele Dependabot-PRs**
```yaml
# Gruppieren Sie Updates in dependabot.yml:
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"  # Statt "daily"
    groups:
      development-dependencies:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"
```

---

## 🔗 Workflow-Integrationen

### AI Review Workflow
```yaml
# .github/workflows/ai-review.yml
# Integriert: CodeRabbit, CodiumAI
# Trigger: Pull Requests
# Zweck: Automatische Code-Reviews
```

### Security Scan Workflow
```yaml
# .github/workflows/security-scan.yml
# Integriert: CodeQL, Snyk, TruffleHog, Gitleaks
# Trigger: Push, PRs, wöchentlich
# Zweck: Sicherheits-Scanning
```

### Code Quality Workflow
```yaml
# .github/workflows/code-quality.yml
# Integriert: Codacy, Codecov, CodeFactor
# Trigger: Push, PRs
# Zweck: Code-Qualitätsüberwachung
```

---

## 📊 Branch Protection Integration

Alle Apps sind in die Branch Protection Rules integriert:

```json
{
  "required_status_checks": {
    "contexts": [
      "security-scan / CodeQL Analysis",
      "security-scan / Snyk Security Scan",
      "code-quality / Codacy Analysis",
      "code-quality / Code Coverage",
      "ai-review / CodeRabbit Review",
      "ai-review / CodiumAI PR Agent"
    ]
  }
}
```

Siehe `.github/branch-protection.json` für vollständige Konfiguration.

---

## 🆘 Allgemeine Troubleshooting-Tipps

### 1. Workflow schlägt fehl
```bash
# Prüfen Sie Logs:
# GitHub → Actions → Failed Workflow → Job Details

# Häufige Ursachen:
# - Fehlende oder abgelaufene Secrets
# - Rate Limits erreicht
# - Netzwerkprobleme
```

### 2. App reagiert nicht
```bash
# Prüfen Sie App-Berechtigungen:
# GitHub → Settings → Integrations → Applications
# Stellen Sie sicher, dass die App installiert und autorisiert ist
```

### 3. Secrets-Probleme
```bash
# Secrets auflisten:
gh secret list

# Secret neu setzen:
gh secret set SECRET_NAME --body "new-value"

# Secret aus Datei setzen:
gh secret set SECRET_NAME < secret-file.txt
```

### 4. Rate Limits
```bash
# GitHub API Rate Limit prüfen:
gh api rate_limit

# Lösung: Warten oder GitHub App Token verwenden
```

---

## 📚 Weitere Ressourcen

- **Secrets-Template:** `.github/secrets-template.env`
- **Workflow-Dateien:** `.github/workflows/`
- **Setup-Skripte:** `scripts/setup-marketplace-apps.sh`
- **Branch Protection:** `.github/branch-protection.json`

---

## English Version

### 📋 Overview

This documentation describes all integrated GitHub Marketplace Apps for the Enterprise Setup Repository. All apps are fully integrated into CI/CD workflows and work seamlessly together.

### 🎯 Integrated Apps

1. [CodeRabbit AI Code Review](#1-coderabbit-ai-code-review-en)
2. [CodiumAI PR Agent](#2-codiumai-pr-agent-en)
3. [CodeFactor](#3-codefactor-en)
4. [Codacy](#4-codacy-en)
5. [Codecov](#5-codecov-en)
6. [Snyk](#6-snyk-en)
7. [Dependabot](#7-dependabot-en)

---

### 1. CodeRabbit AI Code Review {#1-coderabbit-ai-code-review-en}

**🤖 AI-powered automatic code reviews**

#### Description
CodeRabbit is an AI-powered code review tool that automatically analyzes pull requests and provides constructive feedback. It identifies potential bugs, security vulnerabilities, and code quality issues.

#### Main Features
- 🔍 Automatic code analysis on every PR
- 💬 Inline comments with concrete improvement suggestions
- 🐛 Bug detection and security analysis
- 📊 Code quality assessment
- 🔄 Continuous learning from feedback
- 🎯 Best practice recommendations

#### Installation

**Step 1: Install GitHub App**
```bash
# Visit
https://github.com/apps/coderabbitai

# Click "Install"
# Select your repository
# Confirm permissions
```

**Step 2: Repository Configuration**
No additional configuration required. CodeRabbit works automatically after installation.

**Step 3: Workflow Integration**
CodeRabbit is already integrated in `.github/workflows/ai-review.yml`:

```yaml
coderabbit:
  name: CodeRabbit Review
  runs-on: ubuntu-latest
  steps:
    - name: CodeRabbit Integration
      run: |
        echo "🐰 CodeRabbit AI Review"
        echo "CodeRabbit automatically reviews PRs"
```

#### Secrets Configuration
No additional secrets required. CodeRabbit uses GitHub App authentication.

#### Usage
1. Create a pull request
2. CodeRabbit automatically analyzes the code
3. Review comments in the PR
4. Respond to suggestions or mark as resolved

#### Troubleshooting

**Issue: CodeRabbit not commenting**
```bash
# Solution 1: Check installation
# GitHub UI → Settings → Integrations → Applications
# Ensure CodeRabbit is installed

# Solution 2: Check repository permissions
# CodeRabbit requires read and write access to pull requests
```

**Issue: Too many comments**
```yaml
# Configure CodeRabbit in .coderabbit.yaml:
reviews:
  high_level_summary: true
  poem: false
  review_status: true
  collapse_walkthrough: false
  auto_review:
    enabled: true
    drafts: false
```

---

### 2. CodiumAI PR Agent {#2-codiumai-pr-agent-en}

**🤖 AI-driven PR analysis and test generation**

#### Description
CodiumAI PR Agent automatically analyzes pull requests and generates test suggestions, code documentation, and detailed review comments.

#### Main Features
- 🧪 Automatic test generation
- 📝 Code documentation suggestions
- 🔍 Security and quality analysis
- 💡 Intelligent improvement suggestions
- 📊 PR summaries
- 🎯 Test coverage analysis

#### Installation

**Step 1: Install GitHub App**
```bash
https://github.com/apps/codiumai-pr-agent
```

**Step 2: Activate Repository**
After installation, CodiumAI automatically activates for all PRs.

**Step 3: Workflow Integration**
Integration in `.github/workflows/ai-review.yml`:

```yaml
codiumai:
  name: CodiumAI PR Agent
  runs-on: ubuntu-latest
  steps:
    - name: CodiumAI PR Agent Integration
      run: |
        echo "🤖 CodiumAI PR Agent Review"
```

#### Secrets Configuration
Uses GitHub App authentication. Optional: CODIUMAI_API_KEY for advanced features.

```bash
# Optional: Set API key
gh secret set CODIUMAI_API_KEY --body "your-api-key"
```

#### Usage
1. Create a pull request
2. CodiumAI analyzes automatically
3. Use `/improve` comment for improvements
4. Use `/test` comment for test suggestions
5. Use `/describe` for detailed descriptions

#### PR Comment Commands
```bash
/review       # Full code review
/improve      # Improvement suggestions
/test         # Test generation
/describe     # Generate PR description
/ask          # Ask questions about code
```

#### Troubleshooting

**Issue: CodiumAI not responding to commands**
```bash
# Ensure command is at the start of a new line
# Example:
/review
# Not: "Can you /review this?"
```

---

### 3. CodeFactor {#3-codefactor-en}

**📊 Automatic code quality scoring**

#### Description
CodeFactor continuously analyzes code quality and assigns scores based on best practices, code complexity, and maintainability.

#### Main Features
- 📈 Code quality scoring (A+ to F)
- 🔍 Automatic code analysis
- 📊 Quality trends over time
- 🎯 Issue prioritization
- 💡 Refactoring suggestions
- 🔄 Continuous monitoring

#### Installation

**Step 1: Create Account**
```bash
# Visit
https://www.codefactor.io/

# Sign in with GitHub
# Authorize access
```

**Step 2: Add Repository**
```bash
# Dashboard → Add Repository
# Select your repository
# CodeFactor starts analysis automatically
```

**Step 3: Add Badge (Optional)**
```markdown
# In README.md:
[![CodeFactor](https://www.codefactor.io/repository/github/your-org/setup/badge)](https://www.codefactor.io/repository/github/your-org/setup)
```

#### Workflow Integration
Integration in `.github/workflows/code-quality.yml`:

```yaml
codefactor:
  name: CodeFactor Analysis
  runs-on: ubuntu-latest
  steps:
    - name: CodeFactor Analysis
      run: |
        echo "📊 CodeFactor analysis runs automatically"
```

#### Secrets Configuration
No secrets required. CodeFactor uses OAuth authentication.

#### Usage
1. CodeFactor analyzes automatically on every push
2. Check results at codefactor.io/repository/github/{org}/{repo}
3. Fix identified issues
4. Observe quality score improvements

#### Troubleshooting

**Issue: No analysis updates**
```bash
# Solution: Trigger manual analysis
# CodeFactor Dashboard → Repository → "Reanalyze"
```

---

### 4. Codacy {#4-codacy-en}

**🔍 Code quality monitoring and automatic reviews**

#### Description
Codacy is a comprehensive code quality platform that combines static analysis, security checks, and code coverage.

#### Main Features
- 🔍 Static code analysis
- 🛡️ Security vulnerability detection
- 📊 Code coverage tracking
- 💡 Code pattern detection
- 🎯 Technical debt analysis
- 🔄 PR quality gates

#### Installation

**Step 1: Codacy Account**
```bash
https://app.codacy.com/

# Use GitHub login
# Authorize organization
```

**Step 2: Add Repository**
```bash
# Codacy Dashboard → Add repository
# Select your repository
# Configure analysis settings
```

**Step 3: Generate Project Token**
```bash
# Codacy → Repository → Settings → Integrations → Project API
# Copy the Project Token
```

#### Secrets Configuration

**Required:**
```bash
gh secret set CODACY_PROJECT_TOKEN --body "your-project-token"
```

**Get Token:**
1. Open Codacy Dashboard
2. Repository → Settings → Integrations
3. Under "Project API" → "Create token" or copy existing
4. Save as GitHub Secret

#### Workflow Integration
In `.github/workflows/code-quality.yml`:

```yaml
codacy:
  name: Codacy Analysis
  runs-on: ubuntu-latest
  steps:
    - name: Run Codacy Analysis
      uses: codacy/codacy-analysis-cli-action@master
      with:
        project-token: ${{ secrets.CODACY_PROJECT_TOKEN }}
        upload: true
```

#### Usage
1. Codacy analyzes automatically on every push and PR
2. Check results in Codacy Dashboard
3. Respond to PR comments
4. Track quality trends

#### Code Pattern Configuration
```yaml
# Create .codacy.yml:
---
engines:
  eslint:
    enabled: true
  shellcheck:
    enabled: true
exclude_paths:
  - 'node_modules/**'
  - 'dist/**'
```

#### Troubleshooting

**Issue: "Project token not found"**
```bash
# Solution: Set secret correctly
gh secret set CODACY_PROJECT_TOKEN --body "your-actual-token"

# Verify:
gh secret list
```

**Issue: Analysis fails**
```bash
# Check .codacy.yml syntax:
# Validate at https://app.codacy.com/
```

---

### 5. Codecov {#5-codecov-en}

**📈 Test coverage tracking and reporting**

#### Description
Codecov visualizes test coverage, shows untested code areas, and prevents coverage drops through PR checks.

#### Main Features
- 📊 Detailed coverage reports
- 🎯 Line-by-line coverage
- 📈 Coverage trends
- 🚫 Coverage drop prevention
- 💬 PR comments with coverage changes
- 🔍 Branch and commit analysis

#### Installation

**Step 1: Codecov Account**
```bash
https://codecov.io/

# GitHub login
# Authorize repository
```

**Step 2: Activate Repository**
```bash
# Codecov Dashboard → Add new repository
# Select your repository
```

**Step 3: Upload Token**
```bash
# Codecov → Repository → Settings → General
# Copy "Repository Upload Token"
```

#### Secrets Configuration

**Required:**
```bash
gh secret set CODECOV_TOKEN --body "your-upload-token"
```

**Find Token:**
1. codecov.io → Your Repository
2. Settings → General
3. Copy "Repository Upload Token"

#### Workflow Integration
In `.github/workflows/code-quality.yml`:

```yaml
codecov:
  name: Code Coverage
  runs-on: ubuntu-latest
  steps:
    - name: Run tests with coverage
      run: npm run test -- --coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v4
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        files: ./coverage/lcov.info
```

#### Usage

**Generate Test Coverage:**
```bash
# Node.js/Jest:
npm run test -- --coverage

# Python/pytest:
pytest --cov=. --cov-report=xml

# Go:
go test -coverprofile=coverage.out ./...
```

**Check Coverage Reports:**
1. Visit Codecov Dashboard
2. Check latest commits
3. View file-based coverage
4. Review PR comments for coverage changes

#### Codecov Configuration
```yaml
# Create codecov.yml:
coverage:
  status:
    project:
      default:
        target: 80%
        threshold: 2%
    patch:
      default:
        target: 90%

comment:
  layout: "reach, diff, files"
  behavior: default
```

#### Troubleshooting

**Issue: Coverage not uploading**
```bash
# Solution 1: Verify token
gh secret list | grep CODECOV

# Solution 2: Check coverage file
ls -la coverage/
# Ensure lcov.info exists

# Solution 3: Check workflow logs
# GitHub Actions → Code Coverage Job → Logs
```

---

### 6. Snyk {#6-snyk-en}

**🔒 Security scanning and dependency monitoring**

#### Description
Snyk continuously scans for security vulnerabilities in dependencies, container images, and code. It offers automatic fix suggestions and PR updates.

#### Main Features
- 🔍 Dependency vulnerability scanning
- 🛡️ Security advisory monitoring
- 🔄 Automatic fix PRs
- 📊 Vulnerability prioritization
- 🎯 License compliance checks
- 🚨 Real-time security alerts

#### Installation

**Step 1: Snyk Account**
```bash
https://app.snyk.io/

# Use GitHub login
# Connect organization
```

**Step 2: Import Repository**
```bash
# Snyk Dashboard → Add project
# Select GitHub
# Select repository(s)
# Snyk starts first scan
```

**Step 3: Generate API Token**
```bash
# Snyk → Account Settings → API Token
# Click "Show" or "Generate"
# Copy the token
```

#### Secrets Configuration

**Required:**
```bash
gh secret set SNYK_TOKEN --body "your-snyk-token"
```

**Get Token:**
1. Open https://app.snyk.io/account
2. Scroll down to "API Token"
3. Show or regenerate token
4. Save as GitHub Secret

#### Workflow Integration
In `.github/workflows/security-scan.yml`:

```yaml
snyk:
  name: Snyk Security Scan
  runs-on: ubuntu-latest
  steps:
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

#### Usage

**CLI Installation (local):**
```bash
# npm:
npm install -g snyk

# Authenticate:
snyk auth

# Scan repository:
snyk test

# Apply fix suggestions:
snyk wizard
```

**Severity Levels:**
- 🔴 Critical: Immediate action required
- 🟠 High: Fix recommended soon
- 🟡 Medium: Fix in next release
- 🔵 Low: Optional, when convenient

#### Snyk Configuration
```yaml
# Create .snyk:
# Snyk (https://snyk.io) policy file
version: v1.22.1
ignore:
  'npm:package-name:20210101':
    - package-name > vulnerable-dep:
        reason: 'Fix not available yet'
        expires: '2024-12-31'
```

#### Troubleshooting

**Issue: "Authentication failed"**
```bash
# Solution: Reset token
gh secret set SNYK_TOKEN --body "new-token-from-snyk"

# Verify (local):
snyk auth
snyk test
```

**Issue: Too many false positives**
```bash
# Use .snyk policy file
# Ignore specific vulnerabilities
# CAUTION: Only after careful review!
```

---

### 7. Dependabot {#7-dependabot-en}

**🔄 Automatic dependency updates**

#### Description
Dependabot is integrated into GitHub and automatically creates pull requests for outdated dependencies and security updates.

#### Main Features
- 🔄 Automatic dependency updates
- 🛡️ Security advisory integration
- 📊 Update strategies (weekly, daily, monthly)
- 🎯 Grouped updates
- 🔍 Compatibility checks
- ✅ Auto-merge when tests pass

#### Installation

**Step 1: Dependabot is Already Enabled**
Dependabot is enabled by default in GitHub repositories.

**Step 2: Configuration**
Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "github-actions"
    
  # npm
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    labels:
      - "dependencies"
      - "npm"
    versioning-strategy: increase
    
  # Python
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "python"
```

#### Secrets Configuration
No additional secrets required. Uses GitHub token automatically.

Optional for private registries:
```bash
gh secret set NPM_TOKEN --body "your-npm-token"
```

#### Workflow Integration
Dependabot works independently but can be extended with auto-merge:

```yaml
# .github/workflows/dependabot-auto-merge.yml
name: Dependabot Auto-Merge
on: pull_request

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'
    steps:
      - name: Auto-merge for Dependabot PRs
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{github.event.pull_request.html_url}}
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

#### Usage
1. Dependabot creates PRs automatically
2. Review changelog and compatibility
3. Wait for successful tests
4. Merge manually or via auto-merge

#### Dependabot Commands (in PR comments)
```bash
@dependabot rebase       # Rebase PR
@dependabot recreate     # Recreate PR
@dependabot merge        # Merge PR
@dependabot squash       # Squash and merge
@dependabot cancel merge # Cancel merge
@dependabot reopen       # Reopen PR
@dependabot close        # Close PR
@dependabot ignore       # Ignore version
```

#### Troubleshooting

**Issue: Dependabot not creating PRs**
```yaml
# Solution: Check .github/dependabot.yml
# Ensure:
# 1. File is correctly formatted
# 2. package-ecosystem is correct
# 3. directory exists

# Validate:
# GitHub UI → Insights → Dependency graph → Dependabot
```

**Issue: Too many Dependabot PRs**
```yaml
# Group updates in dependabot.yml:
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"  # Instead of "daily"
    groups:
      development-dependencies:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"
```

---

## 🔗 Workflow Integrations

### AI Review Workflow
```yaml
# .github/workflows/ai-review.yml
# Integrates: CodeRabbit, CodiumAI
# Trigger: Pull Requests
# Purpose: Automatic code reviews
```

### Security Scan Workflow
```yaml
# .github/workflows/security-scan.yml
# Integrates: CodeQL, Snyk, TruffleHog, Gitleaks
# Trigger: Push, PRs, weekly
# Purpose: Security scanning
```

### Code Quality Workflow
```yaml
# .github/workflows/code-quality.yml
# Integrates: Codacy, Codecov, CodeFactor
# Trigger: Push, PRs
# Purpose: Code quality monitoring
```

---

## 📊 Branch Protection Integration

All apps are integrated into Branch Protection Rules:

```json
{
  "required_status_checks": {
    "contexts": [
      "security-scan / CodeQL Analysis",
      "security-scan / Snyk Security Scan",
      "code-quality / Codacy Analysis",
      "code-quality / Code Coverage",
      "ai-review / CodeRabbit Review",
      "ai-review / CodiumAI PR Agent"
    ]
  }
}
```

See `.github/branch-protection.json` for complete configuration.

---

## 🆘 General Troubleshooting Tips

### 1. Workflow Fails
```bash
# Check logs:
# GitHub → Actions → Failed Workflow → Job Details

# Common causes:
# - Missing or expired secrets
# - Rate limits reached
# - Network issues
```

### 2. App Not Responding
```bash
# Check app permissions:
# GitHub → Settings → Integrations → Applications
# Ensure app is installed and authorized
```

### 3. Secrets Issues
```bash
# List secrets:
gh secret list

# Reset secret:
gh secret set SECRET_NAME --body "new-value"

# Set secret from file:
gh secret set SECRET_NAME < secret-file.txt
```

### 4. Rate Limits
```bash
# Check GitHub API rate limit:
gh api rate_limit

# Solution: Wait or use GitHub App token
```

---

## 📚 Additional Resources

- **Secrets Template:** `.github/secrets-template.env`
- **Workflow Files:** `.github/workflows/`
- **Setup Scripts:** `scripts/setup-marketplace-apps.sh`
- **Branch Protection:** `.github/branch-protection.json`

---

**Last Updated:** 2026-01-02  
**Version:** 1.0.0  
**Maintained By:** Enterprise Setup Team
