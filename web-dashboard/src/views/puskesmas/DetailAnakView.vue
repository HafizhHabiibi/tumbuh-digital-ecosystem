<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Back Navigation ──────────────────────────────────── -->
        <div class="flex items-center">
            <button
                type="button"
                class="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 hover:text-slate-900 transition-all shadow-2xs cursor-pointer"
                @click="router.push({ name: 'PuskesmasAnak' })"
            >
                <i class="pi pi-arrow-left text-xs text-slate-400" />
                <span>Kembali ke Data Anak</span>
            </button>
        </div>

        <!-- ─── Loading State ────────────────────────────────────── -->
        <div v-if="puskesmasStore.loading.anakDetail" class="space-y-4">
            <div class="skeleton h-36 rounded-2xl" />
            <div class="skeleton h-20 rounded-2xl" />
            <div class="skeleton h-12 rounded-xl" />
            <div class="skeleton h-64 rounded-2xl" />
        </div>

        <!-- ─── Error State ──────────────────────────────────────── -->
        <div
            v-else-if="puskesmasStore.error.anakDetail"
            class="bg-white p-8 rounded-2xl border border-red-100 flex flex-col items-center gap-3 text-center shadow-xs"
            role="alert"
        >
            <i class="pi pi-exclamation-circle text-4xl text-red-600" aria-hidden="true" />
            <p class="text-sm m-0 text-slate-500">
                {{ puskesmasStore.error.anakDetail }}
            </p>
            <button
                class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white cursor-pointer"
                @click="fetchData"
            >
                Coba Lagi
            </button>
        </div>

        <template v-else-if="puskesmasStore.anakDetail">
            <!-- ─── 1. Hero Card Info Anak (Tanpa Tombol Unduh PDF) ─── -->
            <AnakCard
                :anak="puskesmasStore.anakDetail"
                :status-tbu-terakhir="latestPengukuran?.status_tbu"
            />

            <!-- ─── 2. Vital Stats Row (Ringkasan Terakhir) ──────── -->
            <div
                v-if="latestPengukuran"
                class="space-y-2.5"
            >
                <div class="flex items-center gap-2 px-4">
                    <h2 class="text-xs font-bold uppercase tracking-wider text-slate-800 m-0">
                        Pengukuran Terakhir
                    </h2>
                    <span
                        v-if="latestPengukuran.tanggal_ukur"
                        class="text-xs text-slate-600 font-medium"
                    >
                        • {{ formatTanggal(latestPengukuran.tanggal_ukur) }}
                    </span>
                </div>

                <div class="grid grid-cols-2 lg:grid-cols-4 gap-3.5">
                    <!-- Berat Badan -->
                    <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                        <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center justify-center flex-shrink-0">
                            <i class="pi pi-chart-bar text-sm" />
                        </div>
                        <div class="min-w-0 flex-1">
                            <div class="text-[11px] font-medium text-slate-400">Berat Badan</div>
                            <div class="text-base font-bold text-slate-800 tracking-tight">
                                {{ formatUkuran(latestPengukuran.berat_badan) }}
                                <span class="text-xs font-normal text-slate-400">kg</span>
                            </div>
                        </div>
                    </div>

                    <!-- Tinggi Badan -->
                    <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                        <div class="w-10 h-10 rounded-xl bg-sky-50 text-sky-600 border border-sky-100 flex items-center justify-center flex-shrink-0">
                            <i class="pi pi-arrows-v text-sm" />
                        </div>
                        <div class="min-w-0 flex-1">
                            <div class="text-[11px] font-medium text-slate-400">Tinggi Badan</div>
                            <div class="text-base font-bold text-slate-800 tracking-tight">
                                {{ formatUkuran(latestPengukuran.tinggi_badan) }}
                                <span class="text-xs font-normal text-slate-400">cm</span>
                            </div>
                        </div>
                    </div>

                    <!-- Tinggi Badan / Umur -->
                    <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                        <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 border border-amber-100 flex items-center justify-center flex-shrink-0">
                            <i class="pi pi-heart text-sm" />
                        </div>
                        <div class="min-w-0 flex-1">
                            <div class="text-[11px] font-medium text-slate-400 mb-0.5">Tinggi Badan / Umur</div>
                            <StatusBadge
                                type="antropometri"
                                :value="latestPengukuran.status_tbu"
                            />
                        </div>
                    </div>

                    <!-- Prioritas Pemantauan -->
                    <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                        <div class="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 border border-rose-100 flex items-center justify-center flex-shrink-0">
                            <i class="pi pi-exclamation-circle text-sm" />
                        </div>
                        <div class="min-w-0 flex-1">
                            <div class="text-[11px] font-medium text-slate-400 mb-0.5">Prioritas Pemantauan</div>
                            <StatusBadge
                                type="prioritas"
                                :value="latestPengukuran.prioritas_pemantauan?.kategori"
                            />
                        </div>
                    </div>
                </div>
            </div>

            <!-- ─── 3. Selector Riwayat (Desain Selaras Halaman Kader) ── -->
            <div
                class="bg-slate-100/90 p-1 rounded-2xl flex gap-1 border border-slate-200/70 overflow-x-auto"
                role="tablist"
                aria-label="Pilihan Riwayat Anak"
            >
                <button
                    v-for="tab in tabs"
                    :id="`tab-${tab.key}`"
                    :key="tab.key"
                    type="button"
                    role="tab"
                    :tabindex="activeTab === tab.key ? 0 : -1"
                    :aria-selected="activeTab === tab.key"
                    :aria-controls="`tabpanel-${tab.key}`"
                    class="flex flex-1 min-w-max items-center justify-center gap-2 px-4 py-2.5 rounded-xl text-xs font-semibold transition-all cursor-pointer whitespace-nowrap focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-emerald-600"
                    :class="
                        activeTab === tab.key
                            ? 'bg-emerald-600 text-white shadow-xs'
                            : 'text-slate-600 hover:text-slate-900 hover:bg-slate-200/60'
                    "
                    @click="activeTab = tab.key"
                    @keydown.left.prevent="moveTab(-1)"
                    @keydown.right.prevent="moveTab(1)"
                    @keydown.home.prevent="moveToTab(0)"
                    @keydown.end.prevent="moveToTab(tabs.length - 1)"
                >
                    <span>{{ tab.label }}</span>
                    <span
                        class="min-w-5 px-1.5 py-0.5 rounded-full text-[10px] font-bold text-center transition-colors"
                        :class="
                            activeTab === tab.key
                                ? 'bg-white/20 text-white'
                                : 'bg-slate-200 text-slate-600'
                        "
                    >
                        {{ tab.count }}
                    </span>
                </button>
            </div>

            <!-- ══ TAB 1: Pengukuran & Pertumbuhan ══════════════════ -->
            <div
                v-show="activeTab === 'pengukuran'"
                id="tabpanel-pengukuran"
                role="tabpanel"
                aria-labelledby="tab-pengukuran"
                class="space-y-5"
            >
                <!-- Grafik tren mengikuti standar visual aplikasi -->
                <div
                    v-if="trenPertumbuhan.length > 0"
                    class="space-y-5"
                >
                    <GrowthTrendChart
                        metric="weight"
                        :measurements="riwayatPengukuranList"
                    />
                    <GrowthTrendChart
                        metric="height"
                        :measurements="riwayatPengukuranList"
                    />
                </div>

                <!-- Tabel riwayat pengukuran lengkap -->
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                    <div class="flex items-center justify-between p-4 border-b border-slate-100">
                        <div>
                            <h3 class="text-sm font-bold text-slate-800 m-0">
                                Riwayat Pengukuran
                            </h3>
                            <p class="text-xs text-slate-400 mt-0.5 mb-0">
                                Data diurutkan dari yang terbaru. Geser tabel secara horizontal untuk melihat seluruh hasil.
                            </p>
                        </div>
                        <div>
                            <span
                                class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                            >
                                {{ riwayatPengukuranList.length }} data
                            </span>
                        </div>
                    </div>

                    <div
                        v-if="pengukuranStore.loading.riwayat || puskesmasStore.loading.anakDetail"
                        class="p-4 space-y-3"
                    >
                        <div
                            v-for="i in 3"
                            :key="i"
                            class="skeleton h-12 rounded-xl"
                        />
                    </div>

                    <div
                        v-else-if="riwayatPengukuranList.length === 0"
                        class="flex flex-col items-center py-12 gap-2 text-center"
                    >
                        <i class="pi pi-chart-bar text-3xl text-slate-300" aria-hidden="true" />
                        <p class="text-sm text-slate-500 m-0">
                            Belum ada riwayat pengukuran untuk anak ini
                        </p>
                    </div>

                    <div v-else class="measurement-table-scroll overflow-x-auto">
                        <table
                            class="w-full text-sm text-left border-collapse"
                            aria-label="Riwayat lengkap hasil pengukuran anak"
                        >
                            <thead>
                                <tr class="bg-slate-50/80 border-b border-slate-200/80">
                                    <th class="th-cell min-w-[130px]">Tanggal Pengukuran</th>
                                    <th class="th-cell min-w-[135px]">Usia Saat Pengukuran</th>
                                    <th class="th-cell min-w-[120px]">Berat Badan</th>
                                    <th class="th-cell min-w-[120px]">Tinggi Badan</th>
                                    <th class="th-cell min-w-[125px]">Lingkar Kepala</th>
                                    <th class="th-cell min-w-[145px]">Lingkar Lengan Atas</th>
                                    <th class="th-cell min-w-[145px]">Indeks Massa Tubuh</th>
                                    <th class="th-cell min-w-[210px]">Status Berat Badan menurut Umur</th>
                                    <th class="th-cell min-w-[220px]">Z-Score Berat Badan menurut Umur</th>
                                    <th class="th-cell min-w-[210px]">Status Tinggi Badan menurut Umur</th>
                                    <th class="th-cell min-w-[220px]">Z-Score Tinggi Badan menurut Umur</th>
                                    <th class="th-cell min-w-[235px]">Status Berat Badan menurut Tinggi Badan</th>
                                    <th class="th-cell min-w-[245px]">Z-Score Berat Badan menurut Tinggi Badan</th>
                                    <th class="th-cell min-w-[235px]">Status Indeks Massa Tubuh menurut Umur</th>
                                    <th class="th-cell min-w-[245px]">Z-Score Indeks Massa Tubuh menurut Umur</th>
                                    <th class="th-cell min-w-[175px]">Prioritas Pemantauan</th>
                                    <th class="th-cell min-w-[210px]">Skor Simple Additive Weighting</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 bg-white">
                                <tr
                                    v-for="p in riwayatPengukuranList"
                                    :key="p.id"
                                    class="hover:bg-slate-50/70 transition-colors"
                                >
                                    <!-- Tanggal -->
                                    <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-slate-800">
                                        {{ formatTanggal(p.tanggal_ukur) }}
                                    </td>

                                    <!-- Usia saat pengukuran -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <span class="inline-block px-2.5 py-0.5 rounded-md text-xs font-medium text-slate-600 bg-slate-100/90 border border-slate-200/60">
                                            {{ getUsiaSaatUkur(p.tanggal_ukur) || '—' }}
                                        </span>
                                    </td>

                                    <!-- Berat Badan -->
                                    <td class="px-4 py-3 whitespace-nowrap text-sm font-semibold text-slate-800 tabular-nums">
                                        {{ formatUkuran(p.berat_badan) }}
                                        <span class="text-xs font-normal text-slate-400">kg</span>
                                    </td>

                                    <!-- Tinggi Badan -->
                                    <td class="px-4 py-3 whitespace-nowrap text-sm font-semibold text-slate-800 tabular-nums">
                                        {{ formatUkuran(p.tinggi_badan) }}
                                        <span class="text-xs font-normal text-slate-400">cm</span>
                                    </td>

                                    <!-- Lingkar Kepala -->
                                    <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-slate-700 tabular-nums">
                                        <template v-if="p.lingkar_kepala !== null && p.lingkar_kepala !== undefined">
                                            {{ formatUkuran(p.lingkar_kepala) }}
                                            <span class="text-xs font-normal text-slate-400">cm</span>
                                        </template>
                                        <span v-else class="text-slate-300">—</span>
                                    </td>

                                    <!-- Lingkar Lengan Atas -->
                                    <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-slate-700 tabular-nums">
                                        <template v-if="p.lingkar_lengan !== null && p.lingkar_lengan !== undefined">
                                            {{ formatUkuran(p.lingkar_lengan) }}
                                            <span class="text-xs font-normal text-slate-400">cm</span>
                                        </template>
                                        <span v-else class="text-slate-300">—</span>
                                    </td>

                                    <!-- Indeks Massa Tubuh (IMT) -->
                                    <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-slate-700 tabular-nums">
                                        {{ p.nilai_imt ? Number(p.nilai_imt).toFixed(1) : '—' }}
                                    </td>

                                    <!-- Status Berat Badan menurut Umur -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <StatusBadge
                                            type="antropometri"
                                            :value="p.status_bbu"
                                        />
                                    </td>

                                    <td class="px-4 py-3 whitespace-nowrap font-mono text-xs text-slate-600 tabular-nums">
                                        {{ formatZScore(p.zscore_bbu) }}
                                    </td>

                                    <!-- Status Tinggi Badan menurut Umur -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <StatusBadge
                                            type="antropometri"
                                            :value="p.status_tbu"
                                        />
                                    </td>

                                    <td class="px-4 py-3 whitespace-nowrap font-mono text-xs text-slate-600 tabular-nums">
                                        {{ formatZScore(p.zscore_tbu) }}
                                    </td>

                                    <!-- Status Berat Badan menurut Tinggi Badan -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <StatusBadge
                                            type="antropometri"
                                            :value="p.status_bbtb"
                                        />
                                    </td>

                                    <td class="px-4 py-3 whitespace-nowrap font-mono text-xs text-slate-600 tabular-nums">
                                        {{ formatZScore(p.zscore_bbtb) }}
                                    </td>

                                    <!-- Status Indeks Massa Tubuh menurut Umur -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <StatusBadge
                                            type="antropometri"
                                            :value="p.status_imtu"
                                        />
                                    </td>

                                    <td class="px-4 py-3 whitespace-nowrap font-mono text-xs text-slate-600 tabular-nums">
                                        {{ formatZScore(p.zscore_imtu) }}
                                    </td>

                                    <!-- Prioritas Pemantauan -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <StatusBadge
                                            type="prioritas"
                                            :value="p.prioritas_pemantauan?.kategori"
                                        />
                                    </td>

                                    <td class="px-4 py-3 whitespace-nowrap font-mono text-xs font-semibold text-slate-700 tabular-nums">
                                        {{ formatSkor(p.skor_saw) }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ══ TAB 2: Pemberian PMT & Vitamin ═══════════════════ -->
            <div
                v-show="activeTab === 'pemberian'"
                id="tabpanel-pemberian"
                role="tabpanel"
                aria-labelledby="tab-pemberian"
                class="space-y-4"
            >
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                    <div class="flex items-center justify-between p-4 border-b border-slate-100">
                        <div>
                            <h3 class="text-sm font-bold text-slate-800 m-0">
                                Riwayat Pemberian PMT & Vitamin
                            </h3>
                            <p class="text-xs text-slate-400 mt-0.5 mb-0">
                                Daftar asupan vitamin dan makanan tambahan yang telah dicatat
                            </p>
                        </div>
                        <span
                            class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                        >
                            {{ riwayatPemberianList.length }} data
                        </span>
                    </div>

                    <div
                        v-if="pemberianStore.loading.riwayat || puskesmasStore.loading.pemberian"
                        class="p-4 space-y-3"
                    >
                        <div
                            v-for="i in 3"
                            :key="i"
                            class="skeleton h-12 rounded-xl"
                        />
                    </div>

                    <div
                        v-else-if="riwayatPemberianList.length === 0"
                        class="flex flex-col items-center py-12 gap-2 text-center"
                    >
                        <i class="pi pi-inbox text-3xl text-slate-300" aria-hidden="true" />
                        <p class="text-sm text-slate-500 m-0">
                            Belum ada riwayat pemberian PMT atau vitamin untuk anak ini
                        </p>
                    </div>

                    <div v-else class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-100">
                                    <th class="th-cell">Tanggal</th>
                                    <th class="th-cell">Jenis Pemberian</th>
                                    <th class="th-cell">Dosis</th>
                                    <th class="th-cell hidden md:table-cell">
                                        Dicatat Oleh
                                    </th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 bg-white">
                                <tr
                                    v-for="item in riwayatPemberianList"
                                    :key="item.id"
                                    class="hover:bg-slate-50/80 transition-colors"
                                >
                                    <td class="px-4 py-3.5 text-sm text-slate-700 whitespace-nowrap font-medium">
                                        {{ formatTanggal(item.tanggal_pemberian) }}
                                    </td>
                                    <td class="px-4 py-3.5">
                                        <StatusBadge
                                            :label="
                                                LABEL_JENIS[item.jenis] ?? item.jenis
                                            "
                                            :variant="
                                                variantJenis[item.jenis] ?? 'gray'
                                            "
                                        />
                                    </td>
                                    <td class="px-4 py-3.5 font-medium text-slate-800">
                                        {{ item.dosis ?? "—" }}
                                    </td>
                                    <td class="px-4 py-3.5 hidden md:table-cell text-sm text-slate-500">
                                        {{ item.dicatat_oleh }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ══ TAB 3: Riwayat Rujukan ═══════════════════════════ -->
            <div
                v-show="activeTab === 'rujukan'"
                id="tabpanel-rujukan"
                role="tabpanel"
                aria-labelledby="tab-rujukan"
                class="space-y-4"
            >
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                    <div class="flex items-center justify-between p-4 border-b border-slate-100">
                        <div>
                            <h3 class="text-sm font-bold text-slate-800 m-0">
                                Riwayat Rujukan
                            </h3>
                            <p class="text-xs text-slate-400 mt-0.5 mb-0">
                                Rekam jejak rujukan anak ke fasilitas pelayanan kesehatan
                            </p>
                        </div>
                        <span
                            class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                        >
                            {{ rujukanStore.riwayatAnak.list.length }} data
                        </span>
                    </div>

                    <div
                        v-if="rujukanStore.loading.fetchByAnak"
                        class="p-4 space-y-3"
                    >
                        <div
                            v-for="i in 3"
                            :key="i"
                            class="skeleton h-12 rounded-xl"
                        />
                    </div>

                    <div
                        v-else-if="rujukanStore.riwayatAnak.list.length === 0"
                        class="flex flex-col items-center py-12 gap-2 text-center"
                    >
                        <i class="pi pi-send text-3xl text-slate-300" aria-hidden="true" />
                        <p class="text-sm text-slate-500 m-0">
                            Belum ada riwayat rujukan untuk anak ini
                        </p>
                    </div>

                    <div v-else class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-100">
                                    <th class="th-cell">Tanggal</th>
                                    <th class="th-cell">Status</th>
                                    <th class="th-cell hidden md:table-cell">
                                        Prioritas
                                    </th>
                                    <th class="th-cell hidden md:table-cell">
                                        Ditangani Oleh
                                    </th>
                                    <th class="th-cell text-center w-24">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 bg-white">
                                <tr
                                    v-for="r in rujukanStore.riwayatAnak.list"
                                    :key="r.id"
                                    class="hover:bg-slate-50/80 transition-colors"
                                >
                                    <td class="px-4 py-3.5 text-sm text-slate-700 whitespace-nowrap font-medium">
                                        {{ formatTanggal(r.created_at) }}
                                    </td>
                                    <td class="px-4 py-3.5">
                                        <StatusBadge
                                            type="rujukan"
                                            :value="r.status"
                                        />
                                    </td>
                                    <td class="px-4 py-3.5 hidden md:table-cell">
                                        <StatusBadge
                                            type="prioritas"
                                            :value="r.prioritas_pemantauan?.kategori"
                                        />
                                    </td>
                                    <td class="px-4 py-3.5 hidden md:table-cell text-sm text-slate-500">
                                        {{ r.ditangani_oleh ?? "—" }}
                                    </td>
                                    <td class="px-4 py-3.5 text-center">
                                        <button
                                            class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 transition-colors cursor-pointer"
                                            @click="lihatDetailRujukan(r.id)"
                                        >
                                            <i class="pi pi-eye text-xs" aria-hidden="true" />
                                            Detail
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </template>

        <!-- ─── Dialog Detail Rujukan ────────────────────────────── -->
        <Dialog
            v-model:visible="showDetailRujukan"
            modal
            header="Detail Rujukan"
            :style="{ width: '640px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <div v-if="rujukanStore.loading.fetchDetail" class="p-4 space-y-3">
                <div v-for="i in 4" :key="i" class="skeleton h-10 rounded-xl" />
            </div>
            <RujukanDetailCard
                v-else-if="rujukanStore.rujukanDetail"
                :rujukan="rujukanStore.rujukanDetail"
                @close="showDetailRujukan = false"
            />
        </Dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { Dialog } from "primevue";
import { usePuskesmasStore } from "@/stores/puskesmasStore";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { usePemberianStore, LABEL_JENIS } from "@/stores/pemberianStore";
import { useRujukanStore } from "@/stores/rujukanStore";
import { formatUkuran, formatTanggal } from "@/utils/format.js";

import AnakCard from "@/components/cards/AnakCard.vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import RujukanDetailCard from "@/components/cards/RujukanDetailCard.vue";
import GrowthTrendChart from "@/components/charts/GrowthTrendChart.vue";

const route = useRoute();
const router = useRouter();
const puskesmasStore = usePuskesmasStore();
const pengukuranStore = usePengukuranStore();
const pemberianStore = usePemberianStore();
const rujukanStore = useRujukanStore();

const anakId = route.params.id;
const activeTab = ref("pengukuran");
const showDetailRujukan = ref(false);

const formatZScore = (value) => {
    if (value === null || value === undefined) return "—";
    const num = Number(value);
    if (isNaN(num)) return "—";
    return num > 0 ? `+${num.toFixed(2)} SD` : `${num.toFixed(2)} SD`;
};

const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);

/* ── Fallback List Data Gabungan ──────────────────────────────────── */
const riwayatPengukuranList = computed(() => {
    return pengukuranStore.riwayat.list.length > 0
        ? pengukuranStore.riwayat.list
        : puskesmasStore.riwayatPengukuran;
});

const riwayatPemberianList = computed(() => {
    return pemberianStore.riwayat.list.length > 0
        ? pemberianStore.riwayat.list
        : puskesmasStore.riwayatPemberian;
});

const latestPengukuran = computed(() => {
    return pengukuranStore.pengukuranTerakhir || puskesmasStore.pengukuranTerakhir || riwayatPengukuranList.value[0] || null;
});

const trenPertumbuhan = computed(() => {
    return [...riwayatPengukuranList.value].reverse().map((p) => ({
        tanggal: p.tanggal_ukur,
        berat_badan: parseFloat(p.berat_badan),
        tinggi_badan: parseFloat(p.tinggi_badan),
    }));
});

/* ── Tabs Riwayat (Desain Bersih Tanpa Ikon & Indikator Hijau) ───── */
const tabs = computed(() => [
    {
        key: "pengukuran",
        label: "Pengukuran & Pertumbuhan",
        count: riwayatPengukuranList.value.length,
    },
    {
        key: "pemberian",
        label: "Pemberian PMT & Vitamin",
        count: riwayatPemberianList.value.length,
    },
    {
        key: "rujukan",
        label: "Riwayat Rujukan",
        count: rujukanStore.riwayatAnak.list.length,
    },
]);

const focusActiveTab = () => {
    document.getElementById(`tab-${activeTab.value}`)?.focus();
};

const moveToTab = (index) => {
    activeTab.value = tabs.value[index].key;
    requestAnimationFrame(focusActiveTab);
};

const moveTab = (direction) => {
    const currentIndex = tabs.value.findIndex(
        (tab) => tab.key === activeTab.value,
    );
    const nextIndex =
        (currentIndex + direction + tabs.value.length) % tabs.value.length;
    moveToTab(nextIndex);
};

/* ── Warna badge jenis pemberian ─────────────────────────────────── */
const variantJenis = {
    vitamin_a_merah: "red",
    vitamin_a_biru: "blue",
    obat_cacing: "green",
    pmt_biskuit: "yellow",
    pmt_susu: "purple",
    pmt_lainnya: "green",
};

const getUsiaSaatUkur = (tglUkur) => {
    const tglLahir = puskesmasStore.anakDetail?.tanggal_lahir || pengukuranStore.riwayat.anak?.tanggal_lahir;
    if (!tglLahir || !tglUkur) return null;
    const lahir = new Date(tglLahir);
    const ukur = new Date(tglUkur);
    const diffTime = ukur - lahir;
    if (diffTime < 0) return null;
    const diffDays = diffTime / (1000 * 60 * 60 * 24);
    const months = Math.floor(diffDays / 30.4375);
    if (months < 12) return `Usia ${months} bln`;
    const years = Math.floor(months / 12);
    const remMonths = months % 12;
    return remMonths > 0
        ? `Usia ${years} thn ${remMonths} bln`
        : `Usia ${years} thn`;
};

/* ── Detail rujukan ──────────────────────────────────────────────── */
const lihatDetailRujukan = async (id) => {
    showDetailRujukan.value = true;
    await rujukanStore.fetchDetailRujukan(id);
};

/* ── Fetch semua data paralel ────────────────────────────────────── */
const fetchData = () => {
    Promise.all([
        puskesmasStore.fetchDetailAnak(anakId),
        pengukuranStore.fetchRiwayat(anakId),
        pemberianStore.fetchRiwayat(anakId),
        rujukanStore.fetchRujukanByAnak(anakId),
    ]);
};

onMounted(fetchData);
</script>

<style scoped>
.th-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #1e293b;
}
.measurement-table-scroll {
    scrollbar-color: #94a3b8 #f1f5f9;
    scrollbar-width: thin;
}
.measurement-table-scroll::-webkit-scrollbar {
    height: 10px;
}
.measurement-table-scroll::-webkit-scrollbar-track {
    background: #f1f5f9;
}
.measurement-table-scroll::-webkit-scrollbar-thumb {
    background: #94a3b8;
    border: 2px solid #f1f5f9;
    border-radius: 999px;
}
.measurement-table-scroll::-webkit-scrollbar-thumb:hover {
    background: #64748b;
}
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
}
@keyframes shimmer {
    0% {
        background-position: 200% 0;
    }
    100% {
        background-position: -200% 0;
    }
}
</style>
