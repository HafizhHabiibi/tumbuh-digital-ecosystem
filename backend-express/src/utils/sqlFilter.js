export const toLikePattern = (value) => {
    const escaped = String(value)
        .replaceAll("!", "!!")
        .replaceAll("%", "!%")
        .replaceAll("_", "!_");
    return `%${escaped}%`;
};

