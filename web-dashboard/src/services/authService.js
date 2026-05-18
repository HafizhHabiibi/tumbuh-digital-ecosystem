import api from "./api.js";

export const login = async (email, password, turnstileToken) => {
    const res = await api.post("/auth/login", {
        email,
        password,
        turnstileToken,
    });
    return res.data;
};

export const forgotPassword = async (email, turnstileToken) => {
    const res = await api.post("/auth/forgot-password", {
        email,
        turnstileToken,
    });
    return res.data;
};

export const resetPassword = async (token, password_baru) => {
    const res = await api.post("/auth/reset-password", {
        token,
        password_baru,
    });
    return res.data;
};

export const changePassword = async (password_lama, password_baru) => {
    const res = await api.put("/auth/change-password", {
        password_lama,
        password_baru,
    });
    return res.data;
};
