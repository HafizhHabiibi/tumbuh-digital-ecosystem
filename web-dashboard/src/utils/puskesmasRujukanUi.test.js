import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";

const readSource = (relativePath) =>
    readFileSync(fileURLToPath(new URL(relativePath, import.meta.url)), "utf8");

describe("stabilisasi UI rujukan Puskesmas", () => {
    const viewSource = readSource("../views/puskesmas/RujukanView.vue");

    it("menyembunyikan cancel button bawaan dan mempertahankan tombol hapus aplikasi", () => {
        expect(viewSource).toContain("rujukan-search-input");
        expect(viewSource).toContain(
            ".rujukan-search-input::-webkit-search-cancel-button",
        );
        expect(viewSource).toContain(".rujukan-search-input::-ms-clear");
        expect(viewSource).toContain('aria-label="Bersihkan pencarian"');
    });

    it("hanya menerapkan debounce pada pencarian", () => {
        expect(viewSource).toContain(
            "watch(search, reloadSearchFromFirstPage)",
        );
        expect(viewSource).toContain(
            "watch(filterStatus, handleFilterStatusChange)",
        );
        expect(viewSource).not.toContain("watch([search, filterStatus]");
        expect(viewSource).toContain("reloadSearchFromFirstPage.cancel()");
        expect(viewSource).toContain("loadData(1)");
    });

    it("membedakan initial loading dan refresh tanpa membongkar tabel lama", () => {
        expect(viewSource).toContain("initialListLoading");
        expect(viewSource).toContain("refreshingEmptyList");
        expect(viewSource).toContain('aria-label="Memperbarui daftar rujukan"');
        expect(viewSource).toContain(
            ':inert="rujukanStore.loading.fetchAll"',
        );
    });

    it("mempertahankan request-id guard di store", () => {
        const storeSource = readSource("../stores/rujukanStore.js");

        expect(storeSource).toContain("const requestId = ++this.listRequestId");
        expect(storeSource).toContain("requestId !== this.listRequestId");
    });
});
