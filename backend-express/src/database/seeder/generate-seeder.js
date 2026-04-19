import bcrypt from 'bcrypt';
import { uuidv7 } from 'uuidv7';
import fs from 'fs';

const SALT_ROUNDS = 10;

const accounts = {
    kader: [
        {
            nama_lengkap: 'Riri',
            email: 'meongterbang22@gmail.com',
            password: 'password123',
            no_hp: '081234567890',
        }
    ],
    puskesmas: [
        {
            nama_lengkap: 'Ciko',
            email: 'bullmini123@gmail.com',
            password: 'password123',
            no_hp: '081234567891',
            jabatan: 'Bidan'
        }
    ]
}

async function generateSeeder() {
    console.log('Generating seeder...\n');
    const lines = [];

    lines.push('USE posyandu_pui')
    lines.push('')

    for (const data of accounts.kader) {
        const userId = uuidv7();
        const kaderId = uuidv7();
        const hash = await bcrypt.hash(data.password, SALT_ROUNDS);

        console.log(`Kader: ${data.nama_lengkap}`)
        console.log(`Email: ${data.email}`) 
        console.log(`Password: ${data.password}`)
        console.log(`UserId: ${userId}`)
        console.log(`KaderId: ${kaderId}\n`)

        lines.push(`INSERT INTO users (id, email, password_hash, role, is_active)`)
        lines.push(`VALUES ('${userId}', '${data.email}', '${hash}', 'kader', TRUE);`)
        lines.push('')
        lines.push(`INSERT INTO kader (id, user_id, nama_lengkap, no_hp)`)
        lines.push(`VALUES ('${kaderId}', '${userId}', '${data.nama_lengkap}', '${data.no_hp}');`)
        lines.push('')
    }

    for (const data of accounts.puskesmas) {
        const userId = uuidv7();
        const puskesmasId = uuidv7();
        const hash = await bcrypt.hash(data.password, SALT_ROUNDS);

        console.log(`Puskesmas: ${data.nama_lengkap}`)
        console.log(`Email: ${data.email}`) 
        console.log(`Password: ${data.password}`)
        console.log(`UserId: ${userId}`)
        console.log(`PusksId: ${puskesmasId}\n`)

        lines.push(`INSERT INTO users (id, email, password_hash, role, is_active)`)
        lines.push(`VALUES ('${userId}', '${data.email}', '${hash}', 'puskesmas', TRUE);`)
        lines.push('')
        lines.push(`INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp)`)
        lines.push(`VALUES ('${puskesmasId}', '${userId}', '${data.nama_lengkap}', '${data.jabatan}', '${data.no_hp}');`)
        lines.push('')
    }

    fs.writeFileSync('./src/database/seeder/seeder.sql', lines.join('\n'), 'utf8')
    console.log('seeder.sql berhasil dibuat!')
    console.log('Jalankan seeder.sql di Datagrip')
}

generateSeeder().catch(console.error)