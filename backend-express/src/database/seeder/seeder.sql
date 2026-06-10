USE posyandu_pui;

-- ==========================================================
-- FULL RESET — Hapus semua data lama (urutan FK terbalik)
-- ==========================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE notifikasi;
TRUNCATE TABLE ai_insight;
TRUNCATE TABLE rujukan;
TRUNCATE TABLE saw_result_detail;
TRUNCATE TABLE saw_result;
TRUNCATE TABLE riwayat_pemberian;
TRUNCATE TABLE pengukuran;
TRUNCATE TABLE anak;
TRUNCATE TABLE jadwal_posyandu;
TRUNCATE TABLE orang_tua;
TRUNCATE TABLE kader;
TRUNCATE TABLE puskesmas_user;
TRUNCATE TABLE refresh_tokens;
TRUNCATE TABLE login_attempts;
TRUNCATE TABLE password_reset_token;
TRUNCATE TABLE users;
TRUNCATE TABLE saw_kriteria;
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================================
-- SAW KRITERIA SETUP
-- ==========================================================
INSERT INTO saw_kriteria (nama_kriteria, bobot, keterangan) VALUES
    ('zscore_tbu',      0.4000, 'Tinggi Badan per Umur'),
    ('zscore_bbu',      0.3000, 'Berat Badan per Umur'),
    ('zscore_bbtb',     0.2000, 'Berat Badan per Tinggi Badan'),
    ('frekuensi_hadir', 0.1000, 'Kehadiran rutin ke posyandu');

-- ==========================================================
-- TIER 1: Users, Kader, Puskesmas
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fa-73b0-a4c6-8a3cafbf1487', 'meongterbang22@gmail.com', '$2b$10$7laSsaFY5i1vqEafbYcZzeNFzRjCm6iSYPnTOFOAaw55mLaI5MngO', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019eb2c7-b1fb-75a4-933f-036814d054d9', '019eb2c7-b1fa-73b0-a4c6-8a3cafbf1487', 'Riri Andayani', '081234567890');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-036996074b25', 'budi.kader@gmail.com', '$2b$10$0dg/02PNPZQ4uWBTHAx7UeC72O28CNi6tIout5UhVkeCWS9Vl6bsO', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019eb2c7-b1fb-75a4-933f-036a022e7136', '019eb2c7-b1fb-75a4-933f-036996074b25', 'Budi Santoso', '082345678901');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-036b86bf57d2', 'sari.kader@gmail.com', '$2b$10$WuwMEUmxnblRRVuFZsMOeeJ2KtWrz0XW5vcRxCEp6cRc2ZoX/fZNy', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '019eb2c7-b1fb-75a4-933f-036b86bf57d2', 'Sari Dewi', '083456789012');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-036d42d8944c', 'bullmini123@gmail.com', '$2b$10$RwHuoa9jolWALp1snEBIxuvMFJpr5jcjTcev65dTKx5Es18T5ls5u', 'puskesmas', TRUE);
INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('019eb2c7-b1fb-75a4-933f-036eba31771d', '019eb2c7-b1fb-75a4-933f-036d42d8944c', 'Ciko Wijaya', 'Bidan', '081234567891');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-036fd1eb0fcd', 'hana.pertiwi@gmail.com', '$2b$10$ItEbwZJE.DNtp56B5agwPez3YWJSv1sg4jyRTB.w2NYKn.UabKaF2', 'puskesmas', TRUE);
INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('019eb2c7-b1fb-75a4-933f-0370eb1d44a3', '019eb2c7-b1fb-75a4-933f-036fd1eb0fcd', 'dr. Hana Pertiwi', 'Dokter', '084567890123');

