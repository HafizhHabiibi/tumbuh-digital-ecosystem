import { error } from "../utils/response.js";

export class ValidationError extends Error {}

const isEmpty = (value) =>
    value === undefined || value === null || value === "";

export const rules = {
    string: ({ required = true, min = 0, max = 255, pattern, lowercase = false } = {}) =>
        (value, field) => {
            if (isEmpty(value)) {
                if (required) throw new ValidationError(`${field} wajib diisi`);
                return undefined;
            }
            if (typeof value !== "string") {
                throw new ValidationError(`${field} harus berupa teks`);
            }
            let normalized = value.trim();
            if (lowercase) normalized = normalized.toLowerCase();
            if (normalized.length < min || normalized.length > max) {
                throw new ValidationError(
                    `${field} harus memiliki panjang ${min}-${max} karakter`,
                );
            }
            if (pattern && !pattern.test(normalized)) {
                throw new ValidationError(`${field} tidak valid`);
            }
            return normalized;
        },
    number: ({ required = true, min = -Infinity, max = Infinity } = {}) =>
        (value, field) => {
            if (isEmpty(value)) {
                if (required) throw new ValidationError(`${field} wajib diisi`);
                return undefined;
            }
            const normalized = Number(value);
            if (!Number.isFinite(normalized) || normalized < min || normalized > max) {
                throw new ValidationError(`${field} harus berupa angka antara ${min}-${max}`);
            }
            return normalized;
        },
    integer: ({ required = true, min = 1, max = Number.MAX_SAFE_INTEGER } = {}) =>
        (value, field) => {
            const normalized = rules.number({ required, min, max })(value, field);
            if (normalized === undefined) return undefined;
            if (!Number.isInteger(normalized)) {
                throw new ValidationError(`${field} harus berupa bilangan bulat`);
            }
            return normalized;
        },
    enum: (values, { required = true } = {}) => (value, field) => {
        if (isEmpty(value)) {
            if (required) throw new ValidationError(`${field} wajib diisi`);
            return undefined;
        }
        if (!values.includes(value)) {
            throw new ValidationError(`${field} harus salah satu dari: ${values.join(", ")}`);
        }
        return value;
    },
    date: ({ required = true, allowFuture = true, allowPast = true } = {}) => (value, field) => {
        if (isEmpty(value)) {
            if (required) throw new ValidationError(`${field} wajib diisi`);
            return undefined;
        }
        if (typeof value !== "string") {
            throw new ValidationError(`${field} harus berformat YYYY-MM-DD`);
        }
        const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
        if (!match) throw new ValidationError(`${field} harus berformat YYYY-MM-DD`);
        const date = new Date(Date.UTC(+match[1], +match[2] - 1, +match[3]));
        if (
            date.getUTCFullYear() !== +match[1] ||
            date.getUTCMonth() !== +match[2] - 1 ||
            date.getUTCDate() !== +match[3]
        ) {
            throw new ValidationError(`${field} bukan tanggal kalender yang valid`);
        }
        const now = new Date();
        const today = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
        if (!allowFuture && date > today) {
            throw new ValidationError(`${field} tidak boleh di masa depan`);
        }
        if (!allowPast && date < today) {
            throw new ValidationError(`${field} tidak boleh di masa lampau`);
        }
        return value;
    },
    time: ({ required = true } = {}) =>
        rules.string({ required, min: 5, max: 5, pattern: /^([01]\d|2[0-3]):[0-5]\d$/ }),
};

export const validateBody = ({ fields, refine }) => (req, res, next) => {
    try {
        const normalized = { ...req.body };
        for (const [field, validator] of Object.entries(fields)) {
            const value = validator(req.body?.[field], field);
            if (value === undefined) delete normalized[field];
            else normalized[field] = value;
        }
        if (refine) refine(normalized);
        req.body = normalized;
        next();
    } catch (err) {
        if (err instanceof ValidationError) {
            return error(res, err.message, 400);
        }
        next(err);
    }
};
