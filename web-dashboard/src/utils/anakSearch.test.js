import { describe, expect, it } from "vitest";
import {
    filterAnakOptions,
    nextAnakSearchIndex,
    normalizeAnakSearch,
} from "./anakSearch.js";

const options = [
    {
        id: "anak-1",
        nama: "Aisyah Putri",
        nik: "3273010101010001",
        nama_orang_tua: "Siti Aminah",
    },
    {
        id: "anak-2",
        nama: "Bima Éka",
        nik: "3273010101010002",
        nama_orang_tua: "Rudi Hartono",
    },
];

describe("pencarian opsi anak", () => {
    it("mengembalikan opsi asli untuk query kosong", () => {
        expect(filterAnakOptions(options, "   ")).toBe(options);
    });

    it("mencari nama anak tanpa membedakan kapital dan aksen", () => {
        expect(filterAnakOptions(options, "bima eka").map(({ id }) => id))
            .toEqual(["anak-2"]);
    });

    it("mencari berdasarkan NIK dan nama orang tua", () => {
        expect(filterAnakOptions(options, "0001").map(({ id }) => id))
            .toEqual(["anak-1"]);
        expect(filterAnakOptions(options, "rudi").map(({ id }) => id))
            .toEqual(["anak-2"]);
    });

    it("mengembalikan array kosong ketika tidak ada hasil", () => {
        expect(filterAnakOptions(options, "tidak ada")).toEqual([]);
    });

    it("menavigasi hasil ke dua arah dan berputar di batas", () => {
        expect(nextAnakSearchIndex(-1, 2, 1)).toBe(0);
        expect(nextAnakSearchIndex(0, 2, 1)).toBe(1);
        expect(nextAnakSearchIndex(1, 2, 1)).toBe(0);
        expect(nextAnakSearchIndex(0, 2, -1)).toBe(1);
        expect(nextAnakSearchIndex(0, 0, 1)).toBe(-1);
    });

    it("normalisasi aman untuk nilai kosong", () => {
        expect(normalizeAnakSearch(null)).toBe("");
    });
});
