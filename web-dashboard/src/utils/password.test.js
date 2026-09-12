import { describe, expect, it } from "vitest";
import {
    isNewPasswordLengthValid,
    passwordByteLength,
} from "./password.js";

describe("password policy", () => {
    it("menerima minimal 8 karakter ASCII", () => {
        expect(isNewPasswordLengthValid("12345678")).toBe(true);
    });

    it("menolak input yang melampaui 72 byte UTF-8", () => {
        const value = "🔐".repeat(20);
        expect(value.length).toBeLessThanOrEqual(72);
        expect(passwordByteLength(value)).toBeGreaterThan(72);
        expect(isNewPasswordLengthValid(value)).toBe(false);
    });
});
