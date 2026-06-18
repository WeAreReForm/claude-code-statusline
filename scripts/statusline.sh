#!/usr/bin/env bash
# statusline.sh — Claude Code status line (graphical edition)
# Reads JSON from stdin, outputs colored ANSI string

set -euo pipefail

# Use $'...' so ESC byte (0x1B) is stored correctly in variables
# — works in printf %s arguments AND direct format strings
ORANGE=$'\033[38;5;208m'
ORANGE_LIGHT=$'\033[38;5;214m'
ORANGE_DARK=$'\033[38;5;202m'
ORANGE_WARM=$'\033[38;5;172m'
YELLOW_ORANGE=$'\033[38;5;220m'
RED=$'\033[0;31m'
GRAY=$'\033[38;5;240m'
GRAY_LIGHT=$'\033[38;5;245m'
WHITE=$'\033[1;37m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# --- Progress bar (▰ filled / ▱ empty) ---
progress_bar() {
  local pct=$1
  local width=${2:-8}
  local filled=$(echo "scale=0; $pct * $width / 100" | bc 2>/dev/null || echo 0)
  local empty=$((width - filled))
  local i=0

  local bar_color="$ORANGE"
  if [ "$(echo "$pct > 85" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
    bar_color="$RED"
  elif [ "$(echo "$pct > 70" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
    bar_color="$YELLOW_ORANGE"
  fi

  printf "%s" "$bar_color"
  i=0; while [ $i -lt "$filled" ]; do printf "▰"; i=$((i + 1)); done
  printf "%s" "$GRAY"
  i=0; while [ $i -lt "$empty" ]; do printf "▱"; i=$((i + 1)); done
  printf "%s" "$RESET"
}

# --- Read JSON from stdin ---
INPUT=$(cat)

if command -v jq &>/dev/null; then
  MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "unknown"')
  CONTEXT_PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')
  TOTAL_INPUT=$(echo "$INPUT" | jq -r '.context_window.total_input_tokens // 0')
  TOTAL_OUTPUT=$(echo "$INPUT" | jq -r '.context_window.total_output_tokens // 0')
else
  MODEL="unknown"; CONTEXT_PCT=0; TOTAL_INPUT=0; TOTAL_OUTPUT=0
fi

# --- Model label ---
case "$MODEL" in
  *opus*)   MODEL_LABEL="Opus"   ;;
  *sonnet*) MODEL_LABEL="Sonnet" ;;
  *haiku*)  MODEL_LABEL="Haiku"  ;;
  *)        MODEL_LABEL="$MODEL" ;;
esac

# --- Context text color ---
CTX_COLOR="$ORANGE"
if [ "$(echo "$CONTEXT_PCT > 85" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
  CTX_COLOR="$RED"
elif [ "$(echo "$CONTEXT_PCT > 70" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
  CTX_COLOR="$YELLOW_ORANGE"
fi

# --- Cost estimate (USD → EUR) ---
INPUT_COST=$(echo  "scale=4; $TOTAL_INPUT  / 1000000 * 3  * 0.92" | bc -l 2>/dev/null || echo "0")
OUTPUT_COST=$(echo "scale=4; $TOTAL_OUTPUT / 1000000 * 15 * 0.92" | bc -l 2>/dev/null || echo "0")
TOTAL_COST=$(echo  "scale=4; $INPUT_COST + $OUTPUT_COST"           | bc -l 2>/dev/null || echo "0")
COST_DISPLAY=$(printf "%.3f" "$TOTAL_COST" 2>/dev/null || echo "0.000")

# --- Water consumption ---
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
GIT_PART=""
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  GIT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "")
  MODIFIED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$MODIFIED" -gt 0 ]; then
    GIT_PART="${ORANGE_LIGHT}⎇ ${GIT_BRANCH}${ORANGE_WARM} ✎${MODIFIED}${RESET}"
  else
    GIT_PART="${ORANGE_LIGHT}⎇ ${GIT_BRANCH}${RESET}"
  fi
fi

FOLDER=$(basename "$PWD")
SEP="${GRAY_LIGHT} ╱ ${RESET}"

# --- Build output ---
printf "%s✦%s %s%s%s" "$ORANGE" "$RESET" "$WHITE$BOLD" "$MODEL_LABEL" "$RESET"
printf "%s" "$SEP"
progress_bar "$CONTEXT_PCT" 8
printf " %s%s%s%s%%" "$CTX_COLOR" "$BOLD" "$CONTEXT_PCT" "$RESET"
printf "%s" "$SEP"
if [ -n "$GIT_PART" ]; then
  printf "%s" "$GIT_PART"
  printf "%s" "$SEP"
fi
printf "%s📁 %s%s" "$GRAY_LIGHT" "$FOLDER" "$RESET"
printf "%s" "$SEP"
printf "💧 %s%smL%s" "$ORANGE_LIGHT" "$WATER_DISPLAY" "$RESET"
printf "%s" "$SEP"
printf "🪙 %s€%s%s" "$ORANGE" "$COST_DISPLAY" "$RESET"
printf "\n"
