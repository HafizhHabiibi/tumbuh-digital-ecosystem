<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <header>
            <h1
                class="text-2xl font-bold m-0"
                style="color: var(--color-text-heading)"
            >
                Data Anak
            </h1>
            <p class="text-sm mt-1 m-0" style="color: var(--color-text-muted)">
                Daftar anak dan akses riwayat pemantauan di wilayah kerja
                Puskesmas.
            </p>
        </header>

        <div class="card p-4 rounded-2xl flex flex-col md:flex-row gap-4">
            <div class="relative flex-1">
                <i class="pi pi-search input-icon" aria-hidden="true" />
                <input
                    v-model="search"
                    class="input-field w-full pl-10 pr-4 py-2.5 rounded-xl text-sm"
                    type="search"
                    placeholder="Cari nama anak atau orang tua..."
                />
            </div>
            <select
                v-model="filterJenisKelamin"
                class="input-field w-full md:w-52 px-4 py-2.5 rounded-xl text-sm"
                aria-label="Filter jenis kelamin"
            >
                <option value="semua">Semua jenis kelamin</option>
                <option value="L">Laki-laki</option>
                <option value="P">Perempuan</option>
            </select>
        </div>

        <div class="card rounded-2xl overflow-hidden">
            <div v-if="store.loading.anakList" class="p-6 space-y-3">
                <div v-for="item in 5" :key="item" class="skeleton h-14 rounded-xl" />
            </div>

            <div
                v-else-if="store.error.anakList"
                class="p-12 flex flex-col items-center gap-3 text-center"
                role="alert"
            >
                <i class="pi pi-exclamation-circle text-4xl text-red-600" />
                <p class="text-sm m-0" style="color: var(--color-text-muted)">
                    {{ store.error.anakList }}
                </p>
                <button class="btn-primary" @click="loadData()">Coba Lagi</button>
            </div>

            <div
                v-else-if="filteredAnak.length === 0"
                class="p-14 flex flex-col items-center gap-3 text-center"
            >
                <i class="pi pi-users text-4xl" style="color: var(--color-text-muted)" />
                <p class="text-sm m-0" style="color: var(--color-text-muted)">
                    {{ search || filterJenisKelamin !== "semua"
                        ? "Tidak ada data yang cocok."
                        : "Belum ada anak terdaftar." }}
                </p>
            </div>

            <div v-else class="overflow-x-auto">
                <table class="w-full text-sm" aria-label="Daftar anak Puskesmas">
                    <thead>
                        <tr class="table-head">
                            <th class="th-cell">Nama Anak</th>
                            <th class="th-cell">Jenis Kelamin</th>
                            <th class="th-cell hidden md:table-cell">Tanggal Lahir</th>
                            <th class="th-cell hidden lg:table-cell">Usia</th>
                            <th class="th-cell">Orang Tua</th>
                            <th class="th-cell text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="(anak, index) in filteredAnak"
                            :key="anak.id"
                            class="table-row"
                            :class="{ 'bg-green-soft': index % 2 !== 0 }"
                        >
                            <td class="px-4 py-3">
                                <div class="font-semibold" style="color: var(--color-text-heading)">
                                    {{ anak.nama }}
                                </div>
                                <div class="text-xs md:hidden" style="color: var(--color-text-muted)">
                                    {{ hitungUsia(anak.tanggal_lahir) }}
                                </div>
                            </td>
                            <td class="px-4 py-3">
                                <StatusBadge type="jk" :value="anak.jenis_kelamin" />
                            </td>
                            <td class="px-4 py-3 hidden md:table-cell" style="color: var(--color-text-body)">
                                {{ formatTanggal(anak.tanggal_lahir) }}
                            </td>
                            <td class="px-4 py-3 hidden lg:table-cell" style="color: var(--color-text-body)">
                                {{ hitungUsia(anak.tanggal_lahir) }}
                            </td>
                            <td class="px-4 py-3" style="color: var(--color-text-body)">
                                {{ anak.nama_orang_tua || "—" }}
                            </td>
                            <td class="px-4 py-3 text-center">
                                <button
                                    class="btn-detail"
                                    :aria-label="`Lihat riwayat ${anak.nama}`"
                                    @click="lihatDetail(anak.id)"
                                >
                                    <i class="pi pi-eye" aria-hidden="true" />
                                    Detail
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <PaginationControls
                :pagination="store.pagination"
                :loading="store.loading.anakList"
                @change-page="loadData"
            />
        </div>
    </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useRouter } from "vue-router";
import { usePuskesmasStore } from "@/stores/puskesmasStore";
import { formatTanggal, hitungUsia } from "@/utils/format";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";

const router = useRouter();
const store = usePuskesmasStore();
const search = ref("");
const filterJenisKelamin = ref("semua");

const filteredAnak = computed(() => {
    const query = search.value.trim().toLocaleLowerCase("id-ID");
    return store.anakList.filter((anak) => {
        const cocokJenisKelamin =
            filterJenisKelamin.value === "semua" ||
            anak.jenis_kelamin === filterJenisKelamin.value;
        const cocokPencarian =
            !query ||
            [anak.nama, anak.nama_orang_tua]
                .filter(Boolean)
                .some((value) =>
                    String(value).toLocaleLowerCase("id-ID").includes(query),
                );
        return cocokJenisKelamin && cocokPencarian;
    });
});

const loadData = (page = store.pagination.page) =>
    store.fetchAllAnak({ page });

const lihatDetail = (id) =>
    router.push({ name: "PuskesmasDetailAnak", params: { id } });

onMounted(() => loadData());
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.input-icon {
    position: absolute;
    left: 0.875rem;
    top: 50%;
    transform: translateY(-50%);
    color: var(--color-text-muted);
}
.table-head, .bg-green-soft { background: var(--color-green-50); }
.th-cell {
    padding: 0.75rem 1rem;
    text-align: left;
    color: var(--color-text-muted);
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}
.table-row:hover { background: var(--color-green-50); }
.btn-primary, .btn-detail {
    border: 0;
    border-radius: 0.625rem;
    background: var(--color-green-700);
    color: white;
    cursor: pointer;
    font-size: 0.75rem;
    font-weight: 600;
    padding: 0.5rem 0.875rem;
}
.btn-detail { display: inline-flex; align-items: center; gap: 0.375rem; }
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
}
@keyframes shimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
}
</style>
