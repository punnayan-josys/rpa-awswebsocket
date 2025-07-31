import { Controller, Get, Param } from '@nestjs/common';
import { AppService } from './app.service';
import { RedisService } from './redis.service';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly redisService: RedisService,
  ) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('health')
  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'NestJS RPA Backend'
    };
  }

  @Get('queue/:sessionId/count')
  async getQueueCount(@Param('sessionId') sessionId: string) {
    const count = await this.redisService.getPendingStepsCount(sessionId);
    return {
      sessionId,
      pendingSteps: count,
      timestamp: new Date().toISOString()
    };
  }

  @Get('queue/:sessionId/steps')
  async getQueueSteps(@Param('sessionId') sessionId: string) {
    const steps = await this.redisService.getAllPendingSteps(sessionId);
    return {
      sessionId,
      steps: steps.map(step => JSON.parse(step)),
      count: steps.length,
      timestamp: new Date().toISOString()
    };
  }
}
