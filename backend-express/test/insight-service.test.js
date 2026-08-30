import test from "node:test";
import assert from "node:assert/strict";

import { GeminiClientError } from "../src/integrations/geminiClient.js";
import { buatInsightService } from "../src/services/insightService.js";

const source = {
    id: 11,
    anak_id: "anak-1",
    tanggal_ukur: "2026-08-26",
    berat_badan: "11.00",
    tinggi_badan: "85.00",
    insight_attempts: 1,
    jenis_kelamin: "L",
    tanggal_lahir: "2024-08-26",
};

const generated = {
    insight_teks: "Insight edukatif",
    model: "gemini-3.6-flash",
};

test("processor menghitung konteks dan menyelesaikan insight yang berhasil", async () => {
    let generatedInput;
    let completion;
    const repository = {
        claim: async () => source,
        complete: async (...args) => {
            completion = args;
            return true;
        },
    };
    const service = buatInsightService({
        repository,
        generateContent: async (input) => {
            generatedInput = input;
            return generated;
        },
    });

    const result = await service.processInsight(11);

    assert.deepEqual(result, { processed: true, success: true, reason: null });
    assert.equal(generatedInput.status_bbu, "berat_badan_normal");
    assert.equal(generatedInput.kategori_prioritas, "rendah");
    assert.equal("zscore_bbu" in generatedInput, false);
    assert.deepEqual(completion, [
        11,
        1,
        "Insight edukatif",
        "gemini-3.6-flash",
    ]);
});

test("processor tidak memanggil Gemini jika claim tidak diperoleh", async () => {
    let generatedCalled = false;
    const service = buatInsightService({
        repository: { claim: async () => null },
        generateContent: async () => {
            generatedCalled = true;
        },
    });

    assert.deepEqual(await service.processInsight(11), {
        processed: false,
        reason: "not_due_or_already_claimed",
    });
    assert.equal(generatedCalled, false);
});

test("error Gemini retryable dijadwalkan mengikuti retry-after provider", async () => {
    let failure;
    const repository = {
        claim: async () => source,
        recordFailure: async (value) => {
            failure = value;
            return true;
        },
    };
    const providerError = new GeminiClientError("Key cooldown", {
        code: "GEMINI_KEYS_EXHAUSTED",
        retryable: true,
        retryAfterMs: 120000,
    });
    const service = buatInsightService({
        repository,
        generateContent: async () => {
            throw providerError;
        },
    });

    const result = await service.processInsight(11);

    assert.equal(result.willRetry, true);
    assert.equal(result.reason, "scheduled_retry");
    assert.equal(failure.retryDelaySeconds, 120);
    assert.equal(failure.willRetry, true);
    assert.match(failure.errorMessage, /^GEMINI_KEYS_EXHAUSTED:/);
});

test("attempt terakhir dan error non-retryable menjadi failed terminal", async () => {
    const failures = [];
    const repository = {
        claim: async (id) => ({
            ...source,
            id,
            insight_attempts: id === 3 ? 3 : 1,
        }),
        recordFailure: async (value) => {
            failures.push(value);
            return true;
        },
    };
    const retryableError = new GeminiClientError("Sementara", {
        retryable: true,
    });
    const retryableService = buatInsightService({
        repository,
        generateContent: async () => {
            throw retryableError;
        },
    });

    assert.equal((await retryableService.processInsight(3)).reason, "failed");
    assert.equal(failures[0].willRetry, false);

    const fatalService = buatInsightService({
        repository,
        generateContent: async () => {
            throw new Error("Data pengukuran tidak valid");
        },
    });
    assert.equal((await fatalService.processInsight(1)).reason, "failed");
    assert.equal(failures[1].willRetry, false);
});

test("hasil worker lama tidak menimpa hasil worker dengan lease baru", async () => {
    const service = buatInsightService({
        repository: {
            claim: async () => source,
            complete: async () => false,
        },
        generateContent: async () => generated,
    });

    assert.deepEqual(await service.processInsight(11), {
        processed: true,
        success: false,
        reason: "claim_expired",
    });
});

test("worker batch memproses seluruh id yang jatuh tempo", async () => {
    const claimedIds = [];
    const repository = {
        findDueIds: async () => [1, 2, 3],
        claim: async (id) => {
            claimedIds.push(id);
            return { ...source, id };
        },
        complete: async () => true,
    };
    const service = buatInsightService({
        repository,
        generateContent: async () => generated,
    });

    const result = await service.processPendingInsights();

    assert.equal(result.processed, 3);
    assert.deepEqual(claimedIds.sort(), [1, 2, 3]);
    assert.equal(result.results.every((item) => item.success), true);
});

test("insight historis yang belum selesai menjadi superseded", async () => {
    const service = buatInsightService({
        repository: {
            findForOrangTua: async () => ({
                insight_status: "pending",
                insight_teks: null,
                is_latest: 0,
            }),
        },
    });

    const result = await service.getInsightForOrangTua(11, "orang-tua-1");

    assert.equal(result.insight_status, "superseded");
});

test("insight historis completed tetap dapat dibaca", async () => {
    const completed = {
        insight_status: "completed",
        insight_teks: "Insight Agustus",
        is_latest: 0,
    };
    const service = buatInsightService({
        repository: { findForOrangTua: async () => completed },
    });

    assert.deepEqual(
        await service.getInsightForOrangTua(11, "orang-tua-1"),
        completed,
    );
});
