#!/bin/bash
# Post-start script - runs every time container starts

set -e

echo "🔄 Running post-start checks..."

# Source environment variables
for env_file in env.d/*.env; do
  if [ -f "$env_file" ]; then
    source "$env_file" 2>/dev/null || true
  fi
done

# Display environment info
echo "📊 Environment Status:"
echo "  Node: $(node --version 2>/dev/null || echo 'not installed')"
echo "  Python: $(python --version 2>/dev/null || echo 'not installed')"
echo "  Rust: $(rustc --version 2>/dev/null || echo 'not installed')"
echo "  pnpm: $(pnpm --version 2>/dev/null || echo 'not installed')"

echo "✅ Ready to code!"
