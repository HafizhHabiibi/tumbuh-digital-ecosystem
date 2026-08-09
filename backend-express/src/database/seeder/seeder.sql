USE tumbuh_pp;

-- ==========================================================
-- FULL RESET — Hapus semua data lama (urutan FK terbalik)
-- ==========================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE notifikasi;
TRUNCATE TABLE rujukan;
TRUNCATE TABLE pemberian;
TRUNCATE TABLE pengukuran;
TRUNCATE TABLE anak;
TRUNCATE TABLE jadwal_posyandu;
TRUNCATE TABLE orang_tua;
TRUNCATE TABLE kader;
TRUNCATE TABLE puskesmas;
TRUNCATE TABLE refresh_tokens;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================================
-- TIER 1: Users, Kader, Puskesmas
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d231-7b4c-b65c-03c1f06fe25b', 'meongterbang22@gmail.com', '$2b$10$on8wBlcWByzTl4mkn9YlP.VXiFwEACsoIyqIIzLnhFYzas9IcVX9W', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019fe204-d233-737e-ae03-e0c5d8eadfa5', '019fe204-d231-7b4c-b65c-03c1f06fe25b', 'Riri Andayani', '081234567890');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0c6f58675ee', 'budi.kader@gmail.com', '$2b$10$F8fIV6rWkEvJcGEgvK9xY.v8ACAuuN.72NsGEXhcGjib6PpV5qGo2', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019fe204-d233-737e-ae03-e0c7c598d562', '019fe204-d233-737e-ae03-e0c6f58675ee', 'Budi Santoso', '082345678901');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0c875b7656f', 'sari.kader@gmail.com', '$2b$10$PBNJ32fJrJ8nG74UbMwF8ulhfUILdvtTnLZ6SIv8s4CZz68t1xUau', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019fe204-d233-737e-ae03-e0c909e379e1', '019fe204-d233-737e-ae03-e0c875b7656f', 'Sari Dewi', '083456789012');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0cae204b415', 'bullmini123@gmail.com', '$2b$10$8zOuJuminQ8C7gW3ge35YuX/55GqlSgQbjeL/rGXG.R7rTnpO0ykO', 'puskesmas', TRUE);
INSERT INTO puskesmas (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('019fe204-d233-737e-ae03-e0cbfbadb2fa', '019fe204-d233-737e-ae03-e0cae204b415', 'Ciko Wijaya', 'Bidan', '081234567891');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0cce7ea5c1c', 'hana.pertiwi@gmail.com', '$2b$10$Bu9LaAjEM3PXP9ykIfJ4DukLDwwziWJZZ.4kNE/reZOZOChrsFJyG', 'puskesmas', TRUE);
INSERT INTO puskesmas (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('019fe204-d233-737e-ae03-e0cdb5d54d11', '019fe204-d233-737e-ae03-e0cce7ea5c1c', 'dr. Hana Pertiwi', 'Dokter', '084567890123');

-- ==========================================================
-- TIER 2: Orang Tua
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0ce7176c6bd', 'aminah.kusuma@gmail.com', '$2b$10$BLvHt/iYoNUGuVmID3u0XO5ueR6pZwlOU4y4T4nwrYuezIpTYT6wi', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0cf06d92a34', '019fe204-d233-737e-ae03-e0ce7176c6bd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'Aminah Kusuma', '081111111101', 'Jl. Mawar No. 12 RT 01 RW 05', '3201010101870001');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0d0c6cfa38a', 'dewi.susanti@gmail.com', '$2b$10$0e8csW1jh8oROH3dnt5pZO8VuX5FonZr2YinxOYSaEsOAEdsDwIbS', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0d103eff3db', '019fe204-d233-737e-ae03-e0d0c6cfa38a', '019fe204-d233-737e-ae03-e0c7c598d562', 'Dewi Susanti', '081111111102', 'Jl. Melati No. 5 RT 02 RW 05', '3201010201890002');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0d2707f9674', 'fatimah.rahman@gmail.com', '$2b$10$fx7s0qQD8CeEE7STMMyZLuAq3P1NOoO2q2W8H8VxhQV7X/pXh7U9y', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0d3a14cd7a3', '019fe204-d233-737e-ae03-e0d2707f9674', '019fe204-d233-737e-ae03-e0c909e379e1', 'Fatimah Rahman', '081111111103', 'Jl. Anggrek No. 8 RT 03 RW 05', '3201010301850003');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0d48030ee29', 'siti.rahayu@gmail.com', '$2b$10$wCb2FqP9GjUn1WWJiej.9O0t3aoLMSpDS62todbslTs5tU/AlDkDm', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0d55ae11f61', '019fe204-d233-737e-ae03-e0d48030ee29', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'Siti Rahayu', '081111111104', 'Jl. Dahlia No. 3 RT 01 RW 05', '3201010401900004');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0d6102d5583', 'kartini.wulandari@gmail.com', '$2b$10$YYpCUgguF4fDKujLoE8lBObVny2Psz9T6GpRTSuWRGxdR6c9zUBqS', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0d73b213cb9', '019fe204-d233-737e-ae03-e0d6102d5583', '019fe204-d233-737e-ae03-e0c7c598d562', 'Kartini Wulandari', '081111111105', 'Jl. Kenanga No. 7 RT 04 RW 05', '3201010501880005');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0d8a15a5869', 'rahayu.lestari@gmail.com', '$2b$10$E/XTbdWZB6qhyyvTS21Nl.gHTQ86y0Us4Tf5C/tt/xBJXvV8EbV0.', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0d9ace67237', '019fe204-d233-737e-ae03-e0d8a15a5869', '019fe204-d233-737e-ae03-e0c909e379e1', 'Rahayu Lestari', '081111111106', 'Jl. Bougenville No. 15 RT 02 RW 05', '3201010601910006');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0da2014b647', 'wulan.sari@gmail.com', '$2b$10$hwWCv8c3qtRA8DGnAYQZe.5IDTNQ/i4Ui7P3vAvixoI09T4Q1Qox.', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0db8e480614', '019fe204-d233-737e-ae03-e0da2014b647', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'Wulan Sari', '081111111107', 'Jl. Cempaka No. 4 RT 03 RW 05', '3201010701920007');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0dc84b79edd', 'lestari.handayani@gmail.com', '$2b$10$9BbmJubL7.h1Sfv2usHu9Of425hVhxdLI2coOXN/0.GJl66GtFqNO', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0dd4876a047', '019fe204-d233-737e-ae03-e0dc84b79edd', '019fe204-d233-737e-ae03-e0c7c598d562', 'Lestari Handayani', '081111111108', 'Jl. Flamboyan No. 9 RT 05 RW 05', '3201010801860008');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0de16b713ce', 'nuraini.putri@gmail.com', '$2b$10$nqVL2TpD9xWgJ5tIk7Pw.e9ow1p9XGqnv6YLqCsKn3NvkkXiJ1WgC', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0df6ee1b82c', '019fe204-d233-737e-ae03-e0de16b713ce', '019fe204-d233-737e-ae03-e0c909e379e1', 'Nuraini Putri', '081111111109', 'Jl. Kamboja No. 2 RT 01 RW 05', '3201010901930009');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019fe204-d233-737e-ae03-e0e0bb2d4b03', 'sumiati.wahyu@gmail.com', '$2b$10$Ut2k/w1vdkAYp.1LY85JseXkfi4/qDZShoPKGldrvQG4rP.gn4jOK', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e196e661b0', '019fe204-d233-737e-ae03-e0e0bb2d4b03', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'Sumiati Wahyu', '081111111110', 'Jl. Teratai No. 6 RT 04 RW 05', '3201011001870010');

-- ==========================================================
-- TIER 2: Jadwal Posyandu (5 lampau + 3 mendatang)
-- ==========================================================

INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-01-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Januari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-02-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Februari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0c7c598d562', '2026-03-03', '08:30', '11:30', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Maret 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0c7c598d562', '2026-04-03', '08:00', '12:00', 'Puskesmas Pembantu Cempaka', 'Posyandu + Pemberian Vitamin A Massal');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0c909e379e1', '2026-05-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Mei 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-06-03', '08:30', '12:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juni 2026 - Pembagian PMT');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0c7c598d562', '2026-07-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juli 2026');

