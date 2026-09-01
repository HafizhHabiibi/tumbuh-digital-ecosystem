const NEXT_STATUS = Object.freeze({
    diajukan: "ditangani",
    ditangani: "selesai",
});

export const getNextRujukanStatus = (currentStatus) =>
    NEXT_STATUS[currentStatus] ?? null;

export const isValidRujukanTransition = (currentStatus, nextStatus) =>
    getNextRujukanStatus(currentStatus) === nextStatus;

