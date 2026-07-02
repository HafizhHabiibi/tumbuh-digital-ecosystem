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
    ('019f23b5-2b91-747a-bc15-646a3bc57de6', 'meongterbang22@gmail.com', '$2b$10$x18dGdRvp8n8qtzXN0aScuiN9ydLJmVODPpan8/skTl/0j57xxHxy', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019f23b5-2b93-7def-a105-54bc79b5b32a', '019f23b5-2b91-747a-bc15-646a3bc57de6', 'Riri Andayani', '081234567890');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54bd293b4ad3', 'budi.kader@gmail.com', '$2b$10$dqevNGr/c6lloo3ImiqOk.1K9blhVbbqky40irfIgAvqCC38kuceO', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019f23b5-2b93-7def-a105-54be5f1f6335', '019f23b5-2b93-7def-a105-54bd293b4ad3', 'Budi Santoso', '082345678901');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54bfde182ba3', 'sari.kader@gmail.com', '$2b$10$2B3nJfA0E7Tu2wQllX9HxOaersMyObOIapzmjqpbEeXPAdw7km4lS', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019f23b5-2b93-7def-a105-54c08a740f23', '019f23b5-2b93-7def-a105-54bfde182ba3', 'Sari Dewi', '083456789012');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54c1df06a1df', 'bullmini123@gmail.com', '$2b$10$a23PhZh0MmC7Twe/1XqQh.HxHifXaEu4L6xfcl48oApTdM5sYzxfi', 'puskesmas', TRUE);
INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('019f23b5-2b93-7def-a105-54c2c44fdaef', '019f23b5-2b93-7def-a105-54c1df06a1df', 'Ciko Wijaya', 'Bidan', '081234567891');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54c3e75eb96e', 'hana.pertiwi@gmail.com', '$2b$10$hEDCvlhob9FpKrA/tQMwyeedSLbF8rQ6KezvWjYKWjQeU6DxZoiyK', 'puskesmas', TRUE);
INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('019f23b5-2b93-7def-a105-54c43030297e', '019f23b5-2b93-7def-a105-54c3e75eb96e', 'dr. Hana Pertiwi', 'Dokter', '084567890123');

-- ==========================================================
-- TIER 2: Orang Tua
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54c58d39126d', 'aminah.kusuma@gmail.com', '$2b$10$0yAJCd3GJGnrq4eYWTQ8OOQ.v6DwUBaCbrkyAlMbibCaAWFSp1hx.', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54c69bbe4dd0', '019f23b5-2b93-7def-a105-54c58d39126d', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'Aminah Kusuma', '081111111101', 'Jl. Mawar No. 12 RT 01 RW 05', '3201010101870001');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54c7baef50e0', 'dewi.susanti@gmail.com', '$2b$10$aNgyEA.49B8.qD7H1v7c9O.AyD8/K8wkvXoEtq.b.Hvv4lI.kbsIO', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54c8bc6b0f7e', '019f23b5-2b93-7def-a105-54c7baef50e0', '019f23b5-2b93-7def-a105-54be5f1f6335', 'Dewi Susanti', '081111111102', 'Jl. Melati No. 5 RT 02 RW 05', '3201010201890002');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54c99ff9e89e', 'fatimah.rahman@gmail.com', '$2b$10$i.KmgLDf4GsCZJ1dyNvUgulpGJq2lRl.ZxX6ngLMhxmOU69ggR5xm', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54ca5cd4f6c1', '019f23b5-2b93-7def-a105-54c99ff9e89e', '019f23b5-2b93-7def-a105-54c08a740f23', 'Fatimah Rahman', '081111111103', 'Jl. Anggrek No. 8 RT 03 RW 05', '3201010301850003');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54cb57f41276', 'siti.rahayu@gmail.com', '$2b$10$Z1nyLAmj9GRoCBJzsuOGDeBlV8SKllv7/kaOecfkreGyJuLD3xrVe', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54cc28addaaf', '019f23b5-2b93-7def-a105-54cb57f41276', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'Siti Rahayu', '081111111104', 'Jl. Dahlia No. 3 RT 01 RW 05', '3201010401900004');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54cd68038c66', 'kartini.wulandari@gmail.com', '$2b$10$y7FLSWD6mklPoq5VltpaK.oB/SLBDtOXNHZemd5lqyBbeIPHYEJFq', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54ceb1cb773d', '019f23b5-2b93-7def-a105-54cd68038c66', '019f23b5-2b93-7def-a105-54be5f1f6335', 'Kartini Wulandari', '081111111105', 'Jl. Kenanga No. 7 RT 04 RW 05', '3201010501880005');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54cf8dacc869', 'rahayu.lestari@gmail.com', '$2b$10$mv7s5DmKTh02oTmYrfNgauSdX1DH89D6OOiDrZyIKCI9dmL5LD8nq', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54d0e6f95c58', '019f23b5-2b93-7def-a105-54cf8dacc869', '019f23b5-2b93-7def-a105-54c08a740f23', 'Rahayu Lestari', '081111111106', 'Jl. Bougenville No. 15 RT 02 RW 05', '3201010601910006');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54d1ced6468e', 'wulan.sari@gmail.com', '$2b$10$e5APKFPFmBHjz4Pbjz7v2O/z6.H4baowgzExWP7/hlopnqxYSH7ma', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54d277d8246d', '019f23b5-2b93-7def-a105-54d1ced6468e', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'Wulan Sari', '081111111107', 'Jl. Cempaka No. 4 RT 03 RW 05', '3201010701920007');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54d338f7ec96', 'lestari.handayani@gmail.com', '$2b$10$ngjusrjFDM5r/6EYLTzd7evq4nbDnW4y2JAmNtySzdjp.BJsdEa/a', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54d42a0d1277', '019f23b5-2b93-7def-a105-54d338f7ec96', '019f23b5-2b93-7def-a105-54be5f1f6335', 'Lestari Handayani', '081111111108', 'Jl. Flamboyan No. 9 RT 05 RW 05', '3201010801860008');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54d5b77ab95b', 'nuraini.putri@gmail.com', '$2b$10$qDhiGVEf.2g33OKNQPAutuhltMPziHQaNL9FCneYHG397Jw3JYLqi', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54d61d6c1553', '019f23b5-2b93-7def-a105-54d5b77ab95b', '019f23b5-2b93-7def-a105-54c08a740f23', 'Nuraini Putri', '081111111109', 'Jl. Kamboja No. 2 RT 01 RW 05', '3201010901930009');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019f23b5-2b93-7def-a105-54d71810ec7f', 'sumiati.wahyu@gmail.com', '$2b$10$KrnFdfAqr/io3O9IKvqnPuLAOLJMzDl00Da3qG6Gn6fVX5xptZf2O', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019f23b5-2b93-7def-a105-54d8e299873f', '019f23b5-2b93-7def-a105-54d71810ec7f', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'Sumiati Wahyu', '081111111110', 'Jl. Teratai No. 6 RT 04 RW 05', '3201011001870010');

