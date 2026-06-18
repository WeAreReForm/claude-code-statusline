# claude-code-statusline

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)
![Shell: Bash](https://img.shields.io/badge/Shell-Bash-orange.svg)

Status line graphique pour [Claude Code](https://claude.ai/code) : modèle actif, barre de contexte, branche git, dossier, coût de session, consommation d'eau estimée, mode fast et rate limits.

```
✦ Sonnet ╱ ▰▰▱▱▱▱▱▱ 12% ╱ ⎇ main ✎2 ╱ 📁 my-project ╱ 💧 ~0.44cL ╱ 🪙 €0.043 ╱ ⚡ fast ╱ ⏱ 55%
```

---

## Prérequis

- macOS (Linux compatible)
- `bash` 3.2+
- `jq` → `brew install jq`
- `bc` → inclus sur macOS

---

## Installation

### Rapide (30 secondes)
```bash
git clone https://github.com/WeAreReForm/claude-code-statusline.git
cd claude-code-statusline
bash install.sh
```
Puis redémarre Claude Code.

### Manuelle
```bash
cp scripts/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Ajouter dans `~/.claude/settings.json` :
```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh"
}
```

---

## Ce qui s'affiche

| Segment | Exemple | Description |
|---|---|---|
| Modèle | `✦ Sonnet` | Modèle actif (Opus / Sonnet / Haiku) |
| Contexte | `▰▰▱▱▱▱▱▱ 12%` | Barre de progression + % utilisé |
| Git | `⎇ main ✎2` | Branche active + nb fichiers modifiés |
| Dossier | `📁 my-project` | Dossier du projet Claude Code |
| Eau | `💧 ~0.44cL` | Consommation eau estimée (centilitres) |
| Coût | `🪙 €0.043` | Coût réel de la session (USD → EUR) |
| Fast | `⚡ fast` | Affiché uniquement si fast mode actif |
| Rate limit | `⏱ 55%` | % du quota 5h utilisé (masqué si 0) |

### Couleurs de la barre de contexte

| Seuil | Couleur |
|---|---|
| < 70% | Orange |
| 70–85% | Jaune-orange |
| > 85% | Rouge |

---

## Consommation d'eau

Estimation basée sur la consommation de refroidissement des datacenters (valeurs indicatives) :

| Modèle | cL/1000 tokens |
|---|---|
| Opus | ~0.4 |
| Sonnet | ~0.2 |
| Haiku | ~0.1 |

Le préfixe `~` rappelle que ces chiffres sont des approximations.

---

## Taux de change

Le coût est converti USD → EUR avec un taux fixe de `0.92`. Modifier la ligne dans `statusline.sh` si besoin :

```bash
TOTAL_COST=$(echo "scale=4; $COST_USD * 0.92" | bc -l)
```

---

## FAQ

**La status line ne s'affiche pas ?**
Vérifie que `statusLine.command` pointe vers `~/.claude/statusline.sh` dans `settings.json`.

**Le dossier affiché est `~` au lieu du projet ?**
Lance Claude Code depuis le terminal dans le dossier du projet, pas depuis le menu global.

**Erreur `jq: command not found` ?**
`brew install jq`

---

## Documentation

- [Installation détaillée](docs/INSTALLATION.md)
- [Personnalisation](docs/PERSONALIZATION.md)
- [Dépannage](docs/TROUBLESHOOTING.md)

---

## Roadmap

- [x] v1.0 — modèle, contexte, git, eau, coût
- [x] v1.1 — barre de progression, palette orange, coût réel, fast mode, rate limits
- [ ] v1.2 — support Linux/Windows WSL
- [ ] v1.3 — CO₂ estimation

---

## License

MIT — Copyright 2026 ReForm
