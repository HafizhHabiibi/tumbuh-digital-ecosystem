<template>
    <div class="p-4 md:p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header Modern ────────────────────────────────────── -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-slate-800 m-0 tracking-tight">
                    Input Pengukuran Anak
                </h1>
            </div>
            <div class="flex items-center gap-2 self-start sm:self-auto">
                <div class="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white border border-slate-200/80 shadow-2xs text-xs text-slate-600 font-medium">
                    <i class="pi pi-calendar text-emerald-600 text-xs" />
                    <span>Hari ini: <strong class="text-slate-800">{{ formatTanggal(toLocalDateStr(todayDate)) }}</strong></span>
                </div>
            </div>
        </div>

        <!-- ─── Layout Dua Kolom: Form Kiri, Panel Hasil/Konteks Kanan ─── -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
            <!-- ══ KOLOM KIRI: Form Pengukuran ══════════════════════ -->
            <div class="card p-5 md:p-6 rounded-2xl space-y-5">
                <!-- Error API -->
                <Transition name="slide-down">
                    <div
                        v-if="pengukuranStore.error.create"
                        class="flex items-start gap-2.5 p-3.5 rounded-xl text-xs bg-red-50 border border-red-200 text-red-700"
                        role="alert"
                        aria-live="assertive"
                    >
                        <i class="pi pi-exclamation-circle mt-0.5 shrink-0 text-red-600" aria-hidden="true" />
                        <span>{{ pengukuranStore.error.create }}</span>
                    </div>
                </Transition>

                <form
                    novalidate
                    class="space-y-4"
                    @submit.prevent="handleSubmit"
                >
                    <!-- Pilih Anak -->
                    <div class="space-y-2">
                        <div class="flex items-center justify-between">
                            <label for="anak_id" class="field-label">
                                Pilih Anak
                            </label>
                            <span v-if="kaderStore.anakOptions.length > 0" class="text-[11px] text-slate-400">
                                {{ kaderStore.anakOptions.length }} anak terdaftar
                            </span>
                        </div>

                        <!-- Pencarian Cepat Anak -->
                        <div v-if="!anakTerpilih" class="relative">
                            <i class="pi pi-search input-icon" aria-hidden="true" />
                            <input
                                v-model="searchAnak"
                                type="text"
                                placeholder="Cari nama anak, orang tua, atau NIK..."
                                class="input-field w-full pl-9 pr-8 py-2 text-xs rounded-xl"
                                :disabled="pengukuranStore.loading.create || kaderStore.loading.anakOptions"
                            />
                            <button
                                v-if="searchAnak"
                                type="button"
                                class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                                @click="searchAnak = ''"
                            >
                                <i class="pi pi-times text-xs" />
                            </button>
                        </div>

                        <!-- Dropdown Select Anak -->
                        <div v-if="!anakTerpilih" class="relative">
                            <i class="pi pi-user input-icon" aria-hidden="true" />
                            <select
                                id="anak_id"
                                v-model="form.anak_id"
                                :disabled="pengukuranStore.loading.create || kaderStore.loading.anakOptions"
                                class="input-field w-full pl-9 pr-8 py-2.5 rounded-xl text-sm appearance-none"
                                aria-required="true"
                                :aria-invalid="!!fieldError.anak_id"
                                aria-describedby="anak_id_error"
                            >
                                <option value="" disabled>
                                    {{ kaderStore.loading.anakOptions ? "Memuat data anak..." : (filteredAnakOptions.length === 0 ? "Tidak ditemukan anak yang sesuai pencarian" : "Pilih nama anak") }}
                                </option>
                                <option
                                    v-for="anak in filteredAnakOptions"
                                    :key="anak.id"
                                    :value="anak.id"
                                >
                                    {{ anak.nama }} ({{ anak.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }}) — Ortu: {{ anak.nama_orang_tua || '—' }}
                                </option>
                            </select>
                            <i
                                class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400"
                                aria-hidden="true"
                            />
                        </div>

                        <p id="anak_id_error" v-if="fieldError.anak_id" class="error-hint">
                            {{ fieldError.anak_id }}
                        </p>

                        <!-- Error fetching anakOptions -->
                        <div
                            v-if="kaderStore.error.anakOptions"
                            class="flex items-center justify-between gap-3 text-xs text-red-700 bg-red-50 p-2.5 rounded-xl border border-red-200"
                            role="alert"
                        >
                            <span>{{ kaderStore.error.anakOptions }}</span>
                            <button
                                type="button"
                                class="font-semibold underline cursor-pointer"
                                @click="kaderStore.fetchAnakOptions()"
                            >
                                Coba lagi
                            </button>
                        </div>

                        <!-- Kartu Profil Anak Terpilih -->
                        <div
                            v-if="anakTerpilih"
                            class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 flex items-center justify-between gap-3"
                        >
                            <div class="flex items-center gap-3 min-w-0">
                                <div
                                    class="w-10 h-10 rounded-xl flex items-center justify-center font-bold text-xs shrink-0 shadow-2xs"
                                    :class="anakTerpilih.jenis_kelamin === 'L' ? 'bg-blue-100 text-blue-700' : 'bg-rose-100 text-rose-700'"
                                >
                                    {{ getInitials(anakTerpilih.nama) }}
                                </div>
                                <div class="min-w-0">
                                    <div class="flex items-center gap-1.5 flex-wrap">
                                        <span class="text-xs font-bold text-slate-800 truncate">{{ anakTerpilih.nama }}</span>
                                        <span
                                            class="text-[10px] px-2 py-0.5 rounded-md font-semibold shrink-0"
                                            :class="anakTerpilih.jenis_kelamin === 'L' ? 'bg-blue-50 text-blue-700 border border-blue-200' : 'bg-rose-50 text-rose-700 border border-rose-200'"
                                        >
                                            {{ anakTerpilih.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }}
                                        </span>
                                    </div>
                                    <p class="text-[11px] text-slate-500 mt-0.5 mb-0 truncate">
                                        Ortu: {{ anakTerpilih.nama_orang_tua || '—' }} • Usia: {{ hitungUsia(anakTerpilih.tanggal_lahir) }}
                                    </p>
                                </div>
                            </div>
                            <button
                                type="button"
                                class="text-xs font-semibold px-2.5 py-1.5 rounded-lg bg-white border border-slate-200 hover:bg-slate-100 text-slate-600 transition-colors shrink-0 cursor-pointer"
                                title="Ganti anak terpilih"
                                @click="handleGantiAnak"
                            >
                                Ganti
                            </button>
                        </div>

                        <!-- Peringatan Usia -->
                        <div
                            v-if="currentAgeWarning"
                            class="flex items-start gap-2 text-xs p-2.5 rounded-xl bg-amber-50 border border-amber-200 text-amber-900"
                            role="status"
                        >
                            <i class="pi pi-exclamation-triangle mt-0.5 text-amber-600 shrink-0" />
                            <span>{{ currentAgeWarning.message }}</span>
                        </div>
                    </div>

                    <!-- Tanggal Ukur -->
                    <div class="space-y-1.5">
                        <label for="tanggal_ukur" class="field-label">
                            Tanggal Pengukuran
                        </label>
                        <DatePicker
                            id="tanggal_ukur"
                            v-model="form.tanggal_ukur"
                            :min-date="measurementDateLimits.minDate"
                            :max-date="measurementDateLimits.maxDate || todayDate"
                            :disabled="pengukuranStore.loading.create"
                            date-format="dd/mm/yy"
                            placeholder="Pilih tanggal pengukuran"
                            show-icon
                            icon-display="input"
                            fluid
                            class="w-full"
                            aria-required="true"
                            :aria-invalid="!!fieldError.tanggal_ukur"
                            aria-describedby="tanggal_ukur_error"
                        />
                        <p id="tanggal_ukur_error" v-if="fieldError.tanggal_ukur" class="error-hint">
                            {{ fieldError.tanggal_ukur }}
                        </p>
                    </div>

                    <!-- Berat & Tinggi/Panjang Badan — Wajib (2 kolom) -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <!-- Berat Badan -->
                        <div class="space-y-1.5">
                            <label for="berat_badan" class="field-label">
                                Berat Badan
                            </label>
                            <div class="relative">
                                <input
                                    id="berat_badan"
                                    v-model.number="form.berat_badan"
                                    type="number"
                                    placeholder="0.00"
                                    step="0.01"
                                    min="0.01"
                                    max="30"
                                    :disabled="pengukuranStore.loading.create"
                                    class="input-field w-full pl-3.5 pr-11 py-2.5 rounded-xl text-sm font-semibold text-slate-800"
                                    aria-required="true"
                                    :aria-invalid="!!fieldError.berat_badan"
                                    aria-describedby="berat_badan_error"
                                />
                                <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-bold text-slate-400 pointer-events-none">
                                    kg
                                </span>
                            </div>
                            <p id="berat_badan_error" v-if="fieldError.berat_badan" class="error-hint">
                                {{ fieldError.berat_badan }}
                            </p>
                        </div>

                        <!-- Tinggi/Panjang Badan -->
                        <div class="space-y-1.5">
                            <label for="tinggi_badan" class="field-label">
                                {{ isUnderTwoYears ? 'Panjang Badan' : 'Tinggi Badan' }}
                            </label>
                            <div class="relative">
                                <input
                                    id="tinggi_badan"
                                    v-model.number="form.tinggi_badan"
                                    type="number"
                                    placeholder="0.0"
                                    step="0.01"
                                    min="0.01"
                                    max="120"
                                    :disabled="pengukuranStore.loading.create"
                                    class="input-field w-full pl-3.5 pr-11 py-2.5 rounded-xl text-sm font-semibold text-slate-800"
                                    aria-required="true"
                                    :aria-invalid="!!fieldError.tinggi_badan"
                                    aria-describedby="tinggi_badan_error"
                                />
                                <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-bold text-slate-400 pointer-events-none">
                                    cm
                                </span>
                            </div>
                            <p id="tinggi_badan_error" v-if="fieldError.tinggi_badan" class="error-hint">
                                {{ fieldError.tinggi_badan }}
                            </p>
                        </div>
                    </div>

                    <!-- Lingkar Kepala & Lingkar Lengan (2 kolom) -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <!-- Lingkar Kepala -->
                        <div class="space-y-1.5">
                            <label for="lingkar_kepala" class="field-label">
                                Lingkar Kepala
                            </label>
                            <div class="relative">
                                <input
                                    id="lingkar_kepala"
                                    v-model.number="form.lingkar_kepala"
                                    type="number"
                                    placeholder="0.0"
                                    step="0.01"
                                    min="1"
                                    max="80"
                                    :disabled="pengukuranStore.loading.create"
                                    class="input-field w-full pl-3.5 pr-11 py-2.5 rounded-xl text-sm font-semibold text-slate-800"
                                    :aria-invalid="!!fieldError.lingkar_kepala"
                                    aria-describedby="lingkar_kepala_error"
                                />
                                <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-bold text-slate-400 pointer-events-none">
                                    cm
                                </span>
                            </div>
                            <p id="lingkar_kepala_error" v-if="fieldError.lingkar_kepala" class="error-hint">
                                {{ fieldError.lingkar_kepala }}
                            </p>
                        </div>

                        <!-- Lingkar Lengan Atas (LiLA) -->
                        <div class="space-y-1.5">
                            <label for="lingkar_lengan" class="field-label">
                                Lingkar Lengan (LiLA)
                            </label>
                            <div class="relative">
                                <input
                                    id="lingkar_lengan"
                                    v-model.number="form.lingkar_lengan"
                                    type="number"
                                    placeholder="0.0"
                                    step="0.01"
                                    min="1"
                                    max="60"
                                    :disabled="pengukuranStore.loading.create"
                                    class="input-field w-full pl-3.5 pr-11 py-2.5 rounded-xl text-sm font-semibold text-slate-800"
                                    :aria-invalid="!!fieldError.lingkar_lengan"
                                    aria-describedby="lingkar_lengan_error"
                                />
                                <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-bold text-slate-400 pointer-events-none">
                                    cm
                                </span>
                            </div>
                            <p id="lingkar_lengan_error" v-if="fieldError.lingkar_lengan" class="error-hint">
                                {{ fieldError.lingkar_lengan }}
                            </p>
                        </div>
                    </div>

                    <!-- Tombol Submit -->
                    <button
                        type="submit"
                        :disabled="pengukuranStore.loading.create"
                        class="w-full py-3 px-4 rounded-xl text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 active:bg-emerald-800 transition-all duration-200 shadow-sm hover:shadow flex items-center justify-center gap-2 cursor-pointer disabled:opacity-60 disabled:cursor-not-allowed mt-2"
                    >
                        <i
                            v-if="pengukuranStore.loading.create"
                            class="pi pi-spin pi-spinner"
                            aria-hidden="true"
                        />
                        <i v-else class="pi pi-check" aria-hidden="true" />
                        <span>{{
                            pengukuranStore.loading.create
                                ? "Menyimpan Data..."
                                : "Simpan Hasil Pengukuran"
                        }}</span>
                    </button>
                </form>
            </div>

            <!-- ══ KOLOM KANAN: Panel Interaktif Multi-Kondisi ════════ -->
            <div ref="resultSection" class="space-y-4">
                <!-- KONDISI 1: Belum Memilih Anak — Panduan Standar Posyandu -->
                <div
                    v-if="!pengukuranStore.createResult && !form.anak_id"
                    class="card p-5 md:p-6 rounded-2xl space-y-5"
                >
                    <div class="flex items-center gap-3 pb-3 border-b border-slate-100">
                        <div class="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                            <i class="pi pi-book text-base" />
                        </div>
                        <div>
                            <h3 class="text-sm font-bold text-slate-800 m-0">Standar Pengukuran Posyandu</h3>
                            <p class="text-xs text-slate-400 m-0">Panduan teknis antropometri Kemenkes RI & WHO</p>
                        </div>
                    </div>

                    <!-- Kartu-kartu Edukasi Singkat -->
                    <div class="space-y-3">
                        <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 flex items-start gap-3">
                            <div class="w-7 h-7 rounded-lg bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0 text-xs font-bold">
                                1
                            </div>
                            <div class="text-xs leading-relaxed text-slate-600">
                                <strong class="text-slate-800 block mb-0.5">Penimbangan Berat Badan</strong>
                                Pastikan jarum dacin/timbangan digital berada tepat di angka nol sebelum anak ditimbang. Lepas sepatu, jaket, dan popok tebal balita.
                            </div>
                        </div>

                        <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 flex items-start gap-3">
                            <div class="w-7 h-7 rounded-lg bg-blue-100 text-blue-700 flex items-center justify-center shrink-0 text-xs font-bold">
                                2
                            </div>
                            <div class="text-xs leading-relaxed text-slate-600">
                                <strong class="text-slate-800 block mb-0.5">Panjang vs Tinggi Badan</strong>
                                Anak <strong>&lt; 24 bulan</strong> diukur telentang (*Panjang Badan*). Anak <strong>≥ 24 bulan</strong> diukur berdiri tegak lurus (*Tinggi Badan*).
                            </div>
                        </div>

                        <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 flex items-start gap-3">
                            <div class="w-7 h-7 rounded-lg bg-amber-100 text-amber-700 flex items-center justify-center shrink-0 text-xs font-bold">
                                3
                            </div>
                            <div class="text-xs leading-relaxed text-slate-600">
                                <strong class="text-slate-800 block mb-0.5">Pita LiLA (Lingkar Lengan)</strong>
                                Lingkarkan pita di lengan kiri tanpa menekan otot. LiLA &lt; 11.5 cm pada usia 6-59 bulan menandakan risiko gizi buruk (merah).
                            </div>
                        </div>
                    </div>
                </div>

                <!-- KONDISI 2: Anak Dipilih, Sebelum Submit — Riwayat Terakhir & Live Delta -->
                <div
                    v-else-if="!pengukuranStore.createResult && form.anak_id && anakTerpilih"
                    class="space-y-4"
                >
                    <!-- Rekomendasi Posisi Pengukuran Berdasarkan Usia -->
                    <div v-if="isUnderTwoYears !== null" class="transition-all">
                        <div
                            v-if="isUnderTwoYears"
                            class="flex items-start gap-3 p-4 rounded-2xl bg-blue-50/80 border border-blue-200 text-blue-900 text-xs shadow-2xs"
                        >
                            <div class="w-7 h-7 rounded-xl bg-blue-100 text-blue-700 flex items-center justify-center shrink-0">
                                <i class="pi pi-info-circle text-sm" />
                            </div>
                            <div>
                                <span class="font-bold text-xs text-blue-900 block">Rekomendasi Posisi: Panjang Badan (Terlentang)</span>
                                <p class="mt-1 mb-0 text-blue-700 text-[11px] leading-relaxed">
                                    Anak berusia di bawah 24 bulan (&lt; 2 tahun) diukur panjang badannya dalam posisi telentang menggunakan infantometer.
                                </p>
                            </div>
                        </div>
                        <div
                            v-else
                            class="flex items-start gap-3 p-4 rounded-2xl bg-emerald-50/80 border border-emerald-200 text-emerald-900 text-xs shadow-2xs"
                        >
                            <div class="w-7 h-7 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                                <i class="pi pi-info-circle text-sm" />
                            </div>
                            <div>
                                <span class="font-bold text-xs text-emerald-900 block">Rekomendasi Posisi: Tinggi Badan (Berdiri)</span>
                                <p class="mt-1 mb-0 text-emerald-700 text-[11px] leading-relaxed">
                                    Anak berusia 24 bulan ke atas (≥ 2 tahun) diukur tinggi badannya dalam posisi berdiri tegak menggunakan stadiometer/microtoise.
                                </p>
                            </div>
                        </div>
                    </div>

                    <div class="card p-5 md:p-6 rounded-2xl space-y-5">
                        <!-- Header Ringkasan Anak -->
                    <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                        <div class="flex items-center gap-2.5">
                            <div class="w-8 h-8 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center">
                                <i class="pi pi-history text-sm" />
                            </div>
                            <div>
                                <h3 class="text-sm font-bold text-slate-800 m-0">Riwayat Pengukuran Terakhir</h3>
                            </div>
                        </div>
                        <span
                            v-if="pengukuranStore.loading.riwayat"
                            class="text-xs text-slate-400 flex items-center gap-1.5"
                        >
                            <i class="pi pi-spin pi-spinner text-xs" /> Memuat data...
                        </span>
                    </div>

                    <!-- Loader State -->
                    <div v-if="pengukuranStore.loading.riwayat" class="space-y-3 animate-pulse">
                        <div class="h-16 bg-slate-100 rounded-xl" />
                        <div class="grid grid-cols-2 gap-3">
                            <div class="h-20 bg-slate-100 rounded-xl" />
                            <div class="h-20 bg-slate-100 rounded-xl" />
                        </div>
                    </div>

                    <!-- Belum Pernah Diukur Sebelumnya -->
                    <div
                        v-else-if="!lastPengukuran"
                        class="p-4 rounded-xl bg-slate-50 border border-slate-200 text-center space-y-2"
                    >
                        <i class="pi pi-calendar-plus text-2xl text-slate-400" />
                        <p class="text-xs font-bold text-slate-700 m-0">Pengukuran Perdana</p>
                        <p class="text-[11px] text-slate-500 m-0 leading-relaxed max-w-sm mx-auto">
                            Anak ini belum memiliki data pengukuran sebelumnya. Data yang Anda simpan akan menjadi titik awal (baseline) grafik pertumbuhannya.
                        </p>
                    </div>

                    <!-- Data Pengukuran Terakhir Ditemukan -->
                    <div v-else class="space-y-4">
                        <div class="flex items-center justify-between text-xs text-slate-500">
                            <span>Diukur pada:</span>
                            <span class="font-semibold text-slate-700 bg-slate-100 px-2.5 py-0.5 rounded-md">
                                {{ formatTanggal(lastPengukuran.tanggal_ukur) }}
                            </span>
                        </div>

                        <!-- Card Baseline Pengukuran Terakhir (4 Metrik) -->
                        <div class="grid grid-cols-2 gap-3">
                            <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 text-center">
                                <p class="text-[11px] text-slate-400 m-0">Berat Terakhir</p>
                                <p class="text-lg font-bold text-slate-800 mt-0.5 mb-0">
                                    {{ lastPengukuran.berat_badan }} <span class="text-xs font-normal text-slate-500">kg</span>
                                </p>
                            </div>
                            <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 text-center">
                                <p class="text-[11px] text-slate-400 m-0">Tinggi/Panjang Terakhir</p>
                                <p class="text-lg font-bold text-slate-800 mt-0.5 mb-0">
                                    {{ lastPengukuran.tinggi_badan }} <span class="text-xs font-normal text-slate-500">cm</span>
                                </p>
                            </div>
                            <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 text-center">
                                <p class="text-[11px] text-slate-400 m-0">Lingkar Kepala Terakhir</p>
                                <p class="text-lg font-bold text-slate-800 mt-0.5 mb-0">
                                    {{ lastPengukuran.lingkar_kepala != null && lastPengukuran.lingkar_kepala !== '' ? lastPengukuran.lingkar_kepala : '—' }}
                                    <span v-if="lastPengukuran.lingkar_kepala != null && lastPengukuran.lingkar_kepala !== ''" class="text-xs font-normal text-slate-500">cm</span>
                                </p>
                            </div>
                            <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 text-center">
                                <p class="text-[11px] text-slate-400 m-0">Lingkar Lengan Terakhir</p>
                                <p class="text-lg font-bold text-slate-800 mt-0.5 mb-0">
                                    {{ lastPengukuran.lingkar_lengan != null && lastPengukuran.lingkar_lengan !== '' ? lastPengukuran.lingkar_lengan : '—' }}
                                    <span v-if="lastPengukuran.lingkar_lengan != null && lastPengukuran.lingkar_lengan !== ''" class="text-xs font-normal text-slate-500">cm</span>
                                </p>
                            </div>
                        </div>

                        <!-- Live Delta Box (Saat Kader Mengetik Input Baru) -->
                        <div
                            v-if="deltaBB || deltaTB"
                            class="p-4 rounded-xl border border-emerald-200 bg-emerald-50/60 space-y-2.5 transition-all"
                        >
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-emerald-900 flex items-center gap-1.5">
                                    <i class="pi pi-chart-line text-emerald-600" />
                                    Perubahan Terhadap Bulan Lalu
                                </span>
                                <span class="text-[10px] text-emerald-700 font-semibold bg-emerald-100/70 px-2 py-0.5 rounded">
                                    Realtime
                                </span>
                            </div>

                            <div class="grid grid-cols-2 gap-2 text-xs">
                                <!-- Delta BB -->
                                <div v-if="deltaBB" class="bg-white p-2.5 rounded-lg border border-emerald-100">
                                    <span class="text-[11px] text-slate-500 block">Selisih Berat:</span>
                                    <div class="flex items-center gap-1.5 mt-0.5">
                                        <i
                                            v-if="deltaBB.direction === 'up'"
                                            class="pi pi-arrow-up text-emerald-600 text-xs font-bold"
                                        />
                                        <i
                                            v-else-if="deltaBB.direction === 'down'"
                                            class="pi pi-arrow-down text-rose-600 text-xs font-bold"
                                        />
                                        <i
                                            v-else
                                            class="pi pi-minus text-slate-400 text-xs"
                                        />
                                        <span
                                            class="font-bold text-sm"
                                            :class="deltaBB.direction === 'up' ? 'text-emerald-700' : (deltaBB.direction === 'down' ? 'text-rose-700' : 'text-slate-700')"
                                        >
                                            {{ deltaBB.formatted }}
                                        </span>
                                    </div>
                                </div>

                                <!-- Delta TB -->
                                <div v-if="deltaTB" class="bg-white p-2.5 rounded-lg border border-emerald-100">
                                    <span class="text-[11px] text-slate-500 block">Selisih Tinggi:</span>
                                    <div class="flex items-center gap-1.5 mt-0.5">
                                        <i
                                            v-if="deltaTB.direction === 'up'"
                                            class="pi pi-arrow-up text-emerald-600 text-xs font-bold"
                                        />
                                        <i
                                            v-else-if="deltaTB.direction === 'down'"
                                            class="pi pi-arrow-down text-rose-600 text-xs font-bold"
                                        />
                                        <i
                                            v-else
                                            class="pi pi-minus text-slate-400 text-xs"
                                        />
                                        <span
                                            class="font-bold text-sm"
                                            :class="deltaTB.direction === 'up' ? 'text-emerald-700' : (deltaTB.direction === 'down' ? 'text-rose-700' : 'text-slate-700')"
                                        >
                                            {{ deltaTB.formatted }}
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Peringatan jika BB turun tajam -->
                            <div
                                v-if="deltaBB && deltaBB.diff < -0.8"
                                class="text-[11px] text-rose-800 bg-rose-50 border border-rose-200 p-2 rounded-lg leading-relaxed flex items-start gap-1.5"
                            >
                                <i class="pi pi-exclamation-triangle text-rose-600 mt-0.5 shrink-0" />
                                <span>Perhatian: Berat badan mengalami penurunan cukup tajam (&gt; 0.8 kg). Pastikan angka timbangan sudah benar.</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

                <!-- KONDISI 3: Pengukuran Berhasil Disimpan — Komponen Hasil -->
                <template v-else-if="pengukuranStore.createResult">
                    <PengukuranResultCard
                        :result="pengukuranStore.createResult"
                        :anak="anakTerpilih"
                    />
                </template>
            </div>
        </div>

        <!-- ─── Dialog Konfirmasi Pengukuran ────────────────────────── -->
        <Dialog
            v-model:visible="showConfirmation"
            modal
            header="Konfirmasi Pengukuran"
            :style="{ width: '520px', maxWidth: '95vw' }"
        >
            <div class="space-y-4">
                <div class="p-3.5 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs leading-relaxed flex items-start gap-2">
                    <i class="pi pi-exclamation-circle text-amber-600 mt-0.5 shrink-0 text-sm" />
                    <span>Pastikan identitas anak dan seluruh nilai ukuran sudah tepat. Data yang tersimpan akan langsung memengaruhi grafik pertumbuhan dan skor prioritas posyandu.</span>
                </div>

                <div class="rounded-xl border border-slate-200 divide-y divide-slate-100 overflow-hidden">
                    <div class="p-4 bg-slate-50/60">
                        <p class="text-[11px] uppercase tracking-wider font-semibold text-slate-400 m-0">Anak</p>
                        <p class="text-sm font-bold text-slate-800 mt-1 mb-0">{{ anakTerpilih?.nama }}</p>
                        <p class="text-xs text-slate-500 mt-0.5 mb-0">Orang tua: {{ anakTerpilih?.nama_orang_tua || "—" }}</p>
                    </div>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-3 p-4 text-xs m-0">
                        <div>
                            <dt class="text-slate-400">Tanggal Pengukuran</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ formattedMeasurementDate }}</dd>
                        </div>
                        <div>
                            <dt class="text-slate-400">Berat Badan</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ form.berat_badan }} kg</dd>
                        </div>
                        <div>
                            <dt class="text-slate-400">{{ isUnderTwoYears ? 'Panjang Badan' : 'Tinggi Badan' }}</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ form.tinggi_badan }} cm</dd>
                        </div>
                        <div>
                            <dt class="text-slate-400">Lingkar Kepala</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ optionalMeasurementLabel(form.lingkar_kepala) }}</dd>
                        </div>
                        <div>
                            <dt class="text-slate-400">Lingkar Lengan Atas</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ optionalMeasurementLabel(form.lingkar_lengan) }}</dd>
                        </div>
                    </dl>
                </div>

                <div class="flex justify-end gap-2.5 pt-2">
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 cursor-pointer transition-colors"
                        :disabled="pengukuranStore.loading.create"
                        @click="showConfirmation = false"
                    >
                        Periksa Kembali
                    </button>
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-700 inline-flex items-center gap-2 cursor-pointer disabled:opacity-60 transition-colors shadow-2xs"
                        :disabled="pengukuranStore.loading.create"
                        @click="confirmSubmit"
                    >
                        <i v-if="pengukuranStore.loading.create" class="pi pi-spin pi-spinner" aria-hidden="true" />
                        <i v-else class="pi pi-check" aria-hidden="true" />
                        Simpan Pengukuran
                    </button>
                </div>
            </div>
        </Dialog>
    </div>
