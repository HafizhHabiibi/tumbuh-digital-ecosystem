USE posyandu_pui

INSERT INTO users (id, email, password_hash, role, is_active)
VALUES ('019d9f36-c7d5-7521-ab23-5d9781be981f', 'meongterbang22@gmail.com', '$2b$10$Mhr2gvidDSlqg5mTeWKtd.MW6yowc18ZMAzwQrJEIWRvDd18XtBSC', 'kader', TRUE);

INSERT INTO kader (id, user_id, nama_lengkap, no_hp)
VALUES ('019d9f36-c7d8-70cc-822b-859688f83f5f', '019d9f36-c7d5-7521-ab23-5d9781be981f', 'Riri', '081234567890');

INSERT INTO users (id, email, password_hash, role, is_active)
VALUES ('019d9f36-c826-7d77-8f44-27d586eef134', 'bullmini123@gmail.com', '$2b$10$uECPSCymeDJVrGRrt3YFQeKuBA9SqEK9bVLIOnaSezN/bG04PF/Hy', 'puskesmas', TRUE);

INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp)
VALUES ('019d9f36-c826-7d77-8f44-27d629140b2c', '019d9f36-c826-7d77-8f44-27d586eef134', 'Ciko', 'Bidan', '081234567891');
