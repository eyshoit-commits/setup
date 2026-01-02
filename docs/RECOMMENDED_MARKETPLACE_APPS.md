# 🛠️ Recommended GitHub Marketplace Apps

This repository is configured with the following **free/OSS-friendly** GitHub Marketplace Apps:

## 🔐 Security

### ✅ Dependabot (GitHub-native)
**Status:** ✅ Configured  
**What:** Automated dependency updates & security PRs  
**Setup:** Automatic (`.github/dependabot.yml`)

### ✅ GitHub CodeQL
**Status:** ✅ Configured  
**What:** Native security analysis via GitHub Actions  
**Setup:** Automatic (`.github/workflows/codeql-analysis.yml`)

### ✅ Snyk
**Status:** ⚠️ Requires Secret  
**What:** Vulnerability scanning (Free Tier)  
**Setup:**
1. Sign up at https://snyk.io/
2. Get API token
3. Add `SNYK_TOKEN` to repository secrets

**Workflow:** `.github/workflows/snyk-security.yml`

---

## 📈 Code Quality & Coverage

### ✅ Codacy
**Status:** ⚠️ Requires Secret  
**What:** Static analysis & quality feedback  
**Setup:**
1. Sign up at https://www.codacy.com/
2. Add repository
3. Get project token
4. Add `CODACY_PROJECT_TOKEN` to secrets

**Workflow:** `.github/workflows/codacy-analysis.yml`

### ✅ Codecov
**Status:** ⚠️ Requires Secret  
**What:** Coverage reports in PRs  
**Setup:**
1. Sign up at https://codecov.io/
2. Add repository
3. Get upload token
4. Add `CODECOV_TOKEN` to secrets

**Workflow:** `.github/workflows/codecov.yml`

### ✅ CodeFactor
**Status:** ✅ Auto-detected  
**What:** Static checks in PRs  
**Setup:** Add repository at https://www.codefactor.io/

**Config:** `.codefactor.yml`

### ✅ Coveralls
**Status:** ✅ Configured  
**What:** Coverage tracking over time  
**Setup:** Automatic via GITHUB_TOKEN

**Workflow:** `.github/workflows/coveralls.yml`

---

## 🤖 AI Review & Automation

### ✅ CodeRabbit
**Status:** ✅ Configured  
**What:** AI-powered PR summaries & review  
**Setup:** Install at https://github.com/apps/coderabbitai

**Workflow:** `.github/workflows/coderabbit.yml`

### ✅ CodiumAI (Qodo)
**Status:** ✅ Configured  
**What:** AI test generation  
**Setup:** Install at https://github.com/apps/codiumai-pr-agent

**Workflow:** `.github/workflows/qodo.yml`

---

## 🧠 Developer Analytics

### ✅ WakaTime
**Status:** ⚠️ Requires Secret  
**What:** Developer activity & productivity metrics  
**Setup:**
1. Sign up at https://wakatime.com/
2. Get API key
3. Add `WAKATIME_API_KEY` to secrets

**Workflow:** `.github/workflows/wakatime.yml`

---

## 🔑 Required Secrets

Add these in **Settings → Secrets and variables → Actions**:

| Secret | Required? | App |
|--------|-----------|-----|
| `GITHUB_TOKEN` | ✅ Auto-provided | All workflows |
| `SNYK_TOKEN` | ⚠️ Optional | Snyk |
| `CODECOV_TOKEN` | ⚠️ Optional | Codecov |
| `CODACY_PROJECT_TOKEN` | ⚠️ Optional | Codacy |
| `WAKATIME_API_KEY` | ⚠️ Optional | WakaTime |

---

## ✅ Recommended Status Checks

Enable these in **Settings → Branches → Branch protection rules**:

- `codeql-analysis`
- `codacy/quality`
- `codecov/patch`
- `codecov/project`
- `snyk/vuln`
- `Dependabot`
- `CodeRabbit Review`

---

## 📊 Badges

Add to your README.md:

```markdown
![CodeQL](https://github.com/eyshoit-commits/setup/workflows/CodeQL%20Analysis/badge.svg)
![Snyk](https://snyk.io/test/github/eyshoit-commits/setup/badge.svg)
![Codecov](https://codecov.io/gh/eyshoit-commits/setup/branch/main/graph/badge.svg)
![Codacy](https://app.codacy.com/project/badge/Grade/{PROJECT_ID})
![CodeFactor](https://www.codefactor.io/repository/github/eyshoit-commits/setup/badge)
![WakaTime](https://wakatime.com/badge/github/eyshoit-commits/setup.svg)
```
