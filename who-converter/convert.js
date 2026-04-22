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

        data.push({
            key : parseFloat(keyVal),
            L   : parseFloat(L),
            M   : parseFloat(M),
            S   : parseFloat(S),
        })
    })

    return data
}

// ── Konversi data harian ke bulanan untuk wfa dan lhfa ──────
// WHO menyimpan data per hari (0-1856 hari)
// Kita ambil satu representasi per bulan
// Rumus: bulan ke-n = hari ke-(n * 30.4375)
const konversiHariKeBulan = (dataHarian) => {
    const dataBulanan = []

    for (let bulan = 0; bulan <= 60; bulan++) {
        // Hitung hari tengah dari bulan tersebut
        const hariTarget = Math.round(bulan * 30.4375)

        // Cari data yang paling dekat dengan hari target
        let closest = null
        let minDiff  = Infinity

        for (const row of dataHarian) {
            const diff = Math.abs(row.key - hariTarget)
            if (diff < minDiff) {
                minDiff  = diff
                closest  = row
            }
        }

        if (closest) {
            dataBulanan.push({
                bulan,
                L : closest.L,
                M : closest.M,
                S : closest.S,
            })
        }
    }

    return dataBulanan
}

// ── Main ─────────────────────────────────────────────────────
console.log('Membaca file WHO...\n')

// 1. BB/U (Weight for Age) — referensi: Day
console.log('Memproses wfa (BB/U)...')
const wfaBoys  = await readExcel('wfa-boys-zscore-expanded-tables.xlsx',  'Day')
const wfaGirls = await readExcel('wfa-girls-zscore-expanded-tables.xlsx', 'Day')
result.bbu_L = konversiHariKeBulan(wfaBoys)
result.bbu_P = konversiHariKeBulan(wfaGirls)
console.log(`  bbu_L: ${result.bbu_L.length} baris`)
console.log(`  bbu_P: ${result.bbu_P.length} baris`)

// 2. TB/U (Length/Height for Age) — referensi: Day
console.log('Memproses lhfa (TB/U)...')
const lhfaBoys  = await readExcel('lhfa-boys-zscore-expanded-tables.xlsx',  'Day')
const lhfaGirls = await readExcel('lhfa-girls-zscore-expanded-tables.xlsx', 'Day')
result.tbu_L = konversiHariKeBulan(lhfaBoys)
result.tbu_P = konversiHariKeBulan(lhfaGirls)
console.log(`  tbu_L: ${result.tbu_L.length} baris`)
console.log(`  tbu_P: ${result.tbu_P.length} baris`)

// 3. BB/TB berbaring — wfl (Weight for Length) — referensi: Length (cm)
console.log('Memproses wfl (BB/TB berbaring 0-24 bulan)...')
const wflBoys  = await readExcel('wfl-boys-zscore-expanded-tables.xlsx',  'Length')
const wflGirls = await readExcel('wfl-girls-zscore-expanded-tables.xlsx', 'Length')
result.wfl_L = wflBoys.map(row => ({ panjang: row.key, L: row.L, M: row.M, S: row.S }))
result.wfl_P = wflGirls.map(row => ({ panjang: row.key, L: row.L, M: row.M, S: row.S }))
console.log(`  wfl_L: ${result.wfl_L.length} baris`)
console.log(`  wfl_P: ${result.wfl_P.length} baris`)

// 4. BB/TB berdiri — wfh (Weight for Height) — referensi: Height (cm)
console.log('Memproses wfh (BB/TB berdiri 24-60 bulan)...')
const wfhBoys  = await readExcel('wfh-boys-zscore-expanded-tables.xlsx',  'Height')
const wfhGirls = await readExcel('wfh-girls-zscore-expanded-tables.xlsx', 'Height')
result.wfh_L = wfhBoys.map(row => ({ tinggi: row.key, L: row.L, M: row.M, S: row.S }))
result.wfh_P = wfhGirls.map(row => ({ tinggi: row.key, L: row.L, M: row.M, S: row.S }))
console.log(`  wfh_L: ${result.wfh_L.length} baris`)
console.log(`  wfh_P: ${result.wfh_P.length} baris`)

// ── Tulis ke file JSON ───────────────────────────────────────
fs.writeFileSync('./whoTables.json', JSON.stringify(result, null, 2), 'utf8')

console.log('\n✓ whoTables.json berhasil dibuat!')
console.log('Copy file ini ke src/constants/ di project Express.')
console.log('\nRingkasan:')
console.log(`  bbu_L : ${result.bbu_L.length} bulan (0-60)`)
console.log(`  bbu_P : ${result.bbu_P.length} bulan (0-60)`)
console.log(`  tbu_L : ${result.tbu_L.length} bulan (0-60)`)
console.log(`  tbu_P : ${result.tbu_P.length} bulan (0-60)`)
console.log(`  wfl_L : ${result.wfl_L.length} titik (per 0.1 cm)`)
console.log(`  wfl_P : ${result.wfl_P.length} titik (per 0.1 cm)`)
console.log(`  wfh_L : ${result.wfh_L.length} titik (per 0.1 cm)`)
console.log(`  wfh_P : ${result.wfh_P.length} titik (per 0.1 cm)`)