import fs from "node:fs";
import { describe, expect, it } from "vitest";

const buttonWithLabel = (relativeUrl, label) => {
    const source = fs.readFileSync(new URL(relativeUrl, import.meta.url), "utf8");
    const buttons = [...source.matchAll(/<button\b[\s\S]*?<\/button>/g)].map(
        (match) => match[0],
    );
    const button = buttons.find((item) => item.includes(label));
    expect(button, `Tombol ${label} harus ditemukan`).toBeTruthy();
    return button;
};

const expectInteractive = (relativeUrl, label) => {
    const button = buttonWithLabel(relativeUrl, label);
    expect(button).not.toMatch(/(?:^|\s):?disabled(?:\s|=|>)/);
    expect(button).toContain('aria-busy');
};

describe("tombol aksi utama tetap interaktif saat form belum lengkap", () => {
    it("laporan individual dan rekap tidak memakai disabled", () => {
        expectInteractive("../views/shared/LaporanView.vue", "Unduh Laporan Individual");
        expectInteractive("../views/shared/LaporanView.vue", "Unduh Laporan Rekap");
    });

    it("simpan password kader dan puskesmas tidak memakai disabled", () => {
        expectInteractive("../views/kader/ProfilView.vue", "Simpan Password");
        expectInteractive("../views/puskesmas/ProfilView.vue", "Simpan Password");
    });

    it("login dan lupa password tidak memakai disabled", () => {
        expectInteractive("../components/forms/FormLogin.vue", "Masuk");
        expectInteractive("../components/forms/FormForgotPassword.vue", "Kirim Tautan Reset");
    });
});
