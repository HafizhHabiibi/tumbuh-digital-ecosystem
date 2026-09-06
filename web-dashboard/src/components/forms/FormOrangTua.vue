<template>
    <form class="space-y-4 pt-2" novalidate @submit.prevent="handleSubmit">
        <!-- Error dari API -->
        <Transition name="slide-down">
            <div
                v-if="error"
                class="flex items-start gap-2.5 p-3 rounded-xl text-xs bg-red-50 border border-red-200 text-red-700"
                role="alert"
                aria-live="assertive"
            >
                <i
                    class="pi pi-exclamation-circle mt-0.5 shrink-0 text-red-600"
                    aria-hidden="true"
                />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <!-- Nama Lengkap -->
        <div class="space-y-1.5">
            <label for="nama_lengkap" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Nama Lengkap
            </label>
            <div class="relative">
                <i
                    class="pi pi-user absolute left-3.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none"
                    aria-hidden="true"
                />
                <input
                    id="nama_lengkap"
                    v-model="form.nama_lengkap"
                    type="text"
                    placeholder="Masukkan nama lengkap"
                    autocomplete="name"
                    :disabled="loading"
                    class="w-full pl-9 pr-4 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none"
                    aria-required="true"
                    :aria-invalid="!!fieldError.nama_lengkap"
                />
            </div>
            <p v-if="fieldError.nama_lengkap" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.nama_lengkap }}
            </p>
        </div>

        <!-- NIK -->
        <div class="space-y-1.5">
            <label for="nik" class="text-xs font-semibold text-slate-700 block ml-0.5">
                NIK
            </label>
            <div class="relative">
                <i
                    class="pi pi-id-card absolute left-3.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none"
                    aria-hidden="true"
                />
                <input
                    id="nik"
                    v-model="form.nik"
                    type="text"
                    placeholder="1234567890123456"
                    inputmode="numeric"
                    maxlength="16"
                    :disabled="loading"
                    class="w-full pl-9 pr-4 py-2.5 rounded-xl text-sm font-mono tracking-wider bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none"
                    aria-required="true"
                    :aria-invalid="!!fieldError.nik"
                    @input="form.nik = form.nik.replace(/\D/g, '')"
                />
            </div>
            <p v-if="fieldError.nik" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.nik }}
            </p>
        </div>

        <!-- Email -->
        <div class="space-y-1.5">
            <label for="email_ot" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Email
            </label>
            <div class="relative">
                <i
                    class="pi pi-envelope absolute left-3.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none"
                    aria-hidden="true"
                />
                <input
                    id="email_ot"
                    v-model="form.email"
                    type="email"
                    placeholder="nama@email.com"
                    autocomplete="email"
                    :disabled="loading || isEdit"
                    class="w-full pl-9 pr-4 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200"
                    :aria-required="!isEdit"
                    :aria-invalid="!!fieldError.email"
                />
            </div>
            <p v-if="fieldError.email" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.email }}
            </p>
        </div>

        <!-- Password (hanya saat tambah baru) -->
        <div v-if="!isEdit" class="space-y-1.5">
            <label for="password_ot" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Password
            </label>
            <div class="relative">
                <i
                    class="pi pi-lock absolute left-3.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none"
                    aria-hidden="true"
                />
                <input
                    id="password_ot"
                    v-model="form.password"
                    :type="showPassword ? 'text' : 'password'"
                    placeholder="Minimal 6 karakter"
                    :disabled="loading"
                    maxlength="72"
                    class="w-full pl-9 pr-10 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none"
                    aria-required="true"
                    :aria-invalid="!!fieldError.password"
                />
                <button
                    type="button"
                    class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1.5 rounded-lg cursor-pointer transition-colors"
                    :aria-label="
                        showPassword
                            ? 'Sembunyikan password'
                            : 'Tampilkan password'
                    "
                    :aria-pressed="showPassword"
                    @click="showPassword = !showPassword"
                >
                    <i
                        :class="showPassword ? 'pi pi-eye-slash' : 'pi pi-eye'"
                        class="text-xs"
                        aria-hidden="true"
                    />
                </button>
            </div>
            <p v-if="fieldError.password" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.password }}
            </p>
        </div>

        <!-- No Telepon -->
        <div class="space-y-1.5">
            <label for="no_hp" class="text-xs font-semibold text-slate-700 block ml-0.5">
                No Telepon
            </label>
            <div class="relative">
                <i
                    class="pi pi-phone absolute left-3.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none"
                    aria-hidden="true"
                />
                <input
                    id="no_hp"
                    v-model="form.no_hp"
                    type="tel"
                    placeholder="08xxxxxxxxxx"
                    inputmode="tel"
                    :disabled="loading"
                    class="w-full pl-9 pr-4 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none"
                    aria-required="true"
                    :aria-invalid="!!fieldError.no_hp"
                    @input="form.no_hp = form.no_hp.replace(/[^\d+]/g, '')"
                />
            </div>
            <p v-if="fieldError.no_hp" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.no_hp }}
            </p>
        </div>

        <!-- Alamat -->
        <div class="space-y-1.5">
            <label for="alamat" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Alamat
            </label>
            <textarea
                id="alamat"
                v-model="form.alamat"
                placeholder="Masukkan alamat lengkap"
                rows="3"
                :disabled="loading"
                class="w-full px-3.5 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none resize-none"
                aria-required="true"
                :aria-invalid="!!fieldError.alamat"
            />
            <p v-if="fieldError.alamat" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.alamat }}
            </p>
        </div>

        <!-- Tombol aksi -->
        <div class="flex gap-3 pt-3">
            <button
                type="button"
                :disabled="loading"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer border-0 disabled:opacity-50"
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                :disabled="loading || !isValid"
                class="btn-primary flex-1 py-2.5 rounded-xl text-sm font-semibold text-white transition-all flex items-center justify-center gap-2 cursor-pointer shadow-sm hover:shadow-md disabled:opacity-50 disabled:cursor-not-allowed"
            >
                <i
                    v-if="loading"
                    class="pi pi-spin pi-spinner text-xs"
                    aria-hidden="true"
                />
                <span>{{ submitLabel }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { ref, computed, reactive, watch } from "vue";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    mode: {
        type: String,
        default: "create",
        validator: (value) => ["create", "edit"].includes(value),
    },
    initialData: { type: Object, default: null },
});
const emit = defineEmits(["submit", "cancel"]);

