# Personnalisation

Toutes les modifications se font dans `~/.claude/statusline.sh`.

---

## 1. Masquer la consommation d'eau

Commenter ou supprimer :
```bash
# printf "💧 ${CYAN}%smL${RESET}" "$WATER_DISPLAY"
# printf " │ "
```

## 2. Masquer le coût

```bash
# printf "€${GREEN}%s${RESET}" "$COST_DISPLAY"
```

## 3. Masquer Git

Commenter le bloc `if [ -n "$GIT_BRANCH" ]`.

## 4. Changer les seuils de couleur

```bash
# Par défaut : warning à 70%, danger à 85%
CTX_COLOR=$GREEN
if [ "$(echo "$CONTEXT_PCT > 90" | bc -l)" = "1" ]; then  # danger à 90%
  CTX_COLOR=$RED
elif [ "$(echo "$CONTEXT_PCT > 75" | bc -l)" = "1" ]; then  # warning à 75%
  CTX_COLOR=$YELLOW
fi
```

## 5. Ajouter l'heure

```bash
TIME=$(date +%H:%M)
printf " │ %s" "$TIME"
```

## 6. Ajouter estimation CO₂

```bash
# ~0.5g CO₂ par 1000 tokens (estimation datacenter)
CO2=$(echo "scale=2; $TOTAL_TOKENS / 1000 * 0.5" | bc -l)
printf " │ 🌱 %.1fg" "$CO2"
```

## 7. Changer l'emoji eau

Remplacer `💧` par `🌊` ou supprimer l'emoji.

## 8. Afficher les tokens bruts

```bash
printf " │ %d↑ %d↓" "$TOTAL_INPUT" "$TOTAL_OUTPUT"
```

## 9. Changer les taux eau par modèle

```bash
case "$MODEL_LABEL" in
  Opus)   WATER_RATE="0.006" ;;  # plus conservateur
  Sonnet) WATER_RATE="0.003" ;;
  Haiku)  WATER_RATE="0.001" ;;
esac
```

## 10. Modifier le taux de change USD→EUR

```bash
# Remplacer 0.92 par le taux actuel
INPUT_COST=$(echo "scale=4; $TOTAL_INPUT / 1000000 * 3 * 0.95" | bc -l)
```

## 11. Afficher en USD plutôt qu'EUR

Remplacer `* 0.92` par `* 1` et `€` par `$`.

## 12. Format compact (sans séparateurs)

```bash
printf "%s %s%% %s €%s\n" "$MODEL_LABEL" "$CONTEXT_PCT" "$GIT_BRANCH" "$COST_DISPLAY"
```

## 13. Ajouter nom d'utilisateur

```bash
printf " │ %s" "$(whoami)"
```

## 14. Afficher durée session (approximée)

Nécessite de stocker un timestamp au démarrage — voir docs/ADVANCED.md.

## 15. Désactiver les couleurs

Remplacer toutes les variables couleur par `""` en haut du script :
```bash
RED='' YELLOW='' GREEN='' CYAN='' BLUE='' MAGENTA='' BOLD='' RESET=''
```
