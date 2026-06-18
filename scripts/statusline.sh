#!/usr/bin/env bash
# statusline.sh — Claude Code status line: model | context | git | folder | water | cost
# Reads JSON from stdin, outputs colored ANSI string

set -euo pipefail

# --- Color codes ---
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Read JSON from stdin ---
INPUT=$(cat)

# Extract fields (fallback to defaults if jq not available or field missing)
if command -v jq &>/dev/null; then
  MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "unknown"')
  CONTEXT_PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')
  TOTAL_INPUT=$(echo "$INPUT" | jq -r '.context_window.total_input_tokens // 0')
  TOTAL_OUTPUT=$(echo "$INPUT" | jq -r '.context_window.total_output_tokens // 0')
else
  MODEL="unknown"
  CONTEXT_PCT=0
  TOTAL_INPUT=0
  TOTAL_OUTPUT=0
fi

# --- Context color ---
CTX_COLOR=$GREEN
if [ "$(echo "$CONTEXT_PCT > 85" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
  CTX_COLOR=$RED
elif [ "$(echo "$CONTEXT_PCT > 70" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
  CTX_COLOR=$YELLOW
fi

# --- Model short name ---
case "$MODEL" in
  *opus*)   MODEL_LABEL="Opus"   ;;
  *sonnet*) MODEL_LABEL="Sonnet" ;;
  *haiku*)  MODEL_LABEL="Haiku"  ;;
  *)        MODEL_LABEL="$MODEL" ;;
esac

# --- Cost estimate (USD → EUR at 0.92) ---
# Sonnet: $3/MTok input, $15/MTok output
INPUT_COST=$(echo "scale=4; $TOTAL_INPUT / 1000000 * 3 * 0.92" | bc -l 2>/dev/null || echo "0")
OUTPUT_COST=$(echo "scale=4; $TOTAL_OUTPUT / 1000000 * 15 * 0.92" | bc -l 2>/dev/null || echo "0")
TOTAL_COST=$(echo "scale=4; $INPUT_COST + $OUTPUT_COST" | bc -l 2>/dev/null || echo "0")
COST_DISPLAY=$(printf "%.3f" "$TOTAL_COST" 2>/dev/null || echo "0.000")

# --- Water consumption (mL) ---
# Rough estimates: Opus ~0.004 mL/token, Sonnet ~0.002 mL/token, Haiku ~0.001 mL/token
case "$MODEL_LABEL" in
  Opus)   WATER_RATE="0.004" ;;
  Sonnet) WATER_RATE="0.002" ;;
  Haiku)  WATER_RATE="0.001" ;;
  *)      WATER_RATE="0.002" ;;
esac
TOTAL_TOKENS=$(echo "$TOTAL_INPUT + $TOTAL_OUTPUT" | bc 2>/dev/null || echo "0")
WATER_ML=$(echo "scale=1; $TOTAL_TOKENS * $WATER_RATE" | bc -l 2>/dev/null || echo "0")
WATER_DISPLAY=$(printf "%.1f" "$WATER_ML" 2>/dev/null || echo "0.0")

# --- Git info ---
GIT_BRANCH=""
GIT_DIRTY=""
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  GIT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || "")
  MODIFIED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [ "$MODIFIED" -gt 0 ] && GIT_DIRTY=" *${MODIFIED}" || GIT_DIRTY=""
fi

# --- Current folder (basename) ---
FOLDER=$(basename "$PWD")

# --- Build output ---
printf "${BOLD}${CYAN}%s${RESET}" "$MODEL_LABEL"
printf " ${RESET}│${RESET} "
printf "${CTX_COLOR}%s%%%s" "$CONTEXT_PCT" "${RESET}"
printf " │ "
if [ -n "$GIT_BRANCH" ]; then
  printf "${BLUE} %s${MAGENTA}%s${RESET}" "$GIT_BRANCH" "$GIT_DIRTY"
  printf " │ "
fi
printf "${RESET} %s" "$FOLDER"
printf " │ "
printf "💧 ${CYAN}%smL${RESET}" "$WATER_DISPLAY"
printf " │ "
printf "€${GREEN}%s${RESET}" "$COST_DISPLAY"
printf "\n"