const showPassword = ref(false);
const submitted = ref(false);
const isEdit = computed(() => props.mode === "edit");

const form = reactive({
    nama_lengkap: "",
    nik: "",
    email: "",
    password: "",
    no_hp: "",
    alamat: "",
});

watch(
    () => props.initialData,
    (data) => {
        form.nama_lengkap = data?.nama_lengkap || "";
        form.nik = data?.nik || "";
        form.email = data?.email || "";
        form.password = "";
        form.no_hp = data?.no_hp || data?.no_telepon || "";
        form.alamat = data?.alamat || "";
        submitted.value = false;
        showPassword.value = false;
    },
    { immediate: true },
);

const fieldError = computed(() => {
    const e = {};
    if (form.nama_lengkap && form.nama_lengkap.trim().length < 2)
        e.nama_lengkap = "Nama minimal 2 karakter";
    if (form.nik && !/^\d{16}$/.test(form.nik))
        e.nik = "NIK harus tepat 16 digit angka";
    if (!isEdit.value && form.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email))
        e.email = "Format email tidak valid";
    if (!isEdit.value && form.password && form.password.length < 6)
        e.password = "Password minimal 6 karakter";
    else if (!isEdit.value && form.password.length > 72)
        e.password = "Password maksimal 72 karakter";
    if (form.no_hp && !/^\+?\d{8,20}$/.test(form.no_hp))
        e.no_hp = "Format nomor telepon tidak valid";
    if (form.alamat && form.alamat.trim().length < 3)
        e.alamat = "Alamat minimal 3 karakter";

    if (submitted.value) {
        if (!e.nama_lengkap && !form.nama_lengkap.trim())
            e.nama_lengkap = "Nama lengkap wajib diisi";
        if (!e.nik && !form.nik) e.nik = "NIK wajib diisi";
        if (!isEdit.value && !e.email && !form.email)
            e.email = "Email wajib diisi";
        if (!isEdit.value && !e.password && !form.password)
            e.password = "Password wajib diisi";
        if (!e.no_hp && !form.no_hp.trim()) e.no_hp = "No Telepon wajib diisi";
        if (!form.alamat.trim()) e.alamat = "Alamat wajib diisi";
    }
    return e;
});

const isValid = computed(
    () =>
        form.nama_lengkap.trim().length >= 2 &&
        /^\d{16}$/.test(form.nik) &&
        (isEdit.value || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) &&
        (isEdit.value ||
            (form.password.length >= 6 && form.password.length <= 72)) &&
        /^\+?\d{8,20}$/.test(form.no_hp) &&
        form.alamat.trim().length >= 3 &&
        Object.keys(fieldError.value).length === 0,
);

const submitLabel = computed(() => {
    if (props.loading) return "Menyimpan...";
    return isEdit.value ? "Perbarui" : "Simpan";
});

const handleSubmit = () => {
    submitted.value = true;
    if (!isValid.value || props.loading) return;

    const payload = {
        nama_lengkap: form.nama_lengkap.trim(),
        nik: form.nik,
        no_hp: form.no_hp.trim(),
        alamat: form.alamat.trim(),
    };
    if (!isEdit.value) {
        payload.email = form.email.trim();
        payload.password = form.password;
    }
    emit("submit", payload);
};
</script>

<style scoped>
.btn-primary {
    border: 0;
    background: #059669;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-primary:hover:not(:disabled) {
    background: #047857;
}

.btn-primary:active:not(:disabled) {
    transform: scale(0.99);
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
