<template>
    <article class="space-y-4 pt-3">
        <header class="flex items-start justify-between flex-wrap gap-3">
            <div>
                <p class="eyebrow">Status Rujukan</p>
                <h2 class="text-base font-bold text-slate-800 mt-1 mb-0">
                    {{ LABEL_STATUS[rujukan.status] ?? rujukan.status }}
                </h2>
            </div>
            <span
                class="text-xs px-3 py-1.5 rounded-full font-semibold"
                :style="`background: ${warnaBg[rujukan.status]}; color: ${warnaHex[rujukan.status]}`"
            >
                {{ formatTanggal(rujukan.created_at) }}
            </span>
        </header>

        <section class="rounded-xl border border-slate-200 p-4" aria-labelledby="timeline-title">
            <p id="timeline-title" class="section-title">Perjalanan Rujukan</p>
            <ol class="timeline mt-3">
                <li
                    v-for="(step, index) in timelineSteps"
                    :key="step.key"
                    class="timeline-step"
                    :class="{ 'timeline-step--complete': step.complete, 'timeline-step--current': step.current }"
                >
                    <div class="timeline-marker">
                        <i :class="step.complete ? 'pi pi-check' : 'pi pi-circle-fill'" aria-hidden="true" />
                    </div>
                    <div class="min-w-0">
                        <p class="text-xs font-bold text-slate-700 m-0">{{ step.label }}</p>
                        <p class="text-[10px] text-slate-400 mt-1 mb-0">{{ step.date }}</p>
                        <p v-if="index === 1 && rujukan.ditangani_oleh" class="text-[10px] text-slate-500 mt-1 mb-0">
                            {{ rujukan.ditangani_oleh }}
                        </p>
                    </div>
                </li>
            </ol>
        </section>

        <section class="rounded-xl bg-emerald-50 border border-emerald-100 p-4">
            <p class="section-title">Identitas Anak</p>
            <dl class="info-grid mt-3">
                <div><dt>Nama Anak</dt><dd>{{ rujukan.nama_anak || "—" }}</dd></div>
                <div><dt>Orang Tua</dt><dd>{{ rujukan.nama_orang_tua || "—" }}</dd></div>
                <div><dt>Tanggal Lahir</dt><dd>{{ formatTanggal(rujukan.tanggal_lahir) }}</dd></div>
                <div>
                    <dt>Nomor HP Orang Tua</dt>
                    <dd>
                        <a
                            v-if="rujukan.no_hp_orang_tua"
                            :href="`tel:${rujukan.no_hp_orang_tua}`"
                            class="text-emerald-700 hover:underline"
                        >
                            {{ rujukan.no_hp_orang_tua }}
                        </a>
                        <span v-else>—</span>
                    </dd>
                </div>
            </dl>
        </section>

        <section class="rounded-xl border border-slate-200 p-4 space-y-3">
            <div class="flex items-start justify-between gap-3 flex-wrap">
                <div>
                    <p class="section-title">Dasar Pengukuran</p>
                    <p class="text-[11px] text-slate-400 mt-1 mb-0">
                        Diukur pada {{ formatTanggal(rujukan.tanggal_ukur) }}
                    </p>
                </div>
                <span
                    class="text-xs px-2.5 py-1 rounded-full font-semibold capitalize"
                    :style="`background: ${warnaBg[rujukan.prioritas_pemantauan?.kategori]}; color: ${warnaHex[rujukan.prioritas_pemantauan?.kategori]}`"
                >
                    Prioritas {{ rujukan.prioritas_pemantauan?.kategori ?? "—" }}
                </span>
            </div>

            <dl class="metric-grid">
                <div><dt>Berat Badan</dt><dd>{{ formatUkuran(rujukan.berat_badan) }} <small>kg</small></dd></div>
                <div><dt>Tinggi Badan</dt><dd>{{ formatUkuran(rujukan.tinggi_badan) }} <small>cm</small></dd></div>
                <div><dt>Lingkar Kepala</dt><dd>{{ measurement(rujukan.lingkar_kepala) }}</dd></div>
                <div><dt>Lingkar Lengan Atas</dt><dd>{{ measurement(rujukan.lingkar_lengan) }}</dd></div>
                <div><dt>Indeks Massa Tubuh</dt><dd>{{ formatNullable(rujukan.nilai_imt) }} <small>kg/m²</small></dd></div>
            </dl>

            <div class="divide-y divide-slate-100 border border-slate-100 rounded-xl overflow-hidden">
                <div v-for="item in statusAntropometri" :key="item.label" class="flex items-center justify-between gap-3 px-3 py-2.5">
                    <div>
                        <p class="text-xs font-semibold text-slate-700 m-0">{{ item.label }}</p>
                        <p class="text-[10px] text-slate-400 mt-0.5 mb-0">{{ item.shortLabel }}</p>
                    </div>
                    <span class="text-xs font-semibold text-slate-700 capitalize text-right">
                        {{ formatStatus(item.value) }}
                    </span>
                </div>
            </div>

            <div class="flex items-center justify-between gap-3 px-3 py-2 rounded-lg bg-slate-50 text-xs">
                <span class="text-slate-500">Skor analisis risiko (SAW)</span>
                <strong class="font-mono text-slate-700">{{ formatSkor(rujukan.skor_saw) }}</strong>
            </div>
        </section>

        <section class="rounded-xl border border-slate-200 p-4 space-y-2">
            <p class="section-title">Catatan Kader</p>
            <p class="text-sm text-slate-700 leading-relaxed whitespace-pre-wrap m-0">{{ rujukan.catatan_kader || "—" }}</p>
            <p class="text-[11px] text-slate-400 m-0">Diajukan oleh {{ rujukan.nama_kader || "—" }}</p>
        </section>

        <section class="rounded-xl border border-slate-200 p-4 space-y-2">
            <p class="section-title">Catatan Puskesmas</p>
            <p class="text-sm text-slate-700 leading-relaxed whitespace-pre-wrap m-0">
                {{ rujukan.catatan_puskesmas || "Belum ada catatan dari puskesmas." }}
            </p>
            <p v-if="rujukan.ditangani_oleh" class="text-[11px] text-slate-400 m-0">
                Ditangani oleh {{ rujukan.ditangani_oleh }}
            </p>
        </section>
    </article>
