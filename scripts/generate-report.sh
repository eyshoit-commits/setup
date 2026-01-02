#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load version locks
source "$REPO_ROOT/config/versions.env"

REPORT_FILE="$REPO_ROOT/setup-report.json"

if [ ! -f "$REPORT_FILE" ]; then
  echo "Error: setup-report.json not found. Run setup.sh first."
  exit 1
fi

# Generate report
echo "Generating setup report..."

cat > "$REPORT_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "os": "$(uname -s)",
  "arch": "$(uname -m)",
  "tools": [],
  "summary": {
    "installed": 0,
    "skipped": 0,
    "failed": 0,
    "total": 0
  }
}
EOF

echo "Report generated: $REPORT_FILE"
