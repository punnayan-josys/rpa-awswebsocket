#!/bin/bash

echo "🧪 Testing Client API Endpoints"
echo "==============================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Test 1: Send events to create data
echo ""
print_info "Step 1: Creating test data..."

# Send multiple events for the same client
for i in {1..3}; do
    response=$(curl -s -X POST http://localhost:3001/send-event \
        -H 'Content-Type: application/json' \
        -d "{
            \"clientId\": \"demo-client-001\",
            \"sessionId\": \"demo-session-001\",
            \"action\": \"click\",
            \"target\": \"#button-$i\"
        }")
    print_status "Sent event $i for demo-client-001"
done

# Send events for another client
for i in {1..2}; do
    response=$(curl -s -X POST http://localhost:3001/send-event \
        -H 'Content-Type: application/json' \
        -d "{
            \"clientId\": \"demo-client-002\",
            \"sessionId\": \"demo-session-002\",
            \"action\": \"type\",
            \"target\": \"#input-$i\",
            \"value\": \"test-value-$i\"
        }")
    print_status "Sent event $i for demo-client-002"
done

echo ""
print_info "Step 2: Testing system overview..."
response=$(curl -s http://localhost:3001/overview)
echo "System Overview: $response" | jq '.'

echo ""
print_info "Step 3: Testing pending steps by session..."
response=$(curl -s http://localhost:3001/pending-steps/demo-session-001)
echo "Pending Steps for demo-session-001: $response" | jq '.'

echo ""
print_info "Step 4: Testing client by session API..."
response=$(curl -s http://localhost:3001/client/demo-client-001/session/demo-session-001)
echo "Client demo-client-001 in demo-session-001: $response" | jq '.'

echo ""
print_info "Step 5: Testing non-existent client..."
response=$(curl -s http://localhost:3001/client/non-existent-client)
echo "Non-existent client response: $response" | jq '.'

echo ""
print_status "Client API testing completed!"
echo ""
echo "🌐 Available Endpoints:"
echo "  - GET /overview - System overview"
echo "  - GET /pending-steps/{sessionId} - Get pending steps by session"
echo "  - GET /client/{clientId}/session/{sessionId} - Get client data by session"
echo "  - POST /send-event - Send RPA event"
echo ""
echo "📊 Dashboard: http://localhost:3001/dashboard.html" 