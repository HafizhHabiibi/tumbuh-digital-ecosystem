import test from "node:test";
import assert from "node:assert/strict";

import { createAiObservability } from "../src/services/aiObservabilityService.js";

test("observability menghitung hasil chat tanpa mencatat isi atau identitas", () => {
    const logs = [];
    const metrics = createAiObservability({
        logger: {
            info: (value) => logs.push(value),
            warn: (value) => logs.push(value),
        },
        nowFn: () => Date.UTC(2026, 7, 27),
    });

    metrics.recordChatSuccess({
        requestId: "req-1\nISI-PALSU",
        responseType: "answered",
        providerUsed: true,
        durationMs: 120.4,
    });
    metrics.recordChatSuccess({
        requestId: "req-2",
        responseType: "medical_advice_refused",
        idempotent: true,
        durationMs: 20,
    });
    metrics.recordChatFailure({
        requestId: "req-3",
        code: "GEMINI_KEYS_EXHAUSTED\nrahasia",
        providerUsed: true,
        durationMs: 10,
    });
    metrics.recordRateLimited({ requestId: "req-4" });

    const snapshot = metrics.getSnapshot();
    assert.deepEqual(snapshot.requests, {
        total: 3,
        answered: 1,
        out_of_scope: 0,
        medical_advice_refused: 1,
        failed: 1,
        rate_limited: 1,
        idempotent: 1,
        provider_calls: 2,
    });
    assert.equal(snapshot.average_duration_ms, 50);
    assert.equal(snapshot.errors.GEMINI_KEYS_EXHAUSTED_rahasia, 1);

    const serialized = logs.join("\n");
    assert.doesNotMatch(serialized, /orang_tua_id|pengukuran_id|message|content/i);
    assert.doesNotMatch(serialized, /\nISI-PALSU|\nrahasia/);
    assert.match(serialized, /req-1_ISI-PALSU/);
});

test("kegagalan logger tidak menggagalkan pencatatan metrik", () => {
    const metrics = createAiObservability({
        logger: {
            info: () => {
                throw new Error("logger gagal");
            },
        },
    });

    assert.doesNotThrow(() =>
        metrics.recordChatSuccess({ responseType: "out_of_scope" }),
    );
    assert.equal(metrics.getSnapshot().requests.out_of_scope, 1);
});
