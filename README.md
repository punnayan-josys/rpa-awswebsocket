# 🤖 RPA System with AWS LocalStack

A complete local RPA (Robotic Process Automation) testing environment using AWS LocalStack, Lambda functions, Redis, and a web dashboard.

## 📋 Prerequisites

Before starting, ensure you have the following installed:

- **Docker Desktop** (v20.10 or higher)
- **Node.js** (v18 or higher)
- **Git**

## 🚀 Quick Start

### Step 1: Clone the Repository
```bash
git clone <your-github-repo-url>
cd aws-localsetup
```

### Step 2: Install Dependencies
```bash
npm install
```

### Step 3: Start the System
```bash
chmod +x start-system.sh
./start-system.sh
```

### Step 4: Access Dashboard
Open your browser and go to: **http://localhost:3001/dashboard.html**

## 📖 Complete Setup Guide

### 1. Environment Setup

#### Check Prerequisites
```bash
# Verify Docker
docker --version
docker-compose --version

# Verify Node.js
node --version
npm --version

# Verify Git
git --version
```

#### Clone Repository
```bash
git clone <your-github-repo-url>
cd aws-localsetup
```

#### Install Dependencies
```bash
npm install
```

### 2. System Startup

#### Make Scripts Executable
```bash
chmod +x start-system.sh
chmod +x deploy-websocket.sh
chmod +x test-client-api.sh
```

#### Start Complete System
```bash
./start-system.sh
```

**Expected Output:**
```
🚀 Starting RPA System...
=========================

ℹ️ Step 1: Starting Docker infrastructure...
✅ Docker containers started successfully

ℹ️ Step 2: Waiting for services to be ready...

ℹ️ Step 3: Checking LocalStack status...
✅ LocalStack is ready

ℹ️ Step 4: Deploying Lambda functions and API Gateway...
✅ Lambda functions and API Gateway deployed

ℹ️ Step 5: Starting Management API...
✅ Management API started
✅ Management API is responding

🌐 Access Points:
  📊 Dashboard: http://localhost:3001/dashboard.html
  🔧 Management API: http://localhost:3001
  🐳 LocalStack: http://localhost:4566
  📦 Redis: localhost:6379

✅ RPA System is ready!
```

### 3. Manual Startup (Alternative)

If the startup script doesn't work, use these manual steps:

#### Start Docker Infrastructure
```bash
docker-compose up -d
```

#### Wait for Services
```bash
sleep 10
```

#### Deploy Lambda Functions
```bash
./deploy-websocket.sh
```

#### Start Management API
```bash
node management-api.js
```

## 🧪 Testing the System

### Test API Endpoints
```bash
# Test system overview
curl http://localhost:3001/overview

# Test health endpoint
curl http://localhost:3001/health

# Send a test event
curl -X POST http://localhost:3001/send-event \
  -H 'Content-Type: application/json' \
  -d '{
    "clientId": "test-client",
    "sessionId": "test-session",
    "action": "click",
    "target": "#button"
  }'

# View pending steps
curl http://localhost:3001/pending-steps/test-session
```

### Run Complete Test Suite
```bash
./test-client-api.sh
```

### Test Dashboard
1. Open browser: http://localhost:3001/dashboard.html
2. Use "Manual Event Sender" to send events
3. View "Pending Steps" tab for results
4. Check "Logs" tab for activity

## 🔧 System Verification

### Check All Services
```bash
# Check Docker containers
docker ps

# Check LocalStack
curl http://localhost:4566/health

# Check Management API
curl http://localhost:3001/health

# Check Redis
docker exec -it aws-localsetup-redis-1 redis-cli ping
```

### Expected Results
- **Docker**: 2 containers running (localstack, redis)
- **LocalStack**: `{"status": "running"}`
- **Management API**: `{"status":"ok","service":"RPA Management API"}`
- **Redis**: `PONG`

## 🌐 API Endpoints

### Management API (Port 3001)

#### System Overview
```bash
GET http://localhost:3001/overview
```

#### Health Check
```bash
GET http://localhost:3001/health
```

#### Send RPA Event
```bash
POST http://localhost:3001/send-event
Content-Type: application/json

{
  "clientId": "user-001",
  "sessionId": "session-001",
  "action": "click",
  "target": "#button",
  "value": "text value (optional)"
}
```

#### Get Pending Steps by Session
```bash
GET http://localhost:3001/pending-steps/{sessionId}
```

#### Get Client Data by Session
```bash
GET http://localhost:3001/client/{clientId}/session/{sessionId}
```

#### Clear All Data
```bash
POST http://localhost:3001/clear-data
```

### LocalStack (Port 4566)

#### Health Check
```bash
curl http://localhost:4566/health
```

#### List Lambda Functions
```bash
awslocal lambda list-functions
```