</template>

<script setup>
import { computed, reactive, ref, watch, nextTick, onMounted } from "vue";
import { useRoute } from "vue-router";
import { DatePicker, Dialog } from "primevue";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { useKaderStore } from "@/stores/kaderStore";
import PengukuranResultCard from "@/components/cards/PengukuranResultCard.vue";
import { formatTanggal, hitungUsia, toLocalDateStr } from "@/utils/format.js";
import { validateMeasurement } from "@/utils/measurementValidation.js";
import {
    getCurrentAgeMeasurementWarning,
    getMeasurementDateLimits,
    validateMeasurementDate,
} from "@/utils/measurementEligibility.js";

const pengukuranStore = usePengukuranStore();
const kaderStore = useKaderStore();
const route = useRoute();

const todayDate = new Date();
const showConfirmation = ref(false);
const attemptedSubmit = ref(false);
const resultSection = ref(null);
const searchAnak = ref("");

const form = reactive({
    anak_id: "",
    tanggal_ukur: todayDate,
    berat_badan: null,
    tinggi_badan: null,
    lingkar_kepala: null,
    lingkar_lengan: null,
});

/* ── Helper inisial nama ────────────────────────────────────────── */
const getInitials = (name) => {
    if (!name) return "A";
    const parts = name.trim().split(" ");
    return parts.length >= 2
        ? (parts[0][0] + parts[1][0]).toUpperCase()
        : name.slice(0, 2).toUpperCase();
};

