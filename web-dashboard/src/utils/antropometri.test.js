import { describe, expect, it } from "vitest";
import {
    LABEL_STATUS_ANTROPOMETRI,
    VARIANT_STATUS_ANTROPOMETRI,
    formatStatusAntropometri,
} from "./antropometri";

describe("format status antropometri", () => {
    it("menggunakan terminologi resmi untuk status yang dikenal", () => {
        expect(formatStatusAntropometri("gizi_buruk")).toBe("Gizi buruk");
        expect(formatStatusAntropometri("risiko_berat_badan_lebih")).toBe(
            "Risiko berat badan lebih",
        );
    });

    it("memiliki warna untuk setiap label resmi", () => {
        expect(Object.keys(VARIANT_STATUS_ANTROPOMETRI).sort()).toEqual(
            Object.keys(LABEL_STATUS_ANTROPOMETRI).sort(),
        );
    });

    it("tetap aman untuk status baru dan nilai kosong", () => {
        expect(formatStatusAntropometri("status_baru")).toBe("status baru");
        expect(formatStatusAntropometri(null)).toBe("—");
    });
});
