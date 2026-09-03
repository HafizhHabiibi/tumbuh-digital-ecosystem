import { afterEach, describe, expect, it, vi } from "vitest";
import { debounce } from "./debounce.js";

describe("debounce", () => {
    afterEach(() => vi.useRealTimers());

    it("hanya menjalankan pencarian terakhir setelah 300 ms", () => {
        vi.useFakeTimers();
        const callback = vi.fn();
        const run = debounce(callback, 300);

        run("D");
        run("De");
        run("Dewi");
        vi.advanceTimersByTime(299);
        expect(callback).not.toHaveBeenCalled();

        vi.advanceTimersByTime(1);
        expect(callback).toHaveBeenCalledOnce();
        expect(callback).toHaveBeenCalledWith("Dewi");
    });
});
