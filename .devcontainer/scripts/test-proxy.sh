#!/bin/bash
# Tests du proxy Claude Code avec Mammouth.ai/Codestral

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; PASSED=$((PASSED+1)); }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; FAILED=$((FAILED+1)); }
warn() { echo -e "${YELLOW}⚠️  WARN${NC}: $1"; }

# Compteurs
PASSED=0
FAILED=0

# URL du proxy
PROXY_URL="http://localhost:8082"

echo "=========================================="
echo "🧪 Tests du proxy Claude Code"
echo "   Proxy: $PROXY_URL"
echo "=========================================="

# Test 1: Health check
echo ""
echo "📋 Test 1: Health check"
if curl -s "$PROXY_URL/" | grep -q "running"; then
    pass "Health endpoint répond"
else
    fail "Health endpoint ne répond pas"
fi

# Test 2: Requête simple via curl (Haiku → mistral-small)
echo ""
echo "📋 Test 2: API directe - Haiku"
RESPONSE=$(curl -s -X POST "$PROXY_URL/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${ANTHROPIC_API_KEY:-test}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-haiku-20240307",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "Écris une fonction Python qui retourne la somme de deux nombres. Juste le code, sans explication."}]
  }')

if echo "$RESPONSE" | grep -q "content"; then
    pass "Haiku → mistral-small fonctionne"
    echo "   Réponse: $(echo $RESPONSE | jq -r '.content[0].text' 2>/dev/null | head -c 100)"
else
    fail "API ne répond pas: $RESPONSE"
fi

# Test 3: Requête via curl (Sonnet → codestral)
echo ""
echo "📋 Test 3: API directe - Sonnet"
RESPONSE=$(curl -s -X POST "$PROXY_URL/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${ANTHROPIC_API_KEY:-test}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "Écris une fonction JavaScript qui inverse un tableau. Juste le code, sans explication."}]
  }')

if echo "$RESPONSE" | grep -q "content"; then
    pass "Sonnet → codestral fonctionne"
    echo "   Réponse: $(echo $RESPONSE | jq -r '.content[0].text' 2>/dev/null | head -c 100)"
else
    fail "API ne répond pas: $RESPONSE"
fi

# Test 4: Requête via curl (Opus → mistral-large)
echo ""
echo "📋 Test 4: API directe - Opus"
RESPONSE=$(curl -s -X POST "$PROXY_URL/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${ANTHROPIC_API_KEY:-test}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4-20250514",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "Écris une fonction Go qui vérifie si un nombre est pair. Juste le code, sans explication."}]
  }')

if echo "$RESPONSE" | grep -q "content"; then
    pass "Opus → mistral-large fonctionne"
    echo "   Réponse: $(echo $RESPONSE | jq -r '.content[0].text' 2>/dev/null | head -c 100)"
else
    fail "API ne répond pas: $RESPONSE"
fi

# Test 5: Claude Code CLI
echo ""
echo "📋 Test 5: Claude Code CLI"
RESPONSE=$(claude -p "Réponds juste OK" --model haiku --max-turns 1 2>&1 || true)
if echo "$RESPONSE" | grep -qi "ok\|bonjour\|oui"; then
    pass "Claude CLI fonctionne"
    echo "   Réponse: $(echo $RESPONSE | head -c 100)"
else
    warn "Claude CLI - réponse: $(echo $RESPONSE | head -c 100)"
fi

# Résumé
echo ""
echo "=========================================="
echo "🎉 Tests terminés"
echo "=========================================="
echo ""
echo "Résumé: $PASSED passés, $FAILED échoués"
echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Tous les tests ont réussi${NC}"
    exit 0
else
    echo -e "${RED}❌ Certains tests ont échoué${NC}"
    exit 1
fi
