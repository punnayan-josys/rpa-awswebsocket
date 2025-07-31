export declare class RedisService {
    private readonly logger;
    private redis;
    constructor();
    processPendingSteps(): Promise<void>;
    private processStep;
    getPendingStepsCount(sessionId: string): Promise<number>;
    getAllPendingSteps(sessionId: string): Promise<string[]>;
}
