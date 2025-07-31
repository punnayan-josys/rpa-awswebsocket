import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import Redis from 'ioredis';

@Injectable()
export class RedisService {
  private readonly logger = new Logger(RedisService.name);
  private redis: Redis;

  constructor() {
    this.redis = new Redis({
      host: 'localhost',
      port: 6379,
    });

    this.redis.on('connect', () => {
      this.logger.log('Connected to Redis');
    });

    this.redis.on('error', (error) => {
      this.logger.error('Redis connection error:', error);
    });
  }

  @Cron(CronExpression.EVERY_5_SECONDS)
  async processPendingSteps() {
    try {
      // Get all keys that match the pattern pending_steps:*
      const keys = await this.redis.keys('pending_steps:*');
      
      for (const key of keys) {
        // Pop one item from the list (non-blocking)
        const step = await this.redis.rpop(key);
        
        if (step) {
          const sessionId = key.replace('pending_steps:', '');
          const stepData = JSON.parse(step);
          
          this.logger.log(`Processing step for session ${sessionId}:`, stepData);
          
          // Here you would process the step (e.g., save to database, trigger actions, etc.)
          await this.processStep(sessionId, stepData);
        }
      }
    } catch (error) {
      this.logger.error('Error processing pending steps:', error);
    }
  }

  private async processStep(sessionId: string, stepData: any) {
    // Simulate processing time
    await new Promise(resolve => setTimeout(resolve, 100));
    
    this.logger.log(`✅ Processed step for session ${sessionId}:`, {
      type: stepData.payload?.type,
      target: stepData.payload?.target,
      timestamp: new Date().toISOString()
    });
  }

  async getPendingStepsCount(sessionId: string): Promise<number> {
    return await this.redis.llen(`pending_steps:${sessionId}`);
  }

  async getAllPendingSteps(sessionId: string): Promise<string[]> {
    return await this.redis.lrange(`pending_steps:${sessionId}`, 0, -1);
  }
} 