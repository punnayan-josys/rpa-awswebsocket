# 📮 Postman Testing Guide for RPA System

## Overview

This guide shows you how to test all the RPA system API endpoints using Postman. You can import these requests into Postman or follow the manual setup instructions.

## 🚀 Quick Setup

### 1. **Start the System**
```bash
./start-system.sh
```

### 2. **Verify API is Running**
```bash
curl http://localhost:3001/health
```

### 3. **Base URL for All Requests**
```
http://localhost:3001
```

## 📋 Postman Collection

### **Import Collection (Recommended)**

1. **Download the collection file**: [rpa-system-collection.json](#collection-json)
2. **Open Postman**
3. **Click "Import"**
4. **Upload the JSON file**
5. **All requests will be pre-configured**

### **Manual Setup**

If you prefer to create requests manually, follow the sections below.

## 🔧 Core API Endpoints

### **1. Health Check**
```
GET http://localhost:3001/health
```

**Headers:**
```
Content-Type: application/json
```

**Expected Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-07-31T13:33:24.837Z",
  "service": "RPA Management API"
}
```

### **2. System Overview**
```
GET http://localhost:3001/overview
```

**Expected Response:**
```json
{
  "timestamp": "2025-07-31T13:33:24.837Z",
  "activeConnections": 0,
  "activeClients": 0,
  "pendingSteps": {
    "session-001": 3,
    "session-002": 2
  },
  "totalPendingSteps": 5
}
```

## 🚀 Event Management

### **3. Send RPA Event**
```
POST http://localhost:3001/send-event
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "clientId": "postman-client-001",
  "sessionId": "postman-session-001",
  "action": "click",
  "target": "#login-button",
  "value": "test value (optional)"
}
```

**Example Variations:**

#### Click Event
```json
{
  "clientId": "postman-client-001",
  "sessionId": "postman-session-001",
  "action": "click",
  "target": "#submit-button"
}
```

#### Type Event
```json
{
  "clientId": "postman-client-001",
  "sessionId": "postman-session-001",
  "action": "type",
  "target": "#username-input",
  "value": "testuser123"
}
```

#### Scroll Event
```json
{
  "clientId": "postman-client-001",
  "sessionId": "postman-session-001",
  "action": "scroll",
  "target": "body"
}
```

#### Hover Event
```json
{
  "clientId": "postman-client-001",
  "sessionId": "postman-session-001",
  "action": "hover",
  "target": "#menu-item"
}
```

**Expected Response:**
```json
{
  "message": "Event sent",
  "event": {
    "action": "recordStep",
    "sessionId": "postman-session-001",
    "payload": {
      "type": "click",
      "target": "#login-button",
      "timestamp": "2025-07-31T13:33:24.837Z",
      "clientId": "postman-client-001"
    }
  },
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

### **4. Clear All Data**
```
POST http://localhost:3001/clear-data
```

**Expected Response:**
```json
{
  "message": "Data cleared",
  "clearedKeys": 5,
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

## 🔍 Redis Data Queries

### **5. Get All Redis Keys**
```
GET http://localhost:3001/redis/keys
```

**Expected Response:**
```json
{
  "keys": [
    "pending_steps:session-001",
    "pending_steps:session-002",
    "clients:client-001"
  ],
  "data": {
    "pending_steps:session-001": [
      "{\"action\":\"recordStep\",\"sessionId\":\"session-001\",\"payload\":{\"type\":\"click\",\"target\":\"#button\"}}"
    ]
  },
  "count": 3,
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

### **6. Get Pending Steps**
```
GET http://localhost:3001/redis/pending-steps
```

**Expected Response:**
```json
{
  "keys": [
    "pending_steps:session-001",
    "pending_steps:session-002"
  ],
  "data": {
    "pending_steps:session-001": [
      {
        "action": "recordStep",
        "sessionId": "session-001",
        "payload": {
          "type": "click",
          "target": "#button",
          "timestamp": "2025-07-31T13:33:24.837Z",
          "clientId": "postman-client-001"
        }
      }
    ]
  },
  "count": 2,
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

### **7. Get Client Data**
```
GET http://localhost:3001/redis/clients
```

**Expected Response:**
```json
{
  "keys": [
    "clients:client-001",
    "clients:client-002"
  ],
  "data": {
    "clients:client-001": {
      "clientId": "client-001",
      "connectionId": "conn-123",
      "timestamp": "2025-07-31T13:33:24.837Z",
      "status": "connected"
    }
  },
  "count": 2,
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

### **8. Get Connection Data**
```
GET http://localhost:3001/redis/connections
```

**Expected Response:**
```json
{
  "keys": [
    "connections:conn-123",
    "connections:conn-456"
  ],
  "data": {
    "connections:conn-123": {
      "connectionId": "conn-123",
      "clientId": "client-001",
      "timestamp": "2025-07-31T13:33:24.837Z",
      "status": "connected"
    }
  },
  "count": 2,
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

### **9. Custom Redis Key Query**
```
GET http://localhost:3001/redis/custom/pending_steps:session-001
```

**Expected Response:**
```json
{
  "key": "pending_steps:session-001",
  "type": "list",
  "data": [
    {
      "action": "recordStep",
      "sessionId": "session-001",
      "payload": {
        "type": "click",
        "target": "#button",
        "timestamp": "2025-07-31T13:33:24.837Z",
        "clientId": "postman-client-001"
      }
    }
  ],
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

## 👥 Client Management

### **10. Get Client Summary**
```
GET http://localhost:3001/clients/summary
```

**Expected Response:**
```json
{
  "clients": [
    {
      "clientId": "client-001",
      "connectionId": "conn-123",
      "eventsSent": 5,
      "lastActivity": "2025-07-31T13:33:24.837Z",
      "totalPendingSteps": 3,
      "sessions": [
        {
          "sessionId": "session-001",
          "stepsCount": 3
        }
      ],
      "isActive": true
    }
  ],
  "count": 1,
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

### **11. Get Client by Session**
```
GET http://localhost:3001/client/postman-client-001/session/postman-session-001
```

**Expected Response:**
```json
{
  "clientId": "postman-client-001",
  "sessionId": "postman-session-001",
  "steps": [
    {
      "action": "recordStep",
      "sessionId": "postman-session-001",
      "payload": {
        "type": "click",
        "target": "#login-button",
        "timestamp": "2025-07-31T13:33:24.837Z",
        "clientId": "postman-client-001"
      }
    }
  ],
  "count": 1,
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

### **12. Get Pending Steps by Session**
```
GET http://localhost:3001/pending-steps/postman-session-001
```

**Expected Response:**
```json
{
  "sessionId": "postman-session-001",
  "steps": [
    {
      "action": "recordStep",
      "sessionId": "postman-session-001",
      "payload": {
        "type": "click",
        "target": "#login-button",
        "timestamp": "2025-07-31T13:33:24.837Z",
        "clientId": "postman-client-001"
      }
    }
  ],
  "count": 1,
  "timestamp": "2025-07-31T13:33:24.837Z"
}
```

## 🧪 Testing Workflow

### **Step 1: Health Check**
1. Send `GET http://localhost:3001/health`
2. Verify response shows `"status": "ok"`

### **Step 2: Check Initial State**
1. Send `GET http://localhost:3001/overview`
2. Note the initial pending steps count

### **Step 3: Send Test Events**
1. Send multiple `POST /send-event` requests with different:
   - Client IDs: `postman-client-001`, `postman-client-002`
   - Session IDs: `postman-session-001`, `postman-session-002`
   - Actions: `click`, `type`, `scroll`, `hover`
   - Targets: `#button`, `#input`, `body`

### **Step 4: Verify Data Storage**
1. Send `GET http://localhost:3001/redis/pending-steps`
2. Verify your events appear in the response

### **Step 5: Query Specific Data**
1. Send `GET http://localhost:3001/redis/custom/pending_steps:postman-session-001`
2. Verify your session-specific events

### **Step 6: Check Client Summary**
1. Send `GET http://localhost:3001/clients/summary`
2. Verify client activity is tracked

### **Step 7: Clear Data**
1. Send `POST http://localhost:3001/clear-data`
2. Verify all pending steps are cleared

## 📊 Environment Variables (Optional)

Create a Postman environment with these variables:

```
BASE_URL: http://localhost:3001
CLIENT_ID: postman-client-001
SESSION_ID: postman-session-001
```

Then use in requests:
```
{{BASE_URL}}/health
{{BASE_URL}}/send-event
```

## 🔄 Automated Testing

### **Create a Test Collection**

1. **Create a new collection** in Postman
2. **Add all the requests** above
3. **Set up test scripts** for each request
4. **Run the collection** to test all endpoints

### **Example Test Script**

Add this to the "Tests" tab in Postman:

```javascript
// Test for /health endpoint
pm.test("Status is ok", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has status field", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.status).to.eql("ok");
});

pm.test("Response time is less than 1000ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(1000);
});
```

## 🚨 Troubleshooting

### **Common Issues**

#### **Connection Refused**
- Check if the Management API is running: `curl http://localhost:3001/health`
- Restart if needed: `node management-api.js`

#### **Empty Responses**
- Send some test events first
- Check if Redis has data: `curl http://localhost:3001/redis/keys`

#### **JSON Parse Errors**
- Verify Content-Type header is set to `application/json`
- Check JSON syntax in request body

### **Debug Commands**

```bash
# Check if API is running
curl http://localhost:3001/health

# Check Redis data
curl http://localhost:3001/redis/keys

# Send test event
curl -X POST http://localhost:3001/send-event \
  -H 'Content-Type: application/json' \
  -d '{"clientId": "test", "sessionId": "test", "action": "click", "target": "#button"}'
```

## 📋 Postman Collection JSON

```json
{
  "info": {
    "name": "RPA System API",
    "description": "Complete API collection for RPA System testing",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:3001"
    }
  ],
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/health",
          "host": ["{{base_url}}"],
          "path": ["health"]
        }
      }
    },
    {
      "name": "System Overview",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/overview",
          "host": ["{{base_url}}"],
          "path": ["overview"]
        }
      }
    },
    {
      "name": "Send Event",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"clientId\": \"postman-client-001\",\n  \"sessionId\": \"postman-session-001\",\n  \"action\": \"click\",\n  \"target\": \"#login-button\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/send-event",
          "host": ["{{base_url}}"],
          "path": ["send-event"]
        }
      }
    },
    {
      "name": "Get All Redis Keys",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/redis/keys",
          "host": ["{{base_url}}"],
          "path": ["redis", "keys"]
        }
      }
    },
    {
      "name": "Get Pending Steps",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/redis/pending-steps",
          "host": ["{{base_url}}"],
          "path": ["redis", "pending-steps"]
        }
      }
    },
    {
      "name": "Clear All Data",
      "request": {
        "method": "POST",
        "header": [],
        "url": {
          "raw": "{{base_url}}/clear-data",
          "host": ["{{base_url}}"],
          "path": ["clear-data"]
        }
      }
    }
  ]
}
```

## 🎉 Success Indicators

✅ **All GET requests return 200 status**
✅ **All POST requests return 200 status**
✅ **JSON responses are properly formatted**
✅ **Data persists between requests**
✅ **Redis queries return expected data**
✅ **Event sending works correctly**

---

**Your RPA System is ready for Postman testing!** 🚀 