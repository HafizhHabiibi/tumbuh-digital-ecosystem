import test from 'node:test'
import assert from 'node:assert/strict'
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const directory = path.dirname(fileURLToPath(import.meta.url))
const readJson = (relativePath) => JSON.parse(
    fs.readFileSync(path.join(directory, relativePath), 'utf8'),
)
const checksum = (value) => crypto
    .createHash('sha256')
    .update(JSON.stringify(value))
    .digest('hex')
const generated = readJson('whoTables.json')

const EXPECTED_PHYSICAL_TABLE_CHECKSUMS = Object.freeze({
    wfl_boys: '5422866b698d7c5931e14a845f58be24b4412456b6dc263516600e90a3869f2a',
    wfl_girls: '4260c514df1b0b1ae450113beec39cf3ded95aa5f192ccfd44923e5be4e4c642',
    wfh_boys: '04250a0b0129564c28ca1d7a64ce4aea5113c84445319aa3d1865b7f844495b7',
    wfh_girls: '37c568a96edad772a48a99a1f7a3c4bba09e2c0372d4a41a4a45a0338e1a92f2',
})

test('hasil konversi berisi tepat 10 tabel WHO', () => {
    assert.deepEqual(Object.keys(generated).sort(), [
        'bfa_boys',
        'bfa_girls',
        'lhfa_boys',
        'lhfa_girls',
        'wfa_boys',
        'wfa_girls',
        'wfh_boys',
        'wfh_girls',
        'wfl_boys',
        'wfl_girls',
    ])
})

test('checksum tabel wfl dan wfh sesuai sumber WHO yang diverifikasi', () => {
    for (const [key, expected] of Object.entries(EXPECTED_PHYSICAL_TABLE_CHECKSUMS)) {
        assert.equal(checksum(generated[key]), expected, key)
    }
})

test('converter memiliki tepat 10 file Excel sumber', () => {
    const sourceFiles = fs.readdirSync(path.join(directory, 'who-data'))
        .filter((filename) => filename.endsWith('.xlsx'))
    assert.equal(sourceFiles.length, 10)
})

test('tabel berbasis usia mempertahankan urutan harian 0 sampai 1856', () => {
    for (const key of ['wfa_boys', 'wfa_girls', 'lhfa_boys', 'lhfa_girls', 'bfa_boys', 'bfa_girls']) {
        assert.equal(generated[key].length, 1857, key)
        generated[key].forEach((row, index) => assert.equal(row.day, index, `${key}[${index}]`))
    }
})
