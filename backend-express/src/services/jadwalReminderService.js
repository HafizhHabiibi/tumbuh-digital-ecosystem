import * as JadwalModel from "../models/jadwalModel.js";
import { sendBulkNotifications } from "./fcmService.js";

const WIB_OFFSET_MS = 7 * 60 * 60 * 1_000;
const H1_START_MINUTE = 8 * 60;
const H_START_MINUTE = 6 * 60;

export const JADWAL_REMINDER_INTERVAL_MS = 15 * 60 * 1_000;

const addCalendarDays = (dateText, days) => {
    const date = new Date(`${dateText}T00:00:00.000Z`);
    date.setUTCDate(date.getUTCDate() + days);
    return date.toISOString().slice(0, 10);
};

const getWibClock = (now) => {
    const shifted = new Date(now.getTime() + WIB_OFFSET_MS);
    return {
        tanggalHariIni: shifted.toISOString().slice(0, 10),
        menitHariIni: shifted.getUTCHours() * 60 + shifted.getUTCMinutes(),
    };
};

const formatTanggalIndonesia = (dateText) => {
    const [year, month, day] = dateText.split("-").map(Number);
    return new Intl.DateTimeFormat("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
        timeZone: "UTC",
    }).format(new Date(Date.UTC(year, month - 1, day)));
};

const formatWaktu = (value) => String(value).slice(0, 5);

const buildReminderPayload = (jadwal, reminderType) => {
    const tanggal = formatTanggalIndonesia(jadwal.tanggal);
    const waktu = `${formatWaktu(jadwal.waktu_mulai)}–${formatWaktu(jadwal.waktu_selesai)}`;
    if (reminderType === "h1") {
        return [
            "Pengingat Posyandu Besok",
            `Posyandu akan dilaksanakan besok, ${tanggal}, pukul ${waktu} di ${jadwal.lokasi}.`,
            "jadwal",
            jadwal.id,
        ];
    }
    return [
        "Posyandu Hari Ini",
        `Jangan lupa menghadiri Posyandu hari ini, ${tanggal}, pukul ${waktu} di ${jadwal.lokasi}.`,
        "jadwal",
        jadwal.id,
    ];
};

export const processScheduleReminders = async ({
    now = new Date(),
    findPendingReminders = JadwalModel.findPendingReminders,
    findRecipients = JadwalModel.findAllOrangTua,
    sendBulk = sendBulkNotifications,
    markSent = JadwalModel.markReminderSent,
} = {}) => {
    const { tanggalHariIni, menitHariIni } = getWibClock(now);
    const tanggalBesok = addCalendarDays(tanggalHariIni, 1);
    const candidates = await findPendingReminders(
        tanggalHariIni,
        tanggalBesok,
    );
    const due = candidates.flatMap((jadwal) => {
        if (
            jadwal.tanggal === tanggalBesok &&
            !jadwal.reminder_h1_sent_at &&
            menitHariIni >= H1_START_MINUTE
        ) {
            return [{ jadwal, reminderType: "h1" }];
        }
        if (
            jadwal.tanggal === tanggalHariIni &&
            !jadwal.reminder_h_sent_at &&
            menitHariIni >= H_START_MINUTE
        ) {
            return [{ jadwal, reminderType: "h" }];
        }
        return [];
    });

    if (due.length === 0) {
        return { processed: 0, recipients: 0 };
    }

    const recipients = await findRecipients();
    for (const item of due) {
        await sendBulk(
            recipients,
            () => buildReminderPayload(item.jadwal, item.reminderType),
        );
        await markSent(item.jadwal.id, item.reminderType);
    }

    return { processed: due.length, recipients: recipients.length };
};
