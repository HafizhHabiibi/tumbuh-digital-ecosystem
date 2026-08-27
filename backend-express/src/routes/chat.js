import express from "express";
import {
    getChatHistory,
    postChatMessage,
} from "../controllers/chatController.js";
import {
    validateBody,
    validateParams,
    validateQuery,
} from "../middlewares/validate.js";
import {
    chatHistoryQuerySchema,
    chatMessageSchema,
    chatPengukuranParamsSchema,
} from "../validation/schemas.js";
import { chatRateLimit } from "../middlewares/chatRateLimit.js";

export const buatChatRouter = (handlers = {}) => {
    const router = express.Router();
    const getHistory = handlers.getHistory || getChatHistory;
    const postMessage = handlers.postMessage || postChatMessage;
    const rateLimitMiddleware = handlers.rateLimit || chatRateLimit;

    router.get(
        "/:id/chat",
        validateParams(chatPengukuranParamsSchema),
        validateQuery(chatHistoryQuerySchema),
        getHistory,
    );
    router.post(
        "/:id/chat",
        rateLimitMiddleware,
        validateParams(chatPengukuranParamsSchema),
        validateBody(chatMessageSchema),
        postMessage,
    );
    return router;
};

export default buatChatRouter();