-- ==========================================================
-- TIER 2: Orang Tua
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-0371653ae744', 'aminah.kusuma@gmail.com', '$2b$10$6KOo9u7TIb1alDhkRWmkxOpAkYetEj47q8.T9JBRKhK1Cxze597ma', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-037275a3f476', '019eb2c7-b1fb-75a4-933f-0371653ae744', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'Aminah Kusuma', '081111111101', 'Jl. Mawar No. 12 RT 01 RW 05', '3201010101870001');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-03737307294a', 'dewi.susanti@gmail.com', '$2b$10$zC49v3BJ2vJgvxJLxGSLzOLc1psEGiiuabPk6uMmzvIU7E1reKoz2', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-0374015336ca', '019eb2c7-b1fb-75a4-933f-03737307294a', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'Dewi Susanti', '081111111102', 'Jl. Melati No. 5 RT 02 RW 05', '3201010201890002');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-037568a83192', 'fatimah.rahman@gmail.com', '$2b$10$0P5b0c5oJzYK79Eg11rOEeUTw7kL8JiMz49gCx2STkxrZ9SS.kTA.', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-037642046d23', '019eb2c7-b1fb-75a4-933f-037568a83192', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'Fatimah Rahman', '081111111103', 'Jl. Anggrek No. 8 RT 03 RW 05', '3201010301850003');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-0377655c0091', 'siti.rahayu@gmail.com', '$2b$10$0fKJOd0MimaFbGyulibQR.B/D8m/KEBmX.3MhUV7fZUEpeR1w6OZK', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-0378e4787315', '019eb2c7-b1fb-75a4-933f-0377655c0091', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'Siti Rahayu', '081111111104', 'Jl. Dahlia No. 3 RT 01 RW 05', '3201010401900004');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-037953bd040a', 'kartini.wulandari@gmail.com', '$2b$10$bRMMlhd9X.FgmDZxGBTdAeAZDBuuMq29vLvyJaiWqh1Noq5xcu7nm', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-037ad34acd5b', '019eb2c7-b1fb-75a4-933f-037953bd040a', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'Kartini Wulandari', '081111111105', 'Jl. Kenanga No. 7 RT 04 RW 05', '3201010501880005');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-037b33242ea5', 'rahayu.lestari@gmail.com', '$2b$10$qObtRWOBMEnXtSFNMyJpFu1wJ6SA7eR8HaJeTcUgiYl9tgAP/Nklq', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-037cef0f981d', '019eb2c7-b1fb-75a4-933f-037b33242ea5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'Rahayu Lestari', '081111111106', 'Jl. Bougenville No. 15 RT 02 RW 05', '3201010601910006');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-037d3963d844', 'wulan.sari@gmail.com', '$2b$10$6AbCOeZK6Y7eruyC2D1/a.FhfpcMgLrZYvc/C3/.UFt8Rc4QEgMeG', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-037e927572f5', '019eb2c7-b1fb-75a4-933f-037d3963d844', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'Wulan Sari', '081111111107', 'Jl. Cempaka No. 4 RT 03 RW 05', '3201010701920007');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-037febb6e3b2', 'lestari.handayani@gmail.com', '$2b$10$CcJOid44Zg5xO.E3cvX6wOqC4ehOv2cyVwGzwneUoU0qgtwKcG6fq', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-03809f5aaee0', '019eb2c7-b1fb-75a4-933f-037febb6e3b2', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'Lestari Handayani', '081111111108', 'Jl. Flamboyan No. 9 RT 05 RW 05', '3201010801860008');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-038173caa974', 'nuraini.putri@gmail.com', '$2b$10$wA5y8Jb/I4E3OFTPidwGVewLxJs80ghU7KZSKHZRre1svi5G5O2Yy', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-03826f2ca24b', '019eb2c7-b1fb-75a4-933f-038173caa974', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'Nuraini Putri', '081111111109', 'Jl. Kamboja No. 2 RT 01 RW 05', '3201010901930009');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2c7-b1fb-75a4-933f-038373c676e2', 'sumiati.wahyu@gmail.com', '$2b$10$h2ghuIfsoK5GcmgQ0JBp5uVJrxEMJE9lZOkNQClpdWtOgMwPBJZWi', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2c7-b1fb-75a4-933f-0384ce6c334b', '019eb2c7-b1fb-75a4-933f-038373c676e2', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'Sumiati Wahyu', '081111111110', 'Jl. Teratai No. 6 RT 04 RW 05', '3201011001870010');

-- ==========================================================
-- TIER 2: Jadwal Posyandu (5 lampau + 3 mendatang)
-- ==========================================================

INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-01-19', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Januari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-02-16', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Februari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-03-15', '08:30', '11:30', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Maret 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-04-20', '08:00', '12:00', 'Puskesmas Pembantu Cempaka', 'Posyandu + Pemberian Vitamin A Massal');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-05-18', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Mei 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-06-15', '08:30', '12:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juni 2026 - Pembagian PMT');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-07-20', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juli 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-08-17', '08:30', '11:30', 'Puskesmas Pembantu Cempaka', 'Posyandu + Bulan Imunisasi Nasional 2026');

-- ==========================================================
-- TIER 3: Anak (15 anak)
-- ==========================================================

INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-037275a3f476', 'Rizki', 'L', '2025-06-11', '3201011234560001');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-037275a3f476', 'Rafi', 'L', '2023-10-11', '3201011234560002');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-0374015336ca', 'Nayla', 'P', '2025-10-11', '3201011234560003');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-037642046d23', 'Hasan', 'L', '2024-06-11', '3201011234560004');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-037642046d23', 'Husein', 'L', '2025-12-11', '3201011234560005');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-0378e4787315', 'Zahra', 'P', '2024-12-11', '3201011234560006');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-037ad34acd5b', 'Dani', 'L', '2023-12-11', '3201011234560007');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-037ad34acd5b', 'Dina', 'P', '2025-03-11', '3201011234560008');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-037cef0f981d', 'Bagas', 'L', '2024-10-11', '3201011234560009');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-037e927572f5', 'Putri', 'P', '2025-08-11', '3201011234560010');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-03809f5aaee0', 'Adi', 'L', '2023-06-11', '3201011234560011');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-03809f5aaee0', 'Ayu', 'P', '2024-08-11', '3201011234560012');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-03826f2ca24b', 'Fauzi', 'L', '2025-04-11', '3201011234560013');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-0384ce6c334b', 'Bella', 'P', '2024-02-11', '3201011234560014');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-0384ce6c334b', 'Bimo', 'L', '2025-09-11', '3201011234560015');

-- ==========================================================
-- TIER 4: Pengukuran (6 titik historis per anak = 90 total)
-- Z-score dihitung otomatis menggunakan WHO tables
-- ==========================================================

-- Anak: Rizki (L, lahir 2025-06-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-01-11', 8.1, 68.5, 43.3, 13.6, -0.23, -0.325, 0.028, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-02-11', 8.4, 69.8, 43.7, 13.8, -0.252, -0.403, 0.033, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-03-11', 8.7, 71, 44, 13.9, -0.202, -0.415, 0.073, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-04-11', 8.9, 72.3, 44.3, 14.1, -0.263, -0.416, -0.048, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-05-11', 9.2, 73.5, 44.6, 14.2, -0.204, -0.435, 0.01, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-06-11', 9.5, 74.8, 45, 14.3, -0.138, -0.391, 0.048, 'normal');

