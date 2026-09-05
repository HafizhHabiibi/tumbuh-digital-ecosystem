import { beforeEach, describe, expect, it, vi } from "vitest";
import { createPinia, setActivePinia } from "pinia";

vi.mock("@/services/pemberianService", () => ({
    default: {
        createRiwayat: vi.fn(),
        getRiwayatByAnak: vi.fn(),
    },
}));

import pemberianService from "@/services/pemberianService";
import { usePemberianStore } from "./pemberianStore.js";

const responseRiwayat = (id, nama) => ({
    data: {
        data: {
            anak: { id, nama },
            pemberian: [{ id: `p-${id}`, jenis: "obat_cacing" }],
            filter: "semua",
        },
    },
});

describe("pemberianStore menjaga konsistensi riwayat anak", () => {
    beforeEach(() => {
        setActivePinia(createPinia());
        vi.clearAllMocks();
    });

    it("mengabaikan response anak lama yang selesai paling akhir", async () => {
        let resolveLama;
        const requestLama = new Promise((resolve) => {
            resolveLama = resolve;
        });
        pemberianService.getRiwayatByAnak
            .mockReturnValueOnce(requestLama)
            .mockResolvedValueOnce(responseRiwayat("anak-baru", "Anak Baru"));

        const store = usePemberianStore();
        const fetchLama = store.fetchRiwayat("anak-lama");
        await store.fetchRiwayat("anak-baru");
        resolveLama(responseRiwayat("anak-lama", "Anak Lama"));
        await fetchLama;

        expect(store.riwayat.anak).toEqual({
            id: "anak-baru",
            nama: "Anak Baru",
        });
        expect(store.riwayat.list[0].id).toBe("p-anak-baru");
        expect(store.loading.riwayat).toBe(false);
    });

    it("reset membatalkan response riwayat yang masih berjalan", async () => {
        let resolveRequest;
        pemberianService.getRiwayatByAnak.mockReturnValueOnce(
            new Promise((resolve) => {
                resolveRequest = resolve;
            }),
        );

        const store = usePemberianStore();
        const fetch = store.fetchRiwayat("anak-1");
        store.resetRiwayat();
        resolveRequest(responseRiwayat("anak-1", "Anak Satu"));
        await fetch;

        expect(store.riwayat).toEqual({
            anak: null,
            list: [],
            filterAktif: "semua",
        });
        expect(store.loading.riwayat).toBe(false);
    });
});
