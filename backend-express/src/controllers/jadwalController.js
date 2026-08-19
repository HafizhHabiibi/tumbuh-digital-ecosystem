import * as JadwalModel from "../models/jadwalModel.js";
import * as fcmService from "../services/fcmService.js";
import { success, error } from "../utils/response.js";

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
        const generated = [];
        const skipped = [];

        for (let i = 0; i < jumlah_bulan; i++) {
            const targetDate = new Date(today.getFullYear(), today.getMonth() + i, pengaturan.hari_tetap);

            // Skip jika tanggal sudah lewat
            if (targetDate < today) {
                targetDate.setMonth(targetDate.getMonth() + 1);
            }

            const tanggal = targetDate.toISOString().split("T")[0];

            // Skip jika sudah ada jadwal di tanggal tersebut
            const existing = await JadwalModel.findByTanggal(tanggal);
            if (existing) {
                skipped.push(tanggal);
                continue;
            }

            const id = await JadwalModel.create({
                kader_id: req.kader.id,
                tanggal,
                waktu_mulai: pengaturan.waktu_mulai,
                waktu_selesai: pengaturan.waktu_selesai,
                lokasi: pengaturan.lokasi_default,
                keterangan: null,
            });

            generated.push({ id, tanggal });
        }

        // Broadcast notifikasi ke semua orang tua (jika ada jadwal baru)
        if (generated.length > 0) {
            const semuaOrangTua = await JadwalModel.findAllOrangTua();
            const daftarTanggal = generated.map((g) => g.tanggal).join(", ");

            Promise.all(
                semuaOrangTua.map((ot) =>
                    fcmService.sendNotification(
                        ot.id,
                        "Jadwal Posyandu Baru",
                        `${generated.length} jadwal posyandu baru telah dibuat: ${daftarTanggal}. ` +
                        `Lokasi: ${pengaturan.lokasi_default}. Harap hadir tepat waktu.`,
                        "jadwal",
                        generated[0].id,
                    ),
                ),
            ).catch((err) => console.error("[FCM JADWAL]", err.message));
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
        Promise.all(
            semuaOrangTua.map((ot) =>
                fcmService.sendNotification(
                    ot.id,
                    "Jadwal Posyandu Baru",
                    `Posyandu akan dilaksanakan pada ${tanggal} ` +
                    `pukul ${waktu_mulai} - ${waktu_selesai} ` +
                    `di ${lokasi}. Harap hadir tepat waktu.`,
                    "jadwal",
                    id,
                ),
            ),
        ).catch((err) => console.error("[FCM JADWAL]", err.message));

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

            Promise.all(
                semuaOrangTua.map((ot) =>
                    fcmService.sendNotification(
                        ot.id,
                        "Perubahan Jadwal Posyandu",
                        `Jadwal posyandu telah diubah. Perubahan: ${detailPerubahan}. ` +
                        `Harap perhatikan jadwal terbaru.`,
                        "jadwal",
                        parseInt(id),
                    ),
                ),
            ).catch((err) => console.error("[FCM JADWAL]", err.message));
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
        Promise.all(
            semuaOrangTua.map((ot) =>
                fcmService.sendNotification(
                    ot.id,
                    "Jadwal Posyandu Dibatalkan",
                    `Jadwal posyandu pada ${jadwal.tanggal} di ${jadwal.lokasi} ` +
                    `telah dibatalkan. Mohon maaf atas ketidaknyamanan.`,
                    "jadwal",
                    parseInt(id),
                ),
            ),
        ).catch((err) => console.error("[FCM JADWAL]", err.message));

        return success(res, null, "Jadwal berhasil dihapus");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAllJadwal = async (req, res) => {
    try {
        const jadwal = await JadwalModel.findAll();
        return success(res, jadwal, "Daftar jadwal berhasil diambil");
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
