export const success = (res, data, message = "Success", code = 200) => {
    return res.status(code).json({
        success: true,
        message,
        data,
    });
};

export const error = (
    res,
    message = "Error",
    httpCode = 500,
    errorCode = null,
) => {
    if (httpCode >= 500) {
        console.error(`[SERVER ERROR] ${message}`);
        message = "Terjadi kesalahan server";
    }
    return res.status(httpCode).json({
        success: false,
        message,
        data: errorCode ? { code: errorCode } : null,
    });
};
