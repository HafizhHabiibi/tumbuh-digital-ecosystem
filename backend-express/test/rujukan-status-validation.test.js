import test from "node:test";
import assert from "node:assert/strict";

import { validateBody } from "../src/middlewares/validate.js";
import { rujukanStatusSchema } from "../src/validation/schemas.js";

const runValidation = (body) => {
    const req = { body };
    const res = {
        statusCode: 200,
        payload: null,
        status(code) {
            this.statusCode = code;
            return this;
        },
        json(payload) {
            this.payload = payload;
            return this;
        },
    };
    let nextCalled = false;
    validateBody(rujukanStatusSchema)(req, res, () => {
        nextCalled = true;
    });
    return { req, res, nextCalled };
};

test("status selesai mewajibkan hasil penanganan", () => {
    const result = runValidation({ status: "selesai" });
    assert.equal(result.nextCalled, false);
    assert.equal(result.res.statusCode, 400);
    assert.match(result.res.payload.message, /catatan_puskesmas wajib diisi/);
});

test("status selesai menerima dan merapikan hasil penanganan", () => {
    const result = runValidation({
        status: "selesai",
        catatan_puskesmas: "  Kondisi membaik, kontrol ulang dua minggu.  ",
    });
    assert.equal(result.nextCalled, true);
    assert.equal(
        result.req.body.catatan_puskesmas,
        "Kondisi membaik, kontrol ulang dua minggu.",
    );
});

test("status ditangani tetap mengizinkan catatan kosong", () => {
    const result = runValidation({ status: "ditangani" });
    assert.equal(result.nextCalled, true);
});
