#!/bin/bash
# ==============================================================================
# Firewall initialization script for Claude DevContainer
# Implements restrictive firewall with allowlist for essential services
# ==============================================================================

set -euo pipefail

echo "🔒 Initializing firewall..."

# ==============================================================================
# Helper functions
# ==============================================================================

# Validate IP address format
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    fi
    return 1
}

# Validate CIDR format
validate_cidr() {
    local cidr=$1
    if [[ $cidr =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        return 0
    fi
    return 1
}

# Add IP or CIDR to allowlist
add_to_allowlist() {
    local addr=$1
    if validate_cidr "$addr"; then
        ipset add allowed-domains "$addr" 2>/dev/null || true
    elif validate_ip "$addr"; then
        ipset add allowed-domains "$addr" 2>/dev/null || true
    fi
}

# Resolve domain to IPs and add to allowlist
allow_domain() {
    local domain=$1
    echo "  ✓ Allowing $domain"
    local ips=$(dig +short "$domain" A | grep -E '^[0-9]+\.')
    for ip in $ips; do
        add_to_allowlist "$ip"
    done
}

# ==============================================================================
# Create ipset for allowed domains
# ==============================================================================

# Flush and create ipset
ipset destroy allowed-domains 2>/dev/null || true
ipset create allowed-domains hash:net

# ==============================================================================
# Preserve Docker DNS and add essential rules
# ==============================================================================

echo "📡 Configuring essential rules..."

# Allow localhost
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Allow established and related connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow DNS (port 53)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow SSH (port 22)
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# ==============================================================================
# GitHub IP ranges
# ==============================================================================

echo "🐙 Adding GitHub IP ranges..."
GITHUB_IPS=$(curl -s https://api.github.com/meta | jq -r '.git[]' 2>/dev/null || echo "")
for cidr in $GITHUB_IPS; do
    add_to_allowlist "$cidr"
done

# ==============================================================================
# NPM registry
# ==============================================================================

echo "📦 Adding npm registry..."
allow_domain "registry.npmjs.org"

# ==============================================================================
# Anthropic APIs
# ==============================================================================

echo "🤖 Adding Anthropic APIs..."
allow_domain "api.anthropic.com"
allow_domain "api.claude.ai"

# ==============================================================================
# Mammouth.ai API
# ==============================================================================

echo "🐘 Adding Mammouth.ai API..."
allow_domain "api.mammouth.ai"
allow_domain "mammouth.ai"

# ==============================================================================
# VS Code services
# ==============================================================================

echo "💻 Adding VS Code services..."
allow_domain "update.code.visualstudio.com"
allow_domain "vscode.download.prss.microsoft.com"
allow_domain "marketplace.visualstudio.com"

# ==============================================================================
# Docker internal network
# ==============================================================================

echo "🐳 Adding Docker network..."
# Get Docker network from default route
DOCKER_NETWORK=$(ip route | grep default | awk '{print $3}' | cut -d. -f1-3)
if [ -n "$DOCKER_NETWORK" ]; then
    add_to_allowlist "${DOCKER_NETWORK}.0/24"
fi

# ==============================================================================
# Apply firewall rules
# ==============================================================================

echo "🛡️  Applying firewall rules..."

# Allow traffic to allowlisted IPs
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

# Default DROP policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# ==============================================================================
# Verification
# ==============================================================================

echo "✅ Firewall configured successfully"
echo ""
echo "Testing connectivity:"

# Test blocked site
if ! curl -s --max-time 2 http://example.com > /dev/null 2>&1; then
    echo "  ✓ Blocked: example.com (expected)"
else
    echo "  ✗ Warning: example.com is accessible (unexpected)"
fi

# Test allowed site
if curl -s --max-time 2 https://api.github.com > /dev/null 2>&1; then
    echo "  ✓ Allowed: api.github.com (expected)"
else
    echo "  ✗ Warning: api.github.com is blocked (unexpected)"
fi

echo ""
echo "🔒 Firewall is active and restrictive"
