# Usage avancé

## Intégration n8n

Envoyer les stats vers n8n automatiquement via webhook :

```bash
# Dans scripts/log-daily.sh, configurer :
export N8N_WEBHOOK_URL="https://votre-n8n.example.com/webhook/claude-stats"
bash scripts/log-daily.sh
```

Structure du payload JSON envoyé :
```json
{
  "date": "2026-06-18",
  "sessions": 3,
  "total_tokens": 150000,
  "total_cost_eur": 0.42,
  "water_ml": 300.0,
  "models_used": ["sonnet", "haiku"]
}
```

---

## Alertes Slack

Alerte quand le contexte dépasse 85% — ajouter dans `statusline.sh` :

```bash
if [ "$(echo "$CONTEXT_PCT > 85" | bc -l)" = "1" ] && [ -n "${SLACK_WEBHOOK:-}" ]; then
  curl -s -X POST "$SLACK_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{\"text\":\"⚠️ Claude Code contexte à ${CONTEXT_PCT}% — pense à compresser\"}"
fi
```

---

## Dashboard Notion

Utiliser le MCP Notion dans Claude Code pour créer automatiquement des entrées quotidiennes :

1. Configurer le MCP Notion dans `~/.claude/settings.json`
2. Demander à Claude Code :
   ```
   Crée une entrée Notion aujourd'hui avec mes stats : X tokens, €Y, ZmL eau
   ```

---

## Logging Supabase

Stocker les stats dans Supabase pour analytics :

```bash
# Créer une table stats dans Supabase
# Puis envoyer via l'API REST :
curl -X POST "https://votre-projet.supabase.co/rest/v1/claude_stats" \
  -H "apikey: VOTRE_CLE" \
  -H "Content-Type: application/json" \
  -d '{"date":"2026-06-18","tokens":150000,"cost_eur":0.42}'
```

---

## Durée de session

Stocker l'heure de début dans un fichier temporaire :

```bash
# Au début du script
SESSION_START_FILE="/tmp/.claude-session-start"
if [ ! -f "$SESSION_START_FILE" ]; then
  date +%s > "$SESSION_START_FILE"
fi
START=$(cat "$SESSION_START_FILE")
NOW=$(date +%s)
ELAPSED=$(( (NOW - START) / 60 ))
printf " │ %dmin" "$ELAPSED"
```

---

## Rapport mensuel automatique

Via cron (remplacer l'heure selon besoin) :
```bash
# Ajouter dans crontab -e :
0 9 1 * * bash ~/Projects/claude-code-statusline/scripts/audit-monthly.sh >> ~/logs/claude-audit.log
```