/* ── Info anak terpilih ──────────────────────────────────────────── */
const anakTerpilih = computed(
    () => kaderStore.anakOptions.find((a) => a.id === form.anak_id) || null,
);

const filteredAnakOptions = computed(() => {
    if (!searchAnak.value.trim()) return kaderStore.anakOptions;
    const q = searchAnak.value.toLowerCase().trim();
    return kaderStore.anakOptions.filter(
        (a) =>
            a.nama?.toLowerCase().includes(q) ||
            a.nama_orang_tua?.toLowerCase().includes(q) ||
            a.nik?.includes(q),
    );
});

const handleGantiAnak = () => {
    form.anak_id = "";
    searchAnak.value = "";
    if (pengukuranStore.createResult) {
        pengukuranStore.resetCreateState();
    }
};

/* ── Usia & Panduan Posisi Ukur ─────────────────────────────────── */
const usiaBulanSaatUkur = computed(() => {
    if (!anakTerpilih.value?.tanggal_lahir || !form.tanggal_ukur) return null;
    const lahir = new Date(anakTerpilih.value.tanggal_lahir);
    const ukur = new Date(form.tanggal_ukur);
    const diffDays = (ukur - lahir) / (1000 * 60 * 60 * 24);
    if (diffDays < 0) return null;
    return Math.floor(diffDays / 30.4375);
});

