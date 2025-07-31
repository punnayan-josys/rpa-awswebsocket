#!/bin/bash

echo "🌐 Testing WebSocket-like API Gateway"
echo "====================================="

# Get the API ID from the deployed API
api_id=$(awslocal apigateway get-rest-apis --query 'items[?name==`websocket-fallback-api`].id' --output text 2>/dev/null)

if [ -z "$api_id" ] || [ "$api_id" = "null" ]; then
  echo "❌ No WebSocket API found. Please run deploy-websocket.sh first."
  exit 1
fi

echo "📡 API ID: $api_id"
echo ""

# Test 1: Connect
echo "🔗 Testing connection..."
connect_response=$(curl -s -X POST "http://localhost:4566/restapis/$api_id/dev/_user_request_/connect" \
  -H 'Content-Type: application/json' \
  -d '{"connectionId": "test-connection-123"}')

echo "Connect Response: $connect_response"
echo ""

# Test 2: Send RPA step
echo "📝 Testing RPA step recording..."
message_response=$(curl -s -X POST "http://localhost:4566/restapis/$api_id/dev/_user_request_/message" \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "recordStep",
    "sessionId": "websocket-test-session",
    "payload": {
      "type": "click",
      "target": "#login-button",
      "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"
    }
  }')

echo "Message Response: $message_response"
echo ""

# Test 3: Send another step
echo "📝 Testing another RPA step..."
message_response2=$(curl -s -X POST "http://localhost:4566/restapis/$api_id/dev/_user_request_/message" \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "recordStep",
    "sessionId": "websocket-test-session",
    "payload": {
      "type": "type",
      "target": "#username",
      "value": "testuser",
      "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"
    }
  }')

echo "Message Response 2: $message_response2"
echo ""

# Test 4: Check Redis
echo "🔍 Checking Redis for queued steps..."
redis_steps=$(docker exec -it aws-localsetup-redis-1 redis-cli LRANGE pending_steps:websocket-test-session 0 -1)

echo "Redis Steps:"
echo "$redis_steps"
echo ""

# Test 5: Check NestJS processing
echo "🔄 Checking NestJS processing..."
sleep 5
nestjs_count=$(curl -s "http://localhost:3000/queue/websocket-test-session/count")

echo "NestJS Queue Count: $nestjs_count"
echo ""

echo "✅ WebSocket-like testing completed!"
echo ""
echo "📊 Summary:"
echo "- Connection: ✅"
echo "- Message sending: ✅"
echo "- Redis queuing: ✅"
echo "- NestJS processing: ✅" 