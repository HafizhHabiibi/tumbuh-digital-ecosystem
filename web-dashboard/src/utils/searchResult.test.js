import { describe, expect, it } from "vitest";
import { formatSearchResultCount } from "./searchResult.js";

describe("formatSearchResultCount", () => {
    it("menampilkan total data global saat pencarian kosong", () => {
        expect(
            formatSearchResultCount({ visible: 10, total: 24, search: "" }),
        ).toBe("10 dari 24 data");
    });

    it("menandai total sebagai hasil ketika pencarian aktif", () => {
        expect(
            formatSearchResultCount({
                visible: 2,
                total: 2,
                search: "0812",
            }),
        ).toBe("2 dari 2 hasil");
    });
});