const isUnderTwoYears = computed(() => {
    if (usiaBulanSaatUkur.value === null) {
        if (!anakTerpilih.value?.tanggal_lahir) return null;
        const lahir = new Date(anakTerpilih.value.tanggal_lahir);
        const diffDays = (todayDate - lahir) / (1000 * 60 * 60 * 24);
        return Math.floor(diffDays / 30.4375) < 24;
    }
    return usiaBulanSaatUkur.value < 24;
});

const measurementDateLimits = computed(() =>
    getMeasurementDateLimits(anakTerpilih.value?.tanggal_lahir, todayDate),
);

const currentAgeWarning = computed(() =>
    getCurrentAgeMeasurementWarning(
        anakTerpilih.value?.tanggal_lahir,
        todayDate,
    ),
);

/* ── Riwayat Terakhir & Live Delta ──────────────────────────────── */
const lastPengukuran = computed(() => pengukuranStore.pengukuranTerakhir);

const deltaBB = computed(() => {
    if (!lastPengukuran.value || form.berat_badan === null || form.berat_badan === "") return null;
    const prev = parseFloat(lastPengukuran.value.berat_badan);
    const curr = parseFloat(form.berat_badan);
    if (isNaN(prev) || isNaN(curr)) return null;
    const diff = curr - prev;
    return {
        diff,
        formatted: `${diff > 0 ? "+" : ""}${diff.toFixed(2)} kg`,
        direction: Math.abs(diff) < 0.001 ? "equal" : diff > 0 ? "up" : "down",
    };
});

