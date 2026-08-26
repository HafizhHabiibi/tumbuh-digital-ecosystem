const formatLocalDate = (date) => [
    date.getFullYear(),
    String(date.getMonth() + 1).padStart(2, "0"),
    String(date.getDate()).padStart(2, "0"),
].join("-");

export const buildMonthlyScheduleDates = (today, fixedDay, count) => {
    const currentMonthTarget = new Date(
        today.getFullYear(),
        today.getMonth(),
        fixedDay,
    );
    const startOffset = currentMonthTarget < today ? 1 : 0;

    return Array.from({ length: count }, (_, index) => {
        const target = new Date(
            today.getFullYear(),
            today.getMonth() + startOffset + index,
            fixedDay,
        );
        return formatLocalDate(target);
    });
};
