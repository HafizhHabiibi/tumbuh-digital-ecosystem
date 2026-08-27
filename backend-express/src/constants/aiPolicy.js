export const AI_POLICY_VERSION = "1.0.0";

export const AI_RESPONSE_TYPES = Object.freeze({
    ANSWERED: "answered",
    OUT_OF_SCOPE: "out_of_scope",
    MEDICAL_ADVICE_REFUSED: "medical_advice_refused",
});

export const AI_ALLOWED_TOPICS = Object.freeze([
    "penjelasan_sederhana_hasil_pengukuran",
    "klarifikasi_insight_awal",
    "edukasi_makanan_dan_pola_makan",
    "edukasi_aktivitas_dan_stimulasi",
    "edukasi_kebersihan_dan_sanitasi",
    "edukasi_pemantauan_pertumbuhan_rutin",
]);

export const AI_PROHIBITED_CAPABILITIES = Object.freeze([
    "mendiagnosis_stunting_atau_penyakit",
    "menentukan_tindakan_atau_keputusan_klinis",
    "memberikan_obat_suplemen_atau_dosis",
    "menggantikan_konsultasi_tenaga_kesehatan",
    "menghitung_ulang_zscore_atau_saw",
    "mengubah_kategori_antropometri_atau_prioritas_saw",
    "menjawab_topik_umum_di_luar_konteks_pengukuran",
]);

// Hanya field dalam daftar ini yang boleh dipakai untuk membangun konteks LLM.
// Identitas kepemilikan tetap dipakai backend untuk otorisasi, bukan untuk prompt.
export const AI_CONTEXT_ALLOWED_FIELDS = Object.freeze([
    "jenis_kelamin",
    "usia_bulan",
    "berat_badan",
    "tinggi_badan",
    "nilai_imt",
    "status_bbu",
    "status_tbu",
    "status_bbtb",
    "status_imtu",
    "kategori_prioritas",
    "insight_teks",
    "riwayat_pesan",
]);

export const AI_CONTEXT_PROHIBITED_FIELDS = Object.freeze([
    "nama",
    "nik",
    "alamat",
    "nomor_telepon",
    "email",
    "zscore_bbu",
    "zscore_tbu",
    "zscore_bbtb",
    "zscore_imtu",
    "skor_saw",
    "peringkat_saw",
]);

export const AI_DISCLOSURES = Object.freeze({
    NON_DIAGNOSIS:
        "Informasi ini bersifat edukatif dan bukan diagnosis atau pengganti penilaian tenaga kesehatan.",
    MEDICAL_REDIRECT:
        "Saya tidak dapat memberikan diagnosis atau menentukan pengobatan. Untuk penilaian kondisi anak, silakan hubungi kader atau petugas Puskesmas.",
    OUT_OF_SCOPE:
        "Saya hanya dapat membantu menjelaskan hasil pengukuran terbaru serta edukasi makanan, aktivitas, kebersihan, dan pemantauan anak.",
});

export const AI_CONVERSATION_POLICY = Object.freeze({
    version: AI_POLICY_VERSION,
    purpose:
        "Memberikan edukasi singkat dan percakapan lanjutan berdasarkan pengukuran terbaru anak.",
    audience: "orang_tua",
    activeMeasurementRule:
        "Hanya percakapan milik pengukuran terbaru yang dapat dilanjutkan.",
    historicalMeasurementRule:
        "Percakapan pengukuran sebelumnya hanya dapat dibaca.",
    memoryRule:
        "Riwayat pesan hanya berasal dari percakapan pada pengukuran yang sama.",
    sourceOfTruthRule:
        "Kategori antropometri dan prioritas SAW dari backend tidak boleh dihitung ulang atau diubah oleh LLM.",
});
