const express = require('express');
const Redis = require('ioredis');

const app = express();
const port = 3001;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Redis connection
const redis = new Redis(6379, 'localhost');

// Routes

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'RPA Management API'
  });
});

// Get system overview
app.get('/overview', async (req, res) => {
  try {
    const activeConnections = await redis.scard('active_connections');
    const activeClients = await redis.scard('active_clients');
    
    // Get all pending steps counts
    const keys = await redis.keys('pending_steps:*');
    const pendingSteps = {};
    
    for (const key of keys) {
      const sessionId = key.replace('pending_steps:', '');
      const count = await redis.llen(key);
      pendingSteps[sessionId] = count;
    }
    
    res.json({
      timestamp: new Date().toISOString(),
      activeConnections,
      activeClients,
      pendingSteps,
      totalPendingSteps: Object.values(pendingSteps).reduce((sum, count) => sum + count, 0)
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all active connections
app.get('/connections', async (req, res) => {
  try {
    const connectionIds = await redis.smembers('active_connections');
    const connections = [];
    
    for (const connectionId of connectionIds) {
      const info = await redis.hgetall(`connections:${connectionId}`);
      if (Object.keys(info).length > 0) {
        connections.push(info);
      }
    }
    
    res.json({
      connections,
      count: connections.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all active clients
app.get('/clients', async (req, res) => {
  try {
    const clientIds = await redis.smembers('active_clients');
    const clients = [];
    
    for (const clientId of clientIds) {
      const info = await redis.hgetall(`clients:${clientId}`);
      if (Object.keys(info).length > 0) {
        clients.push(info);
      }
    }
    
    res.json({
      clients,
      count: clients.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get Redis data by client ID
app.get('/client/:clientId', async (req, res) => {
  try {
    const { clientId } = req.params;
    
    // Get client info
    const clientInfo = await redis.hgetall(`clients:${clientId}`);
    
    if (Object.keys(clientInfo).length === 0) {
      return res.status(404).json({ 
        error: 'Client not found',
        clientId,
        timestamp: new Date().toISOString()
      });
    }
    
    // Get connection info if exists
    let connectionInfo = {};
    if (clientInfo.connectionId) {
      connectionInfo = await redis.hgetall(`connections:${clientInfo.connectionId}`);
    }
    
    // Get all pending steps for this client across all sessions
    const allPendingSteps = [];
    const sessionKeys = await redis.keys('pending_steps:*');
    
    for (const key of sessionKeys) {
      const steps = await redis.lrange(key, 0, -1);
      const sessionId = key.replace('pending_steps:', '');
      
      // Filter steps for this client
      const clientSteps = steps
        .map(step => JSON.parse(step))
        .filter(step => step.clientId === clientId)
        .map(step => ({
          ...step,
          sessionId,
          redisKey: key
        }));
      
      allPendingSteps.push(...clientSteps);
    }
    
    // Get client statistics
    const eventsSent = parseInt(clientInfo.eventsSent) || 0;
    const lastActivity = clientInfo.lastActivity || 'Never';
    const isActive = await redis.sismember('active_clients', clientId);
    
    // Get recent activity (last 10 events)
    const recentActivity = allPendingSteps
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
      .slice(0, 10);
    
    res.json({
      clientId,
      clientInfo,
      connectionInfo,
      statistics: {
        eventsSent,
        lastActivity,
        isActive,
        totalPendingSteps: allPendingSteps.length,
        sessions: [...new Set(allPendingSteps.map(step => step.sessionId))]
      },
      pendingSteps: allPendingSteps,
      recentActivity,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get client events by session
app.get('/client/:clientId/session/:sessionId', async (req, res) => {
  try {
    const { clientId, sessionId } = req.params;
    
    // Get all steps for this session
    const steps = await redis.lrange(`pending_steps:${sessionId}`, 0, -1);
    
    // Filter steps for this client
    const clientSteps = steps
      .map(step => JSON.parse(step))
      .filter(step => step.clientId === clientId);
    
    res.json({
      clientId,
      sessionId,
      steps: clientSteps,
      count: clientSteps.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all clients with their data summary
app.get('/clients/summary', async (req, res) => {
  try {
    const clientIds = await redis.smembers('active_clients');
    const clientsSummary = [];
    
    for (const clientId of clientIds) {
      const clientInfo = await redis.hgetall(`clients:${clientId}`);
      
      if (Object.keys(clientInfo).length > 0) {
        // Count pending steps for this client
        const sessionKeys = await redis.keys('pending_steps:*');
        let totalPendingSteps = 0;
        const sessions = [];
        
        for (const key of sessionKeys) {
          const steps = await redis.lrange(key, 0, -1);
          const sessionId = key.replace('pending_steps:', '');
          
          const clientSteps = steps
            .map(step => JSON.parse(step))
            .filter(step => step.clientId === clientId);
          
          if (clientSteps.length > 0) {
            totalPendingSteps += clientSteps.length;
            sessions.push({
              sessionId,
              stepsCount: clientSteps.length
            });
          }
        }
        
        clientsSummary.push({
          clientId,
          connectionId: clientInfo.connectionId,
          eventsSent: parseInt(clientInfo.eventsSent) || 0,
          lastActivity: clientInfo.lastActivity || 'Never',
          totalPendingSteps,
          sessions,
          isActive: true
        });
      }
    }
    
    res.json({
      clients: clientsSummary,
      count: clientsSummary.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get pending steps for a session
app.get('/pending-steps/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const steps = await redis.lrange(`pending_steps:${sessionId}`, 0, -1);
    
    res.json({
      sessionId,
      steps: steps.map(step => JSON.parse(step)),
      count: steps.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Send single RPA event
app.post('/send-event', async (req, res) => {
  try {
    const { clientId, sessionId, action, target, value } = req.body;
    
    const event = {
      action: 'recordStep',
      sessionId: sessionId || 'manual-session',
      payload: {
        type: action || 'click',
        target: target || '#button',
        timestamp: new Date().toISOString(),
        clientId: clientId || 'manual-client'
      }
    };
    
    if (value) {
      event.payload.value = value;
    }
    
    // Store directly in Redis for testing
    await redis.lpush(`pending_steps:${event.sessionId}`, JSON.stringify(event));
    
    res.json({
      message: 'Event sent',
      event,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Clear Redis data
app.post('/clear-data', async (req, res) => {
  try {
    const keys = await redis.keys('pending_steps:*');
    if (keys.length > 0) {
      await redis.del(...keys);
    }
    
    res.json({
      message: 'Data cleared',
      clearedKeys: keys.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start server
app.listen(port, () => {
  console.log(`🚀 Management API running on http://localhost:${port}`);
  console.log(`📊 Dashboard: http://localhost:${port}/dashboard.html`);
});

module.exports = app; 