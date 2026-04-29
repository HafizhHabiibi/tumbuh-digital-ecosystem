USE posyandu_pui

INSERT INTO users (id, email, password_hash, role, is_active)
VALUES ('019dda60-ea68-7769-a1a2-5b6c7eb4b88b', 'meongterbang22@gmail.com', '$2b$10$TvDpyXeKv8RONf80MfaOBeReHtG6l/6xR.TibMDFZKwWCV9cqenEG', 'kader', TRUE);

INSERT INTO kader (id, user_id, nama_lengkap, no_hp)
VALUES ('019dda60-ea69-7d52-9a83-7245eb046fdf', '019dda60-ea68-7769-a1a2-5b6c7eb4b88b', 'Riri', '081234567890');

INSERT INTO users (id, email, password_hash, role, is_active)
VALUES ('019dda60-eaa0-724d-8166-1e49ab0dcc33', 'bullmini123@gmail.com', '$2b$10$EaFo.dl1vgGJrzXj4NrvjeKi2yQabGUUViBXCQgkkg0Ot10el9NMC', 'puskesmas', TRUE);

INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp)
VALUES ('019dda60-eaa0-724d-8166-1e4a6ccbde50', '019dda60-eaa0-724d-8166-1e49ab0dcc33', 'Ciko', 'Bidan', '081234567891');
