import { createRequire } from 'module';
import { fileURLToPath } from 'url';
import { dirname, join, parse } from 'path';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const WHO = JSON.parse(
    fs.readFileSync(join(__dirname, '../constants/whoTables.json'), 'utf8')
)

const hitungZScore = (nilai, L, M, S) => {
    if (L === 0) {
        return Math.log(nilai / M) / S
    }
    return (Math.pow(nilai / M, L) - 1) / (L * S)
}

const hitungZScoreBBU = (berat_badan, usia_bulan, jenis_kelamin) => {
    const key = `bbu_${jenis_kelamin}`
    const table = WHO[key]
    if (!table) return 0

    const lms = table.find(row => row.bulan === usia_bulan)
    if (!lms) return 0

    return hitungZScore(berat_badan, lms.L, lms.M, lms.S)
}

const hitungZScoreTBU = (tinggi_badan, usia_bulan, jenis_kelamin) => {
    const key = `tbu_${jenis_kelamin}`
    const table = WHO[key]
    if (!table) return 0

    const lms = table.find(row => row.bulan === usia_bulan)
    if (!lms) return 0

    return hitungZScore(tinggi_badan, lms.L, lms.M, lms.S)
}

const hitungZScoreBBTB = (berat_badan, tinggi_badan, usia_bulan, jenis_kelamin) => {
    const key = usia_bulan <= 24? `wfl_${jenis_kelamin}` : `wfh_${jenis_kelamin}`
    const table = WHO[key]
    if (!table) return 0

    const kolomRef = usia_bulan <= 24 ? 'panjang' : 'tinggi'
    const tinggiRounded = Math.round(tinggi_badan * 10) / 10
    const lms = table.find(row => row[kolomRef] === tinggiRounded) 

    if (!lms) {
        let closest = null
        let minDiff = Infinity
        for (const row of table) {
            const diff = Math.abs(row[kolomRef] - tinggiRounded)
            if (diff < minDiff) {
                minDiff = diff
                closest = row
            }
        }
        if (!closest) return 0
        return hitungZScore(berat_badan, closest.L, closest.M, closest.S)
    }
    return hitungZScore(berat_badan, lms.L, lms.M, lms.S)
}

const hitungUsiaBulan = (tanggal_lahir, tanggal_ukur) => {
    const lahir = new Date(tanggal_lahir)
    const ukur = new Date(tanggal_ukur)

    const tahun = ukur.getFullYear() - lahir.getFullYear()
    const bulan = ukur.getMonth() - lahir.getMonth()

    return (tahun * 12) + bulan
}

const tentukanStatusGizi = (zscore_tbu) => {
    if (zscore_tbu < -3) return 'Gizi Buruk'
    if (zscore_tbu < -2) return 'Gizi Kurang'
    if (zscore_tbu <= 2) return 'Gizi Normal'
    return 'Gizi Lebih'
}

export const hitungSemuaZScore = (data) => {
    const {
        berat_badan,
        tinggi_badan,
        tanggal_lahir,
        tanggal_ukur,
        jenis_kelamin
    } = data

    const usia_bulan = hitungUsiaBulan(tanggal_lahir, tanggal_ukur)
    const gender = jenis_kelamin === 'L' ? 'L' : 'P'

    const zscore_bbu = hitungZScoreBBU(berat_badan, usia_bulan, gender)
    const zscore_tbu = hitungZScoreTBU(tinggi_badan, usia_bulan, gender)
    const zscore_bbtb = hitungZScoreBBTB(berat_badan, tinggi_badan, usia_bulan, gender)
    const status_gizi = tentukanStatusGizi(zscore_tbu)

    return {
        usia_bulan,
        zscore_bbu : parseFloat(zscore_bbu.toFixed(3)),
        zscore_tbu : parseFloat(zscore_tbu.toFixed(3)),
        zscore_bbtb : parseFloat(zscore_bbtb.toFixed(3)),
        status_gizi
    }
}