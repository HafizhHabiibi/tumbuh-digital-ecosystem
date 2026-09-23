const DATE_ONLY_PATTERN = /^(\d{4})-(\d{2})-(\d{2})$/;
const WIB_DATE_FORMATTER = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Jakarta",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
});

const assertCalendarDate = (dateOnly, field) => {
    const match = DATE_ONLY_PATTERN.exec(dateOnly);
    if (!match) {
        throw new TypeError(`Nilai ${field} bukan tanggal kalender yang valid`);
    }

    const [, yearText, monthText, dayText] = match;
    const year = Number(yearText);
    const month = Number(monthText);
    const day = Number(dayText);
    const date = new Date(Date.UTC(year, month - 1, day));
    if (
        date.getUTCFullYear() !== year ||
        date.getUTCMonth() !== month - 1 ||
        date.getUTCDate() !== day
    ) {
        throw new TypeError(`Nilai ${field} bukan tanggal kalender yang valid`);
    }
    return dateOnly;
};

const formatDateInWib = (value) => {
    const parts = Object.fromEntries(
        WIB_DATE_FORMATTER
            .formatToParts(value)
            .filter(({ type }) => ["year", "month", "day"].includes(type))
            .map(({ type, value: partValue }) => [type, partValue]),
    );
    return `${parts.year}-${parts.month}-${parts.day}`;
};

export const toDateOnly = (value, field = "tanggal") => {
    if (typeof value === "string") {
        return assertCalendarDate(value.slice(0, 10), field);
    }
    if (value instanceof Date && !Number.isNaN(value.getTime())) {
        return assertCalendarDate(formatDateInWib(value), field);
    }
    throw new TypeError(`Nilai ${field} bukan tanggal kalender yang valid`);
};
