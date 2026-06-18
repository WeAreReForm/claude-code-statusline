# Installation

## Pré-requis

| Outil | Requis | Installation |
|---|---|---|
| bash 3.2+ | Oui | Inclus macOS |
| jq | Oui | `brew install jq` |
| bc | Oui | Inclus macOS |
| git | Optionnel | `brew install git` |

Vérifier :
```bash
bash --version
jq --version
bc --version
```

---

## Installation automatisée (recommandée)

```bash
cd claude-code-statusline
bash install.sh
```

Le script :
1. Vérifie les pré-requis
2. Copie `statusline.sh` vers `~/.claude/`
3. Met à jour `~/.claude/settings.json`
4. Lance un test rapide

Puis redémarre Claude Code.

---

## Installation manuelle

### 1. Copier le script
```bash
cp scripts/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

### 2. Configurer settings.json
Ouvrir `~/.claude/settings.json` et ajouter :
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

### 3. Vérifier
```bash
echo '{"model":{"display_name":"claude-sonnet-4-6"},"context_window":{"used_percentage":12,"total_input_tokens":5000,"total_output_tokens":800}}' | bash ~/.claude/statusline.sh
```

Doit afficher une ligne colorée avec Sonnet, 12%, eau et coût.

---

## Vérification complète

```bash
bash tests/test-statusline.sh
```

Tous les tests doivent afficher ✓.

---

## Désinstallation

```bash
rm ~/.claude/statusline.sh
# Supprimer la clé statusLine dans ~/.claude/settings.json
```
