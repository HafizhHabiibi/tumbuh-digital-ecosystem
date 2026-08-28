import api from "./api";

const PDF_MIME_TYPE = "application/pdf";

const decodeFilename = (value) => {
    try {
        return decodeURIComponent(value);
    } catch {
        return value;
    }
};

const sanitizeFilename = (value) =>
    String(value || "laporan.pdf")
        .replace(/[\\/:*?"<>|]/g, "-")
        // Header Content-Disposition tidak boleh menyisipkan karakter kontrol.
        // eslint-disable-next-line no-control-regex
        .replace(/[\u0000-\u001f\u007f]/g, "")
        .trim() || "laporan.pdf";

export const getPdfFilename = (response, fallback = "laporan.pdf") => {
    const disposition = response?.headers?.["content-disposition"] || "";
    const utf8Match = disposition.match(/filename\*=UTF-8''([^;]+)/i);
    const regularMatch = disposition.match(/filename="?([^";]+)"?/i);
    const rawFilename = utf8Match?.[1] || regularMatch?.[1] || fallback;
    const filename = sanitizeFilename(decodeFilename(rawFilename));
    return filename.toLowerCase().endsWith(".pdf")
        ? filename
        : `${filename}.pdf`;
};

export const savePdfResponse = (response, fallbackFilename) => {
    const contentType = response?.headers?.["content-type"] || "";
    if (!contentType.toLowerCase().includes(PDF_MIME_TYPE)) {
        throw new Error("Server tidak mengembalikan dokumen PDF yang valid");
    }

    const blob = response.data instanceof Blob
        ? response.data
        : new Blob([response.data], { type: PDF_MIME_TYPE });
    const objectUrl = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = objectUrl;
    link.download = getPdfFilename(response, fallbackFilename);
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.setTimeout(() => URL.revokeObjectURL(objectUrl), 0);

    return link.download;
};

export const getDownloadErrorMessage = async (
    error,
    fallback = "Gagal mengunduh laporan",
) => {
    const payload = error?.response?.data;

    if (payload instanceof Blob) {
        try {
            const parsed = JSON.parse(await payload.text());
            return parsed?.message || fallback;
        } catch {
            return fallback;
        }
    }

    return payload?.message || error?.message || fallback;
};

const laporanService = {
    downloadIndividual(anakId) {
        return api.get(`/laporan/anak/${anakId}`, {
            responseType: "blob",
        });
    },

    downloadRekap(tanggalMulai, tanggalSelesai) {
        return api.get("/laporan/rekap", {
            params: {
                tanggal_mulai: tanggalMulai,
                tanggal_selesai: tanggalSelesai,
            },
            responseType: "blob",
        });
    },
};

export default laporanService;
