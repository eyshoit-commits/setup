# Mergify Konfiguration / Mergify Configuration

[🇩🇪 Deutsche Version](#deutsche-version) | [🇬🇧 English Version](#english-version)

---

## Deutsche Version

### 📋 Übersicht

Mergify ist ein automatisiertes Merge-Queue-System, das Pull Requests basierend auf definierten Qualitäts- und Sicherheitsanforderungen automatisch zusammenführt. Es stellt sicher, dass nur PRs gemergt werden, die alle Repository-Qualitätskriterien erfüllen.

### 🎯 Hauptfunktionen

- **🔄 Automatische Merge-Queue** - PRs werden automatisch in eine Queue eingereiht
- **✅ Qualitätssicherung** - Nur PRs mit bestandenen CI-Checks werden gemergt
- **👥 Review-Validierung** - Mindestanforderungen für Code-Reviews werden durchgesetzt
- **🚀 Batch-Merging** - Mehrere PRs können gebündelt zusammengeführt werden
- **🔒 Branch Protection** - Integriert mit GitHub Branch Protection Rules
- **⚡ Speculative Checks** - Parallele Prüfung mehrerer PRs für schnellere Merges

### 🔧 Konfiguration

Die Mergify-Konfiguration befindet sich in `.mergify.yml` im Repository-Root.

#### Queue-Regeln

```yaml
queue_rules:
  - name: Merge
    conditions:
      - base=main                        # Ziel-Branch: main
      - "#approved-reviews-by>=1"        # Mindestens 1 Approval
      - check-success=CI / validate      # CI-Checks müssen erfolgreich sein
      - check-success=CI / unit-tests
      - check-success=CI / integration-tests
    batch_size: 1                        # Ein PR pro Merge
    batch_max_wait_time: 0s              # Keine Wartezeit
    merge_method: squash                 # Squash-Merge verwenden
    priority: high                       # Hohe Priorität
```

#### Pull Request Regeln

Die Konfiguration definiert zwei Hauptregeln:

**1. Einfache Auto-Queue-Regel**
```yaml
- name: Add approved PRs with passing checks to Merge queue
  conditions:
    - base=main
    - label=automerge                    # PR muss "automerge" Label haben
    - "#approved-reviews-by>=1"          # Mindestens 1 Approval
    - check-success=CI / validate
    - check-success=CI / unit-tests
    - check-success=CI / integration-tests
```

**2. Erweiterte Enterprise-Regel**
```yaml
- name: Add pull requests to Merge queue when all conditions are met
  conditions:
    - base=main
    - or:
        - label=automerge                # "automerge" ODER "dependencies" Label
        - label=dependencies
    - "#approved-reviews-by>=2"          # 2 Approvals erforderlich
    - "#review-requested=0"              # Keine ausstehenden Review-Anfragen
    - "#changes-requested-reviews-by=0"  # Keine Änderungsanfragen
    - check-success=CI                   # Alle CI-Checks
    - check-success=CodeQL               # Sicherheits-Scans
    - check-success=Snyk
    - check-success=Lint
    - check-success=Smoke tests
    - conflict=FALSE                     # Keine Merge-Konflikte
```

### 🚀 Workflow

#### Automatischer Merge-Ablauf

```
1. PR erstellen
   ↓
2. CI/CD-Checks laufen
   ↓
3. Code-Reviews anfordern
   ↓
4. Approvals erhalten
   ↓
5. Label "automerge" hinzufügen
   ↓
6. Mergify prüft Bedingungen
   ↓
7. PR wird zur Queue hinzugefügt
   ↓
8. Automatischer Merge bei erfolgreicher Validierung
```

#### Merge-Bedingungen

Ein PR wird automatisch gemergt, wenn **ALLE** folgenden Bedingungen erfüllt sind:

✅ **Branch**
- Ziel-Branch ist `main`

✅ **Reviews**
- Mindestens 2 genehmigende Reviews
- Keine ausstehenden Review-Anfragen
- Keine Änderungsanfragen

✅ **Labels**
- Label `automerge` ODER `dependencies` gesetzt

✅ **CI/CD-Checks**
- CI-Workflow erfolgreich
- CodeQL-Sicherheitsscan erfolgreich
- Snyk-Sicherheitsscan erfolgreich
- Lint-Checks erfolgreich
- Smoke-Tests erfolgreich

✅ **Mergability**
- Keine Merge-Konflikte
- Branch ist auf dem neuesten Stand

### 📊 Integration mit bestehenden Workflows

Mergify integriert sich nahtlos mit allen bestehenden Repository-Workflows:

#### GitHub Actions Workflows

| Workflow | Integration | Beschreibung |
|----------|-------------|--------------|
| **CI** | `check-success=CI` | Validierung, Unit- und Integrationstests |
| **CodeQL** | `check-success=CodeQL` | Sicherheitsanalyse |
| **Snyk** | `check-success=Snyk` | Dependency-Schwachstellen-Scan |
| **Lint** | `check-success=Lint` | Code-Qualitätsprüfungen |
| **Smoke tests** | `check-success=Smoke tests` | End-to-End-Validierung |

#### Branch Protection

Mergify-Regeln sind mit `.github/branch-protection.json` synchronisiert:

```json
{
  "required_status_checks": {
    "contexts": ["CI", "CodeQL", "Snyk", "Lint", "Smoke tests"]
  },
  "required_pull_request_reviews": {
    "required_approving_review_count": 2
  }
}
```

#### Code-Review-Tools

- **CodeRabbit**: Automatische Reviews vor Mergify-Validierung
- **CodiumAI**: Test-Generierung und Analyse
- **Codacy/CodeFactor**: Qualitätsprüfungen als CI-Check

### 🛠️ Verwendung

#### Für Entwickler

**Schritt 1: PR erstellen**
```bash
git checkout -b feature/new-feature
git commit -m "feat: add new feature"
git push origin feature/new-feature
# PR auf GitHub erstellen
```

**Schritt 2: Reviews anfordern**
- Mindestens 2 Reviewer zuweisen
- Auf Feedback reagieren
- Änderungen committen

**Schritt 3: Automerge aktivieren**
```bash
# Label über GitHub UI hinzufügen:
# Rechte Sidebar → Labels → "automerge" auswählen

# Oder via GitHub CLI:
gh pr edit <PR-NUMBER> --add-label automerge
```

**Schritt 4: Warten auf automatischen Merge**
- Mergify überwacht den PR automatisch
- Bei Erfüllung aller Bedingungen erfolgt automatischer Merge
- Benachrichtigung über erfolgreichen Merge

#### Für Maintainer

**Dependency Updates automatisieren**
```yaml
# Dependabot-PRs mit "dependencies" Label werden automatisch gemergt
# wenn alle Checks erfolgreich sind und 2 Approvals vorliegen
```

**Merge-Priorität steuern**
```bash
# Hohe Priorität: automerge-Label
# Normale Priorität: dependencies-Label
# Manuell: Kein Label, manueller Merge erforderlich
```

### 🔍 Monitoring und Troubleshooting

#### Status überprüfen

**Mergify-Dashboard**
```
https://dashboard.mergify.com/github/<YOUR-ORG>/setup
```

**PR-Status prüfen**
```bash
# GitHub UI: PR → Checks → Mergify
# Zeigt Queue-Status und fehlende Bedingungen
```

#### Häufige Probleme

**Problem: PR wird nicht zur Queue hinzugefügt**

Lösung:
```bash
# 1. Prüfen Sie alle Bedingungen:
gh pr view <PR-NUMBER> --json reviews,labels,statusCheckRollup

# 2. Stellen Sie sicher, dass Label gesetzt ist:
gh pr edit <PR-NUMBER> --add-label automerge

# 3. Prüfen Sie fehlende Approvals:
# Mindestens 2 genehmigende Reviews erforderlich

# 4. Prüfen Sie CI-Status:
gh pr checks <PR-NUMBER>
```

**Problem: Merge schlägt fehl**

Lösung:
```bash
# 1. Prüfen Sie auf Merge-Konflikte:
git fetch origin main
git merge origin/main
# Konflikte lösen und pushen

# 2. Prüfen Sie fehlgeschlagene Checks:
gh pr checks <PR-NUMBER>
# Fehlende Checks beheben

# 3. Prüfen Sie Review-Status:
gh pr view <PR-NUMBER> --json reviews
# Änderungsanfragen addressieren
```

**Problem: Queue ist gestoppt**

Lösung:
```bash
# 1. Prüfen Sie Queue-Status im Mergify-Dashboard
# 2. Prüfen Sie auf blockierende PRs
# 3. Entfernen Sie blockierende PRs aus der Queue:
gh pr edit <PR-NUMBER> --remove-label automerge
# 4. Fügen Sie PR erneut hinzu nach Problembehebung
```

### ⚙️ Erweiterte Konfiguration

#### Speculative Checks anpassen

```yaml
pull_request_rules:
  - name: Merge queue
    actions:
      queue:
        speculative_checks: 2    # Anzahl paralleler Checks (1-10)
        batch_size: 5            # Maximale Batch-Größe (1-100)
```

#### Commit-Message-Template

```yaml
queue:
  commit_message_template: |
    {{ title }} (#{{ number }})

    {{ body }}
```

#### Prioritäten setzen

```yaml
# Hohe Priorität für Hotfixes
- name: High priority for hotfixes
  conditions:
    - label=hotfix
  actions:
    queue:
      priority: high

# Niedrige Priorität für Dependencies
- name: Low priority for dependencies
  conditions:
    - label=dependencies
  actions:
    queue:
      priority: low
```

### 📚 Best Practices

1. **Labels konsistent verwenden**
   - `automerge`: Für Feature-PRs
   - `dependencies`: Für Dependabot-Updates
   - `hotfix`: Für dringende Fixes (hohe Priorität)

2. **Review-Anforderungen einhalten**
   - Immer 2 Approvals anfordern
   - Reviews von verschiedenen Team-Mitgliedern

3. **CI-Checks grün halten**
   - Lokale Tests vor Push durchführen
   - CI-Logs bei Fehlern prüfen
   - Broken Builds zeitnah beheben

4. **Merge-Konflikte vermeiden**
   - Branch regelmäßig mit `main` synchronisieren
   - Kleine, fokussierte PRs erstellen

5. **Queue überwachen**
   - Mergify-Dashboard regelmäßig prüfen
   - Blockierende PRs identifizieren und beheben

### 🔗 Weiterführende Links

- [Mergify Dokumentation](https://docs.mergify.com/)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## English Version

### 📋 Overview

Mergify is an automated merge queue system that automatically merges pull requests based on defined quality and security requirements. It ensures that only PRs meeting all repository quality criteria are merged.

### 🎯 Key Features

- **🔄 Automated Merge Queue** - PRs are automatically queued for merging
- **✅ Quality Assurance** - Only PRs with passing CI checks are merged
- **👥 Review Validation** - Minimum code review requirements are enforced
- **🚀 Batch Merging** - Multiple PRs can be merged together in batches
- **🔒 Branch Protection** - Integrated with GitHub Branch Protection Rules
- **⚡ Speculative Checks** - Parallel validation of multiple PRs for faster merges

### 🔧 Configuration

The Mergify configuration is located in `.mergify.yml` at the repository root.

#### Queue Rules

```yaml
queue_rules:
  - name: Merge
    conditions:
      - base=main                        # Target branch: main
      - "#approved-reviews-by>=1"        # At least 1 approval
      - check-success=CI / validate      # CI checks must pass
      - check-success=CI / unit-tests
      - check-success=CI / integration-tests
    batch_size: 1                        # One PR per merge
    batch_max_wait_time: 0s              # No wait time
    merge_method: squash                 # Use squash merge
    priority: high                       # High priority
```

#### Pull Request Rules

The configuration defines two main rules:

**1. Simple Auto-Queue Rule**
```yaml
- name: Add approved PRs with passing checks to Merge queue
  conditions:
    - base=main
    - label=automerge                    # PR must have "automerge" label
    - "#approved-reviews-by>=1"          # At least 1 approval
    - check-success=CI / validate
    - check-success=CI / unit-tests
    - check-success=CI / integration-tests
```

**2. Advanced Enterprise Rule**
```yaml
- name: Add pull requests to Merge queue when all conditions are met
  conditions:
    - base=main
    - or:
        - label=automerge                # "automerge" OR "dependencies" label
        - label=dependencies
    - "#approved-reviews-by>=2"          # 2 approvals required
    - "#review-requested=0"              # No pending review requests
    - "#changes-requested-reviews-by=0"  # No change requests
    - check-success=CI                   # All CI checks
    - check-success=CodeQL               # Security scans
    - check-success=Snyk
    - check-success=Lint
    - check-success=Smoke tests
    - conflict=FALSE                     # No merge conflicts
```

### 🚀 Workflow

#### Automated Merge Process

```
1. Create PR
   ↓
2. CI/CD checks run
   ↓
3. Request code reviews
   ↓
4. Receive approvals
   ↓
5. Add "automerge" label
   ↓
6. Mergify validates conditions
   ↓
7. PR is added to queue
   ↓
8. Automatic merge on successful validation
```

#### Merge Conditions

A PR is automatically merged when **ALL** of the following conditions are met:

✅ **Branch**
- Target branch is `main`

✅ **Reviews**
- At least 2 approving reviews
- No pending review requests
- No change requests

✅ **Labels**
- Label `automerge` OR `dependencies` is set

✅ **CI/CD Checks**
- CI workflow successful
- CodeQL security scan successful
- Snyk security scan successful
- Lint checks successful
- Smoke tests successful

✅ **Mergability**
- No merge conflicts
- Branch is up to date

### 📊 Integration with Existing Workflows

Mergify integrates seamlessly with all existing repository workflows:

#### GitHub Actions Workflows

| Workflow | Integration | Description |
|----------|-------------|-------------|
| **CI** | `check-success=CI` | Validation, unit and integration tests |
| **CodeQL** | `check-success=CodeQL` | Security analysis |
| **Snyk** | `check-success=Snyk` | Dependency vulnerability scanning |
| **Lint** | `check-success=Lint` | Code quality checks |
| **Smoke tests** | `check-success=Smoke tests` | End-to-end validation |

#### Branch Protection

Mergify rules are synchronized with `.github/branch-protection.json`:

```json
{
  "required_status_checks": {
    "contexts": ["CI", "CodeQL", "Snyk", "Lint", "Smoke tests"]
  },
  "required_pull_request_reviews": {
    "required_approving_review_count": 2
  }
}
```

#### Code Review Tools

- **CodeRabbit**: Automatic reviews before Mergify validation
- **CodiumAI**: Test generation and analysis
- **Codacy/CodeFactor**: Quality checks as CI checks

### 🛠️ Usage

#### For Developers

**Step 1: Create PR**
```bash
git checkout -b feature/new-feature
git commit -m "feat: add new feature"
git push origin feature/new-feature
# Create PR on GitHub
```

**Step 2: Request reviews**
- Assign at least 2 reviewers
- Respond to feedback
- Commit changes

**Step 3: Enable automerge**
```bash
# Add label via GitHub UI:
# Right sidebar → Labels → Select "automerge"

# Or via GitHub CLI:
gh pr edit <PR-NUMBER> --add-label automerge
```

**Step 4: Wait for automatic merge**
- Mergify monitors the PR automatically
- Automatic merge when all conditions are met
- Notification on successful merge

#### For Maintainers

**Automate dependency updates**
```yaml
# Dependabot PRs with "dependencies" label are automatically merged
# when all checks pass and 2 approvals are present
```

**Control merge priority**
```bash
# High priority: automerge label
# Normal priority: dependencies label
# Manual: No label, manual merge required
```

### 🔍 Monitoring and Troubleshooting

#### Check Status

**Mergify Dashboard**
```
https://dashboard.mergify.com/github/<YOUR-ORG>/setup
```

**Check PR Status**
```bash
# GitHub UI: PR → Checks → Mergify
# Shows queue status and missing conditions
```

#### Common Issues

**Issue: PR not added to queue**

Solution:
```bash
# 1. Check all conditions:
gh pr view <PR-NUMBER> --json reviews,labels,statusCheckRollup

# 2. Ensure label is set:
gh pr edit <PR-NUMBER> --add-label automerge

# 3. Check for missing approvals:
# At least 2 approving reviews required

# 4. Check CI status:
gh pr checks <PR-NUMBER>
```

**Issue: Merge fails**

Solution:
```bash
# 1. Check for merge conflicts:
git fetch origin main
git merge origin/main
# Resolve conflicts and push

# 2. Check failed checks:
gh pr checks <PR-NUMBER>
# Fix failing checks

# 3. Check review status:
gh pr view <PR-NUMBER> --json reviews
# Address change requests
```

**Issue: Queue is stuck**

Solution:
```bash
# 1. Check queue status in Mergify dashboard
# 2. Check for blocking PRs
# 3. Remove blocking PRs from queue:
gh pr edit <PR-NUMBER> --remove-label automerge
# 4. Re-add PR after fixing issues
```

### ⚙️ Advanced Configuration

#### Customize Speculative Checks

```yaml
pull_request_rules:
  - name: Merge queue
    actions:
      queue:
        speculative_checks: 2    # Number of parallel checks (1-10)
        batch_size: 5            # Maximum batch size (1-100)
```

#### Commit Message Template

```yaml
queue:
  commit_message_template: |
    {{ title }} (#{{ number }})

    {{ body }}
```

#### Set Priorities

```yaml
# High priority for hotfixes
- name: High priority for hotfixes
  conditions:
    - label=hotfix
  actions:
    queue:
      priority: high

# Low priority for dependencies
- name: Low priority for dependencies
  conditions:
    - label=dependencies
  actions:
    queue:
      priority: low
```

### 📚 Best Practices

1. **Use labels consistently**
   - `automerge`: For feature PRs
   - `dependencies`: For Dependabot updates
   - `hotfix`: For urgent fixes (high priority)

2. **Maintain review requirements**
   - Always request 2 approvals
   - Reviews from different team members

3. **Keep CI checks green**
   - Run local tests before push
   - Check CI logs on failures
   - Fix broken builds promptly

4. **Avoid merge conflicts**
   - Sync branch regularly with `main`
   - Create small, focused PRs

5. **Monitor the queue**
   - Check Mergify dashboard regularly
   - Identify and fix blocking PRs

### 🔗 Further Resources

- [Mergify Documentation](https://docs.mergify.com/)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [Conventional Commits](https://www.conventionalcommits.org/)
