<template>
    <div class="p-4 sm:p-5 md:p-6 w-full max-w-6xl mx-auto space-y-5 min-w-0">
        <!-- ─── Header Modern ────────────────────────────────────── -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-slate-800 m-0 tracking-tight">
                    Jadwal Posyandu
                </h1>
            </div>
            <div class="flex items-center gap-2 self-start sm:self-auto">
                <div class="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white border border-slate-200/80 shadow-2xs text-xs text-slate-600 font-medium">
                    <i class="pi pi-calendar text-emerald-600 text-xs" />
                    <span>Hari ini: <strong class="text-slate-800">{{ formatTanggal(todayStr) }}</strong></span>
                </div>
            </div>
        </div>

        <!-- ─── Alert Notifikasi Error API ────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="errorAktif"
                class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700"
                role="alert"
            >
                <i class="pi pi-exclamation-circle shrink-0" aria-hidden="true" />
                <span>{{ errorAktif }}</span>
            </div>
        </Transition>

        <!-- ─── Alert Notifikasi Sukses Generate ─────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="jadwalStore.generateResult"
                class="flex items-start justify-between gap-3 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900 shadow-2xs"
                role="status"
            >
                <div class="flex items-start gap-3">
                    <i class="pi pi-check-circle mt-0.5 text-emerald-600 text-base" aria-hidden="true" />
                    <div>
                        <p class="text-sm font-bold m-0">Jadwal otomatis berhasil digenerate</p>
                        <p class="text-xs text-emerald-700 mt-1 mb-0">
                            {{ jadwalStore.generateResult.total_generated }} jadwal baru dibuat,
                            {{ jadwalStore.generateResult.total_skipped }} tanggal dilewati karena jadwal sudah tersedia.
                        </p>
                    </div>
                </div>
                <button
                    type="button"
                    class="p-1 text-emerald-700 hover:text-emerald-900 cursor-pointer"
                    aria-label="Tutup pemberitahuan"
                    @click="jadwalStore.generateResult = null"
                >
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <!-- ─── Alert Sukses Salin Pengumuman ─────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="copySuccess"
                class="flex items-center gap-2.5 px-4 py-2.5 rounded-xl text-xs bg-emerald-500 text-white font-medium shadow-sm fixed bottom-6 right-6 z-50"
                role="status"
            >
                <i class="pi pi-check-circle text-sm" aria-hidden="true" />
                <span>Teks pengumuman berhasil disalin ke clipboard!</span>
            </div>
        </Transition>

        <!-- ─── Hero Card: Jadwal Terdekat ────────────────────────── -->
        <section
            v-if="jadwalStore.jadwalTerdekat"
            class="hero-card p-5 sm:p-6 rounded-2xl relative overflow-hidden shadow-lg"
            aria-labelledby="hero-jadwal-title"
        >
            <!-- Dekorasi latar belakang kalender samar -->
            <i class="pi pi-calendar hero-bg-icon" aria-hidden="true" />

            <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-5">
                <div class="space-y-3 min-w-0">
                    <div class="flex items-center gap-2.5 flex-wrap">
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold tracking-wider uppercase bg-white/15 text-white backdrop-blur-xs border border-white/20">
                            <i class="pi pi-calendar-clock text-[10px]" />
                            Jadwal Terdekat
                        </span>
                        <span
                            class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold"
                            :class="
                                isHariIni(jadwalStore.jadwalTerdekat.tanggal)
                                    ? 'bg-amber-400 text-amber-950 animate-pulse'
                                    : 'bg-emerald-400 text-emerald-950'
                            "
                        >
                            <span class="w-1.5 h-1.5 rounded-full" :class="isHariIni(jadwalStore.jadwalTerdekat.tanggal) ? 'bg-amber-900' : 'bg-emerald-900'" />
                            {{ sisaHari(jadwalStore.jadwalTerdekat.tanggal) }}
                        </span>
                    </div>

                    <div>
                        <h2 id="hero-jadwal-title" class="text-xl sm:text-2xl font-extrabold text-white tracking-tight m-0">
                            {{ formatTanggalPanjang(jadwalStore.jadwalTerdekat.tanggal) }}
                        </h2>
                        <div class="flex items-center gap-4 text-xs text-emerald-100 font-medium mt-2 flex-wrap">
                            <span class="inline-flex items-center gap-1.5">
                                <i class="pi pi-clock text-emerald-300" />
                                {{ formatWaktu(jadwalStore.jadwalTerdekat.waktu_mulai) }} – {{ formatWaktu(jadwalStore.jadwalTerdekat.waktu_selesai) }} WIB
                            </span>
                            <span class="inline-flex items-center gap-1.5">
                                <i class="pi pi-map-marker text-emerald-300" />
                                {{ jadwalStore.jadwalTerdekat.lokasi }}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="flex items-center gap-2.5 shrink-0">
                    <button
                        type="button"
                        class="px-3.5 py-2 rounded-xl text-xs font-semibold bg-white/15 hover:bg-white/25 text-white border border-white/20 backdrop-blur-xs transition-all cursor-pointer inline-flex items-center gap-1.5 shadow-2xs"
                        title="Salin pesan pengumuman jadwal untuk WhatsApp"
                        @click="salinPengumuman(jadwalStore.jadwalTerdekat)"
                    >
                        <i class="pi pi-share-alt text-[11px]" aria-hidden="true" />
                        <span>Salin Pesan WA</span>
                    </button>
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold bg-white text-emerald-900 hover:bg-emerald-50 transition-all cursor-pointer inline-flex items-center gap-1.5 shadow-xs"
                        @click="lihatDetail(jadwalStore.jadwalTerdekat.id)"
                    >
                        <i class="pi pi-eye text-[11px]" aria-hidden="true" />
                        <span>Lihat Detail</span>
                    </button>
                </div>
            </div>
        </section>

        <!-- ─── Toolbar Aksi & Filter ─────────────────────────────── -->
        <section class="card p-3.5 sm:p-4 rounded-2xl flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3.5 w-full min-w-0" aria-label="Menu navigasi dan aksi jadwal">
            <!-- Filter Pills -->
            <div class="flex items-center gap-1.5 overflow-x-auto pb-0.5 filter-scroll" role="group" aria-label="Filter status jadwal">
                <button
                    v-for="tab in filterTabs"
                    :key="tab.key"
                    type="button"
                    class="filter-pill"
                    :class="{ 'filter-pill--active': activeFilter === tab.key }"
                    :aria-pressed="activeFilter === tab.key"
                    @click="activeFilter = tab.key"
                >
                    {{ tab.label }}
                    <span class="ml-1.5 text-[10px] opacity-80 px-1.5 py-0.2 rounded-full" :class="activeFilter === tab.key ? 'bg-white/20 text-white' : 'bg-slate-100 text-slate-600'">
                        {{ getTabCount(tab.key) }}
                    </span>
                </button>
            </div>

            <!-- Group Aksi Kanan -->
            <div class="flex items-center gap-2 flex-wrap shrink-0 justify-end">
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 transition-colors cursor-pointer inline-flex items-center gap-1.5 shadow-2xs"
                    title="Pengaturan jadwal tetap posyandu bulanan"
                    @click="showPengaturan = true"
                >
                    <i class="pi pi-cog text-slate-500 text-xs" aria-hidden="true" />
                    <span>Pengaturan</span>
                </button>
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 transition-colors cursor-pointer inline-flex items-center gap-1.5 shadow-2xs"
                    :disabled="jadwalStore.loading.generate || !jadwalStore.pengaturan"
                    title="Generate jadwal otomatis untuk beberapa bulan"
                    @click="showConfirmGenerate = true"
                >
                    <i
                        class="pi text-xs text-slate-500"
                        :class="jadwalStore.loading.generate ? 'pi-spin pi-spinner' : 'pi-calendar-plus'"
                        aria-hidden="true"
                    />
                    <span>Generate</span>
                </button>
                <button
                    type="button"
                    class="text-xs font-semibold px-3 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white transition-colors shrink-0 cursor-pointer inline-flex items-center gap-1.5 shadow-2xs"
                    @click="openForm"
                >
                    <i class="pi pi-plus text-[10px]" aria-hidden="true" />
                    <span>Tambah Jadwal</span>
                </button>
            </div>
        </section>

        <!-- ─── Loading State ─────────────────────────────────────── -->
        <div v-if="jadwalStore.loading.fetchAll" class="space-y-3">
            <div v-for="i in 3" :key="i" class="skeleton h-24 rounded-2xl" />
        </div>

        <!-- ─── Empty State ───────────────────────────────────────── -->
        <div
            v-else-if="jadwalTampil.length === 0"
            class="card p-10 sm:p-12 rounded-2xl flex flex-col items-center justify-center gap-3 text-center bg-white border border-slate-200/80 shadow-2xs"
        >
            <div class="w-12 h-12 rounded-2xl bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600 shadow-2xs">
                <i class="pi pi-calendar text-xl" aria-hidden="true" />
            </div>
            <div>
                <p class="text-sm font-bold text-slate-800 m-0">
                    {{ activeFilter === "mendatang" ? "Belum ada jadwal posyandu mendatang" : (activeFilter === "lewat" ? "Belum ada riwayat jadwal yang lewat" : "Belum ada data jadwal") }}
                </p>
                <p class="text-xs text-slate-500 mt-1 mb-0 max-w-sm">
                    {{ activeFilter === "mendatang" ? "Buat jadwal posyandu baru atau gunakan fitur generate untuk membuat jadwal rutin otomatis." : "Semua jadwal yang sudah selesai akan tercatat di sini." }}
                </p>
            </div>
            <button
                v-if="activeFilter === 'mendatang'"
                type="button"
                class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white cursor-pointer mt-1 shadow-xs hover:bg-emerald-700 transition-all inline-flex items-center gap-1.5"
                @click="openForm"
            >
                <i class="pi pi-plus text-[10px]" aria-hidden="true" />
                <span>Buat Jadwal Sekarang</span>
            </button>
        </div>

        <!-- ─── Daftar Jadwal Berkonsep Kartu Modern ──────────────── -->
        <div v-else class="space-y-3">
            <article
                v-for="jadwal in jadwalTampil"
                :key="jadwal.id"
                class="card p-4 sm:p-5 rounded-2xl flex flex-col sm:flex-row sm:items-center justify-between gap-4 transition-all duration-150 hover:shadow-md border border-slate-200/80 bg-white"
                :class="{ 'ring-1 ring-amber-300 bg-amber-50/20': isHariIni(jadwal.tanggal) }"
            >
                <!-- Group Kiri: Kotak Tanggal & Rincian Jadwal -->
                <div class="flex items-start sm:items-center gap-4 min-w-0">
                    <!-- Kotak Tanggal Visual -->
                    <div
                        class="w-16 h-16 sm:w-18 sm:h-18 rounded-2xl flex flex-col items-center justify-center shrink-0 border transition-colors shadow-2xs select-none"
                        :class="
                            isHariIni(jadwal.tanggal)
                                ? 'bg-amber-100/90 border-amber-300 text-amber-900'
                                : isLewat(jadwal.tanggal)
                                    ? 'bg-slate-100 border-slate-200 text-slate-500'
                                    : 'bg-emerald-50 border-emerald-200/80 text-emerald-900'
                        "
                    >
                        <span class="text-[10px] uppercase font-bold tracking-wider leading-none">
                            {{ namaHari(jadwal.tanggal) }}
                        </span>
                        <span class="text-xl sm:text-2xl font-extrabold tracking-tight leading-none my-0.5">
                            {{ angkaTanggal(jadwal.tanggal) }}
                        </span>
                        <span class="text-[10px] font-semibold leading-none opacity-80">
                            {{ bulanSingkat(jadwal.tanggal) }}
                        </span>
                    </div>

                    <!-- Informasi Jadwal -->
                    <div class="space-y-1 min-w-0">
                        <div class="flex items-center gap-2 flex-wrap">
                            <h3 class="text-sm sm:text-base font-bold text-slate-800 m-0 truncate">
                                {{ jadwal.lokasi }}
                            </h3>
                            <span
                                v-if="isHariIni(jadwal.tanggal)"
                                class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-amber-100 text-amber-800 border border-amber-200"
                            >
                                <span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
                                Hari Ini
                            </span>
                            <span
                                v-else-if="isLewat(jadwal.tanggal)"
                                class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[11px] font-medium bg-slate-100 text-slate-600 border border-slate-200"
                            >
                                Selesai
                            </span>
                            <span
                                v-else
                                class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/80"
                            >
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                                Mendatang
                            </span>
                        </div>

                        <p class="text-xs text-slate-500 m-0 flex items-center gap-2 flex-wrap">
                            <span class="inline-flex items-center gap-1 text-slate-600 font-medium">
                                <i class="pi pi-clock text-slate-400 text-[11px]" />
                                {{ formatWaktu(jadwal.waktu_mulai) }} – {{ formatWaktu(jadwal.waktu_selesai) }} WIB
                            </span>
                            <span class="text-slate-300">•</span>
                            <span class="inline-flex items-center gap-1 text-slate-600">
                                <i class="pi pi-user text-slate-400 text-[11px]" />
                                Dicatat: {{ jadwal.dibuat_oleh || 'Kader' }}
                            </span>
                        </p>

                        <p
                            v-if="jadwal.keterangan"
                            class="text-xs text-slate-500 m-0 mt-2.5 pt-1.5 border-t border-slate-100/80 line-clamp-1 italic"
                        >
                            {{ jadwal.keterangan }}
                        </p>
                    </div>
                </div>

                <!-- Group Kanan: Aksi Kartu -->
                <div class="flex items-center gap-2 shrink-0 self-end sm:self-center">
                    <button
                        type="button"
                        class="px-2.5 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer inline-flex items-center gap-1"
                        title="Lihat detail lengkap jadwal"
                        @click="lihatDetail(jadwal.id)"
                    >
                        <i class="pi pi-eye text-[11px]" aria-hidden="true" />
                        <span>Detail</span>
                    </button>
                    <template v-if="!isLewat(jadwal.tanggal)">
                        <button
                            type="button"
                            class="px-2 py-1.5 rounded-lg text-xs font-semibold bg-white border border-slate-200 hover:bg-blue-50 hover:text-blue-700 hover:border-blue-200 text-slate-600 transition-colors cursor-pointer"
                            title="Edit jadwal ini"
                            @click="openEdit(jadwal)"
                        >
                            <i class="pi pi-pencil text-[11px]" aria-hidden="true" />
                        </button>
                        <button
                            type="button"
                            class="px-2 py-1.5 rounded-lg text-xs font-semibold bg-white border border-slate-200 hover:bg-red-50 hover:text-red-700 hover:border-red-200 text-slate-600 transition-colors cursor-pointer"
                            title="Hapus jadwal ini"
                            @click="promptDelete(jadwal)"
                        >
                            <i class="pi pi-trash text-[11px]" aria-hidden="true" />
                        </button>
                    </template>
                </div>
            </article>

            <!-- Kontrol Paginasi -->
            <div class="card rounded-2xl overflow-hidden mt-4">
                <PaginationControls
                    :pagination="jadwalStore.pagination"
                    :loading="jadwalStore.loading.fetchAll"
                    @change-page="changePage"
                />
            </div>
        </div>

        <!-- ─── Dialog Detail Jadwal ──────────────────────────────── -->
        <Dialog
            v-model:visible="showDetail"
            modal
            header="Detail Jadwal Posyandu"
            :style="{ width: '460px', maxWidth: '95vw' }"
            :pt="{ header: { style: 'border-bottom: 1px solid var(--color-input-border)' } }"
        >
            <div v-if="jadwalStore.loading.fetchDetail" class="p-4 space-y-3">
                <div v-for="i in 4" :key="i" class="skeleton h-10 rounded-xl" />
            </div>
            <div v-else-if="jadwalStore.jadwalDetail" class="space-y-4 pt-3">
                <div class="p-4 rounded-xl bg-slate-50 border border-slate-200/80 space-y-3">
                    <div>
                        <p class="text-[10px] uppercase font-bold tracking-wider text-slate-400 m-0">Tanggal Pelaksanaan</p>
                        <p class="text-sm font-bold text-slate-800 mt-0.5 mb-0">
                            {{ formatTanggalPanjang(jadwalStore.jadwalDetail.tanggal) }}
                        </p>
                    </div>
                    <div class="grid grid-cols-2 gap-3 pt-1 border-t border-slate-200/60">
                        <div>
                            <p class="text-[10px] uppercase font-bold tracking-wider text-slate-400 m-0">Waktu</p>
                            <p class="text-xs font-semibold text-slate-700 mt-0.5 mb-0">
                                {{ formatWaktu(jadwalStore.jadwalDetail.waktu_mulai) }} – {{ formatWaktu(jadwalStore.jadwalDetail.waktu_selesai) }} WIB
                            </p>
                        </div>
                        <div>
                            <p class="text-[10px] uppercase font-bold tracking-wider text-slate-400 m-0">Lokasi</p>
                            <p class="text-xs font-semibold text-slate-700 mt-0.5 mb-0">
                                {{ jadwalStore.jadwalDetail.lokasi }}
                            </p>
                        </div>
                    </div>
                    <div class="pt-1 border-t border-slate-200/60">
                        <p class="text-[10px] uppercase font-bold tracking-wider text-slate-400 m-0">Dicatat Oleh</p>
                        <p class="text-xs font-semibold text-slate-700 mt-0.5 mb-0">
                            {{ jadwalStore.jadwalDetail.dibuat_oleh || 'Kader' }}
                        </p>
                    </div>
                    <div v-if="jadwalStore.jadwalDetail.keterangan" class="pt-1 border-t border-slate-200/60">
                        <p class="text-[10px] uppercase font-bold tracking-wider text-slate-400 m-0">Keterangan / Catatan</p>
                        <p class="text-xs text-slate-600 mt-0.5 mb-0">
                            {{ jadwalStore.jadwalDetail.keterangan }}
                        </p>
                    </div>
                </div>

                <div class="flex items-center justify-between gap-2 pt-1">
                    <button
                        type="button"
                        class="px-3.5 py-2 rounded-xl text-xs font-semibold bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-200/80 transition-colors cursor-pointer inline-flex items-center gap-1.5"
                        @click="salinPengumuman(jadwalStore.jadwalDetail)"
                    >
                        <i class="pi pi-share-alt text-xs" />
                        <span>Salin Pesan WhatsApp</span>
                    </button>
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 transition-colors cursor-pointer"
                        @click="showDetail = false"
                    >
                        Tutup
                    </button>
                </div>
            </div>
        </Dialog>

        <!-- ─── Dialog Edit Jadwal ────────────────────────────────── -->
        <Dialog
            v-model:visible="showEdit"
            modal
            :closable="!jadwalStore.loading.update"
            header="Edit Jadwal Posyandu"
            :style="{ width: '480px', maxWidth: '95vw' }"
        >
            <FormJadwal
                v-if="jadwalDipilih"
                mode="edit"
                :initial-data="jadwalDipilih"
                :loading="jadwalStore.loading.update"
                :error="jadwalStore.error.update"
                @submit="handleUpdate"
                @cancel="showEdit = false"
            />
        </Dialog>

        <!-- ─── Dialog Pengaturan Jadwal Bulanan ──────────────────── -->
        <Dialog
            v-model:visible="showPengaturan"
            modal
            :closable="!jadwalStore.loading.pengaturan"
            header="Pengaturan Jadwal Bulanan"
            :style="{ width: '460px', maxWidth: '95vw' }"
        >
            <FormPengaturanJadwal
                :initial-data="jadwalStore.pengaturan"
                :loading="jadwalStore.loading.pengaturan"
                :error="jadwalStore.error.pengaturan"
                @submit="handleSavePengaturan"
                @cancel="showPengaturan = false"
            />
        </Dialog>

        <!-- ─── Dialog Form Tambah Jadwal ─────────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!jadwalStore.loading.create"
            header="Buat Jadwal Posyandu"
            :style="{ width: '480px', maxWidth: '95vw' }"
            :pt="{ header: { style: 'border-bottom: 1px solid var(--color-input-border)' } }"
        >
            <FormJadwal
                :loading="jadwalStore.loading.create"
                :error="jadwalStore.error.create"
                @submit="handleSubmit"
                @cancel="closeForm"
            />
        </Dialog>

        <!-- ─── Modal Konfirmasi Generate Jadwal Otomatis ─────────── -->
        <Dialog
            v-model:visible="showConfirmGenerate"
            modal
            :closable="!jadwalStore.loading.generate"
            header="Generate Jadwal Otomatis"
            :style="{ width: '460px', maxWidth: '95vw' }"
        >
            <div class="space-y-4 pt-2">
                <div class="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs leading-relaxed flex items-start gap-2.5">
                    <i class="pi pi-info-circle text-emerald-600 mt-0.5 shrink-0" aria-hidden="true" />
                    <div>
                        <p class="font-bold m-0">Berdasarkan Pengaturan Rutin</p>
                        <p class="mt-0.5 mb-0 text-emerald-800">
                            Jadwal akan digenerate otomatis setiap bulan sesuai aturan tanggal tetap posyandu. Tanggal yang sudah memiliki jadwal akan dilewati dengan aman.
                        </p>
                    </div>
                </div>

                <div class="space-y-1.5">
                    <label for="generate_bulan" class="text-xs font-semibold text-slate-700">Pilih Rentang Waktu</label>
                    <div class="grid grid-cols-3 gap-2">
                        <button
                            v-for="bulan in [3, 6, 12]"
                            :key="bulan"
                            type="button"
                            class="py-2 px-3 rounded-xl text-xs font-bold border transition-all cursor-pointer text-center"
                            :class="jumlahBulan === bulan ? 'bg-emerald-600 text-white border-emerald-600 shadow-xs' : 'bg-white border-slate-200 text-slate-700 hover:bg-slate-50'"
                            @click="jumlahBulan = bulan"
                        >
                            {{ bulan }} Bulan
                        </button>
                    </div>
                </div>

                <div class="flex justify-end gap-2 pt-2">
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors cursor-pointer"
                        :disabled="jadwalStore.loading.generate"
                        @click="showConfirmGenerate = false"
                    >
                        Batal
                    </button>
                    <button
                        type="button"
                        class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white inline-flex items-center gap-2 cursor-pointer shadow-xs hover:bg-emerald-700 transition-all"
                        :disabled="jadwalStore.loading.generate"
                        :aria-busy="jadwalStore.loading.generate"
                        @click="confirmGenerate"
                    >
                        <i v-if="jadwalStore.loading.generate" class="pi pi-spin pi-spinner" aria-hidden="true" />
                        <i v-else class="pi pi-calendar-plus" aria-hidden="true" />
                        {{ jadwalStore.loading.generate ? "Memproses..." : `Generate ${jumlahBulan} Bulan` }}
                    </button>
                </div>
            </div>
        </Dialog>

        <!-- ─── Modal Konfirmasi Hapus Jadwal ─────────────────────── -->
        <Dialog
            v-model:visible="showConfirmDelete"
            modal
            :closable="!jadwalStore.loading.delete"
            header="Hapus Jadwal Posyandu"
            :style="{ width: '440px', maxWidth: '95vw' }"
        >
            <div v-if="jadwalDipilihHapus" class="space-y-4 pt-2">
                <div class="p-3.5 rounded-xl bg-red-50 border border-red-200 text-red-900 text-xs leading-relaxed flex items-start gap-2.5">
                    <i class="pi pi-exclamation-triangle text-red-600 mt-0.5 shrink-0" aria-hidden="true" />
                    <div>
                        <p class="font-bold m-0">Tindakan ini tidak dapat dibatalkan</p>
                        <p class="mt-0.5 mb-0 text-red-700">
                            Orang tua yang telah terdaftar pada jadwal ini akan menerima notifikasi pembatalan.
                        </p>
                    </div>
                </div>

                <div class="p-3 rounded-xl bg-slate-50 border border-slate-200/80 text-xs space-y-1">
                    <p class="font-bold text-slate-800 m-0">
                        {{ formatTanggalPanjang(jadwalDipilihHapus.tanggal) }}
                    </p>
                    <p class="text-slate-600 m-0">
                        Lokasi: {{ jadwalDipilihHapus.lokasi }} ({{ formatWaktu(jadwalDipilihHapus.waktu_mulai) }} – {{ formatWaktu(jadwalDipilihHapus.waktu_selesai) }} WIB)
                    </p>
                </div>

                <div class="flex justify-end gap-2 pt-2">
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors cursor-pointer"
                        :disabled="jadwalStore.loading.delete"
                        @click="showConfirmDelete = false"
                    >
                        Batal
                    </button>
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold bg-red-600 hover:bg-red-700 text-white inline-flex items-center gap-2 cursor-pointer shadow-xs transition-all"
                        :disabled="jadwalStore.loading.delete"
                        :aria-busy="jadwalStore.loading.delete"
                        @click="confirmDelete"
                    >
                        <i v-if="jadwalStore.loading.delete" class="pi pi-spin pi-spinner" aria-hidden="true" />
                        <i v-else class="pi pi-trash" aria-hidden="true" />
                        {{ jadwalStore.loading.delete ? "Menghapus..." : "Hapus Jadwal" }}
                    </button>
                </div>
            </div>
        </Dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { Dialog } from "primevue";
