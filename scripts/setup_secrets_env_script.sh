#!/bin/bash
# scripts/setup-secrets-and-apps.sh
# Setzt alle erforderlichen Secrets via GitHub CLI anhand einer .env-Datei
# Hinweis: GitHub Marketplace Apps müssen einmalig manuell über UI autorisiert werden

ENV_FILE=".github/secrets.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ $ENV_FILE existiert nicht. Bitte erstellen!"
  exit 1
fi

echo "🔐 Secrets aus $ENV_FILE laden..."
export $(grep -v '^#' $ENV_FILE | xargs)

# Mapping für GitHub CLI
declare -A SECRETS
SECRETS=(
  [SNYK_TOKEN]="$SNYK_TOKEN"
  [CODECOV_TOKEN]="$CODECOV_TOKEN"
  [CODACY_PROJECT_TOKEN]="$CODACY_PROJECT_TOKEN"
  [WAKATIME_API_KEY]="$WAKATIME_API_KEY"
  [GITHUB_TOKEN]="$GITHUB_TOKEN"
  [DEPENDABOT_TOKEN]="$DEPENDABOT_TOKEN"
)

for key in "${!SECRETS[@]}"; do
  if [ -n "${SECRETS[$key]}" ]; then
    echo "- Setze $key"
    gh secret set "$key" -b"${SECRETS[$key]}" || echo "⚠️ Fehler beim Setzen von $key"
  else
    echo "⚠️ Wert für $key leer, Secret nicht gesetzt"
  fi
 done

echo "✅ Alle Secrets aus $ENV_FILE gesetzt (falls GitHub CLI korrekt konfiguriert ist)"

# Marketplace Apps Hinweis
echo "\n⚙️ Marketplace Apps vorbereiten (einmalig über UI autorisieren):"
echo "- CodeRabbit: https://github.com/apps/coderabbitai"
echo "- CodiumAI: https://github.com/apps/codiumai-pr-agent"
echo "- CodeFactor: https://www.codefactor.io/"
echo "- Codacy: https://www.codacy.com/"
echo "- Codecov: https://codecov.io/"
echo "- Snyk: https://snyk.io/"
echo "- Dependabot: schon integriert"
echo "📌 Bitte einmalig anmelden und Berechtigungen für das Repo erteilen."
echo "💡 Danach greifen die Workflows automatisch."

# Branch Protection Reminder
echo "\n🔐 Prüfe Branch Protection Settings:"
echo "Settings → Branches → Add rule → main"
echo "✅ Statusprüfungen aus branch-protection.json aktivieren"
echo "✅ Pull Request Reviews required, Include Admins, Linear History optional"
echo "🚀 Setup komplett! Du kannst jetzt Workflows testen."
