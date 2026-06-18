#!/usr/bin/env bash
# audit-monthly.sh — Monthly usage report from daily logs

set -euo pipefail

MONTH=${1:-$(date +%Y-%m)}
LOG_DIR="${HOME}/.claude/logs"
BOLD='\033[1m'
CYAN='\033[0;36m'
RESET='\033[0m'

printf "${BOLD}Monthly audit: %s${RESET}\n\n" "$MONTH"

total_cost=0
total_water=0
file_count=0

for log in "${LOG_DIR}/daily-${MONTH}-"*.json 2>/dev/null; do
  [ -f "$log" ] || continue
  cost=$(jq -r '.total_cost_eur // 0' "$log" 2>/dev/null || echo 0)
  water=$(jq -r '.water_ml // 0' "$log" 2>/dev/null || echo 0)
  total_cost=$(echo "$total_cost + $cost" | bc)
  total_water=$(echo "$total_water + $water" | bc)
  ((file_count++))
done

printf "${CYAN}Days logged:${RESET}  %d\n" "$file_count"
printf "${CYAN}Total cost:${RESET}   €%.4f\n" "$total_cost"
printf "${CYAN}Total water:${RESET}  %.1f mL\n" "$total_water"
