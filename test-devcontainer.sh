#!/bin/bash
# ==============================================================================
# Test du DevContainer depuis l'intérieur du container
# Usage: ./test-devcontainer.sh
# ==============================================================================

set -e

echo "=========================================="
echo "[TEST] Claude DevContainer - Tests internes"
echo "=========================================="
echo ""

# Démarrer le proxy
echo "[PROXY] Démarrage du proxy..."
start-proxy
echo ""

# Attendre un peu
sleep 2

# Exécuter les tests
echo "[TEST] Exécution des tests..."
test-proxy
TEST_RESULT=$?
echo ""

# Résultat
if [ $TEST_RESULT -eq 0 ]; then
    echo "[OK] Tous les tests ont réussi!"
else
    echo "[FAIL] Certains tests ont échoué"
fi

echo ""
echo "=========================================="
echo "[DONE] Test terminé"
echo "=========================================="

exit $TEST_RESULT
