export const WHO_MIN_AGE_DAYS = 0;
export const WHO_MAX_AGE_DAYS = 1856;

export const MEASUREMENT_DATE_CODES = Object.freeze({
    INVALID_DATE: "PENGUKURAN_TANGGAL_TIDAK_VALID",
    BEFORE_BIRTH: "PENGUKURAN_SEBELUM_TANGGAL_LAHIR",
    FUTURE_DATE: "PENGUKURAN_TANGGAL_MASA_DEPAN",
    OUTSIDE_WHO_REFERENCE: "PENGUKURAN_USIA_DI_LUAR_REFERENSI",
});

const MILLISECONDS_PER_DAY = 24 * 60 * 60 * 1000;

const parseCalendarParts = (value) => {
    if (value instanceof Date && !Number.isNaN(value.getTime())) {
        return {
            year: value.getFullYear(),
            month: value.getMonth() + 1,
            day: value.getDate(),
        };
    }

    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(value ?? ""));
    if (!match) return null;

    const parts = {
        year: Number(match[1]),
        month: Number(match[2]),
        day: Number(match[3]),
    };
    const date = new Date(Date.UTC(parts.year, parts.month - 1, parts.day));
    if (
        date.getUTCFullYear() !== parts.year ||
        date.getUTCMonth() + 1 !== parts.month ||
        date.getUTCDate() !== parts.day
    ) {
        return null;
    }
    return parts;
};

const toDayNumber = (parts) =>
    Date.UTC(parts.year, parts.month - 1, parts.day) / MILLISECONDS_PER_DAY;

const fromDayNumber = (dayNumber) => {
    const utc = new Date(dayNumber * MILLISECONDS_PER_DAY);
    return new Date(
        utc.getUTCFullYear(),
        utc.getUTCMonth(),
        utc.getUTCDate(),
    );
};

export const formatCalendarDate = (value) => {
    const parts = parseCalendarParts(value);
    if (!parts) return "";
    return [
        String(parts.year).padStart(4, "0"),
        String(parts.month).padStart(2, "0"),
        String(parts.day).padStart(2, "0"),
    ].join("-");
};

export const validateMeasurementDate = (
    tanggalLahir,
    tanggalUkur,
    hariIni = new Date(),
) => {
    const lahir = parseCalendarParts(tanggalLahir);
    const ukur = parseCalendarParts(tanggalUkur);
    const today = parseCalendarParts(hariIni);
    if (!lahir || !ukur || !today) {
        return {
            eligible: false,
            ageDays: null,
            code: MEASUREMENT_DATE_CODES.INVALID_DATE,
            message: "Tanggal lahir atau tanggal pengukuran tidak valid",
        };
    }

    const birthDay = toDayNumber(lahir);
    const measurementDay = toDayNumber(ukur);
    const todayDay = toDayNumber(today);
    const ageDays = measurementDay - birthDay;

    if (measurementDay < birthDay) {
        return {
            eligible: false,
            ageDays,
            code: MEASUREMENT_DATE_CODES.BEFORE_BIRTH,
            message: "Tanggal pengukuran tidak boleh sebelum tanggal lahir",
        };
    }
    if (measurementDay > todayDay) {
        return {
            eligible: false,
            ageDays,
            code: MEASUREMENT_DATE_CODES.FUTURE_DATE,
            message: "Tanggal pengukuran tidak boleh di masa depan",
        };
    }
    if (ageDays < WHO_MIN_AGE_DAYS || ageDays > WHO_MAX_AGE_DAYS) {
        return {
            eligible: false,
            ageDays,
            code: MEASUREMENT_DATE_CODES.OUTSIDE_WHO_REFERENCE,
            message:
                `Usia saat pengukuran harus ${WHO_MIN_AGE_DAYS}–${WHO_MAX_AGE_DAYS} hari agar sesuai referensi WHO`,
        };
    }

    return { eligible: true, ageDays };
};

export const getMeasurementDateLimits = (
    tanggalLahir,
    hariIni = new Date(),
) => {
    const lahir = parseCalendarParts(tanggalLahir);
    const today = parseCalendarParts(hariIni);
    if (!lahir || !today) return { minDate: null, maxDate: null };

    const birthDay = toDayNumber(lahir);
    const todayDay = toDayNumber(today);
    const maximumDay = Math.min(todayDay, birthDay + WHO_MAX_AGE_DAYS);
    return {
        minDate: fromDayNumber(birthDay),
        maxDate: fromDayNumber(maximumDay),
    };
};

export const getCurrentAgeMeasurementWarning = (
    tanggalLahir,
    hariIni = new Date(),
) => {
    const result = validateMeasurementDate(tanggalLahir, hariIni, hariIni);
    if (result.code !== MEASUREMENT_DATE_CODES.OUTSIDE_WHO_REFERENCE) {
        return null;
    }

    const { maxDate } = getMeasurementDateLimits(tanggalLahir, hariIni);
    return {
        ...result,
        message:
            `Usia anak saat ini sudah di luar referensi WHO ${WHO_MIN_AGE_DAYS}–${WHO_MAX_AGE_DAYS} hari. ` +
            `Data anak tetap dapat disimpan; pengukuran baru hanya dapat dicatat untuk tanggal historis sampai ${formatCalendarDate(maxDate)}.`,
    };
};
