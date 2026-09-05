<template>
    <div class="p-4 sm:p-5 md:p-6 w-full max-w-6xl mx-auto space-y-5 min-w-0">
        <!-- ─── Header Modern (Tanpa Subjudul) ───────────────────── -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-slate-800 m-0 tracking-tight">
                    Profil Pengguna
                </h1>
            </div>
            <div class="flex items-center gap-2 self-start sm:self-auto">
                <div class="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white border border-slate-200/80 shadow-2xs text-xs text-slate-600 font-medium">
                    <i class="pi pi-calendar text-emerald-600 text-xs" />
                    <span>Hari ini: <strong class="text-slate-800">{{ formatTanggal(toLocalDateStr(todayDate)) }}</strong></span>
                </div>
            </div>
        </div>

        <!-- ─── Grid 2 Kolom: Identitas & Keamanan ────────────────── -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-5 sm:gap-6 items-start">
            <!-- ── Kolom Kiri: Identitas Akun & Sesi (5 Kolom) ──── -->
            <div class="lg:col-span-5 space-y-5">
                <!-- Kartu Identitas Profil -->
                <div class="card p-5 sm:p-6 rounded-2xl bg-white border border-slate-200/80 shadow-2xs space-y-5">
                    <div class="flex items-center gap-4">
                        <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-emerald-600 to-emerald-800 text-white font-bold text-xl flex items-center justify-center shadow-md shrink-0">
                            {{ userInitial }}
                        </div>
                        <div class="min-w-0">
                            <h2 class="text-base font-bold text-slate-800 truncate m-0">
                                {{ authStore.namaLengkap }}
                            </h2>
                            <div class="mt-1">
                                <span class="text-xs px-2.5 py-0.5 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 inline-block">
                                    Kader Posyandu
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Rincian Informasi Kontak & Akun -->
                    <div class="pt-4 border-t border-slate-100 space-y-3 text-xs">
                        <div class="flex items-center justify-between gap-2">
                            <span class="text-slate-400 flex items-center gap-2">
                                <i class="pi pi-envelope text-slate-400 text-xs" />
                                <span>Email</span>
                            </span>
                            <span class="font-semibold text-slate-700 truncate max-w-[190px]" :title="authStore.user?.email">
                                {{ authStore.user?.email || '—' }}
                            </span>
                        </div>
                        <div class="flex items-center justify-between gap-2">
                            <span class="text-slate-400 flex items-center gap-2">
                                <i class="pi pi-phone text-slate-400 text-xs" />
                                <span>No. Telepon</span>
                            </span>
                            <span class="font-semibold text-slate-700">
                                {{ authStore.profil?.no_hp || '—' }}
                            </span>
                        </div>
                    </div>

                    <!-- Tombol Keluar Akun -->
                    <div class="pt-4 border-t border-slate-100">
                        <button
                            type="button"
                            class="w-full py-2.5 px-4 rounded-xl text-xs font-semibold text-red-600 bg-red-50 hover:bg-red-100 transition-colors border border-red-200 cursor-pointer flex items-center justify-center gap-2"
                            aria-label="Keluar dari akun"
                            @click="showLogoutModal = true"
                        >
                            <i class="pi pi-sign-out text-xs" />
                            <span>Keluar dari Akun</span>
                        </button>
                    </div>
                </div>
            </div>

            <!-- ── Kolom Kanan: Keamanan & Ubah Password (7 Kolom) ─ -->
            <div class="lg:col-span-7">
                <div class="card p-5 sm:p-6 rounded-2xl bg-white border border-slate-200/80 shadow-2xs space-y-5">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-700 border border-emerald-100 flex items-center justify-center shrink-0">
                            <i class="pi pi-lock text-base" />
                        </div>
                        <h2 class="text-base sm:text-lg font-bold text-slate-800 m-0">
                            Ubah Password
                        </h2>
                    </div>

                    <!-- Notifikasi Sukses -->
                    <Transition name="slide-down">
                        <div
                            v-if="successMsg"
                            class="flex items-center gap-2 p-3.5 rounded-xl text-xs text-emerald-800 bg-emerald-50 border border-emerald-200"
                            role="status"
                        >
                            <i class="pi pi-check-circle text-emerald-600 shrink-0" aria-hidden="true" />
                            <span>{{ successMsg }}</span>
                        </div>
                    </Transition>

                    <!-- Notifikasi Error -->
                    <Transition name="slide-down">
                        <div
                            v-if="authStore.error.changePassword"
                            class="flex items-center gap-2 p-3.5 rounded-xl text-xs text-red-700 bg-red-50 border border-red-200"
                            role="alert"
                            aria-live="assertive"
                        >
                            <i class="pi pi-exclamation-circle text-red-500 shrink-0" aria-hidden="true" />
                            <span>{{ authStore.error.changePassword }}</span>
                        </div>
                    </Transition>

                    <form novalidate class="space-y-4" @submit.prevent="handleSubmit">
                        <!-- Password Lama -->
                        <div class="space-y-1.5">
                            <label for="password_lama" class="block text-xs font-semibold text-slate-700">
                                Password Lama
                            </label>
                            <div class="relative">
                                <i class="pi pi-lock absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs" aria-hidden="true" />
                                <input
                                    id="password_lama"
                                    v-model="form.password_lama"
                                    :type="show.lama ? 'text' : 'password'"
                                    placeholder="••••••••"
                                    autocomplete="current-password"
                                    maxlength="72"
                                    :disabled="authStore.loading.changePassword"
                                    class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-invalid="!!validationErrors.password_lama"
                                    aria-describedby="password_lama_error"
                                />
                                <button
                                    type="button"
                                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer p-1"
                                    :aria-label="show.lama ? 'Sembunyikan password' : 'Tampilkan password'"
                                    @click="show.lama = !show.lama"
                                >
                                    <i :class="show.lama ? 'pi pi-eye-slash' : 'pi pi-eye'" class="text-xs" aria-hidden="true" />
                                </button>
                            </div>
                            <p v-if="validationErrors.password_lama" id="password_lama_error" class="text-xs text-red-600 mt-1 mb-0">
                                {{ validationErrors.password_lama }}
                            </p>
                        </div>

                        <!-- Password Baru -->
                        <div class="space-y-1.5">
                            <div class="flex items-center justify-between">
                                <label for="password_baru" class="block text-xs font-semibold text-slate-700">
                                    Password Baru
                                </label>
                                <span class="text-[11px] text-slate-400">Min. 6 karakter</span>
                            </div>
                            <div class="relative">
                                <i class="pi pi-lock absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs" aria-hidden="true" />
                                <input
                                    id="password_baru"
                                    v-model="form.password_baru"
                                    :type="show.baru ? 'text' : 'password'"
                                    placeholder="••••••••"
                                    autocomplete="new-password"
                                    maxlength="72"
                                    :disabled="authStore.loading.changePassword"
                                    class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-invalid="!!validationErrors.password_baru"
                                    aria-describedby="password_baru_error"
                                />
                                <button
                                    type="button"
                                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer p-1"
                                    :aria-label="show.baru ? 'Sembunyikan password' : 'Tampilkan password'"
                                    @click="show.baru = !show.baru"
                                >
                                    <i :class="show.baru ? 'pi pi-eye-slash' : 'pi pi-eye'" class="text-xs" aria-hidden="true" />
                                </button>
                            </div>
                            <p v-if="validationErrors.password_baru" id="password_baru_error" class="text-xs text-red-600 mt-1 mb-0">
                                {{ validationErrors.password_baru }}
                            </p>
                        </div>

                        <!-- Konfirmasi Password Baru -->
                        <div class="space-y-1.5">
                            <label for="konfirmasi_password" class="block text-xs font-semibold text-slate-700">
                                Konfirmasi Password Baru
                            </label>
                            <div class="relative">
                                <i class="pi pi-lock absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs" aria-hidden="true" />
                                <input
                                    id="konfirmasi_password"
                                    v-model="form.konfirmasi"
                                    :type="show.konfirmasi ? 'text' : 'password'"
                                    placeholder="••••••••"
                                    autocomplete="new-password"
                                    maxlength="72"
                                    :disabled="authStore.loading.changePassword"
                                    class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-invalid="!!validationErrors.konfirmasi"
                                    aria-describedby="konfirmasi_password_error"
                                />
                                <button
                                    type="button"
                                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer p-1"
                                    :aria-label="show.konfirmasi ? 'Sembunyikan password' : 'Tampilkan password'"
                                    @click="show.konfirmasi = !show.konfirmasi"
                                >
                                    <i :class="show.konfirmasi ? 'pi pi-eye-slash' : 'pi pi-eye'" class="text-xs" aria-hidden="true" />
                                </button>
                            </div>
                            <p v-if="validationErrors.konfirmasi" id="konfirmasi_password_error" class="text-xs text-red-600 mt-1 mb-0">
                                {{ validationErrors.konfirmasi }}
                            </p>
                        </div>

                        <!-- Tombol Submit Simpan Password -->
                        <button
                            type="submit"
                            class="btn-primary w-full py-3 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 cursor-pointer mt-2 shadow-sm transition-all"
                            :aria-busy="authStore.loading.changePassword"
                        >
                            <i
                                v-if="authStore.loading.changePassword"
                                class="pi pi-spin pi-spinner text-sm"
                                aria-hidden="true"
                            />
                            <span>{{
                                authStore.loading.changePassword
                                    ? "Menyimpan..."
                                    : "Simpan Password"
                            }}</span>
                        </button>

                        <!-- Tautan Lupa Password -->
                        <div class="text-center pt-1">
                            <button
                                type="button"
                                class="text-xs font-semibold text-emerald-700 hover:text-emerald-800 transition-colors bg-transparent border-0 cursor-pointer"
                                @click="handleLupaPassword"
                            >
                                Lupa password lama?
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- ─── Modal Konfirmasi Logout Modern ────────────────── -->
        <Transition name="modal-fade">
            <div
                v-if="showLogoutModal"
                class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs"
                role="dialog"
                aria-modal="true"
                aria-labelledby="modal-logout-title"
                @click.self="showLogoutModal = false"
            >
                <div class="relative bg-white rounded-2xl p-6 max-w-sm w-full shadow-2xl border border-slate-100 text-center space-y-4">
                    <!-- Tombol Silang Tutup -->
                    <button
                        type="button"
                        class="absolute top-4 right-4 text-slate-400 hover:text-slate-600 hover:bg-slate-100 p-1.5 rounded-xl transition-colors cursor-pointer"
                        aria-label="Tutup modal"
                        @click="showLogoutModal = false"
                    >
                        <i class="pi pi-times text-xs" />
                    </button>

                    <!-- Ikon Peringatan Keluar -->
                    <div class="w-14 h-14 rounded-2xl bg-red-50 border border-red-100 text-red-600 flex items-center justify-center mx-auto shadow-2xs">
                        <i class="pi pi-sign-out text-xl" aria-hidden="true" />
                    </div>

                    <!-- Judul & Keterangan -->
                    <div class="space-y-1.5">
                        <h3 id="modal-logout-title" class="text-base sm:text-lg font-bold text-slate-800 m-0 tracking-tight">
                            Keluar dari Akun?
                        </h3>
                        <p class="text-xs text-slate-500 m-0 leading-relaxed max-w-[280px] mx-auto">
                            Sesi Anda pada peramban ini akan diakhiri. Anda perlu masuk kembali untuk mengakses dashboard.
                        </p>
                    </div>

                    <!-- Ringkasan Akun Pengguna -->
                    <div class="p-3 rounded-xl bg-slate-50 border border-slate-100 flex items-center gap-3 text-left">
                        <div class="w-9 h-9 rounded-xl bg-emerald-600 text-white font-bold text-xs flex items-center justify-center shrink-0 shadow-2xs">
                            {{ userInitial }}
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="text-xs font-bold text-slate-800 truncate m-0">
                                {{ authStore.namaLengkap }}
                            </p>
                            <p class="text-[11px] text-slate-400 truncate m-0">
                                {{ authStore.user?.email || '—' }}
                            </p>
                        </div>
                    </div>

                    <!-- Tombol Aksi -->
                    <div class="grid grid-cols-2 gap-2.5 pt-1">
                        <button
                            type="button"
                            class="w-full py-2.5 px-4 rounded-xl text-xs font-semibold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors cursor-pointer"
                            @click="showLogoutModal = false"
                        >
                            Batal
                        </button>
                        <button
                            type="button"
                            class="w-full py-2.5 px-4 rounded-xl text-xs font-semibold text-white bg-red-600 hover:bg-red-700 transition-colors cursor-pointer flex items-center justify-center gap-1.5 shadow-sm"
                            @click="confirmLogout"
                        >
                            <i class="pi pi-sign-out text-xs" />
                            <span>Ya, Keluar</span>
                        </button>
                    </div>
                </div>
            </div>
        </Transition>
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
import { useAuthStore } from "@/stores/authStore";
import { useRouter } from "vue-router";
import { formatTanggal, toLocalDateStr } from "@/utils/format.js";