-- ==========================================================
-- TIER 3: Anak (15 anak)
-- ==========================================================

INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0cf06d92a34', 'Rizki', 'L', '2025-06-17', '3201011234560001');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0cf06d92a34', 'Rafi', 'L', '2023-10-15', '3201011234560002');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0d103eff3db', 'Nayla', 'P', '2025-10-22', '3201011234560003');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0d3a14cd7a3', 'Hasan', 'L', '2024-06-03', '3201011234560004');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0d3a14cd7a3', 'Husein', 'L', '2025-12-03', '3201011234560005');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0d55ae11f61', 'Zahra', 'P', '2024-12-08', '3201011234560006');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0d73b213cb9', 'Dani', 'L', '2023-12-19', '3201011234560007');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0d73b213cb9', 'Dina', 'P', '2025-03-14', '3201011234560008');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0d9ace67237', 'Bagas', 'L', '2024-10-25', '3201011234560009');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0db8e480614', 'Putri', 'P', '2025-08-07', '3201011234560010');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0dd4876a047', 'Adi', 'L', '2023-06-20', '3201011234560011');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0dd4876a047', 'Ayu', 'P', '2024-08-16', '3201011234560012');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0df6ee1b82c', 'Fauzi', 'L', '2025-04-09', '3201011234560013');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0e196e661b0', 'Bella', 'P', '2024-02-13', '3201011234560014');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0e196e661b0', 'Bimo', 'L', '2025-09-21', '3201011234560015');

