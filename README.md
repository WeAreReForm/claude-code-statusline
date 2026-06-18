# claude-code-statusline

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)
![Shell: Bash](https://img.shields.io/badge/Shell-Bash-orange.svg)

Status line riche pour Claude Code : modèle, contexte, git, coût estimé et consommation d'eau.

```
Sonnet │ 12% │  main │ my-project │ 💧 11.6mL │ €0.014
```

---

## Installation rapide

### 30 secondes
```bash
bash install.sh
```
Puis redémarre Claude Code.

### 1 minute (manuelle)
```bash
cp scripts/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
# Ajouter dans ~/.claude/settings.json :
# "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```

### 5 minutes (avec personnalisation)
Lire [docs/PERSONALIZATION.md](docs/PERSONALIZATION.md).

---

## Ce qui s'affiche

| Élément | Exemple | Description |
|---|---|---|
| Modèle | `Sonnet` | Modèle actif (Opus/Sonnet/Haiku) |
| Contexte | `12%` | Fenêtre de contexte utilisée |
| Git | ` main *3` | Branche + fichiers modifiés |
| Dossier | `my-project` | Dossier courant |
| Eau | `💧 11.6mL` | Consommation eau estimée |
| Coût | `€0.014` | Coût session estimé |

### Couleurs contexte
- `< 70%` → vert
- `70–85%` → jaune (attention)
- `> 85%` → rouge (critique)

---

## Consommation d'eau

Chaque token consomme de l'eau (refroidissement datacenters) :

| Modèle | mL/token |
|---|---|
| Opus | ~0.004 |
| Sonnet | ~0.002 |
| Haiku | ~0.001 |

Ces chiffres sont des estimations — les valeurs réelles varient selon les datacenters.

---

## Pré-requis

- macOS (Linux compatible)
- `bash` 3.2+
- `jq` — `brew install jq`
- `bc` — inclus sur macOS

---

## FAQ

**La status line ne s'affiche pas ?**
Vérifie que `statusLine.command` pointe bien vers `~/.claude/statusline.sh` dans settings.json.

**Erreur "bc: command not found" ?**
`brew install bc` sur macOS (normalement déjà présent).

**Personnaliser les seuils de couleur ?**
Voir [docs/PERSONALIZATION.md](docs/PERSONALIZATION.md).

---

## Documentation

- [Installation détaillée](docs/INSTALLATION.md)
- [Personnalisation](docs/PERSONALIZATION.md)
- [Dépannage](docs/TROUBLESHOOTING.md)
- [Usage avancé](docs/ADVANCED.md)
- [Source Notion](docs/NOTION-LINK.md)

---

## Roadmap

- [x] v1.0 — modèle, contexte, git, eau, coût
- [ ] v1.1 — CO₂ estimation
- [ ] v1.2 — webhook n8n intégré
- [ ] v1.3 — support Linux/Windows WSL

---

## License

MIT — Copyright 2026 ReForm