import { useJadwalStore } from "@/stores/jadwalStore";
import FormJadwal from "@/components/forms/FormJadwal.vue";
import FormPengaturanJadwal from "@/components/forms/FormPengaturanJadwal.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";
import { formatTanggal, toLocalDateStr } from "@/utils/format.js";

const jadwalStore = useJadwalStore();

const todayDate = new Date();
const todayStr = toLocalDateStr(todayDate);

const activeFilter = ref("mendatang");
const showDetail = ref(false);
const showForm = ref(false);
const showEdit = ref(false);
const showPengaturan = ref(false);
const showConfirmGenerate = ref(false);
const showConfirmDelete = ref(false);

const jadwalDipilih = ref(null);
const jadwalDipilihHapus = ref(null);
const jumlahBulan = ref(6);
const copySuccess = ref(false);

const filterTabs = [
    { key: "mendatang", label: "Mendatang" },
    { key: "lewat", label: "Riwayat Lewat" },
    { key: "semua", label: "Semua" },
];

const errorAktif = computed(
    () =>
        jadwalStore.error.fetchAll ||
        jadwalStore.error.delete ||
        jadwalStore.error.generate,
);

const jadwalTampil = computed(() => {
    if (activeFilter.value === "mendatang") return jadwalStore.jadwalMendatang;
    if (activeFilter.value === "lewat") return jadwalStore.jadwalLewat;
    return jadwalStore.jadwalList;
});