-- ==========================================================
-- TIER 4: Pengukuran (6 titik historis per anak = 90 total)
-- Z-score dihitung otomatis menggunakan WHO tables
-- ==========================================================

-- Anak: Rizki (L, lahir 2025-06-17, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-01-03', 8.8, 71.5, 43, 13.5, 0.714, 1.385, 0.056, 'normal', NULL, 0.2663, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-02-03', 9.1, 72.8, 43.3, 13.6, 0.643, 1.267, 0.075, 'normal', 0.28, 0.2035, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-03-03', 9.4, 74, 43.7, 13.8, 0.646, 1.209, 0.132, 'normal', 0.28, 0.2057, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-04-03', 9.6, 75.3, 44, 13.9, 0.555, 1.168, 0.045, 'normal', 0.28, 0.217, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-05-03', 9.9, 76.5, 44.3, 14.1, 0.584, 1.117, 0.121, 'normal', 0.28, 0.2166, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-06-03', 10.2, 77.8, 44.6, 14.2, 0.617, 1.113, 0.183, 'normal', 0.28, 0.2128, 'rendah');

-- Anak: Rafi (L, lahir 2023-10-15, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-01-03', 14.2, 93.5, NULL, NULL, 0.982, 1.297, 0.44, 'normal', NULL, 0.2445, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-02-03', 14.4, 94.2, NULL, NULL, 0.966, 1.24, 0.464, 'normal', 0.2, 0.1739, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-03-03', 14.6, 94.9, NULL, NULL, 0.964, 1.214, 0.486, 'normal', 0.2, 0.1752, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-04-03', 14.8, 95.5, NULL, NULL, 0.953, 1.142, 0.525, 'normal', 0.2, 0.18, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-05-03', 15, 96.2, NULL, NULL, 0.948, 1.115, 0.541, 'normal', 0.2, 0.1818, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-06-03', 15.2, 96.9, NULL, NULL, 0.942, 1.089, 0.552, 'normal', 0.2, 0.1837, 'rendah');

-- Anak: Nayla (P, lahir 2025-10-22, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-01-03', 6.6, 62.5, 37, 11.8, 1.554, 2.106, 0.175, 'normal', NULL, 0.1703, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-02-03', 7, 64.4, 38.5, 12.3, 1.12, 1.715, 0.089, 'normal', 0.4, 0.1432, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-03-03', 7.4, 66.3, 40, 12.7, 0.943, 1.626, 0.038, 'normal', 0.4, 0.1613, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-04-03', 7.8, 68.2, 41.5, 13.1, 0.835, 1.596, 0.018, 'normal', 0.4, 0.1699, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-05-03', 8.2, 70.1, 43, 13.5, 0.819, 1.676, 0.022, 'normal', 0.4, 0.1641, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-06-03', 8.6, 72, 43.3, 13.6, 0.846, 1.792, 0.041, 'normal', 0.4, 0.1527, 'rendah');

