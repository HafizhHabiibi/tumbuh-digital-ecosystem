export const MEASUREMENT_LIMITS = Object.freeze({
    berat_badan: Object.freeze({ min: 0.01, max: 30, label: "Berat badan", unit: "kg" }),
    tinggi_badan: Object.freeze({ min: 0.01, max: 120, label: "Tinggi badan", unit: "cm" }),
    lingkar_kepala: Object.freeze({ min: 1, max: 80, label: "Lingkar kepala", unit: "cm" }),
    lingkar_lengan: Object.freeze({ min: 1, max: 60, label: "Lingkar lengan", unit: "cm" }),
});

const isEmpty = (value) => value === undefined || value === null || value === "";

const hasAtMostTwoDecimals = (value) => {
    const text = String(value);
    const fraction = text.includes(".") ? text.split(".")[1] : "";
    return fraction.length <= 2;
};

export const validateMeasurement = (measurement = {}) => {
    const errors = {};

    for (const [field, limit] of Object.entries(MEASUREMENT_LIMITS)) {
        const value = measurement[field];
        if (isEmpty(value)) continue;

        const numeric = Number(value);
        if (!Number.isFinite(numeric)) {
            errors[field] = `${limit.label} harus berupa angka`;
        } else if (numeric < limit.min || numeric > limit.max) {
            errors[field] =
                `${limit.label} harus antara ${limit.min}–${limit.max} ${limit.unit}`;
        } else if (!hasAtMostTwoDecimals(value)) {
            errors[field] = `${limit.label} maksimal dua angka desimal`;
        }
    }

    return errors;
};

