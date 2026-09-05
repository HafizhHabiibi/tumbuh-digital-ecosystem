import { rules, ValidationError } from "../middlewares/validate.js";

const email = rules.string({
    min: 3,
    max: 255,
    lowercase: true,
    pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
});
const password = rules.string({ min: 6, max: 72 });
const nik = rules.string({ min: 16, max: 16, pattern: /^\d{16}$/ });
const nama = rules.string({ min: 2, max: 100 });
const noHp = rules.string({ min: 8, max: 20, pattern: /^\+?\d+$/ });
const uuid = rules.string({ min: 36, max: 36, pattern: /^[0-9a-f-]{36}$/i });

export const loginSchema = {
    fields: {
        email,
        password: rules.string({ min: 1, max: 72 }),
        fcm_token: rules.string({ required: false, max: 512 }),
        turnstileToken: rules.string({ required: false, max: 2048 }),
        platform: rules.enum(["mobile", "web"], { required: false }),
    },
};

export const forgotPasswordSchema = {
    fields: {
        email,
        turnstileToken: rules.string({ required: false, max: 2048 }),
        platform: rules.enum(["mobile", "web"], { required: false }),
    },
};

export const resetPasswordSchema = {
    fields: {
        token: rules.string({ min: 20, max: 2048 }),
        password_baru: password,
    },
};

export const changePasswordSchema = {
    fields: {
        password_lama: rules.string({ min: 1, max: 72 }),
        password_baru: password,
    },
};

export const refreshTokenSchema = {
    fields: { refresh_token: rules.string({ min: 20, max: 2048 }) },
};

export const orangTuaCreateSchema = {
    fields: {
        nama_lengkap: nama,
        email,
        password,
        no_hp: noHp,
        alamat: rules.string({ min: 3, max: 1000 }),
        nik,
    },
};

export const orangTuaUpdateSchema = {
    fields: {
        nama_lengkap: nama,
        no_hp: noHp,
        alamat: rules.string({ min: 3, max: 1000 }),
        nik,
    },
};

export const anakCreateSchema = {
    fields: {
        orang_tua_id: uuid,
        nama,
        jenis_kelamin: rules.enum(["L", "P"]),
        tanggal_lahir: rules.date({ allowFuture: false }),
        nik,
    },
};

export const anakUpdateSchema = {
    fields: {
        nama,
        jenis_kelamin: rules.enum(["L", "P"]),
        tanggal_lahir: rules.date({ allowFuture: false }),
        nik: rules.string({ required: false, min: 16, max: 16, pattern: /^\d{16}$/ }),
    },
};

export const pengukuranSchema = {
    fields: {
        anak_id: uuid,
        tanggal_ukur: rules.date({ allowFuture: false }),
        berat_badan: rules.number({ min: 0.01, max: 30 }),
        tinggi_badan: rules.number({ min: 0.01, max: 120 }),
        lingkar_kepala: rules.number({ required: false, min: 1, max: 80 }),
        lingkar_lengan: rules.number({ required: false, min: 1, max: 60 }),
    },
};

const paginationQueryFields = {
    page: rules.integer({ required: false, min: 1 }),
    limit: rules.integer({ required: false, min: 1, max: 100 }),
};
const searchQuery = rules.string({ required: false, max: 100 });

export const orangTuaListQuerySchema = {
    fields: {
        ...paginationQueryFields,
        search: searchQuery,
    },
};

export const anakListQuerySchema = {
    fields: {
        ...paginationQueryFields,
        search: searchQuery,
        jenis_kelamin: rules.enum(["L", "P"], { required: false }),
    },
};

export const rankingListQuerySchema = {
    fields: {
        ...paginationQueryFields,
        search: searchQuery,
        prioritas: rules.enum(
            ["rendah", "sedang", "tinggi"],
            { required: false },
        ),
    },
};

