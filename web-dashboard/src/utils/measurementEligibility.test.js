import { describe, expect, it } from "vitest";
import {
    getMeasurementDateLimits,
    validateMeasurementDate,
} from "./measurementEligibility.js";

const today = "2026-09-03";

describe("kelayakan tanggal pengukuran", () => {
    it("menolak tanggal sebelum lahir dan sesudah hari ini", () => {
        expect(validateMeasurementDate(
            "2024-03-01",
            "2024-02-29",
            today,
        )).toMatchObject({ eligible: false, ageDays: -1 });
        expect(validateMeasurementDate(
            "2024-03-01",
            "2026-09-04",
            today,
        )).toMatchObject({ eligible: false });
    });

    it("menghitung tahun kabisat sebagai hari kalender", () => {
        expect(validateMeasurementDate(
            "2024-02-28",
            "2024-03-01",
            today,
        )).toEqual({ eligible: true, ageDays: 2 });
    });

    it("Date lokal dini hari WIB tidak bergeser ke tanggal UTC", () => {
        const waktuWibDiniHari = new Date(2026, 8, 3, 0, 30);
        expect(validateMeasurementDate(
            "2026-09-02",
            waktuWibDiniHari,
            waktuWibDiniHari,
        )).toEqual({ eligible: true, ageDays: 1 });
    });

    it("membatasi kalender ke hari ini atau hari ke-1856", () => {
        const anakLama = getMeasurementDateLimits("2021-08-03", today);
        const bayi = getMeasurementDateLimits("2026-09-01", today);

        expect([
            anakLama.maxDate.getFullYear(),
            anakLama.maxDate.getMonth() + 1,
            anakLama.maxDate.getDate(),
        ]).toEqual([2026, 9, 2]);
        expect([
            bayi.maxDate.getFullYear(),
            bayi.maxDate.getMonth() + 1,
            bayi.maxDate.getDate(),
        ]).toEqual([2026, 9, 3]);
    });
});
