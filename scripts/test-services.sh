#!/bin/bash
set -o pipefail

# Simple script to test the services from the terminal
# Usage: ./scripts/test-services.sh [LOAD_BALANCER_IP]

IP=${1:-"localhost"}
PORT=${2:-"8001"}
URL="http://$IP:$PORT"
MASTER_KEY="mymasterkey"

echo "--- Testing Auth Service at $URL ---"

echo "1. Health Check:"
curl -s "$URL/health" | jq . || echo "Failed to connect to /health"

echo -e "\n2. Database Health (Smoke Test):"
curl -s "$URL/health/db" | jq . || echo "Failed to connect to /health/db"

echo -e "\n3. Create API Key (Admin):"
CREATE_RESPONSE=$(curl -s -X POST "$URL/admin/keys" \
  -H "Authorization: Bearer $MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "CLI Test Key"}')

echo "$CREATE_RESPONSE" | jq .

# Extract the key if jq is available and request succeeded
API_KEY=$(echo "$CREATE_RESPONSE" | jq -r '.key' 2>/dev/null)

if [ "$API_KEY" != "null" ] && [ -n "$API_KEY" ]; then
    echo -e "\n4. Validate Generated Key ($API_KEY):"
    curl -s -X GET "$URL/validate" \
      -H "Authorization: Bearer $API_KEY" | jq .
else
    echo -e "\n4. Skip Validate (No key generated)"
fi

echo -e "\n--- Tests Completed ---"
