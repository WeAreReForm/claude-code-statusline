#!/usr/bin/env bash
# compare-models.sh — Compare water/cost across Opus/Sonnet/Haiku for N tokens

set -euo pipefail

TOKENS=${1:-100000}

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

calc_cost() {
  local input_rate=$1 output_rate=$2 tokens=$3
  echo "scale=4; ($tokens * 0.7 / 1000000 * $input_rate + $tokens * 0.3 / 1000000 * $output_rate) * 0.92" | bc -l
}

calc_water() {
  local rate=$1 tokens=$2
  echo "scale=1; $tokens * $rate" | bc -l
}

printf "${BOLD}Model comparison for %d tokens${RESET}\n\n" "$TOKENS"
printf "%-10s %-12s %-12s\n" "Model" "Cost (€)" "Water (mL)"
printf "%-10s %-12s %-12s\n" "----------" "------------" "------------"

for model in Opus Sonnet Haiku; do
  case "$model" in
    Opus)   ir=15  or=75  wr=0.004 ;;
    Sonnet) ir=3   or=15  wr=0.002 ;;
    Haiku)  ir=0.8 or=4   wr=0.001 ;;
  esac
  cost=$(calc_cost $ir $or $TOKENS)
  water=$(calc_water $wr $TOKENS)
  printf "${CYAN}%-10s${RESET} %-12s %-12s\n" "$model" "€$(printf '%.4f' $cost)" "${water}mL"
done

printf "\n${GREEN}Recommendation: Haiku for routine tasks, Sonnet for balanced, Opus for complex.${RESET}\n"
