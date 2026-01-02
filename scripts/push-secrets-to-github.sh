#!/usr/bin/env bash
# Push local secrets into GitHub Actions secrets using gh CLI.
# Usage: ./scripts/push-secrets-to-github.sh [--env-file path] [--delete-file]

set -euo pipefail

ENV_FILE=".github/secrets.env"
DELETE_FILE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="$2"; shift 2 ;;
    --delete-file)
      DELETE_FILE=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if ! command -v gh >/dev/null 2>&1; then
  echo "❌ gh CLI nicht gefunden. Installiere zuerst GitHub CLI." >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Env-Datei nicht gefunden: $ENV_FILE" >&2
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

echo "🔐 Übertrage Secrets in Repo: $REPO"

while IFS='=' read -r key value; do
  # Skip Leerzeilen und Kommentare
  [[ -z "$key" || "$key" =~ ^# ]] && continue
  # Trim spaces
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)
  if [[ -z "$value" ]]; then
    echo "⚠️  Secret $key hat keinen Wert, übersprungen."
    continue
  fi
  echo "➡️  Setze $key ..."
  printf "%s" "$value" | gh secret set "$key" --repo "$REPO" --app actions --body -
done < "$ENV_FILE"

echo "✅ Secrets gesetzt."

if [[ "$DELETE_FILE" == true ]]; then
  rm -f "$ENV_FILE"
  echo "🗑️  Lokale Datei gelöscht: $ENV_FILE"
fi
