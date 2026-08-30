import test from "node:test";
import assert from "node:assert/strict";

import { ChatServiceError, buatChatService } from "../src/services/chatService.js";

const clientMessageId = "018f0000-0000-7000-8000-000000000001";
const context = {
    pengukuran: { kategori_prioritas: "sedang" },
    insight_awal: "Pertahankan pemantauan rutin.",
    riwayat_pesan: [],
};
const quietObservability = {
    recordChatSuccess: () => {},
    recordChatFailure: () => {},
};
const makeService = (options) =>
    buatChatService({ observability: quietObservability, ...options });

const makeRepository = () => {
    const saved = [];
    const reservations = [];
    const released = [];
    return {
        saved,
        reservations,
        released,
        reserveExchange: async (exchange) => {
            reservations.push(exchange);
            return {
                status: "reserved",
                requestToken: "lease-1",
                userMessage: {
                    id: 1,
                    client_message_id: exchange.clientMessageId,
                    role: "orang_tua",
                    content: exchange.userContent,
                },
            };
        },
        completeExchange: async (exchange) => {
            saved.push(exchange);
            return {
                user_message: exchange.userMessage,
                assistant_message: {
                    id: 2,
                    role: "assistant",
                    content: exchange.assistantContent,
                    response_type: exchange.responseType,
                },
            };
        },
        releaseReservation: async (reservation) => released.push(reservation),
    };
};

test("history milik orang tua mengembalikan status aktif dan pagination", async () => {
    const repository = makeRepository();
    repository.findMeasurementForOrangTua = async () => ({
        id: 10,
        latest_pengukuran_id: 12,
        is_latest: 0,
        insight_status: "completed",
        insight_teks: "Insight pengukuran lama.",
    });
    repository.findMessagesPage = async () => ({
        items: [{ id: 1, role: "orang_tua", content: "Pesan lama" }],
        hasMore: true,
        nextBeforeId: 1,
    });
    const service = makeService({ repository });

    const result = await service.getConversation({
        pengukuranId: 10,
        orangTuaId: "orang-tua-1",
        limit: 20,
    });

    assert.equal(result.is_active, false);
    assert.equal(result.latest_pengukuran_id, 12);
    assert.equal(result.insight_teks, "Insight pengukuran lama.");
    assert.equal(result.messages.length, 1);
    assert.deepEqual(result.pagination, {
        has_more: true,
        next_before_id: 1,
    });
});

test("history pengukuran milik orang tua lain tidak dapat dibaca", async () => {
    const repository = makeRepository();
    repository.findMeasurementForOrangTua = async () => null;
    let messagesCalled = false;
    repository.findMessagesPage = async () => {
        messagesCalled = true;
    };
    const service = makeService({ repository });

    await assert.rejects(
        service.getConversation({
            pengukuranId: 10,
            orangTuaId: "orang-tua-lain",
        }),
        (error) => error.code === "CHAT_CONVERSATION_NOT_FOUND" && error.status === 404,
    );
    assert.equal(messagesCalled, false);
});

test("pesan aman memanggil Gemini lalu menyimpan pasangan pesan", async () => {
    const repository = makeRepository();
    const generateCalls = [];
    const service = makeService({
        repository,
        contextLoader: async () => context,
        generate: async (...args) => {
            generateCalls.push(args);
            return {
                response_type: "answered",
                answer: "Variasikan sumber protein sesuai makanan keluarga.",
            };
        },
    });

    const result = await service.sendMessage({
        pengukuranId: 10,
        orangTuaId: "orang-tua-1",
        clientMessageId,
        message: "<b>Bagaimana</b> pola makannya?",
    });

    assert.equal(generateCalls.length, 1);
    assert.equal(generateCalls[0][1], "Bagaimana pola makannya?");
    assert.equal(repository.saved.length, 1);
    assert.equal(repository.reservations[0].userContent, "Bagaimana pola makannya?");
    assert.equal(result.idempotent, false);
});

test("data pribadi ditolak sebelum context, Gemini, dan database", async () => {
    const repository = makeRepository();
    let contextCalled = false;
    let generateCalled = false;
    const service = makeService({
        repository,
        contextLoader: async () => {
            contextCalled = true;
            return context;
        },
        generate: async () => {
            generateCalled = true;
        },
    });

    await assert.rejects(
        service.sendMessage({
            pengukuranId: 10,
            orangTuaId: "orang-tua-1",
            clientMessageId,
            message: "Email saya ibu@example.com, bagaimana hasilnya?",
        }),
        (error) => error.code === "CHAT_PII_DETECTED" && error.status === undefined,
    );

    assert.equal(contextCalled, false);
    assert.equal(generateCalled, false);
    assert.equal(repository.saved.length, 0);
});

test("service mencatat metadata hasil tanpa meneruskan isi pesan ke observability", async () => {
    const repository = makeRepository();
    const events = [];
    const service = makeService({
        repository,
        contextLoader: async () => context,
        generate: async () => ({
            response_type: "answered",
            answer: "Variasikan makanan keluarga.",
        }),
        observability: {
            recordChatSuccess: (event) => events.push(["success", event]),
            recordChatFailure: (event) => events.push(["failure", event]),
        },
        nowFn: (() => {
            const values = [100, 145];
            return () => values.shift();
        })(),
    });

    await service.sendMessage({
        pengukuranId: 10,
        orangTuaId: "orang-tua-rahasia",
        clientMessageId,
        message: "Menu apa untuk anak saya?",
        requestId: "req-aman",
    });

    assert.deepEqual(events, [["success", {
        requestId: "req-aman",
        responseType: "answered",
        idempotent: false,
        providerUsed: true,
        durationMs: 45,
    }]]);
    const serialized = JSON.stringify(events);
    assert.doesNotMatch(serialized, /Menu apa|orang-tua-rahasia|018f0000/);
});

