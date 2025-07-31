#!/bin/bash

echo "🎯 RPA System Demo for Manager"
echo "=============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if services are running
check_services() {
    echo "🔍 Checking Services..."
    
    # Check Docker containers
    if docker ps | grep -q "localstack"; then
        print_status "LocalStack is running"
    else
        print_error "LocalStack is not running"
        return 1
    fi
    
    if docker ps | grep -q "redis"; then
        print_status "Redis is running"
    else
        print_error "Redis is not running"
        return 1
    fi
    
    # Check NestJS
    if curl -s http://localhost:3000/health > /dev/null; then
        print_status "NestJS is running"
    else
        print_warning "NestJS is not running (will start later)"
    fi
    
    # Check Management API
    if curl -s http://localhost:3001/health > /dev/null; then
        print_status "Management API is running"
    else
        print_warning "Management API is not running (will start later)"
    fi
    
    echo ""
}

# Start Management API
start_management_api() {
    echo "🚀 Starting Management API..."
    node management-api.js &
    MANAGEMENT_PID=$!
    sleep 3
    
    if curl -s http://localhost:3001/health > /dev/null; then
        print_status "Management API started successfully"
    else
        print_error "Failed to start Management API"
        return 1
    fi
    echo ""
}

# Demo 1: System Overview
demo_system_overview() {
    echo "📊 Demo 1: System Overview"
    echo "-------------------------"
    
    response=$(curl -s http://localhost:3001/overview)
    echo "System Status:"
    echo "$response" | jq '.'
    echo ""
}

# Demo 2: Manual Event Sending
demo_manual_events() {
    echo "📤 Demo 2: Manual Event Sending"
    echo "-------------------------------"
    
    print_info "Sending a click event..."
    response=$(curl -s -X POST http://localhost:3001/send-event \
        -H 'Content-Type: application/json' \
        -d '{
            "clientId": "demo-client-1",
            "sessionId": "demo-session-1",
            "action": "click",
            "target": "#login-button"
        }')
    echo "Response: $response"
    echo ""
    
    print_info "Sending a type event..."
    response=$(curl -s -X POST http://localhost:3001/send-event \
        -H 'Content-Type: application/json' \
        -d '{
            "clientId": "demo-client-1",
            "sessionId": "demo-session-1",
            "action": "type",
            "target": "#username",
            "value": "demo-user"
        }')
    echo "Response: $response"
    echo ""
}

# Demo 3: Fake Client Simulation
demo_fake_clients() {
    echo "🤖 Demo 3: Fake Client Simulation"
    echo "--------------------------------"
    
    print_info "Starting simulation with 3 clients, 5 events each..."
    response=$(curl -s -X POST http://localhost:3001/simulation/start \
        -H 'Content-Type: application/json' \
        -d '{
            "numClients": 3,
            "eventsPerClient": 5,
            "intervalMs": 2000
        }')
    echo "Simulation started: $response"
    echo ""
    
    print_info "Waiting for events to be sent..."
    sleep 10
    
    print_info "Checking simulation status..."
    response=$(curl -s http://localhost:3001/simulation/status)
    echo "Status: $response"
    echo ""
    
    print_info "Checking system overview after simulation..."
    response=$(curl -s http://localhost:3001/overview)
    echo "Overview: $response" | jq '.'
    echo ""
}

# Demo 4: Connection Management
demo_connections() {
    echo "🔗 Demo 4: Connection Management"
    echo "-------------------------------"
    
    print_info "Getting active connections..."
    response=$(curl -s http://localhost:3001/connections)
    echo "Connections: $response" | jq '.'
    echo ""
    
    print_info "Getting active clients..."
    response=$(curl -s http://localhost:3001/clients)
    echo "Clients: $response" | jq '.'
    echo ""
}

# Demo 5: Pending Steps
demo_pending_steps() {
    echo "📋 Demo 5: Pending Steps"
    echo "-----------------------"
    
    print_info "Getting pending steps for demo session..."
    response=$(curl -s http://localhost:3001/pending-steps/demo-session-1)
    echo "Pending Steps: $response" | jq '.'
    echo ""
}

# Demo 6: NestJS Processing
demo_nestjs_processing() {
    echo "🔄 Demo 6: NestJS Processing"
    echo "---------------------------"
    
    print_info "Checking NestJS health..."
    response=$(curl -s http://localhost:3000/health)
    echo "NestJS Health: $response"
    echo ""
    
    print_info "Checking queue count..."
    response=$(curl -s http://localhost:3000/queue/demo-session-1/count)
    echo "Queue Count: $response"
    echo ""
    
    print_info "Getting all pending steps..."
    response=$(curl -s http://localhost:3000/queue/demo-session-1/steps)
    echo "All Steps: $response" | jq '.'
    echo ""
}

# Demo 7: Redis Data
demo_redis_data() {
    echo "🗄️ Demo 7: Redis Data"
    echo "---------------------"
    
    print_info "Checking Redis connections..."
    connections=$(docker exec -it aws-localsetup-redis-1 redis-cli SMEMBERS active_connections)
    echo "Active Connections: $connections"
    echo ""
    
    print_info "Checking Redis clients..."
    clients=$(docker exec -it aws-localsetup-redis-1 redis-cli SMEMBERS active_clients)
    echo "Active Clients: $clients"
    echo ""
    
    print_info "Checking pending steps in Redis..."
    steps=$(docker exec -it aws-localsetup-redis-1 redis-cli LRANGE pending_steps:demo-session-1 0 -1)
    echo "Pending Steps in Redis: $steps"
    echo ""
}

# Demo 8: Dashboard
demo_dashboard() {
    echo "📊 Demo 8: Web Dashboard"
    echo "-----------------------"
    
    print_info "Dashboard is available at: http://localhost:3001/dashboard.html"
    print_info "Features:"
    echo "  - Real-time system monitoring"
    echo "  - Simulation controls"
    echo "  - Manual event sending"
    echo "  - Connection and client management"
    echo "  - Live logs and metrics"
    echo ""
}

# Main demo flow
main() {
    echo "🎯 Starting RPA System Demo for Manager"
    echo "======================================"
    echo ""
    
    # Check services
    check_services
    if [ $? -ne 0 ]; then
        print_error "Some services are not running. Please start them first."
        exit 1
    fi
    
    # Start Management API if not running
    if ! curl -s http://localhost:3001/health > /dev/null; then
        start_management_api
    fi
    
    # Run demos
    demo_system_overview
    demo_manual_events
    demo_fake_clients
    demo_connections
    demo_pending_steps
    demo_nestjs_processing
    demo_redis_data
    demo_dashboard
    
    echo "🎉 Demo Complete!"
    echo "================"
    echo ""
    echo "📋 Summary:"
    echo "  ✅ System Overview - Shows real-time metrics"
    echo "  ✅ Manual Events - Send individual RPA steps"
    echo "  ✅ Fake Clients - Simulate multiple clients"
    echo "  ✅ Connection Management - Track WebSocket connections"
    echo "  ✅ Pending Steps - Monitor queued RPA actions"
    echo "  ✅ NestJS Processing - Real-time step processing"
    echo "  ✅ Redis Data - Persistent storage and queuing"
    echo "  ✅ Web Dashboard - Complete management interface"
    echo ""
    echo "🌐 Access Points:"
    echo "  - Dashboard: http://localhost:3001/dashboard.html"
    echo "  - Management API: http://localhost:3001"
    echo "  - NestJS Backend: http://localhost:3000"
    echo "  - LocalStack: http://localhost:4566"
    echo ""
    echo "📚 Documentation:"
    echo "  - README.md - Complete setup guide"
    echo "  - WEBSOCKET_SETUP.md - WebSocket implementation details"
    echo ""
}

# Run the demo
main

# Keep the script running to maintain the Management API
echo "🔄 Keeping Management API running..."
echo "Press Ctrl+C to stop"
wait $MANAGEMENT_PID 