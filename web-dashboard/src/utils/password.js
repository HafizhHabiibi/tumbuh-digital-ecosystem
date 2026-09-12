const encoder = new TextEncoder();

export const passwordByteLength = (value) => encoder.encode(value).length;

export const isNewPasswordLengthValid = (value) =>
    value.length >= 8 && passwordByteLength(value) <= 72;
