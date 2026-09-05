import { beforeEach, describe, expect, it, vi } from "vitest";
import { createPinia, setActivePinia } from "pinia";

vi.mock("@/services/pengukuranService", () => ({
    default: { getRiwayatPengukuran: vi.fn() },
}));

import pengukuranService from "@/services/pengukuranService";
import { usePengukuranStore } from "./pengukuranStore.js";

const response = (id) => ({
    data: { data: { anak: { id }, riwayat: [{ id: `ukur-${id}` }] } },
});

describe("pengukuranStore menjaga riwayat sesuai anak terbaru", () => {
    beforeEach(() => {
        setActivePinia(createPinia());
        vi.clearAllMocks();
    });

    it("mengabaikan response lama ketika kader mengganti anak", async () => {
        let resolveLama;
        pengukuranService.getRiwayatPengukuran
            .mockReturnValueOnce(new Promise((resolve) => { resolveLama = resolve; }))
            .mockResolvedValueOnce(response("anak-baru"));

        const store = usePengukuranStore();
        const requestLama = store.fetchRiwayat("anak-lama");
        await store.fetchRiwayat("anak-baru");
        resolveLama(response("anak-lama"));
        await requestLama;

        expect(store.riwayat.anak.id).toBe("anak-baru");
        expect(store.riwayat.list[0].id).toBe("ukur-anak-baru");
    });
});
