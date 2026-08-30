import { performance } from "node:perf_hooks";

import { getDefaultGeminiClient } from "../src/integrations/geminiClient.js";
import { generateChatContent } from "../src/services/geminiService.js";

const client = getDefaultGeminiClient();
const health = client.getHealth();

if (health.totalKeys === 0) {
    throw new Error(
        "Smoke test dibatalkan: GEMINI_API_KEYS atau GEMINI_API_KEY belum dikonfigurasi",
    );
}

const syntheticContext = {
    pengukuran: {
        jenis_kelamin: "L",
        usia_bulan: 24,
        berat_badan: 11.5,
        tinggi_badan: 84,
        nilai_imt: 16.3,
        status_bbu: "normal",
        status_tbu: "normal",
        status_bbtb: "gizi_baik",
        status_imtu: "gizi_baik",
        kategori_prioritas: "rendah",
    },
    insight_awal:
        "Pertumbuhan berada dalam kategori yang perlu dipertahankan melalui kebiasaan sehat.",
    riwayat_pesan: [],
};

const startedAt = performance.now();
const result = await generateChatContent(
    syntheticContext,
    "Apa contoh sumber protein sederhana untuk anak?",
    { client },
);
const durationMs = Math.round(performance.now() - startedAt);

if (result.response_type !== "answered" || !result.answer?.trim()) {
    throw new Error("Smoke test gagal: respons edukatif Gemini tidak valid");
}

console.log(JSON.stringify({
    success: true,
    model: result.model,
    response_type: result.response_type,
    duration_ms: durationMs,
}));
