import test from "node:test";
import assert from "node:assert/strict";
import {
    getNextRujukanStatus,
    isValidRujukanTransition,
} from "../src/services/rujukanStatusService.js";

test("lifecycle rujukan hanya mengizinkan transisi berurutan", () => {
    assert.equal(getNextRujukanStatus("diajukan"), "ditangani");
    assert.equal(getNextRujukanStatus("ditangani"), "selesai");
    assert.equal(getNextRujukanStatus("selesai"), null);

    assert.equal(isValidRujukanTransition("diajukan", "ditangani"), true);
    assert.equal(isValidRujukanTransition("ditangani", "selesai"), true);
    assert.equal(isValidRujukanTransition("diajukan", "selesai"), false);
    assert.equal(isValidRujukanTransition("ditangani", "ditangani"), false);
    assert.equal(isValidRujukanTransition("selesai", "selesai"), false);
});
