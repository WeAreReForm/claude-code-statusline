#!/usr/bin/env bash
# test-statusline.sh — Unit tests for statusline.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATUSLINE="${SCRIPT_DIR}/../scripts/statusline.sh"

GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

PASS=0
FAIL=0

pass() { printf "${GREEN}✓${RESET} %s\n" "$1"; PASS=$((PASS + 1)); }
fail() { printf "${RED}✗${RESET} %s — %s\n" "$1" "$2"; FAIL=$((FAIL + 1)); }

# --- Test helpers ---
run_script() {
  echo "$1" | bash "$STATUSLINE" 2>/dev/null
}

LOW='{"model":{"display_name":"claude-sonnet-4-6"},"context_window":{"used_percentage":12,"total_input_tokens":5000,"total_output_tokens":800}}'
MED='{"model":{"display_name":"claude-sonnet-4-6"},"context_window":{"used_percentage":72,"total_input_tokens":35000,"total_output_tokens":8000}}'
HIGH='{"model":{"display_name":"claude-opus-4-8"},"context_window":{"used_percentage":91,"total_input_tokens":90000,"total_output_tokens":20000}}'
HAIKU='{"model":{"display_name":"claude-haiku-4-5"},"context_window":{"used_percentage":5,"total_input_tokens":1000,"total_output_tokens":200}}'
EMPTY='{}'

printf "${BOLD}Running statusline tests...${RESET}\n\n"

# 1. Script exists
[ -f "$STATUSLINE" ] && pass "Script exists" || fail "Script exists" "Not found at $STATUSLINE"

# 2. Script is executable or runnable with bash
bash -n "$STATUSLINE" 2>/dev/null && pass "Script syntax valid" || fail "Script syntax valid" "bash -n failed"

# 3. Script outputs something for low context
OUT=$(run_script "$LOW")
[ -n "$OUT" ] && pass "Output non-empty (low context)" || fail "Output non-empty (low context)" "Empty output"

# 4. Model name appears in output
echo "$OUT" | grep -qi "sonnet" && pass "Model name in output" || fail "Model name in output" "Sonnet not found"

# 5. Context percentage appears
echo "$OUT" | grep -q "12" && pass "Context % in output" || fail "Context % in output" "12% not found"

# 6. Medium context output contains %
OUT_MED=$(run_script "$MED")
echo "$OUT_MED" | grep -q "72" && pass "Medium context % correct" || fail "Medium context % correct" "72% not found"

# 7. High context output contains %
OUT_HIGH=$(run_script "$HIGH")
echo "$OUT_HIGH" | grep -q "91" && pass "High context % correct" || fail "High context % correct" "91% not found"

# 8. Haiku model recognized
OUT_HAIKU=$(run_script "$HAIKU")
echo "$OUT_HAIKU" | grep -qi "haiku" && pass "Haiku model recognized" || fail "Haiku model recognized" "Haiku not in output"

# 9. Water display present
echo "$OUT" | grep -q "mL" && pass "Water (mL) shown" || fail "Water (mL) shown" "mL not found"

# 10. Cost display present (€ or EUR)
echo "$OUT" | grep -qE "[€E]" && pass "Cost shown" || fail "Cost shown" "€ not found"

# 11. Empty JSON doesn't crash
OUT_EMPTY=$(run_script "$EMPTY")
[ -n "$OUT_EMPTY" ] && pass "Handles empty JSON" || fail "Handles empty JSON" "Script crashed on empty input"

# 12. Opus recognized
OUT_OPUS=$(run_script "$HIGH")
echo "$OUT_OPUS" | grep -qi "opus" && pass "Opus model recognized" || fail "Opus model recognized" "Opus not in output"

# 13. Output is single line
LINE_COUNT=$(echo "$OUT" | wc -l | tr -d ' ')
[ "$LINE_COUNT" -eq 1 ] && pass "Single-line output" || fail "Single-line output" "Got $LINE_COUNT lines"

# 14. jq available (dependency check)
command -v jq &>/dev/null && pass "jq available" || fail "jq available" "Install: brew install jq"

# 15. bc available (dependency check)
command -v bc &>/dev/null && pass "bc available" || fail "bc available" "Install: brew install bc"

# --- Summary ---
printf "\n${BOLD}Results: ${GREEN}%d passed${RESET}, ${RED}%d failed${RESET}\n" "$PASS" "$FAIL"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