-- Anak: Hasan (L, lahir 2024-06-03, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-01-03', 8.8, 80.5, 47.3, 15.3, -2.113, -0.999, -2.245, 'kurang', NULL, 0.6904, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-02-03', 9, 81.2, 47.6, 15.5, -2.071, -1.081, -2.12, 'kurang', 0.22, 0.6148, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-03-03', 9.2, 81.9, 48, 15.6, -2.012, -1.112, -2.008, 'kurang', 0.22, 0.6099, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-04-03', 9.5, 82.7, 48.3, 15.7, -1.878, -1.139, -1.796, 'normal', 0.22, 0.5969, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-05-03', 9.7, 83.4, 48.6, 15.9, -1.832, -1.172, -1.71, 'normal', 0.22, 0.5938, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-06-03', 9.9, 84.1, NULL, NULL, -1.796, -0.991, -1.635, 'normal', 0.22, 0.5745, 'sedang');

-- Anak: Husein (L, lahir 2025-12-03, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-01-03', 5.2, 57.5, 35.5, 11.4, 1.144, 1.421, -0.163, 'normal', NULL, 0.2506, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-02-03', 5.9, 60.2, 37, 11.8, 0.423, 0.825, -0.295, 'normal', 0.72, 0.2646, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-03-03', 6.6, 62.9, 38.5, 12.3, 0.35, 0.796, -0.28, 'normal', 0.72, 0.27, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-04-03', 7.4, 65.6, 40, 12.7, 0.504, 0.845, -0.015, 'normal', 0.72, 0.2478, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-05-03', 8.1, 68.3, 41.5, 13.1, 0.712, 1.178, 0.096, 'normal', 0.72, 0.2063, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-06-03', 8.8, 71, 43, 13.5, 0.956, 1.585, 0.211, 'normal', 0.72, 0.157, 'rendah');

-- Anak: Zahra (P, lahir 2024-12-08, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-01-03', 7.3, 71, 45, 14.3, -1.873, -1.542, -1.546, 'normal', NULL, 0.6938, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-02-03', 7.5, 72.1, 45.3, 14.5, -1.846, -1.54, -1.538, 'normal', 0.18, 0.6245, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-03-03', 7.7, 73.2, 45.6, 14.6, -1.802, -1.495, -1.525, 'normal', 0.18, 0.6182, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-04-03', 7.8, 74.3, 46, 14.8, -1.883, -1.47, -1.654, 'normal', 0.18, 0.6254, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-05-03', 8, 75.4, 46.3, 14.9, -1.845, -1.422, -1.625, 'normal', 0.18, 0.6185, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-06-03', 8.2, 76.5, 46.6, 15, -1.818, -1.385, -1.592, 'normal', 0.18, 0.6129, 'sedang');

-- Anak: Dani (L, lahir 2023-12-19, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-01-03', 9.3, 82.5, NULL, NULL, -2.413, -1.639, -2.018, 'kurang', NULL, 0.7475, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-02-03', 9.5, 83.4, NULL, NULL, -2.357, -1.591, -2.165, 'kurang', 0.18, 0.6792, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-03-03', 9.7, 84.3, NULL, NULL, -2.291, -1.52, -2.145, 'kurang', 0.18, 0.6694, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-04-03', 9.8, 85.2, NULL, NULL, -2.325, -1.468, -2.266, 'kurang', 0.18, 0.6718, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-05-03', 10, 86.1, NULL, NULL, -2.265, -1.404, -2.256, 'kurang', 0.18, 0.6633, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-06-03', 10.2, 87, NULL, NULL, -2.208, -1.344, -2.246, 'kurang', 0.18, 0.6553, 'sedang');