const getTabCount = (key) => {
    if (key === "mendatang") return jadwalStore.jadwalMendatang.length;
    if (key === "lewat") return jadwalStore.jadwalLewat.length;
    return jadwalStore.jadwalList.length;
};

const isLewat = (tgl) => tgl < todayStr;
const isHariIni = (tgl) => tgl === todayStr;

const sisaHari = (tgl) => {
    if (tgl === todayStr) return "Hari ini!";
    const tglDate = new Date(tgl + "T00:00:00");
    const todayD = new Date(todayStr + "T00:00:00");
    const diff = Math.round((tglDate - todayD) / (1000 * 60 * 60 * 24));
    if (diff === 1) return "Besok";
    if (diff < 0) return `${Math.abs(diff)} hari lalu`;
    return `${diff} hari lagi`;
};

const formatTanggalPanjang = (tgl) =>
    new Date(tgl + "T00:00:00").toLocaleDateString("id-ID", {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
    });

const namaHari = (tgl) =>
    new Date(tgl + "T00:00:00").toLocaleDateString("id-ID", { weekday: "short" });

const angkaTanggal = (tgl) =>
    new Date(tgl + "T00:00:00").getDate();

const bulanSingkat = (tgl) =>
    new Date(tgl + "T00:00:00").toLocaleDateString("id-ID", { month: "short" });

