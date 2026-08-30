import ChatModel from "../models/chatModel.js";
import { loadLatestConversationContext } from "./aiContextService.js";
import { evaluateChatInput } from "./aiGuardrailService.js";
import { generateChatContent } from "./geminiService.js";
import aiObservability from "./aiObservabilityService.js";

const CLIENT_MESSAGE_ID_PATTERN =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export class ChatServiceError extends Error {
    constructor(message, code, status = 400, options = {}) {
        super(message, options.cause ? { cause: options.cause } : undefined);
        this.name = "ChatServiceError";
        this.code = code;
        this.status = status;
    }
}

const validateClientMessageId = (value) => {
    if (typeof value !== "string" || !CLIENT_MESSAGE_ID_PATTERN.test(value)) {
        throw new ChatServiceError(
            "client_message_id wajib berupa UUID yang valid",
            "CHAT_INVALID_CLIENT_MESSAGE_ID",
        );
    }
    return value.toLowerCase();
};

export const buatChatService = (dependencies = {}) => {
    const repository = dependencies.repository || ChatModel;
    const contextLoader =
        dependencies.contextLoader || loadLatestConversationContext;
    const generate = dependencies.generate || generateChatContent;
    const guardInput = dependencies.guardInput || evaluateChatInput;
    const observability = dependencies.observability || aiObservability;
    const nowFn = dependencies.nowFn || Date.now;

    const getConversation = async ({
        pengukuranId,
        orangTuaId,
        limit = 50,
        beforeId = null,
    }) => {
        const measurement = await repository.findMeasurementForOrangTua(
            pengukuranId,
            orangTuaId,
        );
        if (!measurement) {
            throw new ChatServiceError(
                "Percakapan tidak ditemukan",
                "CHAT_CONVERSATION_NOT_FOUND",
                404,
            );
        }

        const page = await repository.findMessagesPage(pengukuranId, {
            limit,
            beforeId,
        });
        return {
            pengukuran_id: measurement.id,
            is_active: Boolean(measurement.is_latest),
            insight_status: measurement.insight_status,
            insight_teks: measurement.insight_teks,
            messages: page.items,
            pagination: {
                has_more: page.hasMore,
                next_before_id: page.nextBeforeId,
            },
        };
    };

    const sendMessage = async ({
        pengukuranId,
        orangTuaId,
        clientMessageId,
        message,
        requestId,
    }) => {
        const startedAt = nowFn();
        let providerUsed = false;
        let reservation = null;
        try {
            const normalizedClientId = validateClientMessageId(clientMessageId);
            const evaluation = guardInput(message);

            const context = await contextLoader(pengukuranId, orangTuaId);
            if (!context) {
                throw new ChatServiceError(
                    "Percakapan hanya dapat dilanjutkan pada pengukuran terbaru milik orang tua",
                    "CHAT_MEASUREMENT_NOT_ACTIVE",
                    404,
                );
            }
            if (!context.insight_awal) {
                throw new ChatServiceError(
                    "Insight awal belum tersedia",
                    "CHAT_INSIGHT_NOT_READY",
                    409,
                );
            }

            try {
                reservation = await repository.reserveExchange({
                    pengukuranId,
                    clientMessageId: normalizedClientId,
                    userContent: evaluation.message,
                });
            } catch (error) {
                if (error?.code === "CHAT_CLIENT_MESSAGE_ID_CONFLICT") {
                    throw new ChatServiceError(
                        "client_message_id sudah digunakan untuk pesan yang berbeda",
                        "CHAT_IDEMPOTENCY_CONFLICT",
                        409,
                        { cause: error },
                    );
                }
                throw error;
            }

            if (reservation.status === "completed") {
                const result = { ...reservation.exchange, idempotent: true };
                observability.recordChatSuccess({
                    requestId,
                    responseType:
                        reservation.exchange.assistant_message.response_type,
                    idempotent: true,
                    providerUsed: false,
                    durationMs: nowFn() - startedAt,
                });
                return result;
            }
            if (reservation.status === "processing") {
                throw new ChatServiceError(
                    "Pesan yang sama sedang diproses",
                    "CHAT_REQUEST_PROCESSING",
                    409,
                );
            }

            let response;
            if (evaluation.allowed) {
                providerUsed = true;
                response = await generate(context, evaluation.message);
            } else {
                response = {
                    response_type: evaluation.response_type,
                    answer: evaluation.answer,
                };
            }

            const exchange = await repository.completeExchange({
                userMessage: reservation.userMessage,
                requestToken: reservation.requestToken,
                assistantContent: response.answer,
                responseType: response.response_type,
            });
            reservation = null;
            const result = { ...exchange, idempotent: false };
            observability.recordChatSuccess({
                requestId,
                responseType: result.assistant_message.response_type,
                idempotent: result.idempotent,
                providerUsed,
                durationMs: nowFn() - startedAt,
            });
            return result;
        } catch (error) {
            if (reservation?.status === "reserved") {
                try {
                    await repository.releaseReservation({
                        userMessageId: reservation.userMessage.id,
                        requestToken: reservation.requestToken,
                    });
                } catch {
                    // Lease tetap memiliki expiry agar dapat dipulihkan.
                }
            }
            observability.recordChatFailure({
                requestId,
                code: error?.code || error?.name,
                providerUsed,
                durationMs: nowFn() - startedAt,
            });
            throw error;
        }
    };

    return Object.freeze({ getConversation, sendMessage });
};

const chatService = buatChatService();
export const getChatConversation = chatService.getConversation;
export const sendChatMessage = chatService.sendMessage;