-- ==========================================================
-- TIER 2: Jadwal Posyandu (5 lampau + 3 mendatang)
-- ==========================================================

INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-01-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Januari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-02-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Februari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54be5f1f6335', '2026-03-03', '08:30', '11:30', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Maret 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54be5f1f6335', '2026-04-03', '08:00', '12:00', 'Puskesmas Pembantu Cempaka', 'Posyandu + Pemberian Vitamin A Massal');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54c08a740f23', '2026-05-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Mei 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-06-03', '08:30', '12:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juni 2026 - Pembagian PMT');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54be5f1f6335', '2026-07-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juli 2026');

-- ==========================================================
-- TIER 3: Anak (15 anak)
-- ==========================================================

INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54c69bbe4dd0', 'Rizki', 'L', '2025-06-17', '3201011234560001');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54c69bbe4dd0', 'Rafi', 'L', '2023-10-15', '3201011234560002');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54c8bc6b0f7e', 'Nayla', 'P', '2025-10-22', '3201011234560003');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54ca5cd4f6c1', 'Hasan', 'L', '2024-06-03', '3201011234560004');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54ca5cd4f6c1', 'Husein', 'L', '2025-12-03', '3201011234560005');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54cc28addaaf', 'Zahra', 'P', '2024-12-08', '3201011234560006');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54ceb1cb773d', 'Dani', 'L', '2023-12-19', '3201011234560007');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54ceb1cb773d', 'Dina', 'P', '2025-03-14', '3201011234560008');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54d0e6f95c58', 'Bagas', 'L', '2024-10-25', '3201011234560009');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54d277d8246d', 'Putri', 'P', '2025-08-07', '3201011234560010');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54d42a0d1277', 'Adi', 'L', '2023-06-20', '3201011234560011');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54d42a0d1277', 'Ayu', 'P', '2024-08-16', '3201011234560012');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54d61d6c1553', 'Fauzi', 'L', '2025-04-09', '3201011234560013');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54d8e299873f', 'Bella', 'P', '2024-02-13', '3201011234560014');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54d8e299873f', 'Bimo', 'L', '2025-09-21', '3201011234560015');

-- ==========================================================
-- TIER 4: Pengukuran (6 titik historis per anak = 90 total)
-- Z-score dihitung otomatis menggunakan WHO tables
-- ==========================================================

-- Anak: Rizki (L, lahir 2025-06-17, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-01-03', 8.8, 71.5, 43, 13.5, 0.714, 1.385, 0.056, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-02-03', 9.1, 72.8, 43.3, 13.6, 0.643, 1.267, 0.075, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-03-03', 9.4, 74, 43.7, 13.8, 0.646, 1.209, 0.132, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-04-03', 9.6, 75.3, 44, 13.9, 0.555, 1.168, 0.045, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-05-03', 9.9, 76.5, 44.3, 14.1, 0.584, 1.117, 0.121, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-06-03', 10.2, 77.8, 44.6, 14.2, 0.617, 1.113, 0.183, 'normal');

-- Anak: Rafi (L, lahir 2023-10-15, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-01-03', 14.2, 93.5, NULL, NULL, 0.982, 1.297, 0.44, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-02-03', 14.4, 94.2, NULL, NULL, 0.966, 1.24, 0.464, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-03-03', 14.6, 94.9, NULL, NULL, 0.964, 1.214, 0.486, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-04-03', 14.8, 95.5, NULL, NULL, 0.953, 1.142, 0.525, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-05-03', 15, 96.2, NULL, NULL, 0.948, 1.115, 0.541, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-06-03', 15.2, 96.9, NULL, NULL, 0.942, 1.089, 0.552, 'normal');

