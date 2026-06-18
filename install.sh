#!/usr/bin/env bash
# install.sh — Install claude-code-statusline to ~/.claude/

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { printf "${GREEN}✓${RESET} %s\n" "$1"; }
warn() { printf "${YELLOW}!${RESET} %s\n" "$1"; }
err()  { printf "${RED}✗${RESET} %s\n" "$1"; exit 1; }
step() { printf "\n${BOLD}%s${RESET}\n" "$1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

printf "${BOLD}claude-code-statusline installer${RESET}\n"
printf "Target: %s\n\n" "$CLAUDE_DIR"

# --- Check prerequisites ---
step "Checking prerequisites..."

command -v bash &>/dev/null && ok "bash found" || err "bash not found"
command -v jq   &>/dev/null && ok "jq found"   || warn "jq missing — install: brew install jq"
command -v bc   &>/dev/null && ok "bc found"   || warn "bc missing — install: brew install bc"
command -v git  &>/dev/null && ok "git found"  || warn "git not found (optional)"

# --- Create ~/.claude if needed ---
step "Setting up ~/.claude/..."
mkdir -p "$CLAUDE_DIR"
ok "~/.claude/ ready"

# --- Copy main script ---
step "Installing scripts..."
cp "${SCRIPT_DIR}/scripts/statusline.sh" "${CLAUDE_DIR}/statusline.sh"
chmod +x "${CLAUDE_DIR}/statusline.sh"
ok "statusline.sh installed → ${CLAUDE_DIR}/statusline.sh"

# --- Update settings.json ---
step "Configuring settings.json..."
SETTINGS="${CLAUDE_DIR}/settings.json"

if [ -f "$SETTINGS" ]; then
  # Backup existing settings
  cp "$SETTINGS" "${SETTINGS}.bak"
  warn "Backed up existing settings.json → settings.json.bak"

  if command -v jq &>/dev/null; then
    UPDATED=$(jq '.statusLine = {"type":"command","command":"~/.claude/statusline.sh"}' "$SETTINGS")
    echo "$UPDATED" > "$SETTINGS"
    ok "settings.json updated"
  else
    warn "jq not found — manually add to settings.json:"
    printf '  "statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}\n'
  fi
else
  cp "${SCRIPT_DIR}/config/settings.json" "$SETTINGS"
  ok "settings.json created"
fi

# --- Quick test ---
step "Running quick test..."
TEST_JSON='{"model":{"display_name":"claude-sonnet-4-6"},"context_window":{"used_percentage":12,"total_input_tokens":5000,"total_output_tokens":800}}'
OUTPUT=$(echo "$TEST_JSON" | bash "${CLAUDE_DIR}/statusline.sh" 2>/dev/null || true)

if [ -n "$OUTPUT" ]; then
  ok "statusline.sh runs correctly"
  printf "  Preview: %s\n" "$OUTPUT"
else
  warn "statusline.sh produced no output — check dependencies"
fi

# --- Done ---
printf "\n${BOLD}${GREEN}Installation complete!${RESET}\n"
printf "Restart Claude Code to see the status line.\n\n"
printf "To test manually:\n"
printf "  bash tests/test-statusline.sh\n\n"
printf "To customize:\n"
printf "  edit %s\n" "${CLAUDE_DIR}/statusline.sh"