const deltaTB = computed(() => {
    if (!lastPengukuran.value || form.tinggi_badan === null || form.tinggi_badan === "") return null;
    const prev = parseFloat(lastPengukuran.value.tinggi_badan);
    const curr = parseFloat(form.tinggi_badan);
    if (isNaN(prev) || isNaN(curr)) return null;
    const diff = curr - prev;
    return {
        diff,
        formatted: `${diff > 0 ? "+" : ""}${diff.toFixed(1)} cm`,
        direction: Math.abs(diff) < 0.001 ? "equal" : diff > 0 ? "up" : "down",
    };
});

/* ── Validasi ────────────────────────────────────────────────────── */
const fieldError = computed(() => {
    const errors = validateMeasurement(form);
    if (attemptedSubmit.value) {
        if (!form.anak_id) errors.anak_id = "Anak wajib dipilih";
        if (!form.tanggal_ukur) {
            errors.tanggal_ukur = "Tanggal pengukuran wajib dipilih";
        }
        if (form.berat_badan === null || form.berat_badan === "") {
            errors.berat_badan = "Berat badan wajib diisi";
        }
        if (form.tinggi_badan === null || form.tinggi_badan === "") {
            errors.tinggi_badan = "Tinggi/panjang badan wajib diisi";
        }
    }
    if (anakTerpilih.value && form.tanggal_ukur) {
        const eligibility = validateMeasurementDate(
            anakTerpilih.value.tanggal_lahir,
            form.tanggal_ukur,
            todayDate,
        );
        if (!eligibility.eligible) {
            errors.tanggal_ukur = eligibility.message;
        }
    }
    return errors;
});