-- Anak: Nayla (P, lahir 2025-10-22, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-01-03', 6.6, 62.5, 37, 11.8, 1.554, 2.106, 0.175, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-02-03', 7, 64.4, 38.5, 12.3, 1.12, 1.715, 0.089, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-03-03', 7.4, 66.3, 40, 12.7, 0.943, 1.626, 0.038, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-04-03', 7.8, 68.2, 41.5, 13.1, 0.835, 1.596, 0.018, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-05-03', 8.2, 70.1, 43, 13.5, 0.819, 1.676, 0.022, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-06-03', 8.6, 72, 43.3, 13.6, 0.846, 1.792, 0.041, 'normal');

-- Anak: Hasan (L, lahir 2024-06-03, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-01-03', 8.8, 80.5, 47.3, 15.3, -2.113, -0.999, -2.245, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-02-03', 9, 81.2, 47.6, 15.5, -2.071, -1.081, -2.12, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-03-03', 9.2, 81.9, 48, 15.6, -2.012, -1.112, -2.008, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-04-03', 9.5, 82.7, 48.3, 15.7, -1.878, -1.139, -1.796, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-05-03', 9.7, 83.4, 48.6, 15.9, -1.832, -1.172, -1.71, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-06-03', 9.9, 84.1, NULL, NULL, -1.796, -0.991, -1.635, 'normal');

-- Anak: Husein (L, lahir 2025-12-03, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-01-03', 5.2, 57.5, 35.5, 11.4, 1.144, 1.421, -0.163, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-02-03', 5.9, 60.2, 37, 11.8, 0.423, 0.825, -0.295, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-03-03', 6.6, 62.9, 38.5, 12.3, 0.35, 0.796, -0.28, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-04-03', 7.4, 65.6, 40, 12.7, 0.504, 0.845, -0.015, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-05-03', 8.1, 68.3, 41.5, 13.1, 0.712, 1.178, 0.096, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-06-03', 8.8, 71, 43, 13.5, 0.956, 1.585, 0.211, 'normal');

-- Anak: Zahra (P, lahir 2024-12-08, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-01-03', 7.3, 71, 45, 14.3, -1.873, -1.542, -1.546, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-02-03', 7.5, 72.1, 45.3, 14.5, -1.846, -1.54, -1.538, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-03-03', 7.7, 73.2, 45.6, 14.6, -1.802, -1.495, -1.525, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-04-03', 7.8, 74.3, 46, 14.8, -1.883, -1.47, -1.654, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-05-03', 8, 75.4, 46.3, 14.9, -1.845, -1.422, -1.625, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-06-03', 8.2, 76.5, 46.6, 15, -1.818, -1.385, -1.592, 'normal');

-- Anak: Dani (L, lahir 2023-12-19, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-01-03', 9.3, 82.5, NULL, NULL, -2.413, -1.639, -2.018, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-02-03', 9.5, 83.4, NULL, NULL, -2.357, -1.591, -2.165, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-03-03', 9.7, 84.3, NULL, NULL, -2.291, -1.52, -2.145, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-04-03', 9.8, 85.2, NULL, NULL, -2.325, -1.468, -2.266, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-05-03', 10, 86.1, NULL, NULL, -2.265, -1.404, -2.256, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-06-03', 10.2, 87, NULL, NULL, -2.208, -1.344, -2.246, 'kurang');

-- Anak: Dina (P, lahir 2025-03-14, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-01-03', 9.3, 74, 44, 13.9, 0.827, 1.2, 0.41, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-02-03', 9.5, 75.2, 44.3, 14.1, 0.759, 1.118, 0.371, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-03-03', 9.8, 76.4, 44.6, 14.2, 0.812, 1.115, 0.452, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-04-03', 10, 77.6, 45, 14.3, 0.767, 1.073, 0.421, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-05-03', 10.3, 78.8, 45.3, 14.5, 0.815, 1.067, 0.491, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-06-03', 10.5, 80, 45.6, 14.6, 0.781, 1.056, 0.443, 'normal');

-- Anak: Bagas (L, lahir 2024-10-25, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-01-03', 8.5, 76, 45.6, 14.6, -1.616, -0.951, -1.632, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-02-03', 8.7, 76.8, 46, 14.8, -1.596, -1.055, -1.537, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-03-03', 8.9, 77.6, 46.3, 14.9, -1.552, -1.096, -1.441, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-04-03', 9.1, 78.5, 46.6, 15, -1.526, -1.127, -1.368, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-05-03', 9.3, 79.3, 47, 15.2, -1.495, -1.177, -1.274, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-06-03', 9.4, 80.1, 47.3, 15.3, -1.56, -1.22, -1.318, 'normal');

-- Anak: Putri (P, lahir 2025-08-07, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-01-03', 7.6, 66.5, 40, 12.7, 0.848, 1.212, 0.264, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-02-03', 7.9, 68, 41.5, 13.1, 0.682, 1.06, 0.217, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-03-03', 8.2, 69.5, 43, 13.5, 0.637, 1.071, 0.189, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-04-03', 8.4, 71, 43.3, 13.6, 0.494, 1.038, 0.044, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-05-03', 8.7, 72.5, 43.7, 13.8, 0.501, 1.07, 0.042, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-06-03', 9, 74, 44, 13.9, 0.522, 1.107, 0.049, 'normal');

