import { beforeEach, describe, expect, it, vi } from "vitest";
import { createPinia, setActivePinia } from "pinia";

vi.mock("../services/authService", () => ({
    login: vi.fn(),
    forgotPassword: vi.fn(),
    resetPassword: vi.fn(),
    changePassword: vi.fn(),
    getProfile: vi.fn(),
}));

import * as authService from "../services/authService";
import { useAuthStore } from "./authStore.js";

const storage = new Map();
const localStorageStub = {
    getItem: (key) => storage.get(key) ?? null,
    setItem: (key, value) => storage.set(key, String(value)),
    removeItem: (key) => storage.delete(key),
    clear: () => storage.clear(),
};

describe("authStore membatasi sesi dashboard ke role web", () => {
    beforeEach(() => {
        vi.stubGlobal("localStorage", localStorageStub);
        storage.clear();
        setActivePinia(createPinia());
        authService.login.mockReset();
    });

    it("tidak menyimpan hasil login orang tua", async () => {
        authService.login.mockResolvedValue({
            data: {
                token: "token-orang-tua",
                user: { id: "user-1", role: "orang_tua" },
            },
        });
        const store = useAuthStore();

        expect(await store.login("parent@example.com", "rahasia", "captcha"))
            .toBe(false);
        expect(store.isLoggedIn).toBe(false);
        expect(store.error.login).toMatch(/dashboard web/i);
        expect(storage.size).toBe(0);
    });

    it("membersihkan sesi lama dengan role tidak didukung", () => {
        storage.set("token", "token-lama");
        storage.set("user", JSON.stringify({ role: "orang_tua" }));

        const store = useAuthStore();

        expect(store.isLoggedIn).toBe(false);
        expect(store.user).toBeNull();
        expect(storage.size).toBe(0);
    });

    it("menyimpan sesi kader yang valid", () => {
        const store = useAuthStore();

        expect(store.setAuth({
            token: "token-kader",
            user: { id: "user-2", role: "kader" },
        })).toBe(true);
        expect(store.isLoggedIn).toBe(true);
        expect(storage.get("token")).toBe("token-kader");
    });
});

