#!/bin/bash

API_URL="http://localhost:4566/restapis/emtme7vrhk/dev/_user_request_/recordStep"

echo "🚀 Testing RPA LocalStack Setup"
echo "================================"

# Test 1: Send a click step
echo "📝 Sending click step..."
curl -X POST "$API_URL" \
  -H 'Content-Type: application/json' \
  -d '{"sessionId": "test-session-01", "payload": {"type": "click", "target": "#login-button"}}'

echo -e "\n\n"

# Test 2: Send a type step
echo "📝 Sending type step..."
curl -X POST "$API_URL" \
  -H 'Content-Type: application/json' \
  -d '{"sessionId": "test-session-01", "payload": {"type": "type", "target": "#username", "value": "testuser"}}'

echo -e "\n\n"

# Test 3: Send a scroll step
echo "📝 Sending scroll step..."
curl -X POST "$API_URL" \
  -H 'Content-Type: application/json' \
  -d '{"sessionId": "test-session-01", "payload": {"type": "scroll", "target": "body", "direction": "down"}}'

echo -e "\n\n"

# Test 4: Send to a different session
echo "📝 Sending step to different session..."
curl -X POST "$API_URL" \
  -H 'Content-Type: application/json' \
  -d '{"sessionId": "test-session-02", "payload": {"type": "click", "target": "#submit-button"}}'

echo -e "\n\n"

echo "✅ All test requests sent!"
echo "Check the NestJS logs to see the processing..." 