-- Anak: Adi (L, lahir 2023-06-20, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-01-03', 10, 84.5, NULL, NULL, -2.488, -2.271, -1.807, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-02-03', 10.2, 85.3, NULL, NULL, -2.423, -2.217, -1.775, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-03-03', 10.3, 86.1, NULL, NULL, -2.43, -2.142, -1.87, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-04-03', 10.4, 86.9, NULL, NULL, -2.447, -2.084, -1.964, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-05-03', 10.6, 87.7, NULL, NULL, -2.379, -2.021, -1.93, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-06-03', 10.8, 88.5, NULL, NULL, -2.315, -1.961, -1.894, 'kurang');

-- Anak: Ayu (P, lahir 2024-08-16, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-01-03', 8.4, 77, 46.3, 14.9, -1.393, -0.788, -1.424, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-02-03', 8.6, 78, 46.6, 15, -1.375, -0.798, -1.376, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-03-03', 8.8, 79, 47, 15.2, -1.339, -0.764, -1.336, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-04-03', 9, 80, 47.3, 15.3, -1.321, -0.756, -1.306, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-05-03', 9.2, 81, 47.6, 15.5, -1.296, -0.729, -1.289, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-06-03', 9.3, 82, 48, 15.6, -1.369, -0.706, -1.409, 'normal');

-- Anak: Fauzi (L, lahir 2025-04-09, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-01-03', 9.8, 75, 43.7, 13.8, 0.935, 1.451, 0.369, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-02-03', 10, 76.3, 44, 13.9, 0.845, 1.414, 0.289, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-03-03', 10.2, 77.7, 44.3, 14.1, 0.794, 1.483, 0.205, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-04-03', 10.5, 79, 44.6, 14.2, 0.825, 1.481, 0.271, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-05-03', 10.7, 80.4, 45, 14.3, 0.78, 1.545, 0.202, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54bc79b5b32a', '2026-06-03', 10.9, 81.8, 45.3, 14.5, 0.741, 1.613, 0.12, 'normal');

-- Anak: Bella (P, lahir 2024-02-13, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-01-03', 9.5, 83, 48.3, 15.7, -1.364, -0.703, -1.411, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-02-03', 9.7, 83.6, 48.6, 15.9, -1.346, -0.643, -1.319, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-03-03', 9.9, 84.2, NULL, NULL, -1.312, -0.63, -1.234, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-04-03', 10.1, 84.8, NULL, NULL, -1.292, -0.701, -1.335, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-05-03', 10.3, 85.4, NULL, NULL, -1.27, -0.761, -1.259, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54be5f1f6335', '2026-06-03', 10.4, 86, NULL, NULL, -1.33, -0.819, -1.299, 'normal');

-- Anak: Bimo (L, lahir 2025-09-21, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-01-03', 5.5, 60.5, 38.5, 12.3, -1.598, -0.944, -1.325, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-02-03', 5.7, 61.8, 40, 12.7, -2.078, -1.418, -1.571, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-03-03', 5.9, 63.1, 41.5, 13.1, -2.325, -1.609, -1.771, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-04-03', 6.2, 64.4, 43, 13.5, -2.375, -1.771, -1.727, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-05-03', 6.4, 65.7, 43.3, 13.6, -2.473, -1.826, -1.869, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54c08a740f23', '2026-06-03', 6.6, 67, 43.7, 13.8, -2.532, -1.861, -1.991, 'kurang');

-- ==========================================================
-- TIER 4: Riwayat Pemberian Vitamin A, Obat Cacing & PMT
-- ==========================================================

-- Rizki (usia: 11 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', '019f23b5-2b93-7def-a105-54be5f1f6335', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Rafi (usia: 31 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-03', NULL);

-- Nayla (usia: 7 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', '019f23b5-2b93-7def-a105-54be5f1f6335', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Hasan (usia: 24 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-03', NULL);

-- Husein (usia: 6 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', '019f23b5-2b93-7def-a105-54be5f1f6335', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Zahra (usia: 17 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Dani (usia: 29 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-03', NULL);