const formatWaktu = (waktu) => waktu?.slice(0, 5) ?? "—";

const salinPengumuman = async (j) => {
    if (!j) return;
    const teks = `📢 *PENGUMUMAN JADWAL POSYANDU*\n\nBunda dan Ayah, berikut jadwal pelayanan Posyandu berikutnya:\n📅 *Hari / Tanggal:* ${formatTanggalPanjang(j.tanggal)}\n⏰ *Waktu:* ${formatWaktu(j.waktu_mulai)} – ${formatWaktu(j.waktu_selesai)} WIB\n📍 *Lokasi:* ${j.lokasi}\n${j.keterangan ? `📝 *Catatan:* ${j.keterangan}\n` : ''}\nYuk bawa si kecil ke posyandu untuk pemantauan tumbuh kembang optimal! 🌿`;
    try {
        await navigator.clipboard.writeText(teks);
        copySuccess.value = true;
        setTimeout(() => {
            copySuccess.value = false;
        }, 3000);
    } catch {
        // Fallback
    }
};

const lihatDetail = async (id) => {
    showDetail.value = true;
    await jadwalStore.fetchDetailJadwal(id);
};

const openForm = () => {
    jadwalStore.resetCreateState();
    showForm.value = true;
};
const closeForm = () => {
    showForm.value = false;
};

