const STATUS_PEMANTAUAN_DARI_PRIORITAS = Object.freeze({
    rendah: "rutin",
    sedang: "perlu_perhatian",
    tinggi: "konsultasi",
});

const STATUS_BBU = new Set([
    "berat_badan_sangat_kurang",
    "berat_badan_kurang",
    "berat_badan_normal",
    "risiko_berat_badan_lebih",
]);

const STATUS_TBU = new Set(["sangat_pendek", "pendek", "normal", "tinggi"]);

const STATUS_BBTB_DAN_IMTU = new Set([
    "gizi_buruk",
    "gizi_kurang",
    "gizi_baik",
    "risiko_gizi_lebih",
    "gizi_lebih",
    "obesitas",
]);

const requiredNumber = (value, field, { integer = false, min = 0 } = {}) => {
    if (value === null || value === undefined || value === "") {
        throw new TypeError(`Nilai ${field} tidak valid untuk kontrak orang tua`);
    }
    const number = Number(value);
    if (
        !Number.isFinite(number) ||
        number < min ||
        (integer && !Number.isInteger(number))
    ) {
        throw new TypeError(`Nilai ${field} tidak valid untuk kontrak orang tua`);
    }
    return number;
};

const optionalPositiveNumber = (value, field) => {
    if (value === null || value === undefined || value === "") return null;
    return requiredNumber(value, field, { min: Number.MIN_VALUE });
};

const requiredEnum = (value, field, allowed) => {
    if (!allowed.has(value)) {
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

const toIsoTimestamp = (value) => {
    if (value === null || value === undefined || value === "") {
        throw new TypeError(
            "Nilai created_at tidak valid untuk kontrak orang tua",
        );
    }
    const date = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(date.getTime())) {
        throw new TypeError(
            "Nilai created_at tidak valid untuk kontrak orang tua",
        );
    }
    return date.toISOString();
};

const toStatusPemantauan = (prioritasPemantauan) => {
    const kategoriPrioritas = prioritasPemantauan?.kategori;
    const status = Object.hasOwn(
        STATUS_PEMANTAUAN_DARI_PRIORITAS,
        kategoriPrioritas,
    )
        ? STATUS_PEMANTAUAN_DARI_PRIORITAS[kategoriPrioritas]
        : null;
    if (!status) {
        throw new TypeError(
            "Prioritas pemantauan tidak valid untuk kontrak orang tua",
        );
    }
    return status;
};

export const toOrangTuaPengukuran = (pengukuran) => {
    if (!pengukuran || typeof pengukuran !== "object") {
        throw new TypeError("Data pengukuran orang tua tidak valid");
    }

    return {
        id: requiredNumber(pengukuran.id, "id", {
            integer: true,
            min: 1,
        }),
        tanggal_ukur: toDateOnly(pengukuran.tanggal_ukur),
        berat_badan: requiredNumber(pengukuran.berat_badan, "berat_badan", {
            min: Number.MIN_VALUE,
        }),
        tinggi_badan: requiredNumber(pengukuran.tinggi_badan, "tinggi_badan", {
            min: Number.MIN_VALUE,
        }),
        lingkar_kepala: optionalPositiveNumber(
            pengukuran.lingkar_kepala,
            "lingkar_kepala",
        ),
        lingkar_lengan: optionalPositiveNumber(
            pengukuran.lingkar_lengan,
            "lingkar_lengan",
        ),
        usia_bulan: requiredNumber(pengukuran.usia_bulan, "usia_bulan", {
            integer: true,
            min: 0,
        }),
        status_bbu: requiredEnum(
            pengukuran.status_bbu,
            "status_bbu",
            STATUS_BBU,
        ),
        status_tbu: requiredEnum(
            pengukuran.status_tbu,
            "status_tbu",
            STATUS_TBU,
        ),
        status_bbtb: requiredEnum(
            pengukuran.status_bbtb,
            "status_bbtb",
            STATUS_BBTB_DAN_IMTU,
        ),
        status_imtu: requiredEnum(
            pengukuran.status_imtu,
            "status_imtu",
            STATUS_BBTB_DAN_IMTU,
        ),
        status_pemantauan: toStatusPemantauan(
            pengukuran.prioritas_pemantauan,
        ),
        created_at: toIsoTimestamp(pengukuran.created_at),
    };
};