-- Dina (usia: 14 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Bagas (usia: 19 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Putri (usia: 9 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', '019f23b5-2b93-7def-a105-54be5f1f6335', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Adi (usia: 35 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-03', NULL);

-- Ayu (usia: 21 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Fauzi (usia: 13 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- Bella (usia: 27 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54be5f1f6335', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', '019f23b5-2b93-7def-a105-54c08a740f23', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-03', NULL);

-- Bimo (usia: 8 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54bc79b5b32a', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54be5f1f6335', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-03', NULL);

-- ==========================================================
-- TIER 5: SAW Result + Detail (1 per pengukuran = 90 total)
-- ==========================================================

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', 1, 0.2541, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_bbu', 0.3, 0.2572, 0.0772);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_tbu', 0.4, 0.123, 0.0492);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_bbtb', 0.2, 0.3888, 0.0778);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', 2, 0.2671, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_bbu', 0.3, 0.2714, 0.0814);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_tbu', 0.4, 0.1466, 0.0586);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_bbtb', 0.2, 0.385, 0.077);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', 3, 0.2692, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_bbu', 0.3, 0.2708, 0.0812);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_tbu', 0.4, 0.1582, 0.0633);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_bbtb', 0.2, 0.3736, 0.0747);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', 4, 0.2815, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_bbu', 0.3, 0.289, 0.0867);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_tbu', 0.4, 0.1664, 0.0666);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_bbtb', 0.2, 0.391, 0.0782);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', 5, 0.2808, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_bbu', 0.3, 0.2832, 0.085);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_tbu', 0.4, 0.1766, 0.0706);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_bbtb', 0.2, 0.3758, 0.0752);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', 6, 0.2766, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_bbu', 0.3, 0.2766, 0.083);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_tbu', 0.4, 0.1774, 0.071);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_bbtb', 0.2, 0.3634, 0.0727);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', 7, 0.2297, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_bbu', 0.3, 0.2036, 0.0611);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_tbu', 0.4, 0.1406, 0.0562);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_bbtb', 0.2, 0.312, 0.0624);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', 8, 0.2343, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_bbu', 0.3, 0.2068, 0.062);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_tbu', 0.4, 0.152, 0.0608);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_bbtb', 0.2, 0.3072, 0.0614);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', 9, 0.2356, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_bbu', 0.3, 0.2072, 0.0622);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_tbu', 0.4, 0.1572, 0.0629);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_bbtb', 0.2, 0.3028, 0.0606);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', 10, 0.2405, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_bbu', 0.3, 0.2094, 0.0628);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_tbu', 0.4, 0.1716, 0.0686);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_bbtb', 0.2, 0.295, 0.059);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', 11, 0.2423, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_bbu', 0.3, 0.2104, 0.0631);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_tbu', 0.4, 0.177, 0.0708);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_bbtb', 0.2, 0.2918, 0.0584);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', 12, 0.2443, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_bbu', 0.3, 0.2116, 0.0635);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_tbu', 0.4, 0.1822, 0.0729);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_bbtb', 0.2, 0.2896, 0.0579);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', 13, 0.1498, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_bbu', 0.3, 0.0892, 0.0268);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_tbu', 0.4, 0, 0);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_bbtb', 0.2, 0.365, 0.073);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', 14, 0.202, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_bbu', 0.3, 0.176, 0.0528);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_tbu', 0.4, 0.057, 0.0228);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_bbtb', 0.2, 0.3822, 0.0764);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', 15, 0.2218, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_bbu', 0.3, 0.2114, 0.0634);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_tbu', 0.4, 0.0748, 0.0299);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_bbtb', 0.2, 0.3924, 0.0785);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', 16, 0.2315, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_bbu', 0.3, 0.233, 0.0699);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_tbu', 0.4, 0.0808, 0.0323);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_bbtb', 0.2, 0.3964, 0.0793);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', 17, 0.2259, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_bbu', 0.3, 0.2362, 0.0709);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_tbu', 0.4, 0.0648, 0.0259);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_bbtb', 0.2, 0.3956, 0.0791);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', 18, 0.2142, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_bbu', 0.3, 0.2308, 0.0692);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_tbu', 0.4, 0.0416, 0.0166);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_bbtb', 0.2, 0.3918, 0.0784);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', 19, 0.7065, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_bbu', 0.3, 0.8226, 0.2468);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_tbu', 0.4, 0.5998, 0.2399);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_bbtb', 0.2, 0.849, 0.1698);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', 20, 0.7055, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_bbu', 0.3, 0.8142, 0.2443);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_tbu', 0.4, 0.6162, 0.2465);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_bbtb', 0.2, 0.824, 0.1648);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', 21, 0.7, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_bbu', 0.3, 0.8024, 0.2407);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_tbu', 0.4, 0.6224, 0.249);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_bbtb', 0.2, 0.8016, 0.1603);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', 22, 0.6856, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_bbu', 0.3, 0.7756, 0.2327);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_tbu', 0.4, 0.6278, 0.2511);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_bbtb', 0.2, 0.7592, 0.1518);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', 23, 0.6821, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_bbu', 0.3, 0.7664, 0.2299);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_tbu', 0.4, 0.6344, 0.2538);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_bbtb', 0.2, 0.742, 0.1484);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', 24, 0.6624, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_bbu', 0.3, 0.7592, 0.2278);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_tbu', 0.4, 0.5982, 0.2393);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_bbtb', 0.2, 0.727, 0.1454);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', 25, 0.2342, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_bbu', 0.3, 0.1712, 0.0514);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_tbu', 0.4, 0.1158, 0.0463);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_bbtb', 0.2, 0.4326, 0.0865);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', 26, 0.3304, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_bbu', 0.3, 0.3154, 0.0946);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_tbu', 0.4, 0.235, 0.094);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_bbtb', 0.2, 0.459, 0.0918);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', 27, 0.3365, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_bbu', 0.3, 0.33, 0.099);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_tbu', 0.4, 0.2408, 0.0963);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_bbtb', 0.2, 0.456, 0.0912);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', 28, 0.3128, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_bbu', 0.3, 0.2992, 0.0898);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_tbu', 0.4, 0.231, 0.0924);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_bbtb', 0.2, 0.403, 0.0806);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', 29, 0.2692, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_bbu', 0.3, 0.2576, 0.0773);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_tbu', 0.4, 0.1644, 0.0658);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_bbtb', 0.2, 0.3808, 0.0762);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', 30, 0.2174, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_bbu', 0.3, 0.2088, 0.0626);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_tbu', 0.4, 0.083, 0.0332);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_bbtb', 0.2, 0.3578, 0.0716);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', 31, 0.7076, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_bbu', 0.3, 0.7746, 0.2324);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_tbu', 0.4, 0.7084, 0.2834);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_bbtb', 0.2, 0.7092, 0.1418);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', 32, 0.7055, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_bbu', 0.3, 0.7692, 0.2308);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_tbu', 0.4, 0.708, 0.2832);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_bbtb', 0.2, 0.7076, 0.1415);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', 33, 0.6987, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_bbu', 0.3, 0.7604, 0.2281);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_tbu', 0.4, 0.699, 0.2796);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_bbtb', 0.2, 0.705, 0.141);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', 34, 0.7067, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_bbu', 0.3, 0.7766, 0.233);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_tbu', 0.4, 0.694, 0.2776);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_bbtb', 0.2, 0.7308, 0.1462);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', 35, 0.6995, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_bbu', 0.3, 0.769, 0.2307);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_tbu', 0.4, 0.6844, 0.2738);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_bbtb', 0.2, 0.725, 0.145);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', 36, 0.6936, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_bbu', 0.3, 0.7636, 0.2291);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_tbu', 0.4, 0.677, 0.2708);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_bbtb', 0.2, 0.7184, 0.1437);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', 37, 0.7666, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_bbu', 0.3, 0.8826, 0.2648);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_tbu', 0.4, 0.7278, 0.2911);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_bbtb', 0.2, 0.8036, 0.1607);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', 38, 0.7653, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_bbu', 0.3, 0.8714, 0.2614);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_tbu', 0.4, 0.7182, 0.2873);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_bbtb', 0.2, 0.833, 0.1666);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', 39, 0.7549, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_bbu', 0.3, 0.8582, 0.2575);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_tbu', 0.4, 0.704, 0.2816);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_bbtb', 0.2, 0.829, 0.1658);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', 40, 0.7576, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_bbu', 0.3, 0.865, 0.2595);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_tbu', 0.4, 0.6936, 0.2774);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_bbtb', 0.2, 0.8532, 0.1706);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', 41, 0.7485, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_bbu', 0.3, 0.853, 0.2559);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_tbu', 0.4, 0.6808, 0.2723);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_bbtb', 0.2, 0.8512, 0.1702);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', 42, 0.7398, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_bbu', 0.3, 0.8416, 0.2525);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_tbu', 0.4, 0.6688, 0.2675);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_bbtb', 0.2, 0.8492, 0.1698);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', 43, 0.248, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_bbu', 0.3, 0.2346, 0.0704);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_tbu', 0.4, 0.16, 0.064);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_bbtb', 0.2, 0.318, 0.0636);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', 44, 0.2602, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_bbu', 0.3, 0.2482, 0.0745);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_tbu', 0.4, 0.1764, 0.0706);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_bbtb', 0.2, 0.3258, 0.0652);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', 45, 0.254, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_bbu', 0.3, 0.2376, 0.0713);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_tbu', 0.4, 0.177, 0.0708);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_bbtb', 0.2, 0.3096, 0.0619);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', 46, 0.2613, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_bbu', 0.3, 0.2466, 0.074);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_tbu', 0.4, 0.1854, 0.0742);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_bbtb', 0.2, 0.3158, 0.0632);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', 47, 0.2561, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_bbu', 0.3, 0.237, 0.0711);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_tbu', 0.4, 0.1866, 0.0746);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_bbtb', 0.2, 0.3018, 0.0604);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', 48, 0.2609, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_bbu', 0.3, 0.2438, 0.0731);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_tbu', 0.4, 0.1888, 0.0755);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_bbtb', 0.2, 0.3114, 0.0623);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', 49, 0.6483, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_bbu', 0.3, 0.7232, 0.217);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_tbu', 0.4, 0.5902, 0.2361);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_bbtb', 0.2, 0.7264, 0.1453);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', 50, 0.6516, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_bbu', 0.3, 0.7192, 0.2158);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_tbu', 0.4, 0.611, 0.2444);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_bbtb', 0.2, 0.7074, 0.1415);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', 51, 0.6484, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_bbu', 0.3, 0.7104, 0.2131);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_tbu', 0.4, 0.6192, 0.2477);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_bbtb', 0.2, 0.6882, 0.1376);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', 52, 0.6464, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_bbu', 0.3, 0.7052, 0.2116);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_tbu', 0.4, 0.6254, 0.2502);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_bbtb', 0.2, 0.6736, 0.1347);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', 53, 0.6448, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_bbu', 0.3, 0.699, 0.2097);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_tbu', 0.4, 0.6354, 0.2542);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_bbtb', 0.2, 0.6548, 0.131);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', 54, 0.6539, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_bbu', 0.3, 0.712, 0.2136);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_tbu', 0.4, 0.644, 0.2576);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_bbtb', 0.2, 0.6636, 0.1327);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', 55, 0.2516, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_bbu', 0.3, 0.2304, 0.0691);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_tbu', 0.4, 0.1576, 0.063);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_bbtb', 0.2, 0.3472, 0.0694);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', 56, 0.2756, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_bbu', 0.3, 0.2636, 0.0791);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_tbu', 0.4, 0.188, 0.0752);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_bbtb', 0.2, 0.3566, 0.0713);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', 57, 0.2785, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_bbu', 0.3, 0.2726, 0.0818);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_tbu', 0.4, 0.1858, 0.0743);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_bbtb', 0.2, 0.3622, 0.0724);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', 58, 0.2956, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_bbu', 0.3, 0.3012, 0.0904);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_tbu', 0.4, 0.1924, 0.077);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_bbtb', 0.2, 0.3912, 0.0782);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', 59, 0.2927, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_bbu', 0.3, 0.2998, 0.0899);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_tbu', 0.4, 0.186, 0.0744);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_bbtb', 0.2, 0.3916, 0.0783);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', 60, 0.2882, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_bbu', 0.3, 0.2956, 0.0887);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_tbu', 0.4, 0.1786, 0.0714);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_bbtb', 0.2, 0.3902, 0.078);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', 61, 0.8132, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_bbu', 0.3, 0.8976, 0.2693);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_tbu', 0.4, 0.8542, 0.3417);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_bbtb', 0.2, 0.7614, 0.1523);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', 62, 0.8037, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_bbu', 0.3, 0.8846, 0.2654);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_tbu', 0.4, 0.8434, 0.3374);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_bbtb', 0.2, 0.755, 0.151);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', 63, 0.802, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_bbu', 0.3, 0.886, 0.2658);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_tbu', 0.4, 0.8284, 0.3314);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_bbtb', 0.2, 0.774, 0.1548);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', 64, 0.8021, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_bbu', 0.3, 0.8894, 0.2668);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_tbu', 0.4, 0.8168, 0.3267);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_bbtb', 0.2, 0.7928, 0.1586);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', 65, 0.7916, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_bbu', 0.3, 0.8758, 0.2627);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_tbu', 0.4, 0.8042, 0.3217);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_bbtb', 0.2, 0.786, 0.1572);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', 66, 0.7815, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_bbu', 0.3, 0.863, 0.2589);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_tbu', 0.4, 0.7922, 0.3169);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_bbtb', 0.2, 0.7788, 0.1558);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', 67, 0.6136, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_bbu', 0.3, 0.6786, 0.2036);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_tbu', 0.4, 0.5576, 0.223);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_bbtb', 0.2, 0.6848, 0.137);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', 68, 0.6114, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_bbu', 0.3, 0.675, 0.2025);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_tbu', 0.4, 0.5596, 0.2238);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_bbtb', 0.2, 0.6752, 0.135);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', 69, 0.6049, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_bbu', 0.3, 0.6678, 0.2003);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_tbu', 0.4, 0.5528, 0.2211);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_bbtb', 0.2, 0.6672, 0.1334);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', 70, 0.602, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_bbu', 0.3, 0.6642, 0.1993);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_tbu', 0.4, 0.5512, 0.2205);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_bbtb', 0.2, 0.6612, 0.1322);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', 71, 0.5976, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_bbu', 0.3, 0.6592, 0.1978);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_tbu', 0.4, 0.5458, 0.2183);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_bbtb', 0.2, 0.6578, 0.1316);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', 72, 0.605, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_bbu', 0.3, 0.6738, 0.2021);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_tbu', 0.4, 0.5412, 0.2165);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_bbtb', 0.2, 0.6818, 0.1364);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', 73, 0.2231, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_bbu', 0.3, 0.213, 0.0639);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_tbu', 0.4, 0.1098, 0.0439);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_bbtb', 0.2, 0.3262, 0.0652);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', 74, 0.2346, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_bbu', 0.3, 0.231, 0.0693);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_tbu', 0.4, 0.1172, 0.0469);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_bbtb', 0.2, 0.3422, 0.0684);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', 75, 0.2355, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_bbu', 0.3, 0.2412, 0.0724);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_tbu', 0.4, 0.1034, 0.0414);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_bbtb', 0.2, 0.359, 0.0718);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', 76, 0.2312, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_bbu', 0.3, 0.235, 0.0705);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_tbu', 0.4, 0.1038, 0.0415);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_bbtb', 0.2, 0.3458, 0.0692);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', 77, 0.2315, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_bbu', 0.3, 0.244, 0.0732);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_tbu', 0.4, 0.091, 0.0364);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_bbtb', 0.2, 0.3596, 0.0719);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', 78, 0.2317, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_bbu', 0.3, 0.2518, 0.0755);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_tbu', 0.4, 0.0774, 0.031);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_bbtb', 0.2, 0.376, 0.0752);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', 79, 0.6045, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_bbu', 0.3, 0.6728, 0.2018);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_tbu', 0.4, 0.5406, 0.2162);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_bbtb', 0.2, 0.6822, 0.1364);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', 80, 0.595, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_bbu', 0.3, 0.6692, 0.2008);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_tbu', 0.4, 0.5286, 0.2114);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_bbtb', 0.2, 0.6638, 0.1328);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', 81, 0.5885, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_bbu', 0.3, 0.6624, 0.1987);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_tbu', 0.4, 0.526, 0.2104);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_bbtb', 0.2, 0.6468, 0.1294);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', 82, 0.597, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_bbu', 0.3, 0.6584, 0.1975);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_tbu', 0.4, 0.5402, 0.2161);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_bbtb', 0.2, 0.667, 0.1334);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', 83, 0.5974, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_bbu', 0.3, 0.654, 0.1962);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_tbu', 0.4, 0.5522, 0.2209);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_bbtb', 0.2, 0.6518, 0.1304);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', 84, 0.6073, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_bbu', 0.3, 0.666, 0.1998);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_tbu', 0.4, 0.5638, 0.2255);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_bbtb', 0.2, 0.6598, 0.132);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', 85, 0.6344, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_bbu', 0.3, 0.7196, 0.2159);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_tbu', 0.4, 0.5888, 0.2355);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_bbtb', 0.2, 0.665, 0.133);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', 86, 0.711, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_bbu', 0.3, 0.8156, 0.2447);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_tbu', 0.4, 0.6836, 0.2734);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_bbtb', 0.2, 0.7142, 0.1428);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', 87, 0.7491, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_bbu', 0.3, 0.865, 0.2595);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_tbu', 0.4, 0.7218, 0.2887);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_bbtb', 0.2, 0.7542, 0.1508);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', 88, 0.7633, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_bbu', 0.3, 0.875, 0.2625);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_tbu', 0.4, 0.7542, 0.3017);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_bbtb', 0.2, 0.7454, 0.1491);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', 89, 0.7792, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_bbu', 0.3, 0.8946, 0.2684);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_tbu', 0.4, 0.7652, 0.3061);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_bbtb', 0.2, 0.7738, 0.1548);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', 90, 0.7904, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_bbu', 0.3, 0.9064, 0.2719);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_tbu', 0.4, 0.7722, 0.3089);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_bbtb', 0.2, 0.7982, 0.1596);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'frekuensi_hadir', 0.1, 0.5, 0.05);

