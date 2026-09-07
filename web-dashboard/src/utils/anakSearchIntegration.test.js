import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";

const readSource = (relativePath) =>
    readFileSync(fileURLToPath(new URL(relativePath, import.meta.url)), "utf8");

describe("integrasi pencarian anak", () => {
    const pages = [
        "../views/kader/PengukuranView.vue",
        "../views/kader/PemberianView.vue",
        "../views/kader/RujukanView.vue",
        "../views/shared/LaporanView.vue",
    ];

    it.each(pages)("menggunakan komponen pencarian bersama pada %s", (page) => {
        const source = readSource(page);

        expect(source).toContain("AnakSearchSelect");
        expect(source).toContain('from "@/components/forms/AnakSearchSelect.vue"');
        expect(source).not.toContain("filteredAnakOptions");
        expect(source).not.toContain("searchAnak");
    });

    it("menyediakan pola combobox yang dapat dioperasikan dengan keyboard", () => {
        const source = readSource("../components/forms/AnakSearchSelect.vue");

        expect(source).toContain('role="combobox"');
        expect(source).toContain('role="listbox"');
        expect(source).toContain('role="option"');
        expect(source).toContain('event.key === "ArrowDown"');
        expect(source).toContain('event.key === "Enter"');
        expect(source).toContain('event.key === "Escape"');
        expect(source).toContain('emit("update:modelValue", anak.id)');
    });
});
