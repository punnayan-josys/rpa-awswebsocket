const Redis = require('ioredis');
const redis = new Redis(6379, 'redis');

exports.handler = async (event) => {
  console.log('Connection event:', JSON.stringify(event, null, 2));
  
  const { requestContext } = event;
  const { eventType, connectionId, routeKey } = requestContext;
  
  try {
    switch (eventType) {
      case 'CONNECT':
        // Parse connection data
        const connectData = JSON.parse(event.body || '{}');
        const clientId = connectData.clientId || connectionId;
        
        // Store connection mapping in Redis
        await redis.hset(`connections:${connectionId}`, {
          connectionId,
          clientId,
          timestamp: new Date().toISOString(),
          status: 'connected',
          sessionId: connectData.sessionId || 'default'
        });
        
        // Store client mapping
        await redis.hset(`clients:${clientId}`, {
          clientId,
          connectionId,
          timestamp: new Date().toISOString(),
          status: 'connected'
        });
        
        // Add to active connections list
        await redis.sadd('active_connections', connectionId);
        await redis.sadd('active_clients', clientId);
        
        console.log(`✅ WebSocket connected: ${connectionId} (Client: ${clientId})`);
        return { statusCode: 200 };
        
      case 'DISCONNECT':
        // Get client info before removing
        const clientInfo = await redis.hgetall(`connections:${connectionId}`);
        const clientIdToRemove = clientInfo.clientId;
        
        // Remove connection info from Redis
        await redis.del(`connections:${connectionId}`);
        if (clientIdToRemove) {
          await redis.del(`clients:${clientIdToRemove}`);
          await redis.srem('active_clients', clientIdToRemove);
        }
        
        // Remove from active connections
        await redis.srem('active_connections', connectionId);
        
        console.log(`❌ WebSocket disconnected: ${connectionId} (Client: ${clientIdToRemove})`);
        return { statusCode: 200 };
        
      case 'MESSAGE':
        // Route messages based on action
        const body = JSON.parse(event.body || '{}');
        const action = body.action || routeKey;
        
        switch (action) {
          case 'recordStep':
            // Get client info from connection
            const connectionInfo = await redis.hgetall(`connections:${connectionId}`);
            const clientId = connectionInfo.clientId || body.clientId || connectionId;
            
            // Add client info to the event
            const enrichedEvent = {
              ...body,
              clientId: clientId,
              connectionId: connectionId,
              timestamp: new Date().toISOString()
            };
            
            // Queue the step for processing
            const sessionId = body.sessionId || 'default';
            await redis.lpush(`pending_steps:${sessionId}`, JSON.stringify(enrichedEvent));
            
            // Track client activity
            await redis.hincrby(`clients:${clientId}`, 'eventsSent', 1);
            await redis.hset(`clients:${clientId}`, 'lastActivity', new Date().toISOString());
            
            console.log(`📝 Step queued via WebSocket for session: ${sessionId} (Client: ${clientId})`);
            
            // Send confirmation back to client
            return {
              statusCode: 200,
              body: JSON.stringify({
                action: 'stepRecorded',
                sessionId,
                clientId,
                connectionId,
                timestamp: new Date().toISOString()
              })
            };
            
          case 'getStatus':
            // Return connection and client status
            const status = await getConnectionStatus(connectionId);
            return {
              statusCode: 200,
              body: JSON.stringify(status)
            };
            
          default:
            console.log(`⚠️ Unknown action: ${action}`);
            return {
              statusCode: 400,
              body: JSON.stringify({ error: 'Unknown action' })
            };
        }
        
      default:
        console.log(`⚠️ Unknown event type: ${eventType}`);
        return { statusCode: 400 };
    }
  } catch (error) {
    console.error('❌ Connection manager error:', error);
    return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
  }
};

// Helper function to get connection status
async function getConnectionStatus(connectionId) {
  const connectionInfo = await redis.hgetall(`connections:${connectionId}`);
  const clientId = connectionInfo.clientId;
  
  let clientInfo = {};
  if (clientId) {
    clientInfo = await redis.hgetall(`clients:${clientId}`);
  }
  
  return {
    connectionId,
    clientId,
    connectionInfo,
    clientInfo,
    timestamp: new Date().toISOString()
  };
} 