-- ==========================================================
-- TIER 6: Rujukan (anak kategori risiko tinggi)
-- ==========================================================

-- Rujukan untuk: Zahra | Status: selesai
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', '019f23b5-2b93-7def-a105-54c08a740f23', '019f23b5-2b93-7def-a105-54c2c44fdaef', 36, 'selesai', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.6936.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-15');

-- Rujukan untuk: Dani | Status: diterima
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', '019f23b5-2b93-7def-a105-54bc79b5b32a', '019f23b5-2b93-7def-a105-54c2c44fdaef', 42, 'diterima', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7398.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-16');

-- Rujukan untuk: Adi | Status: diajukan
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', '019f23b5-2b93-7def-a105-54be5f1f6335', NULL, 66, 'diajukan', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7815.', NULL, NULL);

-- Rujukan untuk: Bimo | Status: diajukan
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', '019f23b5-2b93-7def-a105-54c08a740f23', NULL, 90, 'diajukan', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7904.', NULL, NULL);

-- ==========================================================
-- TIER 6: AI Insight — teks statis (1 per anak)
-- ==========================================================

-- Rizki (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54d91851e09f', 6, '[Seeder] Anak: Rizki, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Rafi (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54da2f2df72a', 12, '[Seeder] Anak: Rafi, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Nayla (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54db8e25a8e0', 18, '[Seeder] Anak: Nayla, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Hasan (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54dc7e0acc02', 24, '[Seeder] Anak: Hasan, JK: L, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Husein (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54dda12b21a3', 30, '[Seeder] Anak: Husein, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Zahra (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54deb7bd750d', 36, '[Seeder] Anak: Zahra, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Dani (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54df958270b2', 42, '[Seeder] Anak: Dani, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- Dina (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54e00265b6bb', 48, '[Seeder] Anak: Dina, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Bagas (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54e15a45d0f5', 54, '[Seeder] Anak: Bagas, JK: L, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Putri (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54e2b29dc0cf', 60, '[Seeder] Anak: Putri, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Adi (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54e36a7f100d', 66, '[Seeder] Anak: Adi, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- Ayu (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54e415f71cec', 72, '[Seeder] Anak: Ayu, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Fauzi (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54e5b05cfba4', 78, '[Seeder] Anak: Fauzi, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Bella (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54e63f96ed4b', 84, '[Seeder] Anak: Bella, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Bimo (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019f23b5-2b93-7def-a105-54e72110af94', 90, '[Seeder] Anak: Bimo, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- ==========================================================
-- TIER 7: Notifikasi
-- Jadwal ID 7 = Posyandu Juli 2026 (jadwal mendatang = hari demo)
-- ==========================================================

-- Notifikasi jadwal posyandu Juli 2026
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54c69bbe4dd0', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54c8bc6b0f7e', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54ca5cd4f6c1', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54cc28addaaf', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54ceb1cb773d', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54d0e6f95c58', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54d277d8246d', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54d42a0d1277', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54d61d6c1553', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54d8e299873f', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);

-- Notifikasi status rujukan
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54cc28addaaf', 'Rujukan Selesai Ditangani', 'Proses rujukan anak Anda telah selesai ditangani. Terus pantau tumbuh kembang si kecil dan rutin bawa ke posyandu setiap bulan agar kondisi tetap terpantau.', 'rujukan', TRUE, '2026-06-01 10:00:00', NULL, 1);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54ceb1cb773d', 'Rujukan Diterima Puskesmas', 'Rujukan anak Anda telah diterima oleh puskesmas. Silakan datang untuk menjalani pemeriksaan dan program intervensi gizi yang telah disiapkan.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 2);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54d42a0d1277', 'Rujukan Baru Telah Diajukan', 'Kader telah mengajukan rujukan untuk anak Anda ke puskesmas. Harap segera datang ke puskesmas terdekat untuk pemeriksaan dan penanganan lebih lanjut.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 3);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019f23b5-2b93-7def-a105-54d8e299873f', 'Rujukan Baru Telah Diajukan', 'Kader telah mengajukan rujukan untuk anak Anda ke puskesmas. Harap segera datang ke puskesmas terdekat untuk pemeriksaan dan penanganan lebih lanjut.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 4);