-- Anak: Rafi (L, lahir 2023-10-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-01-11', 12.7, 89.5, NULL, NULL, -0.033, -0.048, -0.067, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-02-11', 12.9, 90.2, NULL, NULL, -0.026, -0.076, -0.032, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-03-11', 13.1, 90.9, NULL, NULL, -0.009, -0.081, 0.002, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-04-11', 13.3, 91.5, NULL, NULL, 0.001, -0.125, 0.059, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-05-11', 13.5, 92.2, NULL, NULL, 0.013, -0.133, 0.092, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-06-11', 13.7, 92.9, NULL, NULL, 0.027, -0.135, 0.124, 'normal');

-- Anak: Nayla (P, lahir 2025-10-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-01-11', 5.8, 59.5, 38.5, 12.3, -0.072, -0.157, 0.103, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-02-11', 6.2, 61.4, 40, 12.7, -0.315, -0.363, -0.047, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-03-11', 6.6, 63.3, 41.5, 13.1, -0.336, -0.291, -0.141, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-04-11', 7, 65.2, 43, 13.5, -0.337, -0.227, -0.198, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-05-11', 7.4, 67.1, 43.3, 13.6, -0.251, -0.056, -0.222, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-06-11', 7.8, 69, 43.7, 13.8, -0.155, 0.106, -0.219, 'normal');

-- Anak: Hasan (L, lahir 2024-06-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-01-11', 8.8, 80.5, 47.3, 15.3, -2.113, -0.999, -2.245, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-02-11', 9, 81.2, 47.6, 15.5, -2.071, -1.081, -2.12, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-03-11', 9.2, 81.9, 48, 15.6, -2.012, -1.112, -2.008, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-04-11', 9.5, 82.7, 48.3, 15.7, -1.878, -1.139, -1.796, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-05-11', 9.7, 83.4, 48.6, 15.9, -1.832, -1.172, -1.71, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-06-11', 9.9, 84.1, NULL, NULL, -1.796, -0.991, -1.635, 'normal');

-- Anak: Husein (L, lahir 2025-12-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-01-11', 4.2, 53.5, 35.5, 11.4, -0.467, -0.634, 0.178, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-02-11', 4.9, 56.2, 37, 11.8, -1.068, -1.173, 0.019, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-03-11', 5.6, 58.9, 38.5, 12.3, -1.037, -1.162, -0.167, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-04-11', 6.4, 61.6, 40, 12.7, -0.775, -1.078, -0.04, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-05-11', 7.1, 64.3, 41.5, 13.1, -0.478, -0.717, 0.003, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-06-11', 7.8, 67, 43, 13.5, -0.151, -0.284, 0.099, 'normal');

-- Anak: Zahra (P, lahir 2024-12-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-01-11', 7.3, 71, 45.3, 14.5, -1.907, -1.612, -1.546, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-02-11', 7.5, 72.1, 45.6, 14.6, -1.878, -1.605, -1.538, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-03-11', 7.7, 73.2, 46, 14.8, -1.835, -1.559, -1.525, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-04-11', 7.8, 74.3, 46.3, 14.9, -1.914, -1.529, -1.654, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-05-11', 8, 75.4, 46.6, 15, -1.875, -1.478, -1.625, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-06-11', 8.2, 76.5, 47, 15.2, -1.847, -1.441, -1.592, 'normal');

-- Anak: Dani (L, lahir 2023-12-11, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-01-11', 9.3, 82.5, NULL, NULL, -2.481, -1.765, -2.198, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-02-11', 9.5, 83.4, NULL, NULL, -2.423, -1.712, -2.165, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-03-11', 9.7, 84.3, NULL, NULL, -2.356, -1.64, -2.145, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-04-11', 9.8, 85.2, NULL, NULL, -2.386, -1.579, -2.266, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-05-11', 10, 86.1, NULL, NULL, -2.325, -1.515, -2.256, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-06-11', 10.2, 87, NULL, NULL, -2.265, -1.447, -2.246, 'kurang');

-- Anak: Dina (P, lahir 2025-03-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-01-11', 8.3, 71, 44.3, 14.1, -0.185, -0.217, -0.088, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-02-11', 8.5, 72.2, 44.6, 14.2, -0.225, -0.264, -0.14, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-03-11', 8.8, 73.4, 45, 14.3, -0.133, -0.231, -0.056, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-04-11', 9, 74.6, 45.3, 14.5, -0.157, -0.244, -0.091, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-05-11', 9.3, 75.8, 45.6, 14.6, -0.074, -0.213, 0.004, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-06-11', 9.5, 77, 46, 14.8, -0.091, -0.198, -0.019, 'normal');

-- Anak: Bagas (L, lahir 2024-10-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-01-11', 8.5, 76, 46, 14.8, -1.753, -1.255, -1.632, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-02-11', 8.7, 76.8, 46.3, 14.9, -1.723, -1.332, -1.537, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-03-11', 8.9, 77.6, 46.6, 15, -1.675, -1.36, -1.441, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-04-11', 9.1, 78.5, 47, 15.2, -1.647, -1.385, -1.368, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-05-11', 9.3, 79.3, 47.3, 15.3, -1.609, -1.413, -1.274, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-06-11', 9.4, 80.1, 47.6, 15.5, -1.674, -1.452, -1.318, 'normal');

