import { GeminiClientError } from "../integrations/geminiClient.js";
import InsightModel from "../models/insightModel.js";
import { buildMeasurementAiContext } from "./aiContextService.js";
import { generateInsightContent } from "./geminiService.js";

export const INSIGHT_PROCESSING_CONFIG = Object.freeze({
    maxAttempts: 3,
    leaseSeconds: 300,
    batchSize: 10,
    concurrency: 2,
    workerIntervalMs: 30000,
    maxRetryDelaySeconds: 3600,
});

const safeErrorMessage = (error) => {
    const code =
        error instanceof GeminiClientError && error.code
            ? `${error.code}: `
            : "";
    return `${code}${error.message || "Kesalahan tidak diketahui"}`.slice(0, 500);
};

export const buatInsightService = (dependencies = {}) => {
    const repository = dependencies.repository || InsightModel;
    const generateContent =
        dependencies.generateContent || generateInsightContent;
    const config = {
        ...INSIGHT_PROCESSING_CONFIG,
        ...(dependencies.config || {}),
    };

    const processInsight = async (pengukuranId) => {
        const claimed = await repository.claim(
            pengukuranId,
            config.maxAttempts,
            config.leaseSeconds,
        );
        if (!claimed) {
            return { processed: false, reason: "not_due_or_already_claimed" };
        }

        try {
            const generated = await generateContent(
                buildMeasurementAiContext(claimed),
            );
            const saved = await repository.complete(
                claimed.id,
                claimed.insight_attempts,
                generated.insight_teks,
                generated.model,
            );

            return {
                processed: true,
                success: saved,
                reason: saved ? null : "claim_expired",
            };
        } catch (error) {
            const retryable =
                error instanceof GeminiClientError && error.retryable;
            const willRetry =
                retryable && claimed.insight_attempts < config.maxAttempts;
            const exponentialDelay = Math.min(
                15 * 2 ** claimed.insight_attempts,
                config.maxRetryDelaySeconds,
            );
            const providerDelay = Math.ceil(
                Math.max(0, Number(error.retryAfterMs) || 0) / 1000,
            );
            const retryDelaySeconds = Math.min(
                Math.max(exponentialDelay, providerDelay),
                config.maxRetryDelaySeconds,
            );

            await repository.recordFailure({
                pengukuranId: claimed.id,
                attempt: claimed.insight_attempts,
                willRetry,
                retryDelaySeconds,
                errorMessage: safeErrorMessage(error),
            });

            return {
                processed: true,
                success: false,
                willRetry,
                reason: willRetry ? "scheduled_retry" : "failed",
            };
        }
    };

    const processPendingInsights = async (limit = config.batchSize) => {
        const ids = await repository.findDueIds(limit, config.maxAttempts);
        let cursor = 0;
        const results = [];
        const workers = Array.from(
            { length: Math.min(config.concurrency, ids.length) },
            async () => {
                while (cursor < ids.length) {
                    const id = ids[cursor++];
                    results.push(await processInsight(id));
                }
            },
        );
        await Promise.all(workers);
        return { processed: ids.length, results };
    };

    const getInsightForOrangTua = (pengukuranId, orangTuaId) =>
        repository.findForOrangTua(pengukuranId, orangTuaId);

    return Object.freeze({
        processInsight,
        processPendingInsights,
        getInsightForOrangTua,
    });
};

const insightService = buatInsightService();

export const processInsight = insightService.processInsight;
export const processPendingInsights = insightService.processPendingInsights;
export const getInsightForOrangTua = insightService.getInsightForOrangTua;
