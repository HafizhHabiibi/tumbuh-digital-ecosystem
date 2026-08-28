export const createPagination = () => ({
    page: 1,
    limit: 20,
    total: 0,
    total_pages: 0,
});

export const extractPaginatedData = (response) => {
    const payload = response?.data?.data;

    if (!Array.isArray(payload?.items) || !payload?.pagination) {
        throw new Error("Format response pagination API tidak valid");
    }

    return {
        items: payload.items,
        pagination: {
            ...createPagination(),
            ...payload.pagination,
        },
    };
};
