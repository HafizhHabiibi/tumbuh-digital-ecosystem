import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("./api.js", () => ({
    default: {
        post: vi.fn(),
    },
}));

import api from "./api.js";
import { forgotPassword, login } from "./authService.js";

describe("authService kontrak kanal web", () => {
    beforeEach(() => {
        api.post.mockReset();
        api.post.mockResolvedValue({ data: { success: true } });
    });

    it("selalu menandai request login sebagai platform web", async () => {
        await login("kader@example.com", "rahasia", "captcha-token");

        expect(api.post).toHaveBeenCalledWith("/auth/login", {
            email: "kader@example.com",
            password: "rahasia",
            turnstileToken: "captcha-token",
            platform: "web",
        });
    });

    it("selalu menandai forgot password sebagai platform web", async () => {
        await forgotPassword("kader@example.com", "captcha-token");

        expect(api.post).toHaveBeenCalledWith("/auth/forgot-password", {
            email: "kader@example.com",
            turnstileToken: "captcha-token",
            platform: "web",
        });
    });
});

