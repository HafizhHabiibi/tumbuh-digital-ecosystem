export class MeasurementValidationError extends Error {
    constructor(message) {
        super(message);
        this.name = "MeasurementValidationError";
    }
}

export const normalizeMeasurement = (
    value,
    {
        required = true,
        scale = 2,
        min = -Infinity,
        max = Infinity,
        label = "Nilai pengukuran",
    } = {},
) => {
    if (value === undefined || value === null || value === "") {
        if (!required) return null;
        throw new MeasurementValidationError(`${label} wajib diisi`);
    }

    const numeric = Number(value);
    if (!Number.isFinite(numeric)) {
        throw new MeasurementValidationError(`${label} harus berupa angka`);
    }
    if (numeric < min || numeric > max) {
        throw new MeasurementValidationError(
            `${label} harus antara ${min}-${max}`,
        );
    }

    const factor = 10 ** scale;
    return Math.round((numeric + Number.EPSILON) * factor) / factor;
};