-- Anak: Dina (P, lahir 2025-03-14, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-01-03', 9.3, 74, 44, 13.9, 0.827, 1.2, 0.41, 'normal', NULL, 0.2612, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-02-03', 9.5, 75.2, 44.3, 14.1, 0.759, 1.118, 0.371, 'normal', 0.24, 0.1978, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-03-03', 9.8, 76.4, 44.6, 14.2, 0.812, 1.115, 0.452, 'normal', 0.24, 0.1921, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-04-03', 10, 77.6, 45, 14.3, 0.767, 1.073, 0.421, 'normal', 0.24, 0.199, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-05-03', 10.3, 78.8, 45.3, 14.5, 0.815, 1.067, 0.491, 'normal', 0.24, 0.1943, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-06-03', 10.5, 80, 45.6, 14.6, 0.781, 1.056, 0.443, 'normal', 0.24, 0.1987, 'rendah');

-- Anak: Bagas (L, lahir 2024-10-25, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-01-03', 8.5, 76, 45.6, 14.6, -1.616, -0.951, -1.632, 'normal', NULL, 0.6372, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-02-03', 8.7, 76.8, 46, 14.8, -1.596, -1.055, -1.537, 'normal', 0.19, 0.5694, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-03-03', 8.9, 77.6, 46.3, 14.9, -1.552, -1.096, -1.441, 'normal', 0.19, 0.5667, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-04-03', 9.1, 78.5, 46.6, 15, -1.526, -1.127, -1.368, 'normal', 0.19, 0.5649, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-05-03', 9.3, 79.3, 47, 15.2, -1.495, -1.177, -1.274, 'normal', 0.19, 0.5636, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-06-03', 9.4, 80.1, 47.3, 15.3, -1.56, -1.22, -1.318, 'normal', 0.19, 0.5721, 'sedang');

-- Anak: Putri (P, lahir 2025-08-07, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-01-03', 7.6, 66.5, 40, 12.7, 0.848, 1.212, 0.264, 'normal', NULL, 0.2651, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-02-03', 7.9, 68, 41.5, 13.1, 0.682, 1.06, 0.217, 'normal', 0.28, 0.2124, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-03-03', 8.2, 69.5, 43, 13.5, 0.637, 1.071, 0.189, 'normal', 0.28, 0.2149, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-04-03', 8.4, 71, 43.3, 13.6, 0.494, 1.038, 0.044, 'normal', 0.28, 0.2305, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-05-03', 8.7, 72.5, 43.7, 13.8, 0.501, 1.07, 0.042, 'normal', 0.28, 0.2277, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-06-03', 9, 74, 44, 13.9, 0.522, 1.107, 0.049, 'normal', 0.28, 0.2234, 'rendah');

-- Anak: Adi (L, lahir 2023-06-20, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-01-03', 10, 84.5, NULL, NULL, -2.488, -2.271, -1.807, 'kurang', NULL, 0.7934, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-02-03', 10.2, 85.3, NULL, NULL, -2.423, -2.217, -1.775, 'kurang', 0.15, 0.7283, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-03-03', 10.3, 86.1, NULL, NULL, -2.43, -2.142, -1.87, 'kurang', 0.15, 0.7264, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-04-03', 10.4, 86.9, NULL, NULL, -2.447, -2.084, -1.964, 'kurang', 0.15, 0.7264, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-05-03', 10.6, 87.7, NULL, NULL, -2.379, -2.021, -1.93, 'kurang', 0.15, 0.7166, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-06-03', 10.8, 88.5, NULL, NULL, -2.315, -1.961, -1.894, 'kurang', 0.15, 0.7071, 'tinggi');

-- Anak: Ayu (P, lahir 2024-08-16, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-01-03', 8.4, 77, 46.3, 14.9, -1.393, -0.788, -1.424, 'normal', NULL, 0.6047, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-02-03', 8.6, 78, 46.6, 15, -1.375, -0.798, -1.376, 'normal', 0.19, 0.5314, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-03-03', 8.8, 79, 47, 15.2, -1.339, -0.764, -1.336, 'normal', 0.19, 0.5253, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-04-03', 9, 80, 47.3, 15.3, -1.321, -0.756, -1.306, 'normal', 0.19, 0.5225, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-05-03', 9.2, 81, 47.6, 15.5, -1.296, -0.729, -1.289, 'normal', 0.19, 0.5184, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-06-03', 9.3, 82, 48, 15.6, -1.369, -0.706, -1.409, 'normal', 0.19, 0.525, 'sedang');

