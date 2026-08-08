import axios from "axios";
import db from "../database/connection.js";

const getGeminiUrl = () => {
    const model = process.env.GEMINI_MODEL || "gemini-2.0-flash";
    return `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
};

const LABEL_STATUS_TBU = {
    sangat_pendek: "sangat pendek untuk usiannya",
    pendek: "lebih pendek dari rata-rata untuk usiannya",
    normal: "memiliki tinggi badan yang sesuai dengan usiannya",
    tinggi: "lebih tinggi dari rata-rata untuk usiannya",
};

const LABEL_STATUS_BBU = {
    buruk: "berat badan sangat kurang",
    kurang: "berat badan kurang",
    normal: "berat badan normal",
    lebih: "berat badan berlebih",
};

const LABEL_STATUS_BBTB = {
    sangat_kurus: "sangat kurus untuk tingginya",
    kurus: "kurus untuk tingginya",
    normal: "proporsional",
    gemuk: "agak gemuk untuk tingginya",
    obesitas: "obesitas",
};

const susunPrompt = (data) => {
    const {
        jenis_kelamin,
        usia_bulan,
        berat_badan,
        tinggi_badan,
        zscore_bbu,
        zscore_tbu,
        zscore_bbtb,
        status_bbu,
        status_tbu,
        status_bbtb,
        kategori_risiko,
    } = data;

    const gender = jenis_kelamin === "L" ? "laki-laki" : "perempuan";
    const sapaan = jenis_kelamin === "L" ? "putra Anda" : "putri Anda";

    return `Kamu adalah asisten gizi posyandu. Berikan insight dalam Bahasa Indonesia yang hangat dan mudah dipahami orang tua. Jangan gunakan istilah medis yang sulit.
    
    Data anak: ${sapaan}, ${gender}, ${usia_bulan} bulan, BB ${berat_badan}kg, TB ${tinggi_badan}cm
    Status: BB/U ${LABEL_STATUS_BBU[status_bbu] || status_bbu} (Z: ${zscore_bbu}), TB/U ${LABEL_STATUS_TBU[status_tbu] || status_tbu} (Z: ${zscore_tbu}), BB/TB ${LABEL_STATUS_BBTB[status_bbtb] || status_bbtb} (Z: ${zscore_bbtb})
    Risiko stunting: ${kategori_risiko}

    Jawab dalam 3 bagian singkat (total maksimal 200 kata):
    1. Kondisi Saat Ini — jelaskan kondisi anak dalam 2-3 kalimat
    2. Yang Bisa Dilakukan — 3 tips praktis untuk orang tua
    3. Kapan Perlu ke Dokter — tanda yang perlu diwaspadai`.trim();
};

const callGeminiWithRetry = async (prompt, maxRetry = 3) => {
    let lastError = null;

    for (let attempt = 1; attempt <= maxRetry; attempt++) {
        try {
            const response = await axios.post(
                `${getGeminiUrl()}?key=${process.env.GEMINI_API_KEY}`,
                {
                    contents: [
                        {
                            parts: [{ text: prompt }],
                        },
                    ],
                    generationConfig: {
                        temperature: 0.7,
                        maxOutputTokens: 4096,
                    },
                },
                {
                    timeout: 30000,
                },
            );
            return response;
        } catch (err) {
            lastError = err;
            const status = err.response?.status;
            const isRateLimit = status === 429;

            if (isRateLimit && attempt < maxRetry) {
                const delayMS = Math.pow(2, attempt) * 1000;
                console.warn(
                    `[GEMINI] Rate limit hit, retry ${attempt}/${maxRetry}` +
                        `dalam ${delayMS / 1000}s`,
                );
                await new Promise((resolve) => setTimeout(resolve, delayMS));
                continue;
            }
            throw err;
        }
    }
    throw lastError;
};

export const generateInsight = async (anak_id, pengukuran_id, data) => {
    try {
        const [existing] = await db.query(
            `SELECT insight_teks FROM pengukuran WHERE id = ?`,
            [pengukuran_id],
        );
        if (existing[0]?.insight_teks) {
            console.log(
                `[GEMINI] Insight pengukuran ${pengukuran_id} sudah ada, skip`,
            );
            return null;
        }
        const prompt = susunPrompt(data);
        const response = await callGeminiWithRetry(prompt);
        const insight_teks =
            response.data?.candidates?.[0]?.content?.parts?.[0]?.text;

        if (!insight_teks) {
            throw new Error("Response Gemini tidak mengandung teks");
        }
        await db.query(
            `UPDATE pengukuran SET insight_teks = ? WHERE id = ?`,
            [insight_teks, pengukuran_id],
        );

        console.log(
            `[GEMINI] Insight tersimpan untuk pengukuran ${pengukuran_id}`,
        );
        return insight_teks;
    } catch (err) {
        console.error(
            `[GEMINI ERROR] pengukuran_id ${pengukuran_id}`,
            err.message,
        );
        return null;
    }
};

export const getInsight = async (pengukuran_id) => {
    const [rows] = await db.query(
        `SELECT insight_teks, created_at
        FROM pengukuran
        WHERE id = ?`,
        [pengukuran_id],
    );

    if (!rows[0]) return null;              // pengukuran tidak ditemukan
    if (!rows[0].insight_teks) return null; // insight belum selesai diproses

    return rows[0];
};

