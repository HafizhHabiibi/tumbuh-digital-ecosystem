import {
    AI_CONTEXT_ALLOWED_FIELDS,
    AI_CONTEXT_PROHIBITED_FIELDS,
} from "../constants/aiPolicy.js";
import { labelStatusAntropometri } from "../constants/anthropometryLabels.js";
import ChatModel from "../models/chatModel.js";
import * as sawService from "./sawService.js";
import * as zscoreService from "./zscoreService.js";

export const AI_CONTEXT_LIMITS = Object.freeze({
    recentMessages: 10,
    messageCharacters: 2000,
    initialInsightCharacters: 5000,
});

const normalizeText = (value, maxLength) => {
    if (typeof value !== "string") return null;
    const normalized = value.trim();
    if (!normalized) return null;
    return normalized.slice(0, maxLength);
};

export const buildMeasurementAiContext = (source) => {
    const beratBadan = Number(source.berat_badan);
    const tinggiBadan = Number(source.tinggi_badan);
    const zscores = zscoreService.hitungSemuaZScore({
        berat_badan: beratBadan,
        tinggi_badan: tinggiBadan,
        tanggal_lahir: source.tanggal_lahir,
        tanggal_ukur: source.tanggal_ukur,
        jenis_kelamin: source.jenis_kelamin,
    });
    const saw = sawService.hitungSAW({
        zscore_bbu: zscores.zscore_bbu,
        zscore_tbu: zscores.zscore_tbu,
        zscore_bbtb: zscores.zscore_bbtb,
        zscore_imtu: zscores.zscore_imtu,
    });

    // Bentuk object secara eksplisit agar nilai teknis dan identitas tidak ikut
    // terbawa ketika row database bertambah kolom pada masa mendatang.
    return Object.freeze({
        jenis_kelamin: source.jenis_kelamin,
        usia_bulan: zscores.usia_bulan,
        berat_badan: beratBadan,
        tinggi_badan: tinggiBadan,
        nilai_imt: zscores.nilai_imt,
        status_bbu: zscores.status_bbu,
        status_tbu: zscores.status_tbu,
        status_bbtb: zscores.status_bbtb,
        status_imtu: zscores.status_imtu,
        kategori_prioritas: saw.kategori_prioritas,
    });
};

const normalizeHistory = (messages) =>
    messages
        .slice(-AI_CONTEXT_LIMITS.recentMessages)
        .map((message) => ({
            role: message.role,
            content: normalizeText(
                message.content,
                AI_CONTEXT_LIMITS.messageCharacters,
            ),
        }))
        .filter(
            (message) =>
                ["orang_tua", "assistant"].includes(message.role) &&
                message.content,
        );

export const buildConversationAiContext = (source, messages = []) => ({
    pengukuran: buildMeasurementAiContext(source),
    insight_awal: normalizeText(
        source.insight_teks,
        AI_CONTEXT_LIMITS.initialInsightCharacters,
    ),
    riwayat_pesan: normalizeHistory(messages),
});

export const serializeConversationContext = (context) => {
    const p = context.pengukuran;
    const gender = p.jenis_kelamin === "L" ? "laki-laki" : "perempuan";

    return [
        "KONTEKS PENGUKURAN TERBARU",
        `Jenis kelamin: ${gender}`,
        `Usia saat pengukuran: ${p.usia_bulan} bulan`,
        `Pengukuran: BB ${p.berat_badan} kg, TB ${p.tinggi_badan} cm, IMT ${p.nilai_imt}`,
        `BB/U: ${labelStatusAntropometri("bbu", p.status_bbu)}`,
        `TB/U: ${labelStatusAntropometri("tbu", p.status_tbu)}`,
        `BB/TB: ${labelStatusAntropometri("bbtb", p.status_bbtb)}`,
        `IMT/U: ${labelStatusAntropometri("imtu", p.status_imtu)}`,
        `Prioritas pemantauan: ${p.kategori_prioritas}`,
        `Insight awal: ${context.insight_awal || "belum tersedia"}`,
    ].join("\n");
};

export const assertSafeAiContext = (context) => {
    const serialized = JSON.stringify(context);
    const prohibitedKeyPattern = new RegExp(
        `"(${AI_CONTEXT_PROHIBITED_FIELDS.join("|")})"\\s*:`,
        "i",
    );
    if (prohibitedKeyPattern.test(serialized)) {
        throw new Error("Konteks AI mengandung field yang dilarang");
    }

    const measurementFields = Object.keys(context.pengukuran || {});
    const unexpected = measurementFields.filter(
        (field) => !AI_CONTEXT_ALLOWED_FIELDS.includes(field),
    );
    if (unexpected.length > 0) {
        throw new Error(`Konteks AI mengandung field tidak dikenal: ${unexpected.join(", ")}`);
    }
    return context;
};

export const buatAiContextService = (dependencies = {}) => {
    const repository = dependencies.repository || ChatModel;

    const loadLatestConversationContext = async (
        pengukuranId,
        orangTuaId,
    ) => {
        const source = await repository.findLatestMeasurementForOrangTua(
            pengukuranId,
            orangTuaId,
        );
        if (!source) return null;

        const messages = await repository.findRecentMessages(
            pengukuranId,
            AI_CONTEXT_LIMITS.recentMessages,
        );
        return assertSafeAiContext(
            buildConversationAiContext(source, messages),
        );
    };

    return Object.freeze({ loadLatestConversationContext });
};

const aiContextService = buatAiContextService();
export const loadLatestConversationContext =
    aiContextService.loadLatestConversationContext;