-- Anak: Fauzi (L, lahir 2025-04-09, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-01-03', 9.8, 75, 43.7, 13.8, 0.935, 1.451, 0.369, 'normal', NULL, 0.2374, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-02-03', 10, 76.3, 44, 13.9, 0.845, 1.414, 0.289, 'normal', 0.22, 0.1731, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-03-03', 10.2, 77.7, 44.3, 14.1, 0.794, 1.483, 0.205, 'normal', 0.22, 0.1735, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-04-03', 10.5, 79, 44.6, 14.2, 0.825, 1.481, 0.271, 'normal', 0.22, 0.1694, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-05-03', 10.7, 80.4, 45, 14.3, 0.78, 1.545, 0.202, 'normal', 0.22, 0.1693, 'rendah');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', '2026-06-03', 10.9, 81.8, 45.3, 14.5, 0.741, 1.613, 0.12, 'normal', 0.22, 0.1691, 'rendah');

-- Anak: Bella (P, lahir 2024-02-13, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-01-03', 9.5, 83, 48.3, 15.7, -1.364, -0.703, -1.411, 'normal', NULL, 0.5959, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-02-03', 9.7, 83.6, 48.6, 15.9, -1.346, -0.643, -1.319, 'normal', 0.19, 0.5152, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-03-03', 9.9, 84.2, NULL, NULL, -1.312, -0.63, -1.234, 'normal', 0.19, 0.5091, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-04-03', 10.1, 84.8, NULL, NULL, -1.292, -0.701, -1.335, 'normal', 0.19, 0.5178, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-05-03', 10.3, 85.4, NULL, NULL, -1.27, -0.761, -1.259, 'normal', 0.19, 0.5185, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c7c598d562', '2026-06-03', 10.4, 86, NULL, NULL, -1.33, -0.819, -1.299, 'normal', 0.19, 0.5277, 'sedang');

-- Anak: Bimo (L, lahir 2025-09-21, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-01-03', 5.5, 60.5, 38.5, 12.3, -1.598, -0.944, -1.325, 'normal', NULL, 0.6234, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-02-03', 5.7, 61.8, 40, 12.7, -2.078, -1.418, -1.571, 'kurang', 0.22, 0.6202, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-03-03', 5.9, 63.1, 41.5, 13.1, -2.325, -1.609, -1.771, 'kurang', 0.22, 0.6558, 'sedang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-04-03', 6.2, 64.4, 43, 13.5, -2.375, -1.771, -1.727, 'kurang', 0.22, 0.6695, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-05-03', 6.4, 65.7, 43.3, 13.6, -2.473, -1.826, -1.869, 'kurang', 0.22, 0.6845, 'tinggi');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi, tren_bb, skor_saw, kategori_risiko) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c909e379e1', '2026-06-03', 6.6, 67, 43.7, 13.8, -2.532, -1.861, -1.991, 'kurang', 0.22, 0.6951, 'tinggi');

-- ==========================================================
-- TIER 4: Pemberian Vitamin A, Obat Cacing & PMT
-- ==========================================================

