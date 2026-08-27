import {
    AI_DISCLOSURES,
    AI_RESPONSE_TYPES,
} from "../constants/aiPolicy.js";

export const CHAT_INPUT_LIMITS = Object.freeze({
    minCharacters: 2,
    maxCharacters: 1000,
});

export const CHAT_OUTPUT_LIMITS = Object.freeze({
    maxCharacters: 1200,
});

export const CHAT_RESPONSE_SCHEMA = Object.freeze({
    type: "OBJECT",
    properties: {
        response_type: {
            type: "STRING",
            enum: Object.values(AI_RESPONSE_TYPES),
        },
        answer: {
            type: "STRING",
            description: "Jawaban singkat dalam Bahasa Indonesia.",
        },
    },
    required: ["response_type", "answer"],
});

export class ChatInputValidationError extends Error {
    constructor(message, code) {
        super(message);
        this.name = "ChatInputValidationError";
        this.code = code;
    }
}

export class AiOutputValidationError extends Error {
    constructor(message, code = "AI_UNSAFE_OUTPUT") {
        super(message);
        this.name = "AiOutputValidationError";
        this.code = code;
    }
}

const PROMPT_INJECTION_PATTERNS = Object.freeze([
    /abaikan\s+(semua\s+)?(instruksi|aturan|prompt)/i,
    /(tampilkan|bocorkan|ungkapkan)\s+(system\s+prompt|prompt\s+sistem|instruksi\s+sistem)/i,
    /berperan(lah)?\s+sebagai\s+(dokter|developer|system|admin)/i,
    /jailbreak|developer\s+mode/i,
    /ubah\s+role\s+(menjadi|ke)/i,
]);

const MEDICAL_REQUEST_PATTERNS = Object.freeze([
    /(apakah|benarkah|pastikan|tentukan|diagnosis).{0,40}\b(stunting|penyakit|sakit apa|diagnosis)\b/i,
    /\b(obat|antibiotik|resep|dosis|terapi|suplemen)\b.{0,40}\b(apa|berapa|berikan|diberikan|minum|konsumsi|gunakan)\b/i,
    /\b(berapa|apa)\b.{0,30}\b(dosis|obat|antibiotik|suplemen)\b/i,
    /\b(harus|haruskah|perlu|perlukah|wajib)\b.{0,30}\b(dirujuk|ke dokter|ke rumah sakit|rawat inap)\b/i,
    /\b(bolehkah|apakah boleh|aman(?:kah)?)\b.{0,40}\b(obat|antibiotik|suplemen|paracetamol|ibuprofen)\b/i,
    /\b(paracetamol|ibuprofen|antibiotik)\b/i,
    /\b(demam|batuk|diare|muntah|kejang|sesak|pendarahan|tidak sadar|sangat lemas)\b/i,
]);

const EXPLICIT_OUT_OF_SCOPE_PATTERNS = Object.freeze([
    /\b(cuaca|politik|presiden|pemilu|saham|kripto|bitcoin|coding|programming)\b/i,
    /\b(resep masakan untuk orang dewasa|pekerjaan rumah sekolah|ramalan|horoskop)\b/i,
    /\b(siapa kamu|ceritakan lelucon|buatkan puisi)\b/i,
]);

const ALLOWED_TOPIC_PATTERNS = Object.freeze([
    /\b(makan|makanan|menu|gizi|protein|karbohidrat|sayur|buah|asi|mpasi|porsi|nafsu makan)\b/i,
    /\b(aktivitas|bermain|stimulasi|gerak|tidur|istirahat)\b/i,
    /\b(kebersihan|sanitasi|cuci tangan|air bersih|alat makan)\b/i,
    /\b(berat|tinggi|imt|pertumbuhan|pengukuran|hasil|status|prioritas|pemantauan|posyandu)\b/i,
    /\b(insight|penjelasan|jelaskan|maksud|kenapa|mengapa|bagaimana)\b/i,
]);

const UNSAFE_OUTPUT_PATTERNS = Object.freeze([
    {
        code: "AI_DIAGNOSIS_CLAIM",
        pattern:
            /\b(anak|putra|putri|si kecil)(\s+anda)?\s+(mengalami|menderita|terdiagnosis|dipastikan|positif)\b/i,
    },
    {
        code: "AI_STUNTING_CLAIM",
        pattern: /\b(pasti|dipastikan|termasuk|didiagnosis)\s+stunting\b/i,
    },
    {
        code: "AI_MEDICATION_DIRECTIVE",
        pattern:
            /\b(berikan|minum|konsumsi|gunakan)\b.{0,40}\b(obat|antibiotik|tablet|kapsul|suplemen)\b/i,
    },
    {
        code: "AI_DOSAGE_DIRECTIVE",
        pattern: /\b(dosis|\d+(?:[.,]\d+)?\s*(mg|ml|tablet|kapsul))\b/i,
    },
    {
        code: "AI_REFERRAL_DECISION",
        pattern: /\b(harus|wajib|segera)\s+(dirujuk|dibawa ke dokter|dibawa ke rumah sakit)\b/i,
    },
    {
        code: "AI_TECHNICAL_LEAK",
        pattern: /\b(z[- ]?score|skor saw|peringkat saw)\b/i,
    },
    {
        code: "AI_GUARANTEE",
        pattern: /\b(pasti sembuh|dijamin|pasti kembali normal|pasti tumbuh)\b/i,
    },
]);

