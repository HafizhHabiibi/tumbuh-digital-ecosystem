<template>
    <AppLayout
        page-title="Selamat Datang, Siti Aminah"
        active-menu="Dashboard"
        :user="user"
        :has-notification="hasNotification"
        @logout="handleLogout"
        @notification="handleNotification"
        @settings="handleSettings"
    >
        <!-- Error Banner -->
        <div v-if="error" class="error-banner">
            <span class="material-symbols-outlined">error</span>
            {{ error }}
            <button class="error-retry" @click="fetchDashboard">
                Coba Lagi
            </button>
        </div>

        <!-- Stats Row -->
        <div class="stats-grid">
            <StatCard
                icon="groups"
                tag="Total Terdata"
                :value="stats.totalAnak"
                label="Anak Terdaftar"
                bg-color="rgba(114,218,114,0.15)"
                border="1px solid rgba(0,110,28,0.1)"
                icon-bg="rgba(0,110,28,0.1)"
                icon-color="#006e1c"
                tag-color="#006e1c"
                value-color="#171d16"
                label-color="#3f4a3c"
                :loading="loadingStats"
            />
            <StatCard
                icon="warning"
                :icon-fill="true"
                :tag="stats.risikoTag"
                :value="stats.risikoTinggi"
                label="Anak Risiko Tinggi"
                bg-color="#ffccbc"
                icon-bg="rgba(186,26,26,0.1)"
                icon-color="#ba1a1a"
                tag-color="#7b5549"
                tag-bg="rgba(255,255,255,0.5)"
                value-color="#7a5448"
                label-color="#7a5448"
                :loading="loadingStats"
            />
            <StatCard
                icon="medical_services"
                tag="Aktif"
                :value="stats.rujukanAktif"
                label="Kasus Rujukan"
                bg-color="#FFF9C4"
                icon-bg="rgba(139,78,64,0.1)"
                icon-color="#8b4e40"
                tag-color="#8b4e40"
                value-color="#7a4033"
                label-color="#7a4033"
                :loading="loadingStats"
            />
            <StatCard
                icon="straighten"
                :tag="stats.pengukuranPeriode"
                :value="stats.pengukuranSelesai"
                :value-suffix="`/${stats.totalAnak}`"
                :label="`Target Selesai ${stats.pengukuranPersen}%`"
                bg-color="#ffffff"
                border="1px solid #becab8"
                icon-bg="#dee4d8"
                icon-color="#3f4a3c"
                tag-color="#3f4a3c"
                value-color="#171d16"
                suffix-color="#3f4a3c"
                label-color="#3f4a3c"
                :show-progress="true"
                :progress="stats.pengukuranPersen"
                progress-color="#006e1c"
                :loading="loadingStats"
            />
        </div>

        <!-- Charts Row -->
        <div class="charts-grid">
            <DonutChart
                title="Distribusi Status Gizi"
                action-label="Lihat Detail"
                :total="stats.totalAnak"
                :segments="giziSegments"
                :loading="loadingCharts"
                @action="handleGiziDetail"
            />
            <BarChart
                title="Trend Partisipasi"
                subtitle="Pemantauan pertumbuhan 6 bulan terakhir"
                :tabs="['Bulanan', 'Tahunan']"
                :bars="barData"
                :loading="loadingCharts"
                @tab-change="handleBarTabChange"
            />
        </div>

        <!-- Risk Table -->
        <RiskTable
            title="Ranking Risiko Stunting"
            :children="childrenData"
            :total-data="tableMeta.total"
            :page-size="tableMeta.pageSize"
            :current-page="tableMeta.currentPage"
            :loading="loadingTable"
            @page-change="handlePageChange"
            @search="handleSearch"
            @detail="handleDetail"
            @filter="handleFilter"
        />
    </AppLayout>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";

// Layout & komponen baru
import AppLayout from "@/layouts/AppLayout.vue";
import StatCard from "@/components/StatCard.vue";

// Komponen chart & tabel tetap dari folder dashboard
import DonutChart from "@/components/dashboard/DonutChart.vue";
import BarChart from "@/components/dashboard/BarChart.vue";
import RiskTable from "@/components/dashboard/RiskTable.vue";

// ── User ───────────────────────────────────────────────────────────────
// Ganti dengan data dari auth store (Pinia) saat backend sudah siap
const user = reactive({
    name: "Siti Aminah",
    role: "Kader Posyandu",
    posyandu: "Posyandu Melati IV",
});
const hasNotification = ref(false);

// ── Loading & Error ────────────────────────────────────────────────────
const loadingStats = ref(false);
const loadingCharts = ref(false);
const loadingTable = ref(false);
const error = ref(null);

// ── Stats ──────────────────────────────────────────────────────────────
const stats = reactive({
    totalAnak: 0,
    risikoTinggi: 0,
    risikoTag: "",
    rujukanAktif: 0,
    pengukuranSelesai: 0,
    pengukuranPersen: 0,
    pengukuranPeriode: "",
});

// ── Chart ──────────────────────────────────────────────────────────────
const giziSegments = ref([]);
const barData = ref([]);
const barPeriode = ref("Bulanan");

