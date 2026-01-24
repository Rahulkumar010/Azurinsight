#!/bin/bash
# Test script to send Hello World telemetry to Azurinsight
# Usage: ./test-telemetry.sh

set -e

echo "🚀 Sending Hello World telemetry to Azurinsight..."

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

RESPONSE=$(curl -s -X POST http://localhost:5000/v2.1/track \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Microsoft.ApplicationInsights.Message\",
    \"time\": \"$TIMESTAMP\",
    \"iKey\": \"test-key\",
    \"tags\": {
      \"ai.cloud.role\": \"test-script\",
      \"ai.cloud.roleInstance\": \"bash-shell\",
      \"ai.device.os\": \"$(uname -s)\"
    },
    \"data\": {
      \"baseType\": \"MessageData\",
      \"baseData\": {
        \"message\": \"Hello World from Bash Shell!\",
        \"severityLevel\": \"Information\"
      }
    }
  }")

echo "✓ Success!"
echo "Response: $RESPONSE"

echo ""
echo "📊 Querying telemetry..."
TELEMETRY=$(curl -s http://localhost:5000/api/query?top=5)

echo "$TELEMETRY" | jq -r '.value[] | "[\(.time)] \(.itemType): \(.data | fromjson | .baseData.message // .baseData.name // "N/A")"' 2>/dev/null || echo "$TELEMETRY"

echo ""
echo "💡 View all telemetry: curl http://localhost:5000/api/query"
echo "🗑️  Purge telemetry: curl -X DELETE http://localhost:5000/api/purge"