-- Rizki (usia: 11 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e2fe936b9e', '019fe204-d233-737e-ae03-e0c7c598d562', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Rafi (usia: 31 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e3d665b56f', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Nayla (usia: 7 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e44db6b946', '019fe204-d233-737e-ae03-e0c7c598d562', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Hasan (usia: 24 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e57d2112d2', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Husein (usia: 6 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e60c5d8161', '019fe204-d233-737e-ae03-e0c7c598d562', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Zahra (usia: 17 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e7afdf4d31', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Dani (usia: 29 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e854420f94', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Dina (usia: 14 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0e9f7e6c67c', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Bagas (usia: 19 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ea56be573c', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Putri (usia: 9 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0eb49643930', '019fe204-d233-737e-ae03-e0c7c598d562', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Adi (usia: 35 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Ayu (usia: 21 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0ed24ad7bfd', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Fauzi (usia: 13 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0eeb36a46fd', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Bella (usia: 27 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c7c598d562', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0efb6a31b03', '019fe204-d233-737e-ae03-e0c909e379e1', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Bimo (usia: 8 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c5d8eadfa5', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c7c598d562', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- ==========================================================
-- TIER 6: Rujukan (anak kategori risiko tinggi)
-- ==========================================================

-- Rujukan untuk: Adi | Status: selesai
INSERT INTO rujukan (anak_id, kader_id, puskesmas_id, pengukuran_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019fe204-d233-737e-ae03-e0ec994c311b', '019fe204-d233-737e-ae03-e0c7c598d562', '019fe204-d233-737e-ae03-e0cbfbadb2fa', 66, 'selesai', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7071.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-15');

-- Rujukan untuk: Bimo | Status: ditangani
INSERT INTO rujukan (anak_id, kader_id, puskesmas_id, pengukuran_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019fe204-d233-737e-ae03-e0f00c66a86d', '019fe204-d233-737e-ae03-e0c909e379e1', '019fe204-d233-737e-ae03-e0cbfbadb2fa', 90, 'ditangani', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.6951.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-16');

-- ==========================================================
-- TIER 6: AI Insight — UPDATE pengukuran.insight_teks (1 per anak)
-- ==========================================================

-- Rizki (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0e2fe936b9e' AND tanggal_ukur = '2026-06-03';

-- Rafi (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0e3d665b56f' AND tanggal_ukur = '2026-06-03';

-- Nayla (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0e44db6b946' AND tanggal_ukur = '2026-06-03';

-- Hasan (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0e57d2112d2' AND tanggal_ukur = '2026-06-03';

-- Husein (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0e60c5d8161' AND tanggal_ukur = '2026-06-03';

-- Zahra (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0e7afdf4d31' AND tanggal_ukur = '2026-06-03';

-- Dani (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0e854420f94' AND tanggal_ukur = '2026-06-03';

-- Dina (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0e9f7e6c67c' AND tanggal_ukur = '2026-06-03';

-- Bagas (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0ea56be573c' AND tanggal_ukur = '2026-06-03';

-- Putri (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0eb49643930' AND tanggal_ukur = '2026-06-03';

-- Adi (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0ec994c311b' AND tanggal_ukur = '2026-06-03';

-- Ayu (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0ed24ad7bfd' AND tanggal_ukur = '2026-06-03';

-- Fauzi (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0eeb36a46fd' AND tanggal_ukur = '2026-06-03';

-- Bella (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0efb6a31b03' AND tanggal_ukur = '2026-06-03';

-- Bimo (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.'
WHERE anak_id = '019fe204-d233-737e-ae03-e0f00c66a86d' AND tanggal_ukur = '2026-06-03';

-- ==========================================================
-- TIER 7: Notifikasi
-- Jadwal ID 7 = Posyandu Juli 2026 (jadwal mendatang = hari demo)
-- ==========================================================

-- Notifikasi jadwal posyandu Juli 2026
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0cf06d92a34', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0d103eff3db', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0d3a14cd7a3', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0d55ae11f61', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0d73b213cb9', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0d9ace67237', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0db8e480614', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0dd4876a047', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0df6ee1b82c', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0e196e661b0', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);

-- Notifikasi status rujukan
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0dd4876a047', 'Rujukan Selesai Ditangani', 'Proses rujukan anak Anda telah selesai ditangani. Terus pantau tumbuh kembang si kecil dan rutin bawa ke posyandu setiap bulan agar kondisi tetap terpantau.', 'rujukan', TRUE, '2026-06-01 10:00:00', NULL, 1);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019fe204-d233-737e-ae03-e0e196e661b0', 'Rujukan Sedang Ditangani', 'Rujukan anak Anda sedang ditangani oleh puskesmas. Silakan datang untuk pemeriksaan.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 2);