-- Anak: Putri (P, lahir 2025-08-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-01-11', 6.8, 63.5, 41.5, 13.1, -0.127, -0.255, 0.109, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-02-11', 7.1, 65, 43, 13.5, -0.247, -0.361, 0.029, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-03-11', 7.4, 66.5, 43.3, 13.6, -0.251, -0.316, -0.028, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-04-11', 7.6, 68, 43.7, 13.8, -0.369, -0.317, -0.208, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-05-11', 7.9, 69.5, 44, 13.9, -0.324, -0.25, -0.222, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-06-11', 8.2, 71, 44.3, 14.1, -0.269, -0.182, -0.223, 'normal');

-- Anak: Adi (L, lahir 2023-06-11, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-01-11', 10, 84.5, NULL, NULL, -2.546, -2.371, -1.807, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-02-11', 10.2, 85.3, NULL, NULL, -2.478, -2.31, -1.775, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-03-11', 10.3, 86.1, NULL, NULL, -2.484, -2.233, -1.87, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-04-11', 10.4, 86.9, NULL, NULL, -2.501, -2.176, -1.964, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-05-11', 10.6, 87.7, NULL, NULL, -2.429, -2.107, -1.93, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-06-11', 10.8, 88.5, NULL, NULL, -2.366, -2.048, -1.894, 'kurang');

-- Anak: Ayu (P, lahir 2024-08-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-01-11', 8.4, 77, 46.6, 15, -1.469, -0.939, -1.424, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-02-11', 8.6, 78, 47, 15.2, -1.451, -0.946, -1.376, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-03-11', 8.8, 79, 47.3, 15.3, -1.411, -0.902, -1.336, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-04-11', 9, 80, 47.6, 15.5, -1.393, -0.892, -1.306, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-05-11', 9.2, 81, 48, 15.6, -1.364, -0.856, -1.289, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-06-11', 9.3, 82, 48.3, 15.7, -1.438, -0.832, -1.409, 'normal');

-- Anak: Fauzi (L, lahir 2025-04-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-01-11', 8.9, 71, 44, 13.9, -0.011, -0.453, 0.347, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-02-11', 9.1, 72.3, 44.3, 14.1, -0.076, -0.452, 0.22, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-03-11', 9.3, 73.7, 44.6, 14.2, -0.105, -0.349, 0.085, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-04-11', 9.6, 75, 45, 14.3, -0.042, -0.307, 0.122, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-05-11', 9.8, 76.4, 45.3, 14.5, -0.067, -0.208, 0.023, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036814d054d9', '2026-06-11', 10, 77.8, 45.6, 14.6, -0.085, -0.097, -0.055, 'normal');

-- Anak: Bella (P, lahir 2024-02-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-01-11', 9.5, 83, 48.6, 15.9, -1.415, -0.793, -1.411, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-02-11', 9.7, 83.6, NULL, NULL, -1.397, -0.664, -1.319, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-03-11', 9.9, 84.2, NULL, NULL, -1.361, -0.714, -1.415, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-04-11', 10.1, 84.8, NULL, NULL, -1.339, -0.781, -1.335, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-05-11', 10.3, 85.4, NULL, NULL, -1.317, -0.84, -1.259, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036a022e7136', '2026-06-11', 10.4, 86, NULL, NULL, -1.374, -0.893, -1.299, 'normal');

