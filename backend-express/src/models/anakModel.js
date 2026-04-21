import db from '../database/connection.js';
import { uuidv7 } from 'uuidv7';

export const findAll = async () => {
    const [rows] = await db.query(
        `SELECT
            a.id,
            a.nama,
            a.jenis_kelamin,
            a.tanggal_lahir,
            a.no_kk,
            a.created_at,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp AS no_hp_orang_tua
            FROM anak a
            JOIN orang_tua ot ON ot.id = a.orang_tua_id
            ORDER BY a.created_at DESC`
        )
    return rows;
}

export const findById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            a.id,
            a.nama,
            a.jenis_kelamin,
            a.tanggal_lahir,
            a.no_kk,
            a.created_at,
            a.orang_tua_id,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp AS no_hp_orang_tua,
            ot.alamat AS alamat_orang_tua
            FROM anak a
            JOIN orang_tua ot ON ot.id = a.orang_tua_id
            WHERE a.id = ?`,
        [id]
    )
    return rows[0] || null;
}

export const findByOrangTua = async (orang_tua_id) => {
    const [rows] = await db.query(
        `SELECT
            a.id,
            a.nama,
            a.jenis_kelamin,
            a.tanggal_lahir,
            a.no_kk,
            a.created_at\
            FROM anak a
            WHERE a.orang_tua_id = ?
            ORDER BY a.created_at DESC`,
        [orang_tua_id]
    )
    return rows;
}

export const findDuplicate = async (orang_tua_id, nama, tanggal_lahir) => {
    const [rows] = await db.query(
        `SELECT id FROM anak
        WHERE orang_tua_id = ?
        AND nama = ?
        AND tanggal_lahir = ?`,
        [orang_tua_id, nama, tanggal_lahir]
    )
    return rows[0] || null;
}

export const create = async (data) => {
    const id = uuidv7()
    await db.query(
        `INSERT INTO anak
        (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk)
        VALUES (?, ?, ?, ?, ?, ?)`,
        [id, data.orang_tua_id, data.nama, data.jenis_kelamin, data.tanggal_lahir, data.no_kk]
    )
    return { id, ...data };
}