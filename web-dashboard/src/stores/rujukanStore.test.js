import { beforeEach, describe, expect, it, vi } from "vitest";
import { createPinia, setActivePinia } from "pinia";

vi.mock("@/services/rujukanService", () => ({
    default: {
        getRujukanByAnak: vi.fn(),
        getDetailRujukan: vi.fn(),
    },
}));

import rujukanService from "@/services/rujukanService";
import { useRujukanStore } from "./rujukanStore.js";

const childResponse = (id) => ({
    data: { data: { anak: { id, nama: id }, rujukan: [{ id: `r-${id}` }] } },
});

describe("rujukanStore menjaga detail dan riwayat tetap sesuai pilihan terbaru", () => {
    beforeEach(() => {
        setActivePinia(createPinia());
        vi.clearAllMocks();
    });

    it("mengabaikan response riwayat anak yang sudah kedaluwarsa", async () => {
        let resolveLama;
        rujukanService.getRujukanByAnak
            .mockReturnValueOnce(new Promise((resolve) => { resolveLama = resolve; }))
            .mockResolvedValueOnce(childResponse("anak-baru"));

        const store = useRujukanStore();
        const requestLama = store.fetchRujukanByAnak("anak-lama");
        await store.fetchRujukanByAnak("anak-baru");
        resolveLama(childResponse("anak-lama"));
        await requestLama;

        expect(store.riwayatAnak.anak.id).toBe("anak-baru");
        expect(store.riwayatAnak.list[0].id).toBe("r-anak-baru");
    });

    it("mengabaikan response detail lama setelah detail lain dibuka", async () => {
        let resolveLama;
        rujukanService.getDetailRujukan
            .mockReturnValueOnce(new Promise((resolve) => { resolveLama = resolve; }))
            .mockResolvedValueOnce({ data: { data: { id: 2 } } });

        const store = useRujukanStore();
        const requestLama = store.fetchDetailRujukan(1);
        await store.fetchDetailRujukan(2);
        resolveLama({ data: { data: { id: 1 } } });
        await requestLama;

        expect(store.rujukanDetail.id).toBe(2);
    });
});
