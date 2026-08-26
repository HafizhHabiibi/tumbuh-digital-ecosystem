export const parsePagination = (query = {}, defaultLimit = 20) => {
    const rawPage = Number.parseInt(query.page, 10);
    const rawLimit = Number.parseInt(query.limit, 10);
    const page = Number.isInteger(rawPage) && rawPage > 0 ? rawPage : 1;
    const limit = Number.isInteger(rawLimit) && rawLimit > 0
        ? Math.min(rawLimit, 100)
        : defaultLimit;
    return { page, limit, offset: (page - 1) * limit };
};

export const paginationMeta = (page, limit, total) => ({
    page,
    limit,
    total,
    total_pages: Math.ceil(total / limit),
});