const authStore = useAuthStore();
const router = useRouter();

const todayDate = new Date();
const successMsg = ref("");
const attemptedSubmit = ref(false);
const showLogoutModal = ref(false);

const form = reactive({
    password_lama: "",
    password_baru: "",
    konfirmasi: "",
});

const show = reactive({
    lama: false,
    baru: false,
    konfirmasi: false,
});

/* ── Inisial Nama Pengguna ────────────────────────────────────────── */
const userInitial = computed(
    () => authStore.namaLengkap?.charAt(0).toUpperCase() ?? "K",
);

/* ── Validasi ────────────────────────────────────────────────────── */
const isValid = computed(
    () =>
        Boolean(form.password_lama.trim()) &&
        form.password_baru.length >= 6 &&
        form.konfirmasi === form.password_baru,
);

const validationErrors = computed(() => {
    if (!attemptedSubmit.value) return {};
    const errors = {};
    if (!form.password_lama.trim()) errors.password_lama = "Password lama wajib diisi";
    if (!form.password_baru) errors.password_baru = "Password baru wajib diisi";
    else if (form.password_baru.length < 6) errors.password_baru = "Password minimal 6 karakter";
    if (!form.konfirmasi) errors.konfirmasi = "Konfirmasi password wajib diisi";
    else if (form.konfirmasi !== form.password_baru) errors.konfirmasi = "Password tidak cocok";
    return errors;
});

