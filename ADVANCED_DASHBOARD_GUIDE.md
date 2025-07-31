# 🚀 Advanced RPA Dashboard Guide

## Overview

The Advanced RPA Dashboard provides comprehensive multi-client event management and real-time Redis data monitoring capabilities. This guide covers all the new features and how to use them effectively.

## 🌐 Dashboard Access

**URL:** http://localhost:3001/dashboard.html

## 🎯 Key Features

### 1. **Multi-Client Event Sender**
Send bulk events from multiple clients simultaneously with configurable parameters.

### 2. **Real-time Redis Data Query**
Query Redis data in real-time with multiple query types and custom key support.

### 3. **Advanced Monitoring**
Comprehensive system overview, client activity tracking, and performance statistics.

### 4. **Real-time Updates**
Auto-refresh functionality with configurable intervals.

## 🚀 Multi-Client Event Sender

### Configuration Options

- **Number of Clients**: 1-10 clients (default: 3)
- **Events per Client**: 1-20 events (default: 5)
- **Event Interval**: 100-5000ms (default: 1000ms)

### How to Use

1. **Set Configuration**:
   - Enter the number of clients you want to simulate
   - Set how many events each client should send
   - Configure the interval between events

2. **Start Bulk Events**:
   - Click "🚀 Start Bulk Events"
   - Watch the progress bar in real-time
   - Monitor the activity logs

3. **Monitor Progress**:
   - Progress bar shows completion percentage
   - Real-time event count display
   - Activity logs show detailed information

### Event Types Generated

The system automatically generates random events:
- **Click**: `#element-1`, `#element-2`, etc.
- **Type**: Text input events
- **Scroll**: Page scrolling events
- **Hover**: Mouse hover events

### Example Configuration

```
Number of Clients: 3
Events per Client: 5
Event Interval: 1000ms
```

This will create:
- 3 clients: `bulk-client-1`, `bulk-client-2`, `bulk-client-3`
- 3 sessions: `bulk-session-1`, `bulk-session-2`, `bulk-session-3`
- 15 total events (3 × 5)
- 1-second intervals between events

## 🔍 Real-time Redis Data Query

### Query Types Available

#### 1. **All Keys**
- **Endpoint**: `GET /redis/keys`
- **Description**: Shows all Redis keys and their data
- **Use Case**: Complete system overview

#### 2. **Pending Steps**
- **Endpoint**: `GET /redis/pending-steps`
- **Description**: Shows all pending RPA steps by session
- **Use Case**: Monitor queued events

#### 3. **Client Data**
- **Endpoint**: `GET /redis/clients`
- **Description**: Shows all client information
- **Use Case**: Track client activity

#### 4. **Connection Data**
- **Endpoint**: `GET /redis/connections`
- **Description**: Shows all connection information
- **Use Case**: Monitor WebSocket connections

#### 5. **Custom Key**
- **Endpoint**: `GET /redis/custom/{key}`
- **Description**: Query any specific Redis key
- **Use Case**: Debug specific data

### How to Use Redis Query

1. **Select Query Type**:
   - Choose from the dropdown menu
   - For custom queries, select "Custom Key"

2. **Enter Custom Key** (if needed):
   - Format: `pending_steps:session-001`
   - Examples: `clients:client-001`, `connections:conn-123`

3. **Execute Query**:
   - Click "🔍 Query Redis"
   - View results in the display area

4. **Refresh Data**:
   - Click "🔄 Refresh" for real-time updates

### Query Examples

#### View All Pending Steps
```bash
curl http://localhost:3001/redis/pending-steps
```

#### View Specific Session
```bash
curl http://localhost:3001/redis/custom/pending_steps:session-001
```

#### View All Client Data
```bash
curl http://localhost:3001/redis/clients
```

## 📊 Dashboard Tabs

### 1. **Pending Steps Tab**
- Shows all queued events by session
- Real-time count updates
- Session-wise organization

### 2. **Client Activity Tab**
- Client activity summary
- Events sent per client
- Last activity timestamps
- Pending steps per client

### 3. **Statistics Tab**
- System performance metrics
- Total events count
- Average steps per session
- Active sessions count

### 4. **Activity Logs Tab**
- Real-time activity monitoring
- Success/error/warning messages
- Timestamped entries
- Auto-scrolling logs

## 🔧 API Endpoints

### Core Endpoints

