export const normalizeAnakSearch = (value) =>
    String(value ?? "")
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .toLocaleLowerCase("id-ID")
        .trim();

export const filterAnakOptions = (options = [], query = "") => {
    const normalizedQuery = normalizeAnakSearch(query);
    if (!normalizedQuery) return options;

    return options.filter((anak) =>
        [anak?.nama, anak?.nik, anak?.nama_orang_tua]
            .some((value) =>
                normalizeAnakSearch(value).includes(normalizedQuery),
            ),
    );
};

export const nextAnakSearchIndex = (currentIndex, total, direction) => {
    if (total <= 0) return -1;
    const step = direction < 0 ? -1 : 1;
    if (currentIndex < 0) return step > 0 ? 0 : total - 1;
    return (currentIndex + step + total) % total;
};
