# Claude DevContainer

Dev container pour utiliser Claude Code avec des LLM d'entreprise (Mistral, Codestral) via un proxy.

## Prérequis

- Docker Desktop
- VS Code avec l'extension "Dev Containers"

## Installation

1. **Cloner ce projet**
   ```bash
   git clone <ce-repo>
   cd claude-devcontainer
   ```

2. **Configurer les variables d'environnement**
   ```bash
   cp .devcontainer/.env.example .devcontainer/.env
   ```
   Éditez `.devcontainer/.env` avec vos clés API.

3. **Ouvrir dans VS Code**
   ```bash
   code .
   ```

4. **Lancer le dev container**
   - `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

## Configuration

### Phase Test 1 : Anthropic (validation)

Pour valider que le proxy fonctionne, utilisez les modèles Claude natifs :

```env
PREFERRED_PROVIDER="anthropic"
ANTHROPIC_API_KEY="sk-ant-votre-clé"
BIG_MODEL="claude-sonnet-4-20250514"
SMALL_MODEL="claude-haiku-4-20250514"
```

### Phase Test 2 : Mammouth.ai (LLM entreprise)

Pour utiliser les modèles d'entreprise :

```env
PREFERRED_PROVIDER="openai"
OPENAI_BASE_URL="https://api.mammouth.ai/v1"
OPENAI_API_KEY="votre-clé-mammouth"
BIG_MODEL="codestral-2508"
SMALL_MODEL="mistral-small-3.2-24b-instruct"
```

## Utilisation

### Démarrer le proxy

```bash
cd /workspace/claude-devcontainer
uv run uvicorn server:app --host 0.0.0.0 --port 8082 --reload
```

### Utiliser Claude Code

Dans un autre terminal :

```bash
# La variable ANTHROPIC_BASE_URL est déjà configurée
claude
```

Ou manuellement :

```bash
ANTHROPIC_BASE_URL=http://localhost:8082 claude
```

### Vérifier le proxy

```bash
curl http://localhost:8082/
```

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Claude Code    │────▶│  Proxy (8082)   │────▶│  Mammouth.ai    │
│  CLI/VS Code    │     │  claude-code-   │     │  Mistral/       │
│                 │◀────│  proxy          │◀────│  Codestral      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Phase 2 : Support 3 modèles (future)

Le proxy actuel supporte 2 modèles. Pour supporter les 3 modèles Claude :

| Modèle Claude | Variable | Modèle Mammouth.ai |
|---------------|----------|-------------------|
| Opus | `OPUS_MODEL` | `codestral-2508` |
| Sonnet | `SONNET_MODEL` | `mistral-medium-2312` |
| Haiku | `HAIKU_MODEL` | `mistral-small-3.2-24b-instruct` |

Cela nécessitera une modification de `server.py`.

## Dépannage

### Le proxy ne démarre pas
- Vérifiez que le fichier `.env` existe et est correctement configuré
- Vérifiez les logs : `docker-compose logs proxy`

### Claude Code ne se connecte pas
- Vérifiez que `ANTHROPIC_BASE_URL` pointe vers `http://localhost:8082`
- Testez le proxy : `curl http://localhost:8082/`

### Erreur d'authentification
- Vérifiez votre clé API dans `.env`
- Testez directement l'API Mammouth.ai :
  ```bash
  curl -H "Authorization: Bearer $OPENAI_API_KEY" \
       https://api.mammouth.ai/v1/models
  ```
