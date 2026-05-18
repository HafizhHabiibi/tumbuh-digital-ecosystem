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