const handleSubmit = async (payload) => {
    const ok = await jadwalStore.createJadwal(payload);
    if (ok) closeForm();
};

const openEdit = (jadwal) => {
    jadwalStore.resetMutationErrors();
    jadwalDipilih.value = jadwal;
    showEdit.value = true;
};

const handleUpdate = async (payload) => {
    const ok = await jadwalStore.updateJadwal(jadwalDipilih.value.id, payload);
    if (ok) showEdit.value = false;
};

const promptDelete = (jadwal) => {
    jadwalDipilihHapus.value = jadwal;
    showConfirmDelete.value = true;
};

const confirmDelete = async () => {
    if (!jadwalDipilihHapus.value) return;
    const ok = await jadwalStore.deleteJadwal(jadwalDipilihHapus.value.id);
    if (ok) {
        showConfirmDelete.value = false;
        jadwalDipilihHapus.value = null;
    }
};

const handleSavePengaturan = async (payload) => {
    const ok = await jadwalStore.savePengaturan(payload);
    if (ok) showPengaturan.value = false;
};

const confirmGenerate = async () => {
    const ok = await jadwalStore.generateJadwal(jumlahBulan.value);
    if (ok) {
        showConfirmGenerate.value = false;
    }
};

const changePage = (page) => jadwalStore.fetchAllJadwal({ page });

