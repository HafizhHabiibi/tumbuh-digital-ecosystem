import ExcelJS from 'exceljs'
import fs from 'fs'

const result = {}

// ── Helper: baca file Excel dan ambil kolom L, M, S ─────────
const readExcel = async (filename, keyCol) => {
    const workbook = new ExcelJS.Workbook()
    await workbook.xlsx.readFile(`./who-data/${filename}`)

    const sheet = workbook.worksheets[0]
    const data  = []

    // Ambil header dari baris 1
    const headers = []
    sheet.getRow(1).eachCell((cell) => {
        headers.push(cell.value)
    })

    // Index kolom yang kita butuhkan
    const idxKey = headers.indexOf(keyCol)  // Day / Length / Height
    const idxL   = headers.indexOf('L')
    const idxM   = headers.indexOf('M')
    const idxS   = headers.indexOf('S')

    const kolomHilang = [
        [keyCol, idxKey],
        ['L', idxL],
        ['M', idxM],
        ['S', idxS],
    ].filter(([, index]) => index < 0).map(([nama]) => nama)

    if (kolomHilang.length > 0) {
        throw new Error(`${filename}: kolom wajib tidak ditemukan: ${kolomHilang.join(', ')}`)
    }

    // Iterasi semua baris data (mulai baris 2)
    sheet.eachRow((row, rowNumber) => {
        if (rowNumber === 1) return // skip header

        const keyVal = row.getCell(idxKey + 1).value
        const L      = row.getCell(idxL + 1).value
        const M      = row.getCell(idxM + 1).value
        const S      = row.getCell(idxS + 1).value

        // Skip baris kosong
        if (keyVal === null || keyVal === undefined) return
        if (L === null || M === null || S === null)  return

        const parsed = {
            key : Number(keyVal),
            L   : Number(L),
            M   : Number(M),
            S   : Number(S),
        }

        if (Object.values(parsed).some(value => !Number.isFinite(value))) {
            throw new Error(`${filename}: nilai nonnumerik pada baris ${rowNumber}`)
        }

        data.push(parsed)
    })

    return data
}

// Pertahankan granularitas harian dari WHO Expanded Tables agar tidak ada
// pemilihan hari terdekat atau interpolasi ulang di backend.
const gunakanDataHarian = (dataHarian) => dataHarian.map((row, index) => {
    if (!Number.isInteger(row.key) || row.key !== index) {
        throw new Error(`Urutan data harian tidak valid pada indeks ${index}`)
    }

    return {
        day: row.key,
        L: row.L,
        M: row.M,
        S: row.S,
    }
})

// ── Main ─────────────────────────────────────────────────────
console.log('Membaca file WHO...\n')

// 1. wfa — Weight for Age — referensi: Day
console.log('Memproses wfa (Weight for Age)...')
const wfaBoys  = await readExcel('wfa-boys-zscore-expanded-tables.xlsx',  'Day')
const wfaGirls = await readExcel('wfa-girls-zscore-expanded-tables.xlsx', 'Day')
result.wfa_boys  = gunakanDataHarian(wfaBoys)
result.wfa_girls = gunakanDataHarian(wfaGirls)
console.log(`  wfa_boys : ${result.wfa_boys.length} baris`)
console.log(`  wfa_girls: ${result.wfa_girls.length} baris`)

// 2. lhfa — Length/Height for Age — referensi: Day
console.log('Memproses lhfa (Length/Height for Age)...')
const lhfaBoys  = await readExcel('lhfa-boys-zscore-expanded-tables.xlsx',  'Day')
const lhfaGirls = await readExcel('lhfa-girls-zscore-expanded-tables.xlsx', 'Day')
result.lhfa_boys  = gunakanDataHarian(lhfaBoys)
result.lhfa_girls = gunakanDataHarian(lhfaGirls)
console.log(`  lhfa_boys : ${result.lhfa_boys.length} baris`)
console.log(`  lhfa_girls: ${result.lhfa_girls.length} baris`)

// 3. wfl — Weight for Length (berbaring, 0-24 bulan) — referensi: Length (cm)
console.log('Memproses wfl (Weight for Length, 0-24 bulan)...')
const wflBoys  = await readExcel('wfl-boys-zscore-expanded-tables.xlsx',  'Length')
const wflGirls = await readExcel('wfl-girls-zscore-expanded-tables.xlsx', 'Length')
result.wfl_boys  = wflBoys.map(row => ({ length: row.key, L: row.L, M: row.M, S: row.S }))
result.wfl_girls = wflGirls.map(row => ({ length: row.key, L: row.L, M: row.M, S: row.S }))
console.log(`  wfl_boys : ${result.wfl_boys.length} baris`)
console.log(`  wfl_girls: ${result.wfl_girls.length} baris`)

// 4. wfh — Weight for Height (berdiri, 24-60 bulan) — referensi: Height (cm)
console.log('Memproses wfh (Weight for Height, 24-60 bulan)...')
const wfhBoys  = await readExcel('wfh-boys-zscore-expanded-tables.xlsx',  'Height')
const wfhGirls = await readExcel('wfh-girls-zscore-expanded-tables.xlsx', 'Height')
result.wfh_boys  = wfhBoys.map(row => ({ height: row.key, L: row.L, M: row.M, S: row.S }))
result.wfh_girls = wfhGirls.map(row => ({ height: row.key, L: row.L, M: row.M, S: row.S }))
console.log(`  wfh_boys : ${result.wfh_boys.length} baris`)
console.log(`  wfh_girls: ${result.wfh_girls.length} baris`)

// 5. bfa — BMI for Age — referensi: Day
console.log('Memproses bfa (BMI for Age)...')
const bfaBoys  = await readExcel('bfa-boys-zscore-expanded-tables.xlsx',  'Day')
const bfaGirls = await readExcel('bfa-girls-zscore-expanded-tables.xlsx', 'Day')
result.bfa_boys  = gunakanDataHarian(bfaBoys)
result.bfa_girls = gunakanDataHarian(bfaGirls)
console.log(`  bfa_boys : ${result.bfa_boys.length} baris`)
console.log(`  bfa_girls: ${result.bfa_girls.length} baris`)

// ── Tulis ke file JSON ───────────────────────────────────────
fs.writeFileSync('./whoTables.json', JSON.stringify(result, null, 2), 'utf8')

console.log('\n✓ whoTables.json berhasil dibuat!')
console.log('Copy file ini ke src/constants/ di project Express.')
console.log('\nRingkasan:')
console.log(`  wfa_boys  : ${result.wfa_boys.length} hari`)
console.log(`  wfa_girls : ${result.wfa_girls.length} hari`)
console.log(`  lhfa_boys : ${result.lhfa_boys.length} hari`)
console.log(`  lhfa_girls: ${result.lhfa_girls.length} hari`)
console.log(`  wfl_boys  : ${result.wfl_boys.length} titik (per 0.1 cm)`)
console.log(`  wfl_girls : ${result.wfl_girls.length} titik (per 0.1 cm)`)
console.log(`  wfh_boys  : ${result.wfh_boys.length} titik (per 0.1 cm)`)
console.log(`  wfh_girls : ${result.wfh_girls.length} titik (per 0.1 cm)`)
console.log(`  bfa_boys  : ${result.bfa_boys.length} hari`)
console.log(`  bfa_girls : ${result.bfa_girls.length} hari`)
