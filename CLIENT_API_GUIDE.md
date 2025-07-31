# 🔍 Client API Guide

## Overview

The Client API provides endpoints to view Redis data by client ID and session. This allows you to monitor and track RPA events sent by different clients.

## 🌐 Base URL

```
http://localhost:3001
```

## 📋 Available Endpoints

### 1. **System Overview**
```bash
GET /overview
```
Returns system-wide statistics including pending steps by session.

**Response:**
```json
{
  "timestamp": "2025-07-31T11:26:28.877Z",
  "activeConnections": 0,
  "activeClients": 0,
  "pendingSteps": {
    "demo-session-001": 3,
    "demo-session-002": 2,
    "test-session": 1
  },
  "totalPendingSteps": 6
}
```

### 2. **Get Pending Steps by Session**
```bash
GET /pending-steps/{sessionId}
```
Returns all pending steps for a specific session.

**Response:**
```json
{
  "sessionId": "demo-session-001",
  "steps": [
    {
      "action": "recordStep",
      "sessionId": "demo-session-001",
      "payload": {
        "type": "click",
        "target": "#button-1",
        "timestamp": "2025-07-31T11:26:23.319Z",
        "clientId": "demo-client-001"
      }
    }
  ],
  "count": 3,
  "timestamp": "2025-07-31T11:26:58.819Z"
}
```

### 3. **Get Client Data by Session**
```bash
GET /client/{clientId}/session/{sessionId}
```
Returns all events for a specific client in a specific session.

**Response:**
```json
{
  "clientId": "demo-client-001",
  "sessionId": "demo-session-001",
  "steps": [
    {
      "action": "recordStep",
      "sessionId": "demo-session-001",
      "payload": {
        "type": "click",
        "target": "#button-1",
        "timestamp": "2025-07-31T11:26:23.319Z",
        "clientId": "demo-client-001"
      }
    }
  ],
  "count": 3,
  "timestamp": "2025-07-31T11:26:58.819Z"
}
```

### 4. **Send RPA Event**
```bash
POST /send-event
```
Send a new RPA event to the system.

**Request Body:**
```json
{
  "clientId": "demo-client-001",
  "sessionId": "demo-session-001",
  "action": "click",
  "target": "#button",
  "value": "text value (optional, for type actions)"
}
```

**Response:**
```json
{
  "message": "Event sent",
  "event": {
    "action": "recordStep",
    "sessionId": "demo-session-001",
    "payload": {
      "type": "click",
      "target": "#button",
      "timestamp": "2025-07-31T11:26:23.319Z",
      "clientId": "demo-client-001"
    }
  },
  "timestamp": "2025-07-31T11:26:23.319Z"
}
```

## 🎯 How to Use

### Step 1: Start the Management API
```bash
node management-api.js
```

### Step 2: Send Test Events
```bash
# Send a click event
curl -X POST http://localhost:3001/send-event \
  -H 'Content-Type: application/json' \
  -d '{
    "clientId": "demo-client-001",
    "sessionId": "demo-session-001",
    "action": "click",
    "target": "#button"
  }'

# Send a type event
curl -X POST http://localhost:3001/send-event \
  -H 'Content-Type: application/json' \
  -d '{
    "clientId": "demo-client-001",
    "sessionId": "demo-session-001",
    "action": "type",
    "target": "#input",
    "value": "test value"
  }'
```

### Step 3: Query Data
```bash
# Get system overview
curl http://localhost:3001/overview

# Get pending steps for a session
curl http://localhost:3001/pending-steps/demo-session-001

# Get client data by session
curl http://localhost:3001/client/demo-client-001/session/demo-session-001
```

## 🌐 Web Dashboard

Access the web dashboard for a visual interface:
```
http://localhost:3001/dashboard.html
```

Features:
- 📊 **System Overview** - Real-time metrics
- 📤 **Manual Event Sender** - Send individual events
- 📋 **Pending Steps** - View queued events
- 🔄 **Auto-refresh** - Updates every 5 seconds

## 📊 Data Structure

### Event Structure
```json
{
  "action": "recordStep",
  "sessionId": "session-id",
  "payload": {
    "type": "click|type|scroll|hover",
    "target": "CSS selector",
    "value": "text value (for type actions)",
    "timestamp": "ISO timestamp",
    "clientId": "client-id"
  }
}
```

### Supported Actions
- **click** - Click on elements
- **type** - Type text into fields
- **scroll** - Scroll the page
- **hover** - Hover over elements

## 🚀 Quick Test

Run the test script to see all endpoints in action:
```bash
./test-client-api.sh
```

This will:
1. Send multiple test events
2. Query system overview
3. Check pending steps
4. Test client by session API
5. Show all available endpoints

## 🎉 Success!

Your RPA system now has:
- ✅ **Client API** for viewing Redis data by client ID
- ✅ **Session-based queries** for tracking client activity
- ✅ **Web dashboard** for visual monitoring
- ✅ **Real-time event sending** and tracking
- ✅ **Comprehensive testing** capabilities

**Access the dashboard at: http://localhost:3001/dashboard.html** 