onMounted(() =>
    Promise.all([
        jadwalStore.fetchAllJadwal(),
        jadwalStore.fetchPengaturan(),
    ]),
);
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.hero-card {
    background: linear-gradient(135deg, #059669 0%, #047857 50%, #064e3b 100%);
    box-shadow: 0 10px 25px -5px rgba(4, 120, 87, 0.3), 0 8px 10px -6px rgba(4, 120, 87, 0.2);
}

.hero-bg-icon {
    position: absolute;
    right: -1.5rem;
    bottom: -2rem;
    font-size: 11rem;
    color: rgba(255, 255, 255, 0.07);
    pointer-events: none;
}

.filter-scroll {
    scrollbar-width: none;
    -ms-overflow-style: none;
}
.filter-scroll::-webkit-scrollbar {
    display: none;
}

.filter-pill {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.38rem 0.75rem;
    border-radius: 0.65rem;
    font-size: 0.72rem;
    font-weight: 600;
    white-space: nowrap;
    background: white;
    color: #64748b;
    border: 1px solid #e2e8f0;
    cursor: pointer;
    flex-shrink: 0;
    transition: all 0.15s ease;
}
.filter-pill:hover {
    background: #f8fafc;
    color: #1e293b;
    border-color: #cbd5e1;
}
.filter-pill--active {
    background: #047857;
    color: white;
    border-color: #047857;
    box-shadow: 0 1px 2px rgba(4, 120, 87, 0.2);
}
.filter-pill--active:hover {
    background: #065f46;
    color: white;
    border-color: #065f46;
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

.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.25s ease;
}
.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-8px);
}
</style>
