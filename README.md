# Claude DevContainer

Dev container pour utiliser Claude Code avec des LLM d'entreprise (Mistral, Codestral) via un proxy Go.

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

Éditez `.devcontainer/.env` :

```env
# Provider Mammouth.ai
OPENAI_BASE_URL=https://api.mammouth.ai/v1
OPENAI_API_KEY=sk-votre-clé-mammouth-ici

# Mapping des modèles Claude → Mistral/Codestral
ANTHROPIC_DEFAULT_OPUS_MODEL=mistral-large-3
ANTHROPIC_DEFAULT_SONNET_MODEL=codestral-2508
ANTHROPIC_DEFAULT_HAIKU_MODEL=mistral-small-3.2-24b-instruct
```

## Utilisation

Le proxy démarre automatiquement avec le container. Claude Code est pré-configuré pour l'utiliser.

```bash
# Utiliser Claude Code directement
claude

# Commandes proxy
start-proxy   # Démarrer le proxy
stop-proxy    # Arrêter le proxy
test-proxy    # Tester le proxy

# Vérifier le statut du proxy
curl http://localhost:8082/
```

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Claude Code    │────▶│  Proxy Go       │────▶│  Mammouth.ai    │
│  CLI/VS Code    │     │  (localhost:    │     │  Mistral/       │
│                 │◀────│   8082)         │◀────│  Codestral      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

Le proxy traduit les requêtes Claude API → OpenAI API et inversement.

## Proxy

Le proxy utilisé est [claude-code-proxy](https://github.com/nielspeter/claude-code-proxy) (Go).

**Caractéristiques :**
- Binaire unique ~8MB, zéro dépendances
- Démarrage < 10ms
- Support complet de Claude Code (tools, streaming, thinking blocks)
- Détection adaptative par modèle

## Dépannage

### Le proxy ne démarre pas
- Vérifiez que le fichier `.env` existe et est correctement configuré
- Vérifiez les logs : `cat /tmp/claude-code-proxy.log`

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
