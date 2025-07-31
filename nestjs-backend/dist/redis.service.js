"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var RedisService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RedisService = void 0;
const common_1 = require("@nestjs/common");
const schedule_1 = require("@nestjs/schedule");
const ioredis_1 = require("ioredis");
let RedisService = RedisService_1 = class RedisService {
    logger = new common_1.Logger(RedisService_1.name);
    redis;
    constructor() {
        this.redis = new ioredis_1.default({
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
    async processPendingSteps() {
        try {
            const keys = await this.redis.keys('pending_steps:*');
            for (const key of keys) {
                const step = await this.redis.rpop(key);
                if (step) {
                    const sessionId = key.replace('pending_steps:', '');
                    const stepData = JSON.parse(step);
                    this.logger.log(`Processing step for session ${sessionId}:`, stepData);
                    await this.processStep(sessionId, stepData);
                }
            }
        }
        catch (error) {
            this.logger.error('Error processing pending steps:', error);
        }
    }
    async processStep(sessionId, stepData) {
        await new Promise(resolve => setTimeout(resolve, 100));
        this.logger.log(`✅ Processed step for session ${sessionId}:`, {
            type: stepData.payload?.type,
            target: stepData.payload?.target,
            timestamp: new Date().toISOString()
        });
    }
    async getPendingStepsCount(sessionId) {
        return await this.redis.llen(`pending_steps:${sessionId}`);
    }
    async getAllPendingSteps(sessionId) {
        return await this.redis.lrange(`pending_steps:${sessionId}`, 0, -1);
    }
};
exports.RedisService = RedisService;
__decorate([
    (0, schedule_1.Cron)(schedule_1.CronExpression.EVERY_5_SECONDS),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], RedisService.prototype, "processPendingSteps", null);
exports.RedisService = RedisService = RedisService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], RedisService);
//# sourceMappingURL=redis.service.js.map