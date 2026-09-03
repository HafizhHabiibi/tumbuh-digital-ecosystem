import { describe, expect, it } from "vitest";
import { formatUkuranDenganSatuan } from "./format.js";

describe("formatter satuan SI", () => {
    it("menggunakan kg, cm, dan kg/m² dengan kapitalisasi konsisten", () => {
        expect(formatUkuranDenganSatuan(11, "berat")).toBe("11 kg");
        expect(formatUkuranDenganSatuan(85.5, "panjang")).toBe("85,5 cm");
        expect(formatUkuranDenganSatuan(15.25, "imt")).toBe("15,25 kg/m²");
    });

    it("tidak menambahkan unit pada nilai kosong", () => {
        expect(formatUkuranDenganSatuan(null, "berat")).toBe("—");
    });
});
