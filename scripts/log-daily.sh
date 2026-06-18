#!/usr/bin/env bash
# log-daily.sh — Log daily Claude Code stats
# Usage: bash log-daily.sh [--webhook URL] [--notion]

set -euo pipefail

DATE=$(date +%Y-%m-%d)
LOG_DIR="${HOME}/.claude/logs"
LOG_FILE="${LOG_DIR}/daily-${DATE}.json"

mkdir -p "$LOG_DIR"

# --- Collect stats (customize paths as needed) ---
STATS=$(cat <<EOF
{
  "date": "${DATE}",
  "sessions": 0,
  "total_tokens": 0,
  "total_cost_eur": 0,
  "water_ml": 0,
  "models_used": []
}
EOF
)

echo "$STATS" > "$LOG_FILE"
echo "Stats logged to $LOG_FILE"

# --- Webhook n8n (set N8N_WEBHOOK_URL env var) ---
if [ -n "${N8N_WEBHOOK_URL:-}" ]; then
  curl -s -X POST "$N8N_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$STATS" && echo "Webhook sent."
fi