const isValid = computed(
    () =>
        form.anak_id &&
        form.tanggal_ukur &&
        form.berat_badan !== null &&
        form.berat_badan !== "" &&
        form.tinggi_badan !== null &&
        form.tinggi_badan !== "" &&
        Object.keys(fieldError.value).length === 0,
);

const formattedMeasurementDate = computed(() =>
    form.tanggal_ukur ? formatTanggal(toLocalDateStr(form.tanggal_ukur)) : "—",
);

const optionalMeasurementLabel = (value) =>
    value === null || value === "" ? "Tidak diisi" : `${value} cm`;

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = () => {
    attemptedSubmit.value = true;
    if (!isValid.value || pengukuranStore.loading.create) return;
    showConfirmation.value = true;
};

const confirmSubmit = async () => {
    if (!isValid.value || pengukuranStore.loading.create) return;
    showConfirmation.value = false;
    pengukuranStore.resetCreateState();

    const payload = {
        anak_id: form.anak_id,
        tanggal_ukur: toLocalDateStr(form.tanggal_ukur || todayDate),
        berat_badan: form.berat_badan,
        tinggi_badan: form.tinggi_badan,
    };
    if (form.lingkar_kepala !== null && form.lingkar_kepala !== "") {
        payload.lingkar_kepala = form.lingkar_kepala;
    }
    if (form.lingkar_lengan !== null && form.lingkar_lengan !== "") {
        payload.lingkar_lengan = form.lingkar_lengan;
    }

    const success = await pengukuranStore.createPengukuran(payload);
    if (success) {
        await nextTick();
        if (window.innerWidth < 1024) {
            resultSection.value?.scrollIntoView({
                behavior: "smooth",
                block: "start",
            });
        }
    }
};

