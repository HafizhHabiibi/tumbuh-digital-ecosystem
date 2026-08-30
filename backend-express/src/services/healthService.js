import db from "../database/connection.js";
import { getDefaultGeminiClient } from "../integrations/geminiClient.js";

export const READINESS_COMPONENT_STATUS = Object.freeze({
    READY: "ready",
    NOT_CONFIGURED: "not_configured",
    UNAVAILABLE: "unavailable",
    UNKNOWN: "unknown",
});

const defaultGetAiHealth = () => getDefaultGeminiClient().getHealth();

export const buatHealthService = ({
    database = db,
    getAiHealth = defaultGetAiHealth,
} = {}) => {
    const checkReadiness = async () => {
        try {
            await database.query("SELECT 1");
        } catch (error) {
            return {
                ready: false,
                components: {
                    database: READINESS_COMPONENT_STATUS.UNAVAILABLE,
                    ai: READINESS_COMPONENT_STATUS.UNKNOWN,
                },
                error,
            };
        }

        const aiHealth = getAiHealth();
        const aiConfigured = aiHealth.totalKeys > 0;
        const aiAvailable = aiHealth.availableKeys > 0;
        const aiStatus = !aiConfigured
            ? READINESS_COMPONENT_STATUS.NOT_CONFIGURED
            : aiAvailable
              ? READINESS_COMPONENT_STATUS.READY
              : READINESS_COMPONENT_STATUS.UNAVAILABLE;

        return {
            ready: aiStatus === READINESS_COMPONENT_STATUS.READY,
            components: {
                database: READINESS_COMPONENT_STATUS.READY,
                ai: aiStatus,
                ai_model: aiHealth.model,
            },
            error: null,
        };
    };

    return Object.freeze({ checkReadiness });
};

const healthService = buatHealthService();
export const checkReadiness = healthService.checkReadiness;
