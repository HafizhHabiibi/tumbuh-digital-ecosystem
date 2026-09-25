import "dotenv/config";

import { createHash } from "node:crypto";
import { performance } from "node:perf_hooks";

import {
    createGeminiClient,
    getGeminiConfig,
} from "../src/integrations/geminiClient.js";
import { generateChatContent } from "../src/services/geminiService.js";

const config = getGeminiConfig();

if (config.apiKeys.length === 0) {
    throw new Error(
        "Validasi dibatalkan: GEMINI_API_KEYS atau GEMINI_API_KEY belum dikonfigurasi",
    );
}

const fingerprint = (key) =>
    createHash("sha256").update(key).digest("hex").slice(0, 8);

const syntheticContext = Object.freeze({
    pengukuran: Object.freeze({
        jenis_kelamin: "L",
        usia_bulan: 24,
        berat_badan: 11.5,
        tinggi_badan: 84,
        nilai_imt: 16.3,
        status_bbu: "berat_badan_normal",
        status_tbu: "normal",
        status_bbtb: "gizi_baik",
        status_imtu: "gizi_baik",
        prioritas_pemantauan: "rendah",
    }),
    insight_awal:
        "Pertumbuhan perlu dipertahankan melalui kebiasaan makan yang beragam.",
    riwayat_pesan: Object.freeze([]),
});

const results = [];

for (const [index, apiKey] of config.apiKeys.entries()) {
    const attempts = [];
    const client = createGeminiClient({
        ...config,
        apiKeys: [apiKey],
        maxTotalAttempts: 1,
        maxTransientRetries: 0,
        invalidResponseRetries: 0,
        logger: { warn: () => {} },
        onAttemptFailure: (event) => attempts.push(event),
    });
    const startedAt = performance.now();

    try {
        const response = await generateChatContent(
            syntheticContext,
            "Sebutkan satu contoh sumber protein sederhana untuk anak.",
            { client, requestId: `controlled-key-check-${index + 1}` },
        );
        results.push({
            key_index: index + 1,
            key_fingerprint: fingerprint(apiKey),
            status: "success",
            model: response.model,
            response_type: response.response_type,
            attempts: 1,
            duration_ms: Math.round(performance.now() - startedAt),
        });
    } catch (error) {
        const attempt = attempts.at(-1);
        results.push({
            key_index: index + 1,
            key_fingerprint: fingerprint(apiKey),
            status: "failed",
            error_code: error?.code || "UNKNOWN_ERROR",
            diagnostic_code: error?.diagnosticCode || error?.code || null,
            http_status: attempt?.http_status ?? error?.status ?? null,
            provider_status: attempt?.provider_status ?? null,
            provider_reason: attempt?.provider_reason ?? null,
            retry_after_ms: error?.retryAfterMs ?? attempt?.retry_after_ms ?? null,
            attempts: attempts.length || 1,
            duration_ms: Math.round(performance.now() - startedAt),
        });
    }
}

const passed = results.filter((result) => result.status === "success").length;

console.log(
    JSON.stringify(
        {
            success: passed === results.length,
            model: config.model,
            total_keys: results.length,
            passed_keys: passed,
            failed_keys: results.length - passed,
            max_provider_calls_per_key: 1,
            results,
        },
        null,
        2,
    ),
);

if (passed !== results.length) process.exitCode = 1;
