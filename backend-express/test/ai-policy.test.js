import test from "node:test";
import assert from "node:assert/strict";

import {
    AI_ALLOWED_TOPICS,
    AI_CONTEXT_ALLOWED_FIELDS,
    AI_CONTEXT_PROHIBITED_FIELDS,
    AI_CONVERSATION_POLICY,
    AI_PROHIBITED_CAPABILITIES,
    AI_RESPONSE_TYPES,
} from "../src/constants/aiPolicy.js";

test("kebijakan AI menetapkan tiga tipe respons", () => {
    assert.deepEqual(Object.values(AI_RESPONSE_TYPES), [
        "answered",
        "out_of_scope",
        "medical_advice_refused",
    ]);
});

test("konteks LLM tidak mengizinkan Z-Score dan identitas sensitif", () => {
    const prohibitedFields = [
        "nama",
        "nik",
        "alamat",
        "nomor_telepon",
        "email",
        "zscore_bbu",
        "zscore_tbu",
        "zscore_bbtb",
        "zscore_imtu",
    ];

    for (const field of prohibitedFields) {
        assert.ok(AI_CONTEXT_PROHIBITED_FIELDS.includes(field));
        assert.ok(!AI_CONTEXT_ALLOWED_FIELDS.includes(field));
    }
});

test("konteks LLM hanya menggunakan hasil kategoris dari backend", () => {
    const requiredCategoryFields = [
        "status_bbu",
        "status_tbu",
        "status_bbtb",
        "status_imtu",
        "kategori_prioritas",
    ];

    for (const field of requiredCategoryFields) {
        assert.ok(AI_CONTEXT_ALLOWED_FIELDS.includes(field));
    }

    assert.match(AI_CONVERSATION_POLICY.sourceOfTruthRule, /backend/i);
});

test("kebijakan menetapkan ruang lingkup dan kemampuan terlarang", () => {
    assert.ok(AI_ALLOWED_TOPICS.length > 0);
    assert.ok(AI_PROHIBITED_CAPABILITIES.length > 0);
    assert.ok(
        AI_PROHIBITED_CAPABILITIES.includes(
            "mendiagnosis_stunting_atau_penyakit",
        ),
    );
    assert.ok(
        AI_PROHIBITED_CAPABILITIES.includes("menghitung_ulang_zscore_atau_saw"),
    );
});

test("konstanta kebijakan tidak dapat diubah", () => {
    assert.ok(Object.isFrozen(AI_RESPONSE_TYPES));
    assert.ok(Object.isFrozen(AI_ALLOWED_TOPICS));
    assert.ok(Object.isFrozen(AI_PROHIBITED_CAPABILITIES));
    assert.ok(Object.isFrozen(AI_CONTEXT_ALLOWED_FIELDS));
    assert.ok(Object.isFrozen(AI_CONTEXT_PROHIBITED_FIELDS));
    assert.ok(Object.isFrozen(AI_CONVERSATION_POLICY));
});