export const containsPromptInjection = (text) =>
    PROMPT_INJECTION_PATTERNS.some((pattern) => pattern.test(text));

export const sanitizeChatInput = (value) => {
    if (typeof value !== "string") {
        throw new ChatInputValidationError(
            "Pesan wajib berupa teks",
            "CHAT_MESSAGE_NOT_STRING",
        );
    }

    const sanitized = value
        .normalize("NFKC")
        .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "")
        .replace(/<[^>]*>/g, " ")
        .replace(/[\t ]+/g, " ")
        .replace(/\n{3,}/g, "\n\n")
        .trim();

    if (sanitized.length < CHAT_INPUT_LIMITS.minCharacters) {
        throw new ChatInputValidationError(
            "Pesan terlalu pendek",
            "CHAT_MESSAGE_TOO_SHORT",
        );
    }
    if (sanitized.length > CHAT_INPUT_LIMITS.maxCharacters) {
        throw new ChatInputValidationError(
            `Pesan maksimal ${CHAT_INPUT_LIMITS.maxCharacters} karakter`,
            "CHAT_MESSAGE_TOO_LONG",
        );
    }
    return sanitized;
};

const deterministicAnswer = (responseType) => {
    if (responseType === AI_RESPONSE_TYPES.MEDICAL_ADVICE_REFUSED) {
        return AI_DISCLOSURES.MEDICAL_REDIRECT;
    }
    if (responseType === AI_RESPONSE_TYPES.OUT_OF_SCOPE) {
        return AI_DISCLOSURES.OUT_OF_SCOPE;
    }
    return null;
};

export const evaluateChatInput = (value) => {
    const message = sanitizeChatInput(value);

    if (containsPromptInjection(message)) {
        return {
            allowed: false,
            message,
            response_type: AI_RESPONSE_TYPES.OUT_OF_SCOPE,
            answer: deterministicAnswer(AI_RESPONSE_TYPES.OUT_OF_SCOPE),
            reason: "prompt_injection",
        };
    }
    if (MEDICAL_REQUEST_PATTERNS.some((pattern) => pattern.test(message))) {
        return {
            allowed: false,
            message,
            response_type: AI_RESPONSE_TYPES.MEDICAL_ADVICE_REFUSED,
            answer: deterministicAnswer(
                AI_RESPONSE_TYPES.MEDICAL_ADVICE_REFUSED,
            ),
            reason: "medical_advice_request",
        };
    }
    if (EXPLICIT_OUT_OF_SCOPE_PATTERNS.some((pattern) => pattern.test(message))) {
        return {
            allowed: false,
            message,
            response_type: AI_RESPONSE_TYPES.OUT_OF_SCOPE,
            answer: deterministicAnswer(AI_RESPONSE_TYPES.OUT_OF_SCOPE),
            reason: "out_of_scope",
        };
    }

    return {
        allowed: true,
        message,
        response_type: AI_RESPONSE_TYPES.ANSWERED,
        answer: null,
        reason: ALLOWED_TOPIC_PATTERNS.some((pattern) => pattern.test(message))
            ? "allowed_topic"
            : "contextual_follow_up",
    };
};

export const validateEducationalText = (value) => {
    if (typeof value !== "string" || !value.trim()) {
        throw new AiOutputValidationError(
            "Keluaran AI wajib berupa teks",
            "AI_EMPTY_OUTPUT",
        );
    }

    for (const { code, pattern } of UNSAFE_OUTPUT_PATTERNS) {
        if (pattern.test(value)) {
            throw new AiOutputValidationError(
                "Keluaran AI melanggar batas edukasi",
                code,
            );
        }
    }
    return value.trim();
};

export const validateChatModelResponse = (value) => {
    if (!value || typeof value !== "object" || Array.isArray(value)) {
        throw new AiOutputValidationError(
            "Respons chat wajib berupa object",
            "AI_INVALID_RESPONSE_STRUCTURE",
        );
    }
    if (!Object.values(AI_RESPONSE_TYPES).includes(value.response_type)) {
        throw new AiOutputValidationError(
            "Tipe respons chat tidak valid",
            "AI_INVALID_RESPONSE_TYPE",
        );
    }

    if (value.response_type !== AI_RESPONSE_TYPES.ANSWERED) {
        return {
            response_type: value.response_type,
            answer: deterministicAnswer(value.response_type),
        };
    }

    const answer = validateEducationalText(value.answer);
    if (answer.length > CHAT_OUTPUT_LIMITS.maxCharacters) {
        throw new AiOutputValidationError(
            `Jawaban AI melebihi ${CHAT_OUTPUT_LIMITS.maxCharacters} karakter`,
            "AI_OUTPUT_TOO_LONG",
        );
    }
    return { response_type: value.response_type, answer };
};
