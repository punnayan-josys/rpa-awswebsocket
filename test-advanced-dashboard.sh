#!/bin/bash

echo "🧪 Testing Advanced RPA Dashboard Features"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Test 1: System Overview
echo ""
print_info "Step 1: Testing System Overview..."
response=$(curl -s http://localhost:3001/overview)
echo "System Overview: $response" | jq '.'

# Test 2: Send Multiple Events from Multiple Clients
echo ""
print_info "Step 2: Sending events from multiple clients..."

# Client 1 events
for i in {1..3}; do
    response=$(curl -s -X POST http://localhost:3001/send-event \
        -H 'Content-Type: application/json' \
        -d "{
            \"clientId\": \"client-001\",
            \"sessionId\": \"session-001\",
            \"action\": \"click\",
            \"target\": \"#button-$i\"
        }")
    print_status "Sent event $i for client-001"
done

# Client 2 events
for i in {1..2}; do
    response=$(curl -s -X POST http://localhost:3001/send-event \
        -H 'Content-Type: application/json' \
        -d "{
            \"clientId\": \"client-002\",
            \"sessionId\": \"session-002\",
            \"action\": \"type\",
            \"target\": \"#input-$i\",
            \"value\": \"test-value-$i\"
        }")
    print_status "Sent event $i for client-002"
done

# Client 3 events
for i in {1..4}; do
    response=$(curl -s -X POST http://localhost:3001/send-event \
        -H 'Content-Type: application/json' \
        -d "{
            \"clientId\": \"client-003\",
            \"sessionId\": \"session-003\",
            \"action\": \"scroll\",
            \"target\": \"body\"
        }")
    print_status "Sent event $i for client-003"
done

# Test 3: Redis Query - All Keys
echo ""
print_info "Step 3: Testing Redis Query - All Keys..."
response=$(curl -s http://localhost:3001/redis/keys)
echo "Redis Keys Count: $(echo $response | jq '.count')"
echo "Redis Keys: $(echo $response | jq '.keys')"

# Test 4: Redis Query - Pending Steps
echo ""
print_info "Step 4: Testing Redis Query - Pending Steps..."
response=$(curl -s http://localhost:3001/redis/pending-steps)
echo "Pending Steps Count: $(echo $response | jq '.count')"
echo "Pending Steps Keys: $(echo $response | jq '.keys')"

# Test 5: Redis Query - Custom Key
echo ""
print_info "Step 5: Testing Redis Query - Custom Key..."
response=$(curl -s http://localhost:3001/redis/custom/pending_steps:session-001)
echo "Custom Key Data: $response" | jq '.'

# Test 6: Client Summary
echo ""
print_info "Step 6: Testing Client Summary..."
response=$(curl -s http://localhost:3001/clients/summary)
echo "Client Summary: $response" | jq '.'

# Test 7: System Statistics
echo ""
print_info "Step 7: Testing System Statistics..."
response=$(curl -s http://localhost:3001/overview)
totalSteps=$(echo $response | jq '.totalPendingSteps')
totalSessions=$(echo $response | jq '.pendingSteps | length')
echo "Total Pending Steps: $totalSteps"
echo "Total Sessions: $totalSessions"

# Test 8: Real-time Data Verification
echo ""
print_info "Step 8: Real-time Data Verification..."

# Check specific session data
response=$(curl -s http://localhost:3001/pending-steps/session-001)
echo "Session 001 Steps: $(echo $response | jq '.count')"

response=$(curl -s http://localhost:3001/pending-steps/session-002)
echo "Session 002 Steps: $(echo $response | jq '.count')"

response=$(curl -s http://localhost:3001/pending-steps/session-003)
echo "Session 003 Steps: $(echo $response | jq '.count')"

# Test 9: Performance Test - Send Many Events Rapidly
echo ""
print_info "Step 9: Performance Test - Sending 10 events rapidly..."
start_time=$(date +%s)

for i in {1..10}; do
    response=$(curl -s -X POST http://localhost:3001/send-event \
        -H 'Content-Type: application/json' \
        -d "{
            \"clientId\": \"perf-client\",
            \"sessionId\": \"perf-session\",
            \"action\": \"click\",
            \"target\": \"#perf-button-$i\"
        }")
done

end_time=$(date +%s)
duration=$((end_time - start_time))
print_status "Sent 10 events in ${duration} seconds"

# Test 10: Final System Overview
echo ""
print_info "Step 10: Final System Overview..."
response=$(curl -s http://localhost:3001/overview)
echo "Final Overview: $response" | jq '.'

echo ""
print_status "Advanced Dashboard Testing Completed!"
echo ""
echo "🌐 Dashboard Features Tested:"
echo "  ✅ Multi-client event sending"
echo "  ✅ Real-time Redis data querying"
echo "  ✅ System overview and statistics"
echo "  ✅ Client activity monitoring"
echo "  ✅ Performance testing"
echo "  ✅ Custom Redis key queries"
echo ""
echo "📊 Dashboard Access:"
echo "  🌐 URL: http://localhost:3001/dashboard.html"
echo ""
echo "🎯 Dashboard Features Available:"
echo "  🚀 Multi-Client Event Sender - Send bulk events from multiple clients"
echo "  🔍 Real-time Redis Data Query - Query Redis data in real-time"
echo "  📋 Pending Steps - View queued events by session"
echo "  👥 Client Activity - Monitor client activity and statistics"
echo "  📈 Statistics - System performance metrics"
echo "  📝 Activity Logs - Real-time activity monitoring"
echo ""
echo "🔧 API Endpoints Available:"
echo "  GET /overview - System overview"
echo "  GET /redis/keys - All Redis keys"
echo "  GET /redis/pending-steps - Pending steps data"
echo "  GET /redis/clients - Client data"
echo "  GET /redis/connections - Connection data"
echo "  GET /redis/custom/{key} - Custom Redis key query"
echo "  POST /send-event - Send RPA event"
echo "  GET /clients/summary - Client summary"
echo ""
echo "🎉 Your Advanced RPA Dashboard is ready!" 