#### List API Gateways
```bash
awslocal apigateway get-rest-apis
```

## 🎯 Using the Dashboard

### Dashboard Features
- **System Overview**: Real-time metrics and statistics
- **Manual Event Sender**: Send individual RPA events
- **Pending Steps**: View queued events by session
- **Activity Logs**: Monitor all system activity

### Supported Actions
- **click**: Click on elements
- **type**: Type text into fields
- **scroll**: Scroll the page
- **hover**: Hover over elements

### Example Usage
1. Set **Client ID**: `demo-user-001`
2. Set **Session ID**: `demo-session-001`
3. Choose **Action**: `click`
4. Set **Target**: `#login-button`
5. Click **"Send Event"**

## 🚨 Troubleshooting

### Common Issues

#### Docker Not Running
```bash
# Start Docker Desktop
# On macOS: Open Docker Desktop app
# On Windows: Start Docker Desktop from Start menu
# On Linux: sudo systemctl start docker
```

#### Port Already in Use
```bash
# Kill existing processes
pkill -f "node management-api.js"
docker-compose down

# Restart system
./start-system.sh
```

#### LocalStack Not Ready
```bash
# Wait longer for startup
sleep 15
curl http://localhost:4566/health
```

#### Permission Denied
```bash
# Make scripts executable
chmod +x *.sh
```

#### Node Modules Missing
```bash
# Install dependencies
npm install
```

### Debug Commands
```bash
# View Docker logs
docker-compose logs

# Check Redis data
docker exec -it aws-localsetup-redis-1 redis-cli KEYS "*"

# Check Management API logs
# (Check terminal where you ran: node management-api.js)

# Test API connectivity
curl -v http://localhost:3001/health
```

## 🛑 Stopping the System

### Graceful Shutdown
```bash
# Stop Management API
pkill -f "node management-api.js"

# Stop Docker containers
docker-compose down
```

### Complete Cleanup
```bash
# Stop all services
pkill -f "node management-api.js"
docker-compose down -v

# Remove all data
docker system prune -a
```

## 📊 System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Dashboard │    │  Management API │    │   LocalStack    │
│   (Port 3001)   │◄──►│   (Port 3001)   │◄──►│   (Port 4566)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │     Redis       │    │   Lambda Funcs  │
                       │   (Port 6379)   │    │  (Validator,    │
                       └─────────────────┘    │ ConnectionMgr)  │
                                              └─────────────────┘
```

## 📁 Project Structure

```
aws-localsetup/
├── docker-compose.yml          # Docker services configuration
├── start-system.sh            # Complete system startup script
├── deploy-websocket.sh        # Lambda and API Gateway deployment
├── test-client-api.sh         # API testing script
├── management-api.js          # Express.js Management API server
├── package.json               # Node.js dependencies
├── README.md                  # This file
├── CLIENT_API_GUIDE.md        # Detailed API documentation
├── public/
│   └── dashboard.html         # Web dashboard interface
├── lambdas/
│   ├── authorizer/            # Lambda authorizer function
│   ├── connection-manager/    # Lambda connection manager
│   └── validator/             # Lambda validator function
└── nestjs-backend/            # NestJS backend (optional)
```

## 🎯 Use Cases

### RPA Testing
- Send click, type, scroll, and hover events
- Test automation workflows
- Monitor event processing

### Load Testing
- Send multiple events rapidly
- Test system performance
- Monitor Redis queue behavior

### Development
- Test Lambda functions
- Debug event processing
- Develop new automation features

## 📈 Performance Notes

- **Real-time**: Data updates in real-time
- **Scalable**: Supports multiple concurrent clients
- **Persistent**: Data stored in Redis
- **Fast**: Direct Redis queries for optimal performance

## 🆘 Getting Help

### Quick Commands
```bash
# Restart everything
./start-system.sh

# Test all endpoints
./test-client-api.sh

# Check system status
curl http://localhost:3001/overview

# Clear all data
curl -X POST http://localhost:3001/clear-data
```

### Success Indicators
✅ Docker containers running
✅ LocalStack responding on port 4566
✅ Management API responding on port 3001
✅ Dashboard accessible at http://localhost:3001/dashboard.html
✅ Can send events via dashboard
✅ Can view pending steps
✅ Real-time updates working

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify all prerequisites are installed
3. Check system logs for error messages
4. Ensure ports 3001, 4566, and 6379 are available

## 🎉 Success!

Your RPA system is now ready for:
- 🤖 **RPA Testing** - Test automation workflows
- 📊 **Real-time Monitoring** - Monitor event processing
- 🔧 **Development** - Develop and debug automation features
- 📈 **Load Testing** - Test system performance

**Access the dashboard at: http://localhost:3001/dashboard.html**

---

**Happy Automating!** 🚀 # rpa-awswebsocket
