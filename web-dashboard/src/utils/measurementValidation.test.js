import { describe, expect, it } from "vitest";

import { formatUkuran } from "./format.js";
import { validateMeasurement } from "./measurementValidation.js";

describe("validateMeasurement", () => {
    it("menerima seluruh nilai tepat pada batas kontrak API", () => {
        expect(validateMeasurement({
            berat_badan: 0.01,
            tinggi_badan: 120,
            lingkar_kepala: 1,
            lingkar_lengan: 60,
        })).toEqual({});
    });

    it("menolak nilai di luar batas dan lebih dari dua desimal", () => {
        expect(validateMeasurement({
            berat_badan: 0.001,
            tinggi_badan: 120.01,
            lingkar_kepala: 80.01,
            lingkar_lengan: 14.555,
        })).toEqual({
            berat_badan: expect.any(String),
            tinggi_badan: expect.any(String),
            lingkar_kepala: expect.any(String),
            lingkar_lengan: expect.any(String),
        });
    });

    it("membiarkan field lingkar opsional kosong", () => {
        expect(validateMeasurement({
            berat_badan: 11,
            tinggi_badan: 85,
            lingkar_kepala: null,
            lingkar_lengan: "",
        })).toEqual({});
    });
});

describe("formatUkuran", () => {
    it("menampilkan maksimal dua desimal tanpa trailing zero", () => {
        expect(formatUkuran(11)).toBe("11");
        expect(formatUkuran("11.50")).toBe("11,5");
        expect(formatUkuran(11.25)).toBe("11,25");
        expect(formatUkuran(null)).toBe("—");
    });
});

