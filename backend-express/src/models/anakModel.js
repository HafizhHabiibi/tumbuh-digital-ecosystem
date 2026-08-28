import db from "../database/connection.js";
import { uuidv7 } from "uuidv7";

export const findAll = async (page = 1, limit = 20) => {
    const offset = (page - 1) * limit;
    const [rows] = await db.query(
        `SELECT
            a.id,
            a.orang_tua_id,
            a.nama,
            a.jenis_kelamin,
            a.tanggal_lahir,
            a.nik,
            a.created_at,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp AS no_hp_orang_tua
            FROM anak a
            JOIN orang_tua ot ON ot.id = a.orang_tua_id
            ORDER BY a.created_at DESC
            LIMIT ? OFFSET ?`,
        [limit, offset],
    );
    const [[{ total }]] = await db.query("SELECT COUNT(*) AS total FROM anak");
    return { items: rows, total: Number(total) };
};

export const findById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            a.id,
            a.nama,
            a.jenis_kelamin,
            a.tanggal_lahir,
            a.nik,
            a.created_at,
            a.orang_tua_id,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp AS no_hp_orang_tua,
            ot.alamat AS alamat_orang_tua
            FROM anak a
            JOIN orang_tua ot ON ot.id = a.orang_tua_id
            WHERE a.id = ?`,
        [id],
    );
    return rows[0] || null;
};

export const findByOrangTua = async (orang_tua_id) => {
    const [rows] = await db.query(
        `SELECT
            a.id,
            a.nama,
            a.jenis_kelamin,
            a.tanggal_lahir,
            a.nik,
            a.created_at
            FROM anak a
            WHERE a.orang_tua_id = ?
            ORDER BY a.created_at DESC`,
        [orang_tua_id],
    );
    return rows;
};

export const findDuplicate = async (orang_tua_id, nama, tanggal_lahir) => {
    const [rows] = await db.query(
        `SELECT id FROM anak
        WHERE orang_tua_id = ?
        AND nama = ?
        AND tanggal_lahir = ?`,
        [orang_tua_id, nama, tanggal_lahir],
    );
    return rows[0] || null;
};

export const create = async (data) => {
    const id = uuidv7();
    await db.query(
        `INSERT INTO anak
        (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik)
        VALUES (?, ?, ?, ?, ?, ?)`,
        [
            id,
            data.orang_tua_id,
            data.nama,
            data.jenis_kelamin,
            data.tanggal_lahir,
            data.nik,
        ],
    );
    return { id, ...data };
};

export const update = async (id, data) => {
    await db.query(
        `UPDATE anak
        SET nama = ?, jenis_kelamin = ?, tanggal_lahir = ?, nik = ?
        WHERE id = ?`,
        [data.nama, data.jenis_kelamin, data.tanggal_lahir, data.nik, id],
    );
};

export const buatDeleteIfEmpty = (pool = db) => async (id) => {
    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();

        const [anakRows] = await conn.query(
            "SELECT id FROM anak WHERE id = ? FOR UPDATE",
            [id],
        );
        if (!anakRows[0]) {
            await conn.rollback();
            return { status: "not_found" };
        }

        const [relationRows] = await conn.query(
            `SELECT
                (SELECT COUNT(*) FROM pengukuran WHERE anak_id = ?) AS pengukuran,
                (SELECT COUNT(*) FROM pemberian WHERE anak_id = ?) AS pemberian`,
            [id, id],
        );
        const relations = {
            pengukuran: Number(relationRows[0]?.pengukuran || 0),
            pemberian: Number(relationRows[0]?.pemberian || 0),
        };
        if (relations.pengukuran > 0 || relations.pemberian > 0) {
            await conn.rollback();
            return { status: "conflict", relations };
        }

        await conn.query("DELETE FROM anak WHERE id = ?", [id]);
        await conn.commit();
        return { status: "deleted" };
    } catch (error) {
        await conn.rollback();
        throw error;
    } finally {
        conn.release();
    }
};

export const deleteIfEmpty = buatDeleteIfEmpty();