-- Anak: Bimo (L, lahir 2025-09-11, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-01-11', 5.5, 60.5, 40, 12.7, -2.106, -1.643, -1.325, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-02-11', 5.7, 61.8, 41.5, 13.1, -2.453, -1.959, -1.571, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-03-11', 5.9, 63.1, 43, 13.5, -2.632, -2.08, -1.771, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-04-11', 6.2, 64.4, 43.3, 13.6, -2.614, -2.17, -1.727, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-05-11', 6.4, 65.7, 43.7, 13.8, -2.678, -2.2, -1.869, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '2026-06-11', 6.6, 67, 44, 13.9, -2.703, -2.199, -1.991, 'kurang');

-- ==========================================================
-- TIER 4: Riwayat Pemberian Vitamin A, Obat Cacing & PMT
-- ==========================================================

-- Rizki (usia: 12 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Rafi (usia: 32 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Nayla (usia: 8 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Hasan (usia: 24 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Husein (usia: 6 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Zahra (usia: 18 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Dani (usia: 30 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Dina (usia: 15 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Bagas (usia: 20 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Putri (usia: 10 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Adi (usia: 36 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Ayu (usia: 22 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Fauzi (usia: 14 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Bella (usia: 28 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Bimo (usia: 9 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036814d054d9', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036a022e7136', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- ==========================================================
-- TIER 5: SAW Result + Detail (1 per pengukuran = 90 total)
-- ==========================================================

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', 1, 0.4487, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_bbu', 0.3, 0.446, 0.1338);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_tbu', 0.4, 0.465, 0.186);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_bbtb', 0.2, 0.3944, 0.0789);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', 2, 0.456, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_bbu', 0.3, 0.4504, 0.1351);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_tbu', 0.4, 0.4806, 0.1922);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_bbtb', 0.2, 0.3934, 0.0787);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', 3, 0.4524, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_bbu', 0.3, 0.4404, 0.1321);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_tbu', 0.4, 0.483, 0.1932);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_bbtb', 0.2, 0.3854, 0.0771);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', 4, 0.461, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_bbu', 0.3, 0.4526, 0.1358);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_tbu', 0.4, 0.4832, 0.1933);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_bbtb', 0.2, 0.4096, 0.0819);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', 5, 0.4566, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_bbu', 0.3, 0.4408, 0.1322);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_tbu', 0.4, 0.487, 0.1948);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_bbtb', 0.2, 0.398, 0.0796);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', 6, 0.4476, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_bbu', 0.3, 0.4276, 0.1283);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_tbu', 0.4, 0.4782, 0.1913);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_bbtb', 0.2, 0.3904, 0.0781);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', 7, 0.4185, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_bbu', 0.3, 0.4066, 0.122);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_tbu', 0.4, 0.4096, 0.1638);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_bbtb', 0.2, 0.4134, 0.0827);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', 8, 0.4189, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_bbu', 0.3, 0.4052, 0.1216);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_tbu', 0.4, 0.4152, 0.1661);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_bbtb', 0.2, 0.4064, 0.0813);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', 9, 0.4169, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_bbu', 0.3, 0.4018, 0.1205);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_tbu', 0.4, 0.4162, 0.1665);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_bbtb', 0.2, 0.3996, 0.0799);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', 10, 0.4176, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_bbu', 0.3, 0.3998, 0.1199);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_tbu', 0.4, 0.425, 0.17);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_bbtb', 0.2, 0.3882, 0.0776);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', 11, 0.4162, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_bbu', 0.3, 0.3974, 0.1192);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_tbu', 0.4, 0.4266, 0.1706);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_bbtb', 0.2, 0.3816, 0.0763);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', 12, 0.4142, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_bbu', 0.3, 0.3946, 0.1184);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_tbu', 0.4, 0.427, 0.1708);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_bbtb', 0.2, 0.3752, 0.075);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', 13, 0.4228, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_bbu', 0.3, 0.4144, 0.1243);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_tbu', 0.4, 0.4314, 0.1726);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_bbtb', 0.2, 0.3794, 0.0759);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', 14, 0.4598, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_bbu', 0.3, 0.463, 0.1389);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_tbu', 0.4, 0.4726, 0.189);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_bbtb', 0.2, 0.4094, 0.0819);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', 15, 0.4591, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_bbu', 0.3, 0.4672, 0.1402);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_tbu', 0.4, 0.4582, 0.1833);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_bbtb', 0.2, 0.4282, 0.0856);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', 16, 0.4563, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_bbu', 0.3, 0.4674, 0.1402);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_tbu', 0.4, 0.4454, 0.1782);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_bbtb', 0.2, 0.4396, 0.0879);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', 17, 0.4384, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_bbu', 0.3, 0.4502, 0.1351);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_tbu', 0.4, 0.4112, 0.1645);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_bbtb', 0.2, 0.4444, 0.0889);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', 18, 0.4196, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_bbu', 0.3, 0.431, 0.1293);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_tbu', 0.4, 0.3788, 0.1515);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_bbtb', 0.2, 0.4438, 0.0888);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', 19, 0.7065, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_bbu', 0.3, 0.8226, 0.2468);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_tbu', 0.4, 0.5998, 0.2399);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_bbtb', 0.2, 0.849, 0.1698);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', 20, 0.7055, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_bbu', 0.3, 0.8142, 0.2443);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_tbu', 0.4, 0.6162, 0.2465);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_bbtb', 0.2, 0.824, 0.1648);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', 21, 0.7, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_bbu', 0.3, 0.8024, 0.2407);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_tbu', 0.4, 0.6224, 0.249);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_bbtb', 0.2, 0.8016, 0.1603);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', 22, 0.6856, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_bbu', 0.3, 0.7756, 0.2327);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_tbu', 0.4, 0.6278, 0.2511);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_bbtb', 0.2, 0.7592, 0.1518);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', 23, 0.6821, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_bbu', 0.3, 0.7664, 0.2299);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_tbu', 0.4, 0.6344, 0.2538);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_bbtb', 0.2, 0.742, 0.1484);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', 24, 0.6624, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_bbu', 0.3, 0.7592, 0.2278);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_tbu', 0.4, 0.5982, 0.2393);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_bbtb', 0.2, 0.727, 0.1454);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', 25, 0.4816, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_bbu', 0.3, 0.4934, 0.148);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_tbu', 0.4, 0.5268, 0.2107);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_bbtb', 0.2, 0.3644, 0.0729);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', 26, 0.5672, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_bbu', 0.3, 0.6136, 0.1841);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_tbu', 0.4, 0.6346, 0.2538);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_bbtb', 0.2, 0.3962, 0.0792);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', 27, 0.5719, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_bbu', 0.3, 0.6074, 0.1822);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_tbu', 0.4, 0.6324, 0.253);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_bbtb', 0.2, 0.4334, 0.0867);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', 28, 0.5443, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_bbu', 0.3, 0.555, 0.1665);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_tbu', 0.4, 0.6156, 0.2462);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_bbtb', 0.2, 0.408, 0.0816);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', 29, 0.4959, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_bbu', 0.3, 0.4956, 0.1487);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_tbu', 0.4, 0.5434, 0.2174);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_bbtb', 0.2, 0.3994, 0.0799);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', 30, 0.4378, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_bbu', 0.3, 0.4302, 0.1291);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_tbu', 0.4, 0.4568, 0.1827);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_bbtb', 0.2, 0.3802, 0.076);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', 31, 0.7152, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_bbu', 0.3, 0.7814, 0.2344);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_tbu', 0.4, 0.7224, 0.289);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_bbtb', 0.2, 0.7092, 0.1418);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', 32, 0.7126, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_bbu', 0.3, 0.7756, 0.2327);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_tbu', 0.4, 0.721, 0.2884);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_bbtb', 0.2, 0.7076, 0.1415);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', 33, 0.7058, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_bbu', 0.3, 0.767, 0.2301);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_tbu', 0.4, 0.7118, 0.2847);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_bbtb', 0.2, 0.705, 0.141);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', 34, 0.7133, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_bbu', 0.3, 0.7828, 0.2348);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_tbu', 0.4, 0.7058, 0.2823);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_bbtb', 0.2, 0.7308, 0.1462);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', 35, 0.7057, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_bbu', 0.3, 0.775, 0.2325);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_tbu', 0.4, 0.6956, 0.2782);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_bbtb', 0.2, 0.725, 0.145);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', 36, 0.6998, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_bbu', 0.3, 0.7694, 0.2308);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_tbu', 0.4, 0.6882, 0.2753);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_bbtb', 0.2, 0.7184, 0.1437);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', 37, 0.788, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_bbu', 0.3, 0.8962, 0.2689);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_tbu', 0.4, 0.753, 0.3012);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_bbtb', 0.2, 0.8396, 0.1679);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', 38, 0.7789, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_bbu', 0.3, 0.8846, 0.2654);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_tbu', 0.4, 0.7424, 0.297);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_bbtb', 0.2, 0.833, 0.1666);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', 39, 0.7684, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_bbu', 0.3, 0.8712, 0.2614);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_tbu', 0.4, 0.728, 0.2912);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_bbtb', 0.2, 0.829, 0.1658);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', 40, 0.7701, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_bbu', 0.3, 0.8772, 0.2632);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_tbu', 0.4, 0.7158, 0.2863);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_bbtb', 0.2, 0.8532, 0.1706);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', 41, 0.7609, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_bbu', 0.3, 0.865, 0.2595);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_tbu', 0.4, 0.703, 0.2812);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_bbtb', 0.2, 0.8512, 0.1702);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', 42, 0.7515, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_bbu', 0.3, 0.853, 0.2559);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_tbu', 0.4, 0.6894, 0.2758);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_bbtb', 0.2, 0.8492, 0.1698);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', 43, 0.442, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_bbu', 0.3, 0.437, 0.1311);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_tbu', 0.4, 0.4434, 0.1774);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_bbtb', 0.2, 0.4176, 0.0835);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', 44, 0.4502, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_bbu', 0.3, 0.445, 0.1335);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_tbu', 0.4, 0.4528, 0.1811);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_bbtb', 0.2, 0.428, 0.0856);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', 45, 0.4387, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_bbu', 0.3, 0.4266, 0.128);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_tbu', 0.4, 0.4462, 0.1785);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_bbtb', 0.2, 0.4112, 0.0822);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', 46, 0.4426, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_bbu', 0.3, 0.4314, 0.1294);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_tbu', 0.4, 0.4488, 0.1795);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_bbtb', 0.2, 0.4182, 0.0836);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', 47, 0.4313, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_bbu', 0.3, 0.4148, 0.1244);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_tbu', 0.4, 0.4426, 0.177);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_bbtb', 0.2, 0.3992, 0.0798);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', 48, 0.4321, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_bbu', 0.3, 0.4182, 0.1255);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_tbu', 0.4, 0.4396, 0.1758);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_bbtb', 0.2, 0.4038, 0.0808);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', 49, 0.6809, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_bbu', 0.3, 0.7506, 0.2252);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_tbu', 0.4, 0.651, 0.2604);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_bbtb', 0.2, 0.7264, 0.1453);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', 50, 0.6814, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_bbu', 0.3, 0.7446, 0.2234);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_tbu', 0.4, 0.6664, 0.2666);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_bbtb', 0.2, 0.7074, 0.1415);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', 51, 0.6769, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_bbu', 0.3, 0.735, 0.2205);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_tbu', 0.4, 0.672, 0.2688);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_bbtb', 0.2, 0.6882, 0.1376);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', 52, 0.6743, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_bbu', 0.3, 0.7294, 0.2188);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_tbu', 0.4, 0.677, 0.2708);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_bbtb', 0.2, 0.6736, 0.1347);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', 53, 0.6705, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_bbu', 0.3, 0.7218, 0.2165);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_tbu', 0.4, 0.6826, 0.273);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_bbtb', 0.2, 0.6548, 0.131);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', 54, 0.6793, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_bbu', 0.3, 0.7348, 0.2204);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_tbu', 0.4, 0.6904, 0.2762);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_bbtb', 0.2, 0.6636, 0.1327);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', 55, 0.4337, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_bbu', 0.3, 0.4254, 0.1276);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_tbu', 0.4, 0.451, 0.1804);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_bbtb', 0.2, 0.3782, 0.0756);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', 56, 0.4525, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_bbu', 0.3, 0.4494, 0.1348);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_tbu', 0.4, 0.4722, 0.1889);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_bbtb', 0.2, 0.3942, 0.0788);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', 57, 0.4515, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_bbu', 0.3, 0.4502, 0.1351);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_tbu', 0.4, 0.4632, 0.1853);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_bbtb', 0.2, 0.4056, 0.0811);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', 58, 0.4658, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_bbu', 0.3, 0.4738, 0.1421);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_tbu', 0.4, 0.4634, 0.1854);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_bbtb', 0.2, 0.4416, 0.0883);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', 59, 0.4583, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_bbu', 0.3, 0.4648, 0.1394);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_tbu', 0.4, 0.45, 0.18);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_bbtb', 0.2, 0.4444, 0.0889);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', 60, 0.4496, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_bbu', 0.3, 0.4538, 0.1361);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_tbu', 0.4, 0.4364, 0.1746);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_bbtb', 0.2, 0.4446, 0.0889);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', 61, 0.8247, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_bbu', 0.3, 0.9092, 0.2728);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_tbu', 0.4, 0.8742, 0.3497);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_bbtb', 0.2, 0.7614, 0.1523);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', 62, 0.8145, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_bbu', 0.3, 0.8956, 0.2687);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_tbu', 0.4, 0.862, 0.3448);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_bbtb', 0.2, 0.755, 0.151);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', 63, 0.8125, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_bbu', 0.3, 0.8968, 0.269);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_tbu', 0.4, 0.8466, 0.3386);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_bbtb', 0.2, 0.774, 0.1548);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', 64, 0.8127, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_bbu', 0.3, 0.9002, 0.2701);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_tbu', 0.4, 0.8352, 0.3341);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_bbtb', 0.2, 0.7928, 0.1586);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', 65, 0.8015, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_bbu', 0.3, 0.8858, 0.2657);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_tbu', 0.4, 0.8214, 0.3286);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_bbtb', 0.2, 0.786, 0.1572);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', 66, 0.7916, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_bbu', 0.3, 0.8732, 0.262);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_tbu', 0.4, 0.8096, 0.3238);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_bbtb', 0.2, 0.7788, 0.1558);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', 67, 0.6302, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_bbu', 0.3, 0.6938, 0.2081);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_tbu', 0.4, 0.5878, 0.2351);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_bbtb', 0.2, 0.6848, 0.137);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', 68, 0.6278, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_bbu', 0.3, 0.6902, 0.2071);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_tbu', 0.4, 0.5892, 0.2357);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_bbtb', 0.2, 0.6752, 0.135);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', 69, 0.6203, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_bbu', 0.3, 0.6822, 0.2047);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_tbu', 0.4, 0.5804, 0.2322);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_bbtb', 0.2, 0.6672, 0.1334);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', 70, 0.6172, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_bbu', 0.3, 0.6786, 0.2036);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_tbu', 0.4, 0.5784, 0.2314);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_bbtb', 0.2, 0.6612, 0.1322);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', 71, 0.6119, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_bbu', 0.3, 0.6728, 0.2018);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_tbu', 0.4, 0.5712, 0.2285);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_bbtb', 0.2, 0.6578, 0.1316);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', 72, 0.6192, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_bbu', 0.3, 0.6876, 0.2063);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_tbu', 0.4, 0.5664, 0.2266);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_bbtb', 0.2, 0.6818, 0.1364);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', 73, 0.433, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_bbu', 0.3, 0.4022, 0.1207);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_tbu', 0.4, 0.4906, 0.1962);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_bbtb', 0.2, 0.3306, 0.0661);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', 74, 0.4419, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_bbu', 0.3, 0.4152, 0.1246);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_tbu', 0.4, 0.4904, 0.1962);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_bbtb', 0.2, 0.356, 0.0712);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', 75, 0.4408, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_bbu', 0.3, 0.421, 0.1263);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_tbu', 0.4, 0.4698, 0.1879);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_bbtb', 0.2, 0.383, 0.0766);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', 76, 0.4322, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_bbu', 0.3, 0.4084, 0.1225);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_tbu', 0.4, 0.4614, 0.1846);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_bbtb', 0.2, 0.3756, 0.0751);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', 77, 0.4297, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_bbu', 0.3, 0.4134, 0.124);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_tbu', 0.4, 0.4416, 0.1766);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_bbtb', 0.2, 0.3954, 0.0791);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', 78, 0.4251, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_bbu', 0.3, 0.417, 0.1251);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_tbu', 0.4, 0.4194, 0.1678);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_bbtb', 0.2, 0.411, 0.0822);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', 79, 0.6148, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_bbu', 0.3, 0.683, 0.2049);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_tbu', 0.4, 0.5586, 0.2234);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_bbtb', 0.2, 0.6822, 0.1364);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', 80, 0.5997, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_bbu', 0.3, 0.6794, 0.2038);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_tbu', 0.4, 0.5328, 0.2131);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_bbtb', 0.2, 0.6638, 0.1328);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', 81, 0.6054, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_bbu', 0.3, 0.6722, 0.2017);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_tbu', 0.4, 0.5428, 0.2171);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_bbtb', 0.2, 0.683, 0.1366);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', 82, 0.6062, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_bbu', 0.3, 0.6678, 0.2003);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_tbu', 0.4, 0.5562, 0.2225);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_bbtb', 0.2, 0.667, 0.1334);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', 83, 0.6066, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_bbu', 0.3, 0.6634, 0.199);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_tbu', 0.4, 0.568, 0.2272);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_bbtb', 0.2, 0.6518, 0.1304);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', 84, 0.6158, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_bbu', 0.3, 0.6748, 0.2024);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_tbu', 0.4, 0.5786, 0.2314);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_bbtb', 0.2, 0.6598, 0.132);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', 85, 0.7208, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_bbu', 0.3, 0.8212, 0.2464);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_tbu', 0.4, 0.7286, 0.2914);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_bbtb', 0.2, 0.665, 0.133);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', 86, 0.7767, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_bbu', 0.3, 0.8906, 0.2672);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_tbu', 0.4, 0.7918, 0.3167);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_bbtb', 0.2, 0.7142, 0.1428);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', 87, 0.8052, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_bbu', 0.3, 0.9264, 0.2779);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_tbu', 0.4, 0.816, 0.3264);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_bbtb', 0.2, 0.7542, 0.1508);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', 88, 0.8095, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_bbu', 0.3, 0.9228, 0.2768);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_tbu', 0.4, 0.834, 0.3336);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_bbtb', 0.2, 0.7454, 0.1491);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', 89, 0.8214, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_bbu', 0.3, 0.9356, 0.2807);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_tbu', 0.4, 0.84, 0.336);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_bbtb', 0.2, 0.7738, 0.1548);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', 90, 0.8277, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_bbu', 0.3, 0.9406, 0.2822);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_tbu', 0.4, 0.8398, 0.3359);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_bbtb', 0.2, 0.7982, 0.1596);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'frekuensi_hadir', 0.1, 0.5, 0.05);