</template>

<script setup>
import { computed } from "vue";
import { LABEL_STATUS } from "@/stores/rujukanStore";
import { formatTanggal, formatUkuran } from "@/utils/format.js";

const props = defineProps({
    rujukan: { type: Object, required: true },
});

const warnaHex = {
    diajukan: "#2563eb",
    ditangani: "#b45309",
    selesai: "#475569",
    rendah: "#15803d",
    sedang: "#b45309",
    tinggi: "#dc2626",
};
const warnaBg = {
    diajukan: "#dbeafe",
    ditangani: "#fef3c7",
    selesai: "#e2e8f0",
    rendah: "#dcfce7",
    sedang: "#fef3c7",
    tinggi: "#fee2e2",
};

const timelineSteps = computed(() => {
    const currentIndex = { diajukan: 0, ditangani: 1, selesai: 2 }[props.rujukan.status] ?? 0;
    return [
        { key: "diajukan", label: "Diajukan", timestamp: props.rujukan.created_at },
        { key: "ditangani", label: "Mulai Ditangani", timestamp: props.rujukan.validated_at },
        { key: "selesai", label: "Selesai", timestamp: props.rujukan.completed_at },
    ].map((step, index) => ({
        ...step,
        complete: index <= currentIndex,
        current: index === currentIndex,
        date: step.timestamp ? formatTanggalWaktu(step.timestamp) : "Menunggu",
    }));
});

const statusAntropometri = computed(() => [
    { label: "Berat Badan menurut Umur", shortLabel: "BB/U", value: props.rujukan.status_bbu },
    { label: "Tinggi Badan menurut Umur", shortLabel: "TB/U", value: props.rujukan.status_tbu },
    { label: "Berat Badan menurut Tinggi Badan", shortLabel: "BB/TB", value: props.rujukan.status_bbtb },
    { label: "Indeks Massa Tubuh menurut Umur", shortLabel: "IMT/U", value: props.rujukan.status_imtu },
]);

const formatTanggalWaktu = (value) =>
    value
        ? new Date(value).toLocaleString("id-ID", {
              day: "numeric",
              month: "short",
              year: "numeric",
              hour: "2-digit",
              minute: "2-digit",
          })
        : "Menunggu";

const formatStatus = (value) => value?.replaceAll("_", " ") ?? "—";
const formatNullable = (value) => {
    if (value === null || value === undefined || value === "") return "—";
    const number = Number(value);
    return Number.isFinite(number) ? number.toFixed(2) : "—";
};
const measurement = (value) => (value === null || value === undefined ? "—" : `${formatUkuran(value)} cm`);
const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);
</script>

<style scoped>
.eyebrow,
.section-title {
    margin: 0;
    color: #64748b;
    font-size: 0.68rem;
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
}
.timeline {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 0.5rem;
    margin-bottom: 0;
    padding: 0;
    list-style: none;
}
.timeline-step {
    position: relative;
    display: flex;
    gap: 0.5rem;
    color: #cbd5e1;
}
.timeline-step:not(:last-child)::after {
    position: absolute;
    top: 0.65rem;
    left: 1.15rem;
    right: -0.25rem;
    height: 2px;
    background: #e2e8f0;
    content: "";
}
.timeline-step--complete:not(:last-child)::after { background: #86efac; }
.timeline-marker {
    z-index: 1;
    display: grid;
    flex: 0 0 1.35rem;
    width: 1.35rem;
    height: 1.35rem;
    place-items: center;
    border-radius: 999px;
    background: #e2e8f0;
    color: white;
    font-size: 0.55rem;
}
.timeline-step--complete .timeline-marker { background: #16a34a; }
.timeline-step--current .timeline-marker { box-shadow: 0 0 0 3px #dcfce7; }
.info-grid,
.metric-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 0.75rem;
    margin-bottom: 0;
}
.info-grid dt,
.metric-grid dt { color: #94a3b8; font-size: 0.68rem; }
.info-grid dd,
.metric-grid dd { margin: 0.2rem 0 0; color: #334155; font-size: 0.78rem; font-weight: 700; }
.metric-grid > div { padding: 0.65rem; border-radius: 0.7rem; background: #f8fafc; }
.metric-grid small { color: #64748b; font-weight: 500; }
@media (max-width: 520px) {
    .timeline { grid-template-columns: 1fr; gap: 0.75rem; }
    .timeline-step:not(:last-child)::after {
        top: 1.1rem;
        bottom: -0.75rem;
        left: 0.65rem;
        width: 2px;
        height: auto;
    }
    .info-grid,
    .metric-grid { grid-template-columns: 1fr; }
}
</style>
