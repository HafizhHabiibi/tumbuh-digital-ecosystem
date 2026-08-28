import { describe, expect, it } from "vitest";
import { createPagination, extractPaginatedData } from "./apiResponse";

describe("apiResponse pagination", () => {
    it("membuat nilai awal pagination yang konsisten", () => {
        expect(createPagination()).toEqual({
            page: 1,
            limit: 20,
            total: 0,
            total_pages: 0,
        });
    });

    it("mengambil items dan melengkapi metadata yang tidak dikirim backend", () => {
        const result = extractPaginatedData({
            data: {
                data: {
                    items: [{ id: 1 }],
                    pagination: { page: 2, total: 21, total_pages: 2 },
                },
            },
        });

        expect(result.items).toEqual([{ id: 1 }]);
        expect(result.pagination).toEqual({
            page: 2,
            limit: 20,
            total: 21,
            total_pages: 2,
        });
    });

    it.each([undefined, {}, { data: { data: { items: {} } } }])(
        "menolak response yang tidak mengikuti kontrak: %j",
        (response) => {
            expect(() => extractPaginatedData(response)).toThrow(
                "Format response pagination API tidak valid",
            );
        },
    );
});
