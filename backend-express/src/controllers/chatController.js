import { GeminiClientError } from "../integrations/geminiClient.js";
import { ChatInputValidationError } from "../services/aiGuardrailService.js";
import {
    ChatServiceError,
    getChatConversation,
    sendChatMessage,
} from "../services/chatService.js";
import { error, success } from "../utils/response.js";

const handleChatError = (res, err) => {
    if (err instanceof ChatInputValidationError) {
        return error(res, err.message, 400);
    }
    if (err instanceof ChatServiceError) {
        return error(res, err.message, err.status);
    }
    if (err instanceof GeminiClientError) {
        return res.status(503).json({
            success: false,
            message: "Layanan edukasi AI sedang tidak tersedia, silakan coba kembali",
            data: null,
        });
    }
    return error(res, err.message);
};

export const buatChatController = (dependencies = {}) => {
    const getConversation =
        dependencies.getConversation || getChatConversation;
    const sendMessage = dependencies.sendMessage || sendChatMessage;

    const getHistory = async (req, res) => {
        try {
            const result = await getConversation({
                pengukuranId: req.validatedParams.id,
                orangTuaId: req.orangTua.id,
                limit: req.validatedQuery.limit,
                beforeId: req.validatedQuery.before_id || null,
            });
            res.setHeader("Cache-Control", "private, no-store");
            return success(res, result, "Percakapan berhasil diambil");
        } catch (err) {
            return handleChatError(res, err);
        }
    };

    const postMessage = async (req, res) => {
        try {
            const result = await sendMessage({
                pengukuranId: req.validatedParams.id,
                orangTuaId: req.orangTua.id,
                clientMessageId: req.body.client_message_id,
                message: req.body.message,
                requestId: req.id,
            });
            res.setHeader("Cache-Control", "private, no-store");
            return success(
                res,
                result,
                result.idempotent
                    ? "Pesan sebelumnya berhasil diambil"
                    : "Pesan berhasil dijawab",
                result.idempotent ? 200 : 201,
            );
        } catch (err) {
            return handleChatError(res, err);
        }
    };

    return Object.freeze({ getHistory, postMessage });
};

const chatController = buatChatController();
export const getChatHistory = chatController.getHistory;
export const postChatMessage = chatController.postMessage;
