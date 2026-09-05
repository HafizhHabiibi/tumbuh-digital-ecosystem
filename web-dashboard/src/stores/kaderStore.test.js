import { beforeEach, describe, expect, it, vi } from "vitest";
import { createPinia, setActivePinia } from "pinia";

vi.mock("@/services/kaderService", () => ({
    default: {
        getAllAnak: vi.fn(),
        getAllOrangTua: vi.fn(),
    },
}));

import kaderService from "@/services/kaderService";
import { useKaderStore } from "./kaderStore.js";

const emptyPage = {
    data: {
        data: [],
        pagination: {
            page: 1,
            limit: 20,
            total: 0,
            total_pages: 0,
        },
    },
};

describe("kaderStore meneruskan filter list ke backend", () => {
    beforeEach(() => {
        setActivePinia(createPinia());
        kaderService.getAllAnak.mockReset();
        kaderService.getAllOrangTua.mockReset();
        kaderService.getAllAnak.mockResolvedValue(emptyPage);
        kaderService.getAllOrangTua.mockResolvedValue(emptyPage);
    });

    it("meneruskan search dan jenis_kelamin pada daftar anak", async () => {
        const store = useKaderStore();

        await store.fetchAllAnak({
            page: 1,
            limit: 20,
            search: "anak halaman tiga",
            jenis_kelamin: "P",
        });

        expect(kaderService.getAllAnak).toHaveBeenCalledWith({
            page: 1,
            limit: 20,
            search: "anak halaman tiga",
            jenis_kelamin: "P",
        });
    });

    it("meneruskan search pada daftar orang tua", async () => {
        const store = useKaderStore();

        await store.fetchAllOrangTua({
            page: 1,
            limit: 20,
            search: "orang tua halaman tiga",
        });

        expect(kaderService.getAllOrangTua).toHaveBeenCalledWith({
            page: 1,
            limit: 20,
            search: "orang tua halaman tiga",
        });
    });

    it("mengabaikan response lama yang selesai setelah pencarian terbaru", async () => {
        const store = useKaderStore();
        let resolveRequestLama;
        const requestLama = new Promise((resolve) => {
            resolveRequestLama = resolve;
        });
        const pageBaru = {
            data: {
                data: {
                    items: [{ id: "baru", nama: "Hasil Baru" }],
                    pagination: {
                        page: 1,
                        limit: 20,
                        total: 1,
                        total_pages: 1,
                    },
                },
            },
        };
        const pageLama = {
            data: {
                data: {
                    items: [{ id: "lama", nama: "Hasil Lama" }],
                    pagination: {
                        page: 1,
                        limit: 20,
                        total: 1,
                        total_pages: 1,
                    },
                },
            },
        };
        kaderService.getAllAnak
            .mockReturnValueOnce(requestLama)
            .mockResolvedValueOnce(pageBaru);

        const pencarianLama = store.fetchAllAnak({ search: "lama" });
        const pencarianBaru = store.fetchAllAnak({ search: "baru" });
        await pencarianBaru;
        resolveRequestLama(pageLama);
        await pencarianLama;

        expect(store.anakList).toEqual([
            { id: "baru", nama: "Hasil Baru" },
        ]);
        expect(store.loading.anakList).toBe(false);
    });

    it("totalAnak tetap statis saat fetchAllAnak difilter berdasarkan jenis kelamin", async () => {
        const store = useKaderStore();
        kaderService.getAllAnak
            .mockResolvedValueOnce({
                data: {
                    data: {
                        items: [
                            { id: "1", nama: "Anak 1", jenis_kelamin: "L" },
                            { id: "2", nama: "Anak 2", jenis_kelamin: "P" },
                            { id: "3", nama: "Anak 3", jenis_kelamin: "L" },
                        ],
                        pagination: {
                            page: 1,
                            limit: 20,
                            total: 3,
                            total_pages: 1,
                        },
                    },
                },
            })
            .mockResolvedValueOnce({
                data: {
                    data: {
                        items: [
                            { id: "1", nama: "Anak 1", jenis_kelamin: "L" },
                            { id: "3", nama: "Anak 3", jenis_kelamin: "L" },
                        ],
                        pagination: {
                            page: 1,
                            limit: 20,
                            total: 2,
                            total_pages: 1,
                        },
                    },
                },
            });

        // 1. Initial unfiltered fetch
        await store.fetchAllAnak();
        expect(store.totalAnak).toBe(3);

        // 2. Filter laki-laki
        await store.fetchAllAnak({ jenis_kelamin: "L" });
        expect(store.pagination.anak.total).toBe(2);
        // totalAnak harus tetap statis 3, bukan berubah menjadi 2
        expect(store.totalAnak).toBe(3);
    });

    it("totalAnak prioritaskan anakOptions.length saat anakOptions tersedia", async () => {
        const store = useKaderStore();
        store.anakOptions = [
            { id: "1", jenis_kelamin: "L" },
            { id: "2", jenis_kelamin: "P" },
            { id: "3", jenis_kelamin: "L" },
            { id: "4", jenis_kelamin: "P" },
        ];
        store.pagination.anak.total = 2; // misal sedang terfilter

        expect(store.totalAnak).toBe(4);
        expect(store.anakLaki.length).toBe(2);
        expect(store.anakPerempuan.length).toBe(2);
    });
});

