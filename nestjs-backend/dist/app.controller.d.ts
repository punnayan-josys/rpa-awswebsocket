import { AppService } from './app.service';
import { RedisService } from './redis.service';
export declare class AppController {
    private readonly appService;
    private readonly redisService;
    constructor(appService: AppService, redisService: RedisService);
    getHello(): string;
    getHealth(): {
        status: string;
        timestamp: string;
        service: string;
    };
    getQueueCount(sessionId: string): Promise<{
        sessionId: string;
        pendingSteps: number;
        timestamp: string;
    }>;
    getQueueSteps(sessionId: string): Promise<{
        sessionId: string;
        steps: any[];
        count: number;
        timestamp: string;
    }>;
}