export const rujukanListQuerySchema = {
    fields: {
        ...paginationQueryFields,
        search: searchQuery,
        status: rules.enum(
            ["diajukan", "ditangani", "selesai", "aktif"],
            { required: false },
        ),
    },
};

export const pemberianSchema = {
    fields: {
        anak_id: uuid,
        jenis: rules.enum([
            "vitamin_a_merah", "vitamin_a_biru", "obat_cacing",
            "pmt_biskuit", "pmt_susu", "pmt_lainnya",
        ]),
        dosis: rules.string({ required: false, max: 50 }),
        tanggal_pemberian: rules.date({ allowFuture: false }),
        keterangan: rules.string({ required: false, max: 2000 }),
    },
};

export const rujukanCreateSchema = {
    fields: {
        anak_id: uuid,
        pengukuran_id: rules.integer(),
        catatan_kader: rules.string({ min: 3, max: 2000 }),
    },
};

export const rujukanStatusSchema = {
    fields: {
        status: rules.enum(["ditangani", "selesai"]),
        catatan_puskesmas: rules.string({ required: false, max: 2000 }),
    },
    refine: (body) => {
        if (
            body.status === "selesai" &&
            (!body.catatan_puskesmas || body.catatan_puskesmas.length < 3)
        ) {
            throw new ValidationError(
                "catatan_puskesmas wajib diisi minimal 3 karakter saat rujukan diselesaikan",
            );
        }
    },
};

const jadwalFields = {
    tanggal: rules.date({ allowPast: false }),
    waktu_mulai: rules.time(),
    waktu_selesai: rules.time(),
    lokasi: rules.string({ min: 3, max: 255 }),
    keterangan: rules.string({ required: false, max: 2000 }),
};

const waktuRefine = (body) => {
    if (body.waktu_selesai <= body.waktu_mulai) {
        throw new ValidationError("waktu_selesai harus setelah waktu_mulai");
    }
};

export const jadwalSchema = { fields: jadwalFields, refine: waktuRefine };
export const pengaturanJadwalSchema = {
    fields: {
        hari_tetap: rules.integer({ min: 1, max: 28 }),
        waktu_mulai: rules.time(),
        waktu_selesai: rules.time(),
        lokasi_default: rules.string({ min: 3, max: 255 }),
    },
    refine: waktuRefine,
};
export const generateJadwalSchema = {
    fields: { jumlah_bulan: rules.integer({ required: false, min: 1, max: 12 }) },
};

export const fcmTokenSchema = {
    fields: { fcm_token: rules.string({ min: 1, max: 512 }) },
};

const strictUuid = rules.string({
    min: 36,
    max: 36,
    lowercase: true,
    pattern: /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i,
});

export const chatPengukuranParamsSchema = {
    fields: { id: rules.integer() },
};

export const chatHistoryQuerySchema = {
    fields: {
        limit: rules.integer({ required: false, min: 1, max: 100 }),
        before_id: rules.integer({ required: false }),
    },
};

export const chatMessageSchema = {
    fields: {
        client_message_id: strictUuid,
        message: rules.string({ min: 2, max: 1000 }),
    },
};

export const laporanAnakParamsSchema = {
    fields: { anak_id: uuid },
};

export const laporanRekapQuerySchema = {
    fields: {
        tanggal_mulai: rules.date({ allowFuture: false }),
        tanggal_selesai: rules.date({ allowFuture: false }),
    },
    refine: ({ tanggal_mulai, tanggal_selesai }) => {
        const mulai = new Date(`${tanggal_mulai}T00:00:00.000Z`);
        const selesai = new Date(`${tanggal_selesai}T00:00:00.000Z`);
        if (selesai < mulai) {
            throw new ValidationError(
                "tanggal_selesai tidak boleh sebelum tanggal_mulai",
            );
        }
        const jumlahHariInklusif =
            Math.floor((selesai - mulai) / 86_400_000) + 1;
        if (jumlahHariInklusif > 366) {
            throw new ValidationError(
                "Rentang laporan maksimal 366 hari",
            );
        }
    },
};