// ── Table ──────────────────────────────────────────────────────────────
const childrenData = ref([]);
const tableMeta = reactive({
    total: 0,
    pageSize: 10,
    currentPage: 1,
    search: "",
});

// ── API ────────────────────────────────────────────────────────────────
const BASE_URL = import.meta.env.VITE_API_URL ?? "http://localhost:8000/api";

async function apiFetch(path, options = {}) {
    const token = localStorage.getItem("auth_token");
    const res = await fetch(`${BASE_URL}${path}`, {
        ...options,
        headers: {
            "Content-Type": "application/json",
            ...(token ? { Authorization: `Bearer ${token}` } : {}),
            ...options.headers,
        },
    });
    if (!res.ok) throw new Error(`API error ${res.status}: ${res.statusText}`);
    return res.json();
}

async function fetchStats() {
    loadingStats.value = true;
    try {
        const data = await apiFetch("/dashboard/stats");
        Object.assign(stats, {
            totalAnak: data.total_anak,
            risikoTinggi: data.risiko_tinggi,
            risikoTag: data.risiko_tag,
            rujukanAktif: data.rujukan_aktif,
            pengukuranSelesai: data.pengukuran_selesai,
            pengukuranPersen: data.pengukuran_persen,
            pengukuranPeriode: data.pengukuran_periode,
        });
        hasNotification.value = data.has_notification ?? false;
    } catch (e) {
        error.value = "Gagal memuat statistik. " + e.message;
    } finally {
        loadingStats.value = false;
    }
}

async function fetchCharts(periode = "Bulanan") {
    loadingCharts.value = true;
    try {
        const data = await apiFetch(`/dashboard/charts?periode=${periode}`);
        giziSegments.value = data.gizi.map((g) => ({
            label: g.label,
            display: `${g.count} (${Math.round((g.count / g.total) * 100)}%)`,
            percentage: Math.round((g.count / g.total) * 100),
            color: g.color,
        }));
        barData.value = data.partisipasi;
    } catch (e) {
        error.value = "Gagal memuat grafik. " + e.message;
    } finally {
        loadingCharts.value = false;
    }
}

async function fetchTable() {
    loadingTable.value = true;
    try {
        const params = new URLSearchParams({
            page: tableMeta.currentPage,
            limit: tableMeta.pageSize,
            search: tableMeta.search,
        });
        const data = await apiFetch(`/dashboard/risiko?${params}`);
        childrenData.value = data.data.map(mapRisikoColors);
        tableMeta.total = data.total;
    } catch (e) {
        error.value = "Gagal memuat tabel risiko. " + e.message;
    } finally {
        loadingTable.value = false;
    }
}

function mapRisikoColors(child) {
    const map = {
        "Risiko Tinggi": {
            scoreColor: "#ba1a1a",
            badgeBg: "#ffccbc",
            badgeColor: "#7a5448",
        },
        "Risiko Sedang": {
            scoreColor: "#8b4e40",
            badgeBg: "#FFF9C4",
            badgeColor: "#8b4e40",
        },
        "Risiko Rendah": {
            scoreColor: "#006e1c",
            badgeBg: "rgba(114,218,114,0.2)",
            badgeColor: "#006e1c",
        },
    };
    const colors = map[child.kategori_risiko] ?? map["Risiko Rendah"];
    return {
        name: child.nama,
        age: child.usia_bulan,
        bb: child.berat_badan,
        tb: child.tinggi_badan,
        score: child.skor_saw,
        risk: child.kategori_risiko,
        ...colors,
    };
}

async function fetchDashboard() {
    error.value = null;
    await Promise.all([
        fetchStats(),
        fetchCharts(barPeriode.value),
        fetchTable(),
    ]);
}

onMounted(fetchDashboard);

// ── Handlers ───────────────────────────────────────────────────────────
function handleLogout() {
    localStorage.removeItem("auth_token"); /* router.push('/login') */
}
function handleNotification() {
    /* buka panel notifikasi */
}
function handleSettings() {
    /* navigasi ke settings */
}
function handleGiziDetail() {
    /* navigasi ke detail gizi */
}
function handleDetail(child) {
    /* router.push(`/anak/${child.id}`) */
}

async function handleBarTabChange(periode) {
    barPeriode.value = periode;
    await fetchCharts(periode);
}
async function handlePageChange(page) {
    tableMeta.currentPage = page;
    await fetchTable();
}
async function handleSearch(query) {
    tableMeta.search = query;
    tableMeta.currentPage = 1;
    await fetchTable();
}
function handleFilter() {
    /* buka modal filter */
}
</script>

<style scoped>
.stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1.5rem;
}
@media (max-width: 1024px) {
    .stats-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}
@media (max-width: 640px) {
    .stats-grid {
        grid-template-columns: 1fr;
    }
}

.charts-grid {
    display: grid;
    grid-template-columns: 5fr 7fr;
    gap: 1.5rem;
}
@media (max-width: 1024px) {
    .charts-grid {
        grid-template-columns: 1fr;
    }
}

.error-banner {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1.25rem;
    background: #ffdad6;
    color: #93000a;
    border-radius: 0.75rem;
    font-size: 14px;
    font-weight: 500;
}
.error-retry {
    margin-left: auto;
    padding: 4px 12px;
    background: #93000a;
    color: #fff;
    border: none;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
}
</style>
