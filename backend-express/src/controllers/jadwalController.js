import * as JadwalModel from "../models/jadwalModel.js";
import * as fcmService from "../services/fcmService.js";
import { success, error } from "../utils/response.js";
import { parsePagination, paginationMeta } from "../utils/pagination.js";
import { buildMonthlyScheduleDates } from "../utils/schedule.js";

// =============================================================================
// PENGATURAN JADWAL (Template)
// =============================================================================

export const getPengaturan = async (req, res) => {
    try {
        const pengaturan = await JadwalModel.getPengaturan();
        if (!pengaturan) {
            return success(
                res,
                null,
                "Pengaturan jadwal belum diatur. Silakan set terlebih dahulu.",
            );
        }
        return success(res, pengaturan, "Pengaturan jadwal berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const setPengaturan = async (req, res) => {
    try {
        const { hari_tetap, waktu_mulai, waktu_selesai, lokasi_default } =
            req.body;

        if (!hari_tetap || !waktu_mulai || !waktu_selesai || !lokasi_default) {
            return error(
                res,
                "hari_tetap, waktu_mulai, waktu_selesai, lokasi_default wajib diisi",
                400,
            );
        }

        if (hari_tetap < 1 || hari_tetap > 28) {
            return error(
                res,
                "hari_tetap harus antara 1-28 (menghindari masalah bulan pendek)",
                400,
            );
        }

        if (
            !/^\d{2}:\d{2}$/.test(waktu_mulai) ||
            !/^\d{2}:\d{2}$/.test(waktu_selesai)
        ) {
            return error(res, "Format waktu harus HH:MM", 400);
        }

        if (waktu_selesai <= waktu_mulai) {
            return error(res, "Waktu selesai harus setelah waktu mulai", 400);
        }

        const result = await JadwalModel.upsertPengaturan({
            hari_tetap,
            waktu_mulai,
            waktu_selesai,
            lokasi_default,
            updated_by: req.kader.id,
        });

        return success(
            res,
            { id: result.id, hari_tetap, waktu_mulai, waktu_selesai, lokasi_default },
            result.created
                ? "Pengaturan jadwal berhasil dibuat"
                : "Pengaturan jadwal berhasil diperbarui",
            result.created ? 201 : 200,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

// =============================================================================
// GENERATE JADWAL (Bulk dari template)
// =============================================================================

export const generateJadwal = async (req, res) => {
    try {
        const jumlah_bulan = Math.min(12, Math.max(1, parseInt(req.body.jumlah_bulan) || 6));

        const pengaturan = await JadwalModel.getPengaturan();
        if (!pengaturan) {
            return error(
                res,
                "Pengaturan jadwal belum diatur. Set pengaturan terlebih dahulu.",
                400,
            );
        }

        const today = new Date();
        const candidates = [];
        const dates = buildMonthlyScheduleDates(
            today,
            pengaturan.hari_tetap,
            jumlah_bulan,
        );

        for (const tanggal of dates) {
            candidates.push({
                kader_id: req.kader.id,
                tanggal,
                waktu_mulai: pengaturan.waktu_mulai,
                waktu_selesai: pengaturan.waktu_selesai,
                lokasi: pengaturan.lokasi_default,
                keterangan: null,
            });
        }

        const { generated, skipped } = await JadwalModel.createMany(candidates);

        // Broadcast notifikasi ke semua orang tua (jika ada jadwal baru)
        if (generated.length > 0) {
            const semuaOrangTua = await JadwalModel.findAllOrangTua();
            const daftarTanggal = generated.map((g) => g.tanggal).join(", ");

            await fcmService.sendBulkNotifications(
                semuaOrangTua,
                () => [
                        "Jadwal Posyandu Baru",
                        `${generated.length} jadwal posyandu baru telah dibuat: ${daftarTanggal}. ` +
                        `Lokasi: ${pengaturan.lokasi_default}. Harap hadir tepat waktu.`,
                        "jadwal",
                        generated[0].id,
                ],
            );
        }

        return success(
            res,
            {
                generated,
                skipped,
                total_generated: generated.length,
                total_skipped: skipped.length,
            },
            `${generated.length} jadwal berhasil di-generate, ${skipped.length} dilewati (sudah ada)`,
            201,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

// =============================================================================
// CRUD JADWAL (Manual create, Edit, Delete)
// =============================================================================

export const createJadwal = async (req, res) => {
    try {
        const { tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan } =
            req.body;

        if (!tanggal || !waktu_mulai || !waktu_selesai || !lokasi) {
            return error(
                res,
                "tanggal, waktu_mulai, waktu_selesai, dan lokasi harus diisi",
                400,
            );
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal)) {
            return error(res, "Format tanggal harus YYYY-MM-DD", 400);
        }

        const tglJadwal = new Date(tanggal);
        const hariIni = new Date();
        hariIni.setHours(0, 0, 0, 0);
        if (tglJadwal < hariIni) {
            return error(res, "Tanggal jadwal tidak boleh di masa lampau", 400);
        }

        if (
            !/^\d{2}:\d{2}$/.test(waktu_mulai) ||
            !/^\d{2}:\d{2}$/.test(waktu_selesai)
        ) {
            return error(res, "Format waktu harus HH:MM", 400);
        }

        if (waktu_selesai <= waktu_mulai) {
            return error(res, "Waktu selesai harus setelah waktu mulai", 400);
        }

        const existing = await JadwalModel.findByTanggal(tanggal);
        if (existing) {
            return error(
                res,
                "Sudah ada jadwal posyandu pada tanggal tersebut",
                409,
            );
        }

        const id = await JadwalModel.create({
            kader_id: req.kader.id,
            tanggal,
            waktu_mulai,
            waktu_selesai,
            lokasi,
            keterangan,
        });

        // Broadcast notifikasi
        const semuaOrangTua = await JadwalModel.findAllOrangTua();
        await fcmService.sendBulkNotifications(
            semuaOrangTua,
            () => [
                    "Jadwal Posyandu Baru",
                    `Posyandu akan dilaksanakan pada ${tanggal} ` +
                    `pukul ${waktu_mulai} - ${waktu_selesai} ` +
                    `di ${lokasi}. Harap hadir tepat waktu.`,
                    "jadwal",
                    id,
            ],
        );

        return success(
            res,
            {
                id,
                tanggal,
                waktu_mulai,
                waktu_selesai,
                lokasi,
                keterangan: keterangan || null,
                notifikasi_ke: `${semuaOrangTua.length} orang tua`,
            },
            "Jadwal posyandu berhasil dibuat",
            201,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const updateJadwal = async (req, res) => {
    try {
        const { id } = req.params;
        const { tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan } =
            req.body;

        if (!tanggal || !waktu_mulai || !waktu_selesai || !lokasi) {
            return error(
                res,
                "tanggal, waktu_mulai, waktu_selesai, dan lokasi harus diisi",
                400,
            );
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal)) {
            return error(res, "Format tanggal harus YYYY-MM-DD", 400);
        }

        if (
            !/^\d{2}:\d{2}$/.test(waktu_mulai) ||
            !/^\d{2}:\d{2}$/.test(waktu_selesai)
        ) {
            return error(res, "Format waktu harus HH:MM", 400);
        }

        if (waktu_selesai <= waktu_mulai) {
            return error(res, "Waktu selesai harus setelah waktu mulai", 400);
        }

        const jadwal = await JadwalModel.findById(id);
        if (!jadwal) {
            return error(res, "Jadwal tidak ditemukan", 404);
        }

        // Cek duplikasi tanggal (exclude jadwal ini sendiri)
        const duplikat = await JadwalModel.findByTanggalExcluding(tanggal, id);
        if (duplikat) {
            return error(
                res,
                "Sudah ada jadwal posyandu lain pada tanggal tersebut",
                409,
            );
        }

        await JadwalModel.update(id, {
            tanggal,
            waktu_mulai,
            waktu_selesai,
            lokasi,
            keterangan,
        });

        // Bangun pesan perubahan
        const perubahan = [];
        if (jadwal.tanggal !== tanggal) {
            perubahan.push(`tanggal: ${jadwal.tanggal} → ${tanggal}`);
        }
        if (jadwal.waktu_mulai !== waktu_mulai || jadwal.waktu_selesai !== waktu_selesai) {
            perubahan.push(`waktu: ${waktu_mulai} - ${waktu_selesai}`);
        }
        if (jadwal.lokasi !== lokasi) {
            perubahan.push(`lokasi: ${jadwal.lokasi} → ${lokasi}`);
        }

        // Broadcast notifikasi perubahan ke semua orang tua
        if (perubahan.length > 0) {
            const semuaOrangTua = await JadwalModel.findAllOrangTua();
            const detailPerubahan = perubahan.join(", ");

            await fcmService.sendBulkNotifications(
                semuaOrangTua,
                () => [
                        "Perubahan Jadwal Posyandu",
                        `Jadwal posyandu telah diubah. Perubahan: ${detailPerubahan}. ` +
                        `Harap perhatikan jadwal terbaru.`,
                        "jadwal",
                        parseInt(id),
                ],
            );
        }

        return success(
            res,
            { id: parseInt(id), tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan },
            "Jadwal berhasil diperbarui",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const deleteJadwal = async (req, res) => {
    try {
        const { id } = req.params;

        const jadwal = await JadwalModel.findById(id);
        if (!jadwal) {
            return error(res, "Jadwal tidak ditemukan", 404);
        }

        // Hanya boleh hapus jadwal yang belum lewat
        const tglJadwal = new Date(jadwal.tanggal);
        const hariIni = new Date();
        hariIni.setHours(0, 0, 0, 0);
        if (tglJadwal < hariIni) {
            return error(
                res,
                "Jadwal yang sudah lewat tidak bisa dihapus",
                400,
            );
        }

        await JadwalModel.deleteById(id);

        // Broadcast notifikasi pembatalan ke semua orang tua
        const semuaOrangTua = await JadwalModel.findAllOrangTua();
        await fcmService.sendBulkNotifications(
            semuaOrangTua,
            () => [
                    "Jadwal Posyandu Dibatalkan",
                    `Jadwal posyandu pada ${jadwal.tanggal} di ${jadwal.lokasi} ` +
                    `telah dibatalkan. Mohon maaf atas ketidaknyamanan.`,
                    "jadwal",
                    null,
            ],
        );

        return success(res, null, "Jadwal berhasil dihapus");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAllJadwal = async (req, res) => {
    try {
        const { page, limit } = parsePagination(req.query);
        const result = await JadwalModel.findAll(page, limit);
        return success(res, {
            items: result.items,
            pagination: paginationMeta(page, limit, result.total),
        }, "Daftar jadwal berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDetailJadwal = async (req, res) => {
    try {
        const { id } = req.params;

        const jadwal = await JadwalModel.findById(id);
        if (!jadwal) {
            return error(res, "Jadwal tidak ditemukan", 404);
        }

        return success(res, jadwal, "Detail jadwal berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};
