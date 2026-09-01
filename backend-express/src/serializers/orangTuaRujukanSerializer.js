const STATUS_RUJUKAN = new Set(["diajukan", "ditangani", "selesai"]);

const requiredPositiveNumber = (value, field, { integer = false } = {}) => {
    if (value === null || value === undefined || value === "") {
        throw new TypeError(`Nilai ${field} tidak valid untuk kontrak orang tua`);
    }

    const number = Number(value);
    if (
        !Number.isFinite(number) ||
        number <= 0 ||
        (integer && !Number.isInteger(number))
    ) {
        throw new TypeError(`Nilai ${field} tidak valid untuk kontrak orang tua`);
    }
    return number;
};

const requiredEnum = (value, field, allowed) => {
    if (!allowed.has(value)) {
        throw new TypeError(`Nilai ${field} tidak valid untuk kontrak orang tua`);
    }
    return value;
};

const optionalString = (value, field) => {
    if (value === null || value === undefined) return null;
    if (typeof value !== "string") {
        throw new TypeError(`Nilai ${field} tidak valid untuk kontrak orang tua`);
    }
    return value;
};

const toDateOnly = (value) => {
    if (value instanceof Date && !Number.isNaN(value.getTime())) {
        return value.toISOString().slice(0, 10);
    }
    if (typeof value === "string") {
        const dateOnly = value.slice(0, 10);
        const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(dateOnly);
        if (match) {
            const [, yearText, monthText, dayText] = match;
            const year = Number(yearText);
            const month = Number(monthText);
            const day = Number(dayText);
            const date = new Date(Date.UTC(year, month - 1, day));
            if (
                date.getUTCFullYear() === year &&
                date.getUTCMonth() === month - 1 &&
                date.getUTCDate() === day
            ) {
                return dateOnly;
            }
        }
    }
    throw new TypeError(
        "Nilai tanggal_ukur tidak valid untuk kontrak orang tua",
    );
};

const toIsoTimestamp = (value, field, { nullable = false } = {}) => {
    if (value === null || value === undefined || value === "") {
        if (nullable) return null;
        throw new TypeError(`Nilai ${field} tidak valid untuk kontrak orang tua`);
    }

    const date = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(date.getTime())) {
        throw new TypeError(`Nilai ${field} tidak valid untuk kontrak orang tua`);
    }
    return date.toISOString();
};

export const toOrangTuaRujukan = (rujukan) => {
    if (!rujukan || typeof rujukan !== "object") {
        throw new TypeError("Data rujukan orang tua tidak valid");
    }

    return {
        id: requiredPositiveNumber(rujukan.id, "id", { integer: true }),
        status: requiredEnum(rujukan.status, "status", STATUS_RUJUKAN),
        catatan_kader: optionalString(
            rujukan.catatan_kader,
            "catatan_kader",
        ),
        catatan_puskesmas: optionalString(
            rujukan.catatan_puskesmas,
            "catatan_puskesmas",
        ),
        created_at: toIsoTimestamp(rujukan.created_at, "created_at"),
        validated_at: toIsoTimestamp(rujukan.validated_at, "validated_at", {
            nullable: true,
        }),
        completed_at: toIsoTimestamp(rujukan.completed_at, "completed_at", {
            nullable: true,
        }),
        tanggal_ukur: toDateOnly(rujukan.tanggal_ukur),
        berat_badan: requiredPositiveNumber(
            rujukan.berat_badan,
            "berat_badan",
        ),
        tinggi_badan: requiredPositiveNumber(
            rujukan.tinggi_badan,
            "tinggi_badan",
        ),
        ditangani_oleh: optionalString(
            rujukan.ditangani_oleh,
            "ditangani_oleh",
        ),
    };
};