-- ==========================================================
-- TIER 6: Rujukan (anak kategori risiko tinggi)
-- ==========================================================

-- Rujukan untuk: Zahra | Status: selesai
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '019eb2c7-b1fb-75a4-933f-036eba31771d', 36, 'selesai', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.6998.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-15');

-- Rujukan untuk: Dani | Status: diterima
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', '019eb2c7-b1fb-75a4-933f-036814d054d9', '019eb2c7-b1fb-75a4-933f-036eba31771d', 42, 'diterima', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7515.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-16');

-- Rujukan untuk: Bagas | Status: diajukan
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', NULL, 54, 'diajukan', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.6793.', NULL, NULL);

-- Rujukan untuk: Adi | Status: diajukan
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', '019eb2c7-b1fb-75a4-933f-036a022e7136', NULL, 66, 'diajukan', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7916.', NULL, NULL);

-- Rujukan untuk: Bimo | Status: ditolak
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', '019eb2c7-b1fb-75a4-933f-036cdcf0fa8e', '019eb2c7-b1fb-75a4-933f-036eba31771d', 90, 'ditolak', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.8277.', 'Kondisi anak tidak memenuhi kriteria rujukan saat ini. Disarankan kontrol rutin di posyandu setiap bulan.', '2026-05-19');

-- ==========================================================
-- TIER 6: AI Insight — teks statis (1 per anak)
-- ==========================================================

