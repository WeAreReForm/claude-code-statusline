# Dépannage

## La status line ne s'affiche pas

**Vérifier settings.json :**
```bash
cat ~/.claude/settings.json | jq '.statusLine'
```
Doit retourner :
```json
{ "type": "command", "command": "~/.claude/statusline.sh" }
```

**Vérifier que le fichier existe :**
```bash
ls -la ~/.claude/statusline.sh
```

**Vérifier les permissions :**
```bash
chmod +x ~/.claude/statusline.sh
```

---

## Erreur "jq: command not found"

```bash
brew install jq
```

Sur Linux :
```bash
sudo apt-get install jq   # Debian/Ubuntu
sudo yum install jq       # CentOS/RHEL
```

---

## Erreur "bc: command not found"

```bash
brew install bc
```

---

## Sortie vide ou incomplète

Tester manuellement :
```bash
echo '{"model":{"display_name":"claude-sonnet-4-6"},"context_window":{"used_percentage":12,"total_input_tokens":5000,"total_output_tokens":800}}' | bash ~/.claude/statusline.sh
```

Si erreur, activer le mode debug :
```bash
bash -x ~/.claude/statusline.sh <<< '{"model":{"display_name":"claude-sonnet-4-6"},"context_window":{"used_percentage":12,"total_input_tokens":5000,"total_output_tokens":800}}'
```

---

## Caractères illisibles dans le terminal

Les codes ANSI peuvent mal s'afficher dans certains terminaux. Pour désactiver les couleurs, modifier le début de `statusline.sh` :
```bash
RED='' YELLOW='' GREEN='' CYAN='' BLUE='' MAGENTA='' BOLD='' RESET=''
```

---

## Git: "fatal: not a git repository"

Normal si le dossier courant n'est pas un repo git — la section git est simplement masquée.

---

## Tests échouent

```bash
bash tests/test-statusline.sh
```

Chaque test `✗` affiche la raison. Corriger les dépendances manquantes en priorité.

---

## Contacter le support

Ouvrir une issue sur GitHub ou consulter [docs/NOTION-LINK.md](NOTION-LINK.md).