/* ── Lupa Password ──────────────────────────────────────────────── */
const handleLupaPassword = () => {
    authStore.logout();
    router.push({ name: "ForgotPassword" });
};

/* ── Logout Konfirmasi ──────────────────────────────────────────── */
const confirmLogout = () => {
    showLogoutModal.value = false;
    authStore.logout();
    router.push({ name: "Login" });
};

/* ── Submit Ubah Password ───────────────────────────────────────── */
const handleSubmit = async () => {
    if (authStore.loading.changePassword) return;
    attemptedSubmit.value = true;
    if (!isValid.value) return;
    successMsg.value = "";

    const ok = await authStore.changePassword(
        form.password_lama,
        form.password_baru,
    );
    if (ok) {
        successMsg.value = "Password berhasil diubah!";
        form.password_lama = "";
        form.password_baru = "";
        form.konfirmasi = "";
        attemptedSubmit.value = false;
    }
};

onMounted(() => authStore.refreshProfile());
</script>

<style scoped>
.card {
    background: #ffffff;
    border: 1px solid rgba(226, 232, 240, 0.9);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
}

.input-field {
    background: #ffffff;
    border: 1px solid #cbd5e1;
    color: #1e293b;
    outline: none;
    font-family: inherit;
    transition: border-color 0.2s, box-shadow 0.2s;
}

.input-field:focus {
    border-color: #059669;
    box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
}

.input-field:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.btn-primary {
    border: 0;
    background: #059669;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-primary:hover {
    background: #047857;
}

.btn-primary:active {
    transform: scale(0.99);
}

.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.25s ease;
}

.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-6px);
}

.modal-fade-enter-active,
.modal-fade-leave-active {
    transition: opacity 0.2s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
    opacity: 0;
}
</style>
