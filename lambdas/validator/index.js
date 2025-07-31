const Redis = require('ioredis');
const redis = new Redis(6379, 'redis'); // Use the service name from docker-compose

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const sessionId = body.sessionId;
    await redis.lpush(`pending_steps:${sessionId}`, event.body);
    console.log(`Step queued for session: ${sessionId}`);
    return { statusCode: 200, body: 'Step Queued' };
  } catch (error) {
    console.error('Error:', error);
    return { statusCode: 500, body: 'Error: ' + error.message };
  }
}; 