-- Rizki (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-0385bc32ba20', 6, '[Seeder] Anak: Rizki, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Rafi (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-0386d1de59b5', 12, '[Seeder] Anak: Rafi, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Nayla (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-0387e58e6013', 18, '[Seeder] Anak: Nayla, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Hasan (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-03881eb250f7', 24, '[Seeder] Anak: Hasan, JK: L, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Husein (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-03899caa2ad0', 30, '[Seeder] Anak: Husein, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Zahra (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-038adb4873be', 36, '[Seeder] Anak: Zahra, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Dani (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-038b8a55648d', 42, '[Seeder] Anak: Dani, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- Dina (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-038ceaafce2f', 48, '[Seeder] Anak: Dina, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Bagas (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-038da00d94cf', 54, '[Seeder] Anak: Bagas, JK: L, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Putri (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-038e46a47b66', 60, '[Seeder] Anak: Putri, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Adi (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-038fbf879038', 66, '[Seeder] Anak: Adi, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- Ayu (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-0390f236aeb5', 72, '[Seeder] Anak: Ayu, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Fauzi (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-039179df6786', 78, '[Seeder] Anak: Fauzi, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Bella (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-0392928509e2', 84, '[Seeder] Anak: Bella, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Bimo (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2c7-b1fb-75a4-933f-039375d03c8a', 90, '[Seeder] Anak: Bimo, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- ==========================================================
-- TIER 7: Notifikasi
-- Jadwal ID 6 = Posyandu Juni 2026 (jadwal mendatang pertama)
-- ==========================================================

-- Notifikasi jadwal posyandu Juni 2026
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-037275a3f476', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-0374015336ca', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-037642046d23', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-0378e4787315', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-037ad34acd5b', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-037cef0f981d', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-037e927572f5', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-03809f5aaee0', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-03826f2ca24b', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-0384ce6c334b', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);

-- Notifikasi status rujukan
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-0378e4787315', 'Rujukan Selesai Ditangani', 'Proses rujukan anak Anda telah selesai ditangani. Terus pantau tumbuh kembang si kecil dan rutin bawa ke posyandu setiap bulan agar kondisi tetap terpantau.', 'rujukan', TRUE, '2026-06-01 10:00:00', NULL, 1);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-037ad34acd5b', 'Rujukan Diterima Puskesmas', 'Rujukan anak Anda telah diterima oleh puskesmas. Silakan datang untuk menjalani pemeriksaan dan program intervensi gizi yang telah disiapkan.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 2);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-037cef0f981d', 'Rujukan Baru Telah Diajukan', 'Kader telah mengajukan rujukan untuk anak Anda ke puskesmas. Harap segera datang ke puskesmas terdekat untuk pemeriksaan dan penanganan lebih lanjut.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 3);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-03809f5aaee0', 'Rujukan Baru Telah Diajukan', 'Kader telah mengajukan rujukan untuk anak Anda ke puskesmas. Harap segera datang ke puskesmas terdekat untuk pemeriksaan dan penanganan lebih lanjut.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 4);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2c7-b1fb-75a4-933f-0384ce6c334b', 'Update Status Rujukan', 'Status rujukan anak Anda telah diperbarui. Silakan hubungi kader atau puskesmas untuk informasi lebih lanjut.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 5);