/* ── Watchers ────────────────────────────────────────────────────── */
watch(
    () => form.anak_id,
    async (newId) => {
        if (newId) {
            await pengukuranStore.fetchRiwayat(newId);
        }
        if (pengukuranStore.createResult) {
            pengukuranStore.resetCreateState();
        }
    },
);

watch(
    () => [
        form.tanggal_ukur,
        form.berat_badan,
        form.tinggi_badan,
        form.lingkar_kepala,
        form.lingkar_lengan,
    ],
    () => {
        if (pengukuranStore.createResult) {
            pengukuranStore.resetCreateState();
        }
    },
);

onMounted(async () => {
    pengukuranStore.resetCreateState();
    await kaderStore.fetchAnakOptions();
    if (route.query.anakId) {
        const queryId = Array.isArray(route.query.anakId)
            ? route.query.anakId[0]
            : route.query.anakId;
        form.anak_id = queryId || "";
        if (form.anak_id) {
            await pengukuranStore.fetchRiwayat(form.anak_id);
        }
    }
});
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border, #e2e8f0);
    box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.05);
}
.field-label {
    display: block;
    font-size: 0.75rem;
    font-weight: 600;
    color: var(--color-text-body, #334155);
}
.input-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    font-size: 0.8rem;
    color: #94a3b8;
    pointer-events: none;
}
.input-field {
    background: #ffffff;
    border: 1px solid #cbd5e1;
    color: #1e293b;
    outline: none;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
    font-family: inherit;
}
.input-field::placeholder {
    color: #94a3b8;
    font-size: 0.8rem;
}
.input-field:focus {
    border-color: #059669;
    box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2);
}
.input-field:disabled {
    background: #f8fafc;
    opacity: 0.6;
    cursor: not-allowed;
}
.error-hint {
    font-size: 0.72rem;
    color: #dc2626;
    margin: 0.25rem 0 0 0;
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
