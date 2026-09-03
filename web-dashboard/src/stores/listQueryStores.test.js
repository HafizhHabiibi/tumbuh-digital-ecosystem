import { beforeEach, describe, expect, it, vi } from "vitest";
import { createPinia, setActivePinia } from "pinia";

vi.mock("@/services/puskesmasService", () => ({
    default: { getAllAnak: vi.fn() },
}));
vi.mock("@/services/pengukuranService", () => ({
    default: { getRankingAnak: vi.fn() },
}));
vi.mock("@/services/rujukanService", () => ({
    default: { getAllRujukan: vi.fn() },
}));

import puskesmasService from "@/services/puskesmasService";
import pengukuranService from "@/services/pengukuranService";
import rujukanService from "@/services/rujukanService";
import { usePuskesmasStore } from "./puskesmasStore.js";
import { usePengukuranStore } from "./pengukuranStore.js";
import { useRujukanStore } from "./rujukanStore.js";

const pageResponse = (extra = {}) => ({
    data: {
        data: {
            items: [],
            pagination: {
                page: 1,
                limit: 20,
                total: 0,
                total_pages: 0,
            },
            ...extra,
        },
    },
});

describe("store list meneruskan filter Fase 3", () => {
    beforeEach(() => {
        setActivePinia(createPinia());
        vi.clearAllMocks();
        puskesmasService.getAllAnak.mockResolvedValue(pageResponse());
        pengukuranService.getRankingAnak.mockResolvedValue(pageResponse());
        rujukanService.getAllRujukan.mockResolvedValue(pageResponse({
            summary: { diajukan: 2, ditangani: 3, selesai: 4 },
        }));
    });

    it("meneruskan search dan jenis kelamin daftar anak puskesmas", async () => {
        await usePuskesmasStore().fetchAllAnak({
            page: 2,
            limit: 10,
            search: "Ayu",
            jenis_kelamin: "P",
        });

        expect(puskesmasService.getAllAnak).toHaveBeenCalledWith({
            page: 2,
            limit: 10,
            search: "Ayu",
            jenis_kelamin: "P",
        });
    });

    it("meneruskan search dan prioritas ranking", async () => {
        await usePengukuranStore().fetchRankingAnak({
            page: 1,
            limit: 20,
            search: "Budi",
            prioritas: "tinggi",
        });

        expect(pengukuranService.getRankingAnak).toHaveBeenCalledWith({
            page: 1,
            limit: 20,
            search: "Budi",
            prioritas: "tinggi",
        });
    });

    it("meneruskan filter rujukan dan memakai summary global", async () => {
        const store = useRujukanStore();
        await store.fetchAllRujukan({
            page: 1,
            limit: 20,
            search: "Dewi",
            status: "aktif",
        });

        expect(rujukanService.getAllRujukan).toHaveBeenCalledWith({
            page: 1,
            limit: 20,
            search: "Dewi",
            status: "aktif",
        });
        expect(store.jumlahPerStatus).toEqual({
            diajukan: 2,
            ditangani: 3,
            selesai: 4,
        });
        expect(store.totalRujukanAktif).toBe(5);
        expect(store.totalRujukanArsip).toBe(4);
    });
});
