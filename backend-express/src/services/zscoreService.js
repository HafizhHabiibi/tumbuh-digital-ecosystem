import { fileURLToPath } from 'url';
import { dirname, join} from 'path';
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

export const hitungUsiaBulan = (tanggal_lahir, tanggal_ukur) => {
    const lahir = new Date(tanggal_lahir)
    const ukur = new Date(tanggal_ukur)

    let bulan = (ukur.getFullYear() - lahir.getFullYear()) * 12 + (ukur.getMonth() - lahir.getMonth())
    if (ukur.getDate() < lahir.getDate()) {
        bulan--
    }
    return Math.max(0, bulan)
}

const hitungUsiaBulanDesimal = (tanggal_lahir, tanggal_ukur) => {
    const lahir = new Date(tanggal_lahir)
    const ukur = new Date(tanggal_ukur)

    const selisihHari = (ukur - lahir) / (1000 * 60 * 60 * 24)
    return Math.max(0, selisihHari / 30.4375)
}

const cariLMSInterpolasi = (table, usia_desimal) => {
    const bulanBawah = Math.floor(usia_desimal)
    const bulanAtas = Math.ceil(usia_desimal)

    if (bulanBawah === bulanAtas) {
        return table.find(row => row.bulan === bulanBawah) || null
    }

    const lmsBawah = table.find(row => row.bulan === bulanBawah)
    const lmsAtas = table.find(row => row.bulan === bulanAtas)

    if (!lmsBawah) return lmsAtas || null
    if (!lmsAtas) return lmsBawah || null

    const fraksi = usia_desimal - bulanBawah

    return {
        L : lmsBawah.L + (lmsAtas.L - lmsBawah.L) * fraksi,
        M : lmsBawah.M + (lmsAtas.M - lmsBawah.M) * fraksi,
        S : lmsBawah.S + (lmsAtas.S - lmsBawah.S) * fraksi
    }
}

const hitungZScoreBBU = (berat_badan, usia_desimal, gender) => {
    const table = WHO[`bbu_${gender}`]
    if (!table) return 0

    const lms = cariLMSInterpolasi(table, usia_desimal)
    if (!lms) return 0

    return hitungZScore(berat_badan, lms.L, lms.M, lms.S)
}

const hitungZScoreTBU = (tinggi_badan, usia_desimal, gender) => {
    const table = WHO[`tbu_${gender}`]
    if (!table) return 0

    const lms = cariLMSInterpolasi(table, usia_desimal)
    if (!lms) return 0

    return hitungZScore(tinggi_badan, lms.L, lms.M, lms.S)
}

const hitungZScoreBBTB = (berat_badan, tinggi_badan, usia_bulan, gender) => {
    const key = usia_bulan <= 24 ? `wfl_${gender}` : `wfh_${gender}`
    const kolomRef = usia_bulan <= 24? 'panjang' : 'tinggi'
    const table = WHO[key]
    if (!table) return 0

    const tinggiRounded = Math.round(tinggi_badan * 10) / 10

    let lms = table.find(row => row[kolomRef] === tinggiRounded) 

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
        lms = closest
    }
    if (!lms) return 0
    return hitungZScore(berat_badan, lms.L, lms.M, lms.S)
}

const statusBBU = (z) => {
    if (z < -3) return 'buruk'
    if (z < -2) return 'kurang'
    if (z <= 2) return 'normal'
    return 'lebih'
}

const statusTBU = (z) => {
    if (z < -3) return 'sangat_pendek'
    if (z < -2) return 'pendek'
    if (z <= 2) return 'normal'
    return 'tinggi'
}

const statusBBTB = (z) => {
    if (z < -3) return 'sangat_kurus'
    if (z < -2) return 'kurus'
    if (z <= 2) return 'normal'
    if (z <= 3) return 'gemuk'
    return 'obesitas'
}

const ringkasanStatusGizi = (zscore_bbu, zscore_tbu, zscore_bbtb) => {
    const jumlahBuruk = [zscore_bbu, zscore_tbu, zscore_bbtb].filter(z => z < -3).length
    const jumlahKurang = [zscore_bbu, zscore_tbu, zscore_bbtb].filter(z => z < -2).length

    if (jumlahBuruk >= 2 || zscore_tbu < -3) {
        return 'buruk'
    }

    if (jumlahKurang >= 1) {
        return 'kurang'
    }

    if (zscore_bbtb > 2) {
        return 'lebih'
    }

    return 'normal'
}

export const hitungSemuaZScore = (data) => {
    const {
        berat_badan,
        tinggi_badan,
        tanggal_lahir,
        tanggal_ukur,
        jenis_kelamin
    } = data

    const gender = jenis_kelamin === 'L' ? 'L' : 'P'
    const usia_bulan = hitungUsiaBulan(tanggal_lahir, tanggal_ukur)
    const usia_desimal = hitungUsiaBulanDesimal(tanggal_lahir, tanggal_ukur)

    const zscore_bbu = hitungZScoreBBU(berat_badan, usia_desimal, gender)
    const zscore_tbu = hitungZScoreTBU(tinggi_badan, usia_desimal, gender)
    const zscore_bbtb = hitungZScoreBBTB(berat_badan, tinggi_badan, usia_bulan, gender)


    return {
        usia_bulan,
        zscore_bbu : parseFloat(zscore_bbu.toFixed(3)),
        zscore_tbu : parseFloat(zscore_tbu.toFixed(3)),
        zscore_bbtb : parseFloat(zscore_bbtb.toFixed(3)),
        
        status_bbu : statusBBU(zscore_bbu),
        status_tbu : statusTBU(zscore_tbu),
        status_bbtb : statusBBTB(zscore_bbtb),

        status_gizi : ringkasanStatusGizi(zscore_bbu, zscore_tbu, zscore_bbtb)
    }
}