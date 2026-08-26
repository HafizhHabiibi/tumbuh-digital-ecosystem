import "dotenv/config";

const REQUIRED_ENV = [
    "DB_HOST",
    "DB_USER",
    "DB_NAME",
    "JWT_SECRET",
    "JWT_REFRESH_SECRET",
    "CORS_ORIGIN",
];

export const validateEnvironment = () => {
    const missing = REQUIRED_ENV.filter((name) => !process.env[name]?.trim());
    if (missing.length > 0) {
        throw new Error(
            `Environment wajib belum dikonfigurasi: ${missing.join(", ")}`,
        );
    }

    if (process.env.JWT_SECRET.length < 32) {
        throw new Error("JWT_SECRET harus memiliki minimal 32 karakter");
    }
    if (process.env.JWT_REFRESH_SECRET.length < 32) {
        throw new Error("JWT_REFRESH_SECRET harus memiliki minimal 32 karakter");
    }

    const port = Number(process.env.PORT || 3000);
    if (!Number.isInteger(port) || port < 1 || port > 65535) {
        throw new Error("PORT harus berupa angka antara 1-65535");
    }

    const trustProxyHops = Number(process.env.TRUST_PROXY_HOPS || 0);
    if (!Number.isInteger(trustProxyHops) || trustProxyHops < 0 || trustProxyHops > 10) {
        throw new Error("TRUST_PROXY_HOPS harus berupa angka antara 0-10");
    }

    return { port, trustProxyHops };
};
