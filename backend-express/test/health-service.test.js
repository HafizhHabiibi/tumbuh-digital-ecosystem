import assert from "node:assert/strict";
import test from "node:test";

import {
    buatHealthService,
    READINESS_COMPONENT_STATUS,
} from "../src/services/healthService.js";

const healthyDatabase = {
    async query(sql) {
        assert.equal(sql, "SELECT 1");
        return [[{ 1: 1 }]];
    },
};

test("readiness siap ketika database dan key Gemini tersedia", async () => {
    const service = buatHealthService({
        database: healthyDatabase,
        getAiHealth: () => ({
            model: "gemini-3.6-flash",
            totalKeys: 2,
            availableKeys: 2,
            disabledKeys: 0,
        }),
    });

    const result = await service.checkReadiness();

    assert.equal(result.ready, true);
    assert.deepEqual(result.components, {
        database: READINESS_COMPONENT_STATUS.READY,
        ai: READINESS_COMPONENT_STATUS.READY,
        ai_model: "gemini-3.6-flash",
    });
});

test("readiness membedakan Gemini belum dikonfigurasi", async () => {
    const service = buatHealthService({
        database: healthyDatabase,
        getAiHealth: () => ({
            model: "gemini-3.6-flash",
            totalKeys: 0,
            availableKeys: 0,
            disabledKeys: 0,
        }),
    });

    const result = await service.checkReadiness();

    assert.equal(result.ready, false);
    assert.equal(
        result.components.ai,
        READINESS_COMPONENT_STATUS.NOT_CONFIGURED,
    );
    assert.equal("apiKeys" in result.components, false);
});

test("readiness menandai semua key yang sedang tidak tersedia", async () => {
    const service = buatHealthService({
        database: healthyDatabase,
        getAiHealth: () => ({
            model: "gemini-3.6-flash",
            totalKeys: 2,
            availableKeys: 0,
            disabledKeys: 1,
        }),
    });

    const result = await service.checkReadiness();

    assert.equal(result.ready, false);
    assert.equal(result.components.ai, READINESS_COMPONENT_STATUS.UNAVAILABLE);
});

test("readiness tidak memeriksa AI ketika database tidak tersedia", async () => {
    let aiChecked = false;
    const databaseError = new Error("database offline");
    const service = buatHealthService({
        database: {
            async query() {
                throw databaseError;
            },
        },
        getAiHealth: () => {
            aiChecked = true;
            return {};
        },
    });

    const result = await service.checkReadiness();

    assert.equal(result.ready, false);
    assert.equal(result.error, databaseError);
    assert.equal(aiChecked, false);
    assert.deepEqual(result.components, {
        database: READINESS_COMPONENT_STATUS.UNAVAILABLE,
        ai: READINESS_COMPONENT_STATUS.UNKNOWN,
    });
});