test("penolakan deterministik disimpan tanpa memanggil Gemini", async () => {
    const repository = makeRepository();
    let generateCalled = false;
    const service = makeService({
        repository,
        contextLoader: async () => context,
        generate: async () => {
            generateCalled = true;
        },
    });

    const result = await service.sendMessage({
        pengukuranId: 10,
        orangTuaId: "orang-tua-1",
        clientMessageId,
        message: "Obat apa yang harus diberikan?",
    });

    assert.equal(generateCalled, false);
    assert.equal(result.assistant_message.response_type, "medical_advice_refused");
});

test("retry idempotent mengembalikan exchange lama tanpa Gemini dan tanpa insert", async () => {
    const repository = makeRepository();
    repository.reserveExchange = async () => ({
        status: "completed",
        exchange: {
            user_message: {
                id: 5,
                client_message_id: clientMessageId,
                role: "orang_tua",
                content: "Bagaimana pola makannya?",
            },
            assistant_message: {
                id: 6,
                role: "assistant",
                content: "Variasikan lauknya.",
                response_type: "answered",
            },
        },
    });
    let generateCalled = false;
    const service = makeService({
        repository,
        contextLoader: async () => context,
        generate: async () => {
            generateCalled = true;
        },
    });

    const result = await service.sendMessage({
        pengukuranId: 10,
        orangTuaId: "orang-tua-1",
        clientMessageId,
        message: "Bagaimana pola makannya?",
    });

    assert.equal(result.idempotent, true);
    assert.equal(generateCalled, false);
    assert.equal(repository.saved.length, 0);
});

test("idempotency key yang dipakai untuk isi berbeda ditolak", async () => {
    const repository = makeRepository();
    repository.reserveExchange = async () => {
        const error = new Error("conflict");
        error.code = "CHAT_CLIENT_MESSAGE_ID_CONFLICT";
        throw error;
    };
    const service = makeService({
        repository,
        contextLoader: async () => context,
    });

    await assert.rejects(
        service.sendMessage({
            pengukuranId: 10,
            orangTuaId: "orang-tua-1",
            clientMessageId,
            message: "Bagaimana pola makannya?",
        }),
        (error) => error instanceof ChatServiceError && error.code === "CHAT_IDEMPOTENCY_CONFLICT" && error.status === 409,
    );
});

test("request concurrent dengan UUID sama hanya memanggil Gemini sekali", async () => {
    const repository = makeRepository();
    let reservationActive = false;
    repository.reserveExchange = async (input) => {
        if (reservationActive) return { status: "processing" };
        reservationActive = true;
        return {
            status: "reserved",
            requestToken: "lease-concurrent",
            userMessage: {
                id: 7,
                client_message_id: input.clientMessageId,
                role: "orang_tua",
                content: input.userContent,
            },
        };
    };
    let releaseGenerate;
    const generateGate = new Promise((resolve) => {
        releaseGenerate = resolve;
    });
    let generateCalls = 0;
    const service = makeService({
        repository,
        contextLoader: async () => context,
        generate: async () => {
            generateCalls += 1;
            await generateGate;
            return { response_type: "answered", answer: "Jawaban aman." };
        },
    });
    const payload = {
        pengukuranId: 10,
        orangTuaId: "orang-tua-1",
        clientMessageId,
        message: "Bagaimana pola makannya?",
    };

    const first = service.sendMessage(payload);
    await new Promise((resolve) => setImmediate(resolve));
    const second = service.sendMessage(payload);
    await assert.rejects(
        second,
        (error) => error.code === "CHAT_REQUEST_PROCESSING" && error.status === 409,
    );
    releaseGenerate();
    await first;

    assert.equal(generateCalls, 1);
    assert.equal(repository.saved.length, 1);
});

test("kegagalan provider melepas reservasi agar UUID dapat dicoba ulang", async () => {
    const repository = makeRepository();
    const service = makeService({
        repository,
        contextLoader: async () => context,
        generate: async () => {
            throw new Error("provider gagal");
        },
    });

    await assert.rejects(service.sendMessage({
        pengukuranId: 10,
        orangTuaId: "orang-tua-1",
        clientMessageId,
        message: "Bagaimana pola makannya?",
    }));

    assert.deepEqual(repository.released, [{
        userMessageId: 1,
        requestToken: "lease-1",
    }]);
});

test("pengukuran lama, insight belum siap, dan UUID tidak valid ditolak", async () => {
    const repository = makeRepository();
    const inactive = makeService({
        repository,
        contextLoader: async () => null,
    });
    await assert.rejects(
        inactive.sendMessage({
            pengukuranId: 9,
            orangTuaId: "orang-tua-1",
            clientMessageId,
            message: "Bagaimana hasilnya?",
        }),
        (error) => error.code === "CHAT_MEASUREMENT_NOT_ACTIVE",
    );

    const notReady = makeService({
        repository,
        contextLoader: async () => ({ ...context, insight_awal: null }),
    });
    await assert.rejects(
        notReady.sendMessage({
            pengukuranId: 10,
            orangTuaId: "orang-tua-1",
            clientMessageId,
            message: "Bagaimana hasilnya?",
        }),
        (error) => error.code === "CHAT_INSIGHT_NOT_READY",
    );

    await assert.rejects(
        inactive.sendMessage({
            pengukuranId: 10,
            orangTuaId: "orang-tua-1",
            clientMessageId: "bukan-uuid",
            message: "Bagaimana hasilnya?",
        }),
        (error) => error.code === "CHAT_INVALID_CLIENT_MESSAGE_ID",
    );
});
