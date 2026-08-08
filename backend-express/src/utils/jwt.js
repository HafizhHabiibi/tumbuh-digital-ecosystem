import jwt from "jsonwebtoken";

const ACCESS_TOKEN_EXPIRY = {
    kader: "8h",
    puskesmas: "8h",
    orang_tua: "15m",
};

const REFRESH_TOKEN_EXPIRY = "30d";

export const generateToken = (payload) => {
    const expiry = ACCESS_TOKEN_EXPIRY[payload.role] ?? "8h";

    return jwt.sign(payload, process.env.JWT_SECRET, {
        expiresIn: expiry,
    });
};

export const generateRefreshToken = (payload) => {
    return jwt.sign(
        { id: payload.id, role: payload.role },
        process.env.JWT_REFRESH_SECRET,
        { expiresIn: REFRESH_TOKEN_EXPIRY },
    );
};

export const verifyToken = (token) => {
    return jwt.verify(token, process.env.JWT_SECRET);
};

export const verifyRefreshToken = (token) => {
    return jwt.verify(token, process.env.JWT_REFRESH_SECRET);
};

export const generateResetToken = (userId) => {
    return jwt.sign(
        { id: userId, purpose: "password_reset" },
        process.env.JWT_SECRET,
        { expiresIn: "15m" },
    );
};

export const verifyResetToken = (token) => {
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        if (decoded.purpose !== "password_reset") return null;
        return decoded;
    } catch {
        return null;
    }
};

