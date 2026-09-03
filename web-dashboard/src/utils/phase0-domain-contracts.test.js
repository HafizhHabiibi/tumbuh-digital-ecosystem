import { describe, expect, it } from "vitest";
import fs from "node:fs";

describe("kontrak validasi pengukuran frontend", () => {
    it("menggunakan rentang API dan maksimal dua desimal", async () => {
        const { validateMeasurement } = await import(
            "./measurementValidation.js"
        );

        expect(validateMeasurement({
            berat_badan: 0.01,
            tinggi_badan: 0.01,
            lingkar_kepala: 1,
            lingkar_lengan: 1,
        })).toEqual({});

        expect(validateMeasurement({
            berat_badan: 10.123,
            tinggi_badan: 85,
        })).toHaveProperty("berat_badan");

        expect(validateMeasurement({
            berat_badan: 30.01,
            tinggi_badan: 120.01,
            lingkar_kepala: 80.01,
            lingkar_lengan: 60.01,
        })).toEqual(expect.objectContaining({
            berat_badan: expect.any(String),
            tinggi_badan: expect.any(String),
            lingkar_kepala: expect.any(String),
            lingkar_lengan: expect.any(String),
        }));
    });
});

describe("kontrak tanggal pengukuran frontend", () => {
    it("menerima hari ke-0 dan 1856 serta menolak hari ke-1857", async () => {
        const { validateMeasurementDate } = await import(
            "./measurementEligibility.js"
        );

        expect(validateMeasurementDate("2026-09-03", "2026-09-03")).toEqual({
            eligible: true,
            ageDays: 0,
        });
        expect(validateMeasurementDate("2021-08-04", "2026-09-03")).toEqual({
            eligible: true,
            ageDays: 1856,
        });
        expect(validateMeasurementDate("2021-08-03", "2026-09-03")).toEqual(
            expect.objectContaining({ eligible: false, ageDays: 1857 }),
        );
    });
});

describe("kontrak routing role frontend", () => {
    it("hanya memetakan kader dan puskesmas ke dashboard", async () => {
        const { dashboardPathForRole } = await import("./authRouting.js");

        expect(dashboardPathForRole("kader")).toBe("/kader/dashboard");
        expect(dashboardPathForRole("puskesmas")).toBe("/puskesmas/dashboard");
        expect(dashboardPathForRole("orang_tua")).toBeNull();
        expect(dashboardPathForRole("tidak_dikenal")).toBeNull();
    });

    it("membersihkan role invalid tanpa redirect loop pada login", async () => {
        const { resolveAuthNavigation } = await import("./authRouting.js");

        expect(resolveAuthNavigation({
            isLoggedIn: true,
            role: "orang_tua",
            requiresGuest: true,
            currentPath: "/login",
        })).toEqual({ clearSession: true, redirect: null });

        expect(resolveAuthNavigation({
            isLoggedIn: true,
            role: "orang_tua",
            requiresAuth: true,
            currentPath: "/puskesmas/dashboard",
        })).toEqual({ clearSession: true, redirect: "/login" });
    });
});

describe("kontrak grafik antropometri", () => {
    it("menjelaskan bahwa grafik bukan sumber keputusan kategori", () => {
        const source = fs.readFileSync(
            new URL("../components/charts/KMSChart.vue", import.meta.url),
            "utf8",
        );

        expect(source).toContain("kurva referensi WHO bulanan");
        expect(source).toContain("tabel WHO harian dan ambang Permenkes");
        expect(source).toMatch(/bukan\s+penentu kategori/);
        expect(source).toContain("whoMonthlyChartTables.json");
    });
});
