#!/bin/bash

echo "🚀 Starting RPA System..."
echo "========================="

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

# Step 1: Start Infrastructure
echo ""
print_info "Step 1: Starting Docker infrastructure..."
if docker-compose up -d; then
    print_status "Docker containers started successfully"
else
    print_warning "Docker containers may already be running"
fi

# Step 2: Wait for services to be ready
echo ""
print_info "Step 2: Waiting for services to be ready..."
sleep 5

# Step 3: Check if LocalStack is ready
echo ""
print_info "Step 3: Checking LocalStack status..."
if curl -s http://localhost:4566/health > /dev/null; then
    print_status "LocalStack is ready"
else
    print_warning "LocalStack may still be starting up"
fi

# Step 4: Deploy Lambda functions
echo ""
print_info "Step 4: Deploying Lambda functions and API Gateway..."
if ./deploy-websocket.sh; then
    print_status "Lambda functions and API Gateway deployed"
else
    print_warning "Deployment may have encountered issues (check if already deployed)"
fi

# Step 5: Start Management API
echo ""
print_info "Step 5: Starting Management API..."
# Kill any existing process
pkill -f "node management-api.js" 2>/dev/null
sleep 2

# Start the API in background
if node management-api.js & then
    print_status "Management API started"
    sleep 3
    
    # Check if API is responding
    if curl -s http://localhost:3001/health > /dev/null; then
        print_status "Management API is responding"
    else
        print_warning "Management API may still be starting"
    fi
else
    print_warning "Failed to start Management API"
fi

# Step 6: Final status
echo ""
print_info "Step 6: System Status Check..."

echo ""
echo "🌐 Access Points:"
echo "  📊 Dashboard: http://localhost:3001/dashboard.html"
echo "  🔧 Management API: http://localhost:3001"
echo "  🐳 LocalStack: http://localhost:4566"
echo "  📦 Redis: localhost:6379"

echo ""
echo "🧪 Quick Test:"
echo "  curl http://localhost:3001/overview"

echo ""
print_status "RPA System is ready!"
echo ""
echo "💡 Next Steps:"
echo "  1. Open the dashboard: http://localhost:3001/dashboard.html"
echo "  2. Send test events using the dashboard"
echo "  3. Run: ./test-client-api.sh for API testing"
echo "  4. Check logs in the dashboard"

echo ""
echo "🛑 To stop the system:"
echo "  docker-compose down"
echo "  pkill -f 'node management-api.js'" 