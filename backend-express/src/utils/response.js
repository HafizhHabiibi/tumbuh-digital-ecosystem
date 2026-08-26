export const success = (res, data, message = "Success", code = 200) => {
    return res.status(code).json({
        success: true,
        message,
        data,
    });
};

export const error = (res, message = "Error", code = 500) => {
    if (code >= 500) {
        console.error(`[SERVER ERROR] ${message}`);
        message = "Terjadi kesalahan server";
    }
    return res.status(code).json({
        success: false,
        message,
        data: null,
    });
};