#### System Overview
```bash
GET http://localhost:3001/overview
```
Returns system statistics including active connections, clients, and pending steps.

#### Health Check
```bash
GET http://localhost:3001/health
```
Returns API health status.

### Redis Query Endpoints

#### All Redis Keys
```bash
GET http://localhost:3001/redis/keys
```
Returns all Redis keys and their data.

#### Pending Steps
```bash
GET http://localhost:3001/redis/pending-steps
```
Returns all pending RPA steps organized by session.

#### Client Data
```bash
GET http://localhost:3001/redis/clients
```
Returns all client information stored in Redis.

#### Connection Data
```bash
GET http://localhost:3001/redis/connections
```
Returns all connection information.

#### Custom Key Query
```bash
GET http://localhost:3001/redis/custom/{key}
```
Query any specific Redis key.

### Event Management

#### Send Event
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

#### Clear All Data
```bash
POST http://localhost:3001/clear-data
```
Clears all pending steps from Redis.

### Client Management

#### Client Summary
```bash
GET http://localhost:3001/clients/summary
```
Returns summary of all active clients.

#### Client by Session
```bash
GET http://localhost:3001/client/{clientId}/session/{sessionId}
```
Returns events for a specific client in a specific session.

## 🎯 Use Cases

### 1. **Load Testing**
- Use Multi-Client Event Sender to simulate high load
- Monitor system performance under stress
- Test Redis queue behavior

### 2. **Development & Debugging**
- Use Redis queries to inspect data
- Monitor event flow in real-time
- Debug client-specific issues

### 3. **Performance Monitoring**
- Track system statistics
- Monitor client activity patterns
- Analyze event processing efficiency

### 4. **RPA Workflow Testing**
- Test automation scenarios
- Validate event sequences
- Monitor step execution

## 📈 Performance Features

### Real-time Updates
- Auto-refresh every 5 seconds
- Configurable refresh intervals
- Real-time progress tracking

### Bulk Operations
- Concurrent event sending
- Progress monitoring
- Configurable intervals

### Data Visualization
- Progress bars
- Statistics cards
- Activity logs
- Client activity grids

## 🚨 Troubleshooting

### Common Issues

#### Dashboard Not Loading
```bash
# Check if Management API is running
curl http://localhost:3001/health

# Restart if needed
pkill -f "node management-api.js"
node management-api.js
```

#### Redis Queries Failing
```bash
# Check Redis connection
docker exec -it aws-localsetup-redis-1 redis-cli ping

# Check Redis data directly
docker exec -it aws-localsetup-redis-1 redis-cli KEYS "*"
```

#### Bulk Events Not Working
```bash
# Check API endpoint
curl -X POST http://localhost:3001/send-event \
  -H 'Content-Type: application/json' \
  -d '{"clientId": "test", "sessionId": "test", "action": "click", "target": "#button"}'

# Check logs in dashboard
```

### Debug Commands

#### Check System Status
```bash
# All services
curl http://localhost:3001/overview

# Redis data
curl http://localhost:3001/redis/keys

# Client activity
curl http://localhost:3001/clients/summary
```

#### Monitor Real-time Activity
```bash
# Watch Redis data changes
watch -n 2 'curl -s http://localhost:3001/overview | jq .'

# Monitor specific session
watch -n 2 'curl -s http://localhost:3001/pending-steps/session-001 | jq .'
```

## 🎉 Success Indicators

✅ **Dashboard loads without errors**
✅ **Multi-client events send successfully**
✅ **Redis queries return data**
✅ **Real-time updates work**
✅ **Progress bars function correctly**
✅ **Activity logs show events**
✅ **Statistics update in real-time**

## 🚀 Quick Start

### 1. Start the System
```bash
./start-system.sh
```

### 2. Access Dashboard
Open: http://localhost:3001/dashboard.html

### 3. Test Multi-Client Events
- Set: 3 clients, 5 events each, 1000ms interval
- Click "Start Bulk Events"
- Watch progress and logs

### 4. Test Redis Queries
- Select "Pending Steps" query type
- Click "Query Redis"
- View results

### 5. Monitor Activity
- Switch between tabs
- Watch real-time updates
- Check activity logs

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Verify all services are running
3. Check the activity logs in the dashboard
4. Use the debug commands provided

---

**Your Advanced RPA Dashboard is ready for production use!** 🎉 