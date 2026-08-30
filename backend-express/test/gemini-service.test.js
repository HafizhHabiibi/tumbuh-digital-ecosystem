import test from "node:test";
import assert from "node:assert/strict";

import {
    formatInsight,
    generateChatContent,
    generateInsightContent,
    susunPromptChat,
    susunPromptInsight,
    validateInsightResponse,
} from "../src/services/geminiService.js";

const measurement = {
    jenis_kelamin: "L",
    usia_bulan: 24,
    berat_badan: 10.5,
    tinggi_badan: 82.3,
    nilai_imt: 15.5,
    zscore_bbu: -1.2,
    zscore_tbu: -2.1,
    zscore_bbtb: 0.1,
    zscore_imtu: 0.2,
    status_bbu: "berat_badan_normal",
    status_tbu: "pendek",
    status_bbtb: "gizi_baik",
    status_imtu: "gizi_baik",
    kategori_prioritas: "sedang",
};

const validInsight = {
    ringkasan: "Hasil terbaru menunjukkan pertumbuhan anak perlu dipantau bersama.",
    tips: [
        "Sediakan makanan keluarga yang beragam.",
        "Ajak anak bermain aktif sesuai usianya.",
        "Jaga kebersihan tangan dan alat makan.",
    ],
    catatan_pemantauan: "Lanjutkan pemantauan rutin bersama kader Posyandu.",
};

test("prompt insight tidak mengirim Z-Score mentah", () => {
    const prompt = susunPromptInsight(measurement);

    assert.doesNotMatch(prompt, /z-?score/i);
    assert.doesNotMatch(prompt, /-1\.2|-2\.1|0\.1|0\.2/);
    assert.match(prompt, /Usia saat pengukuran: 24 bulan/);
    assert.match(prompt, /Kategori TB\/U: lebih pendek/);
    assert.match(prompt, /Prioritas pemantauan SAW: sedang/);
});

test("validator insight mewajibkan tepat tiga tips dan membatasi teks", () => {
    assert.deepEqual(validateInsightResponse(validInsight), validInsight);
    assert.throws(
        () => validateInsightResponse({ ...validInsight, tips: ["Satu"] }),
        /tepat tiga tips/,
    );
    assert.throws(
        () =>
            validateInsightResponse({
                ...validInsight,
                ringkasan: "x".repeat(701),
            }),
        /batas karakter/,
    );
    assert.throws(
        () =>
            validateInsightResponse({
                ...validInsight,
                ringkasan: "Anak Anda mengalami stunting.",
            }),
        (error) => error.code === "AI_DIAGNOSIS_CLAIM",
    );
});

test("formatter mempertahankan tampilan insight lama dan disclaimer", () => {
    const formatted = formatInsight(validInsight);

    assert.match(formatted, /\*\*Kondisi Saat Ini\*\*/);
    assert.match(formatted, /1\. Sediakan makanan/);
    assert.match(formatted, /3\. Jaga kebersihan/);
    assert.match(formatted, /\*\*Catatan Pemantauan\*\*/);
    assert.match(formatted, /bukan diagnosis/i);
});

test("generateInsightContent memakai client terinjeksi dan menghasilkan teks", async () => {
    let request;
    const client = {
        generateStructuredContent: async (value) => {
            request = value;
            return { data: validInsight, model: "gemini-3.6-flash" };
        },
    };

    const result = await generateInsightContent(measurement, { client });

    assert.equal(result.model, "gemini-3.6-flash");
    assert.deepEqual(result.structured, validInsight);
    assert.match(result.insight_teks, /pemantauan rutin/);
    assert.equal(typeof request.validate, "function");
    assert.equal(request.maxOutputTokens, 1024);
    assert.match(request.systemInstruction, /usia anak saat pengukuran/);
    assert.match(request.systemInstruction, /bukan usia anak saat ini/);
});

const chatContext = {
    pengukuran: {
        jenis_kelamin: "L",
        usia_bulan: 24,
        berat_badan: 11,
        tinggi_badan: 85,
        nilai_imt: 15.22,
        status_bbu: "berat_badan_normal",
        status_tbu: "normal",
        status_bbtb: "gizi_baik",
        status_imtu: "gizi_baik",
        kategori_prioritas: "rendah",
    },
    insight_awal: "Pertahankan kebiasaan makan yang beragam.",
    riwayat_pesan: [
        { role: "orang_tua", content: "Apa contoh proteinnya?" },
        { role: "assistant", content: "Telur, ikan, atau tempe." },
    ],
};

test("prompt chat membawa insight dan history tanpa identitas atau Z-Score", () => {
    const prompt = susunPromptChat(chatContext, "Bagaimana variasinya?");

    assert.match(prompt, /Insight awal: Pertahankan/);
    assert.match(prompt, /Usia saat pengukuran: 24 bulan/);
    assert.match(prompt, /orang_tua: Apa contoh proteinnya/);
    assert.match(prompt, /PERTANYAAN ORANG TUA SAAT INI/);
    assert.doesNotMatch(prompt, /z-?score|nik|nama anak/i);
});

test("generateChatContent memakai schema dan validator guardrail", async () => {
    let request;
    const client = {
        generateStructuredContent: async (options) => {
            request = options;
            return {
                data: options.validate({
                    response_type: "answered",
                    answer: "Variasikan lauk sumber protein setiap hari.",
                }),
                model: "gemini-3.6-flash",
            };
        },
    };

    const result = await generateChatContent(
        chatContext,
        "Apa variasi makanannya?",
        { client },
    );

    assert.equal(result.response_type, "answered");
    assert.equal(result.model, "gemini-3.6-flash");
    assert.equal(request.maxOutputTokens, 512);
    assert.equal(request.responseSchema.type, "OBJECT");
    assert.match(request.systemInstruction, /usia anak saat pengukuran/);
    assert.match(request.systemInstruction, /bukan usia anak saat ini/);
});
