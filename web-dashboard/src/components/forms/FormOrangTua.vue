<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <!-- Error dari API -->
        <Transition name="slide-down">
            <div
                v-if="error"
                class="error-alert flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
                role="alert"
                aria-live="assertive"
            >
                <i
                    class="pi pi-exclamation-circle mt-0.5 flex-shrink-0"
                    aria-hidden="true"
                />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <!-- Nama Lengkap -->
        <div class="space-y-1.5">
            <label for="nama_lengkap" class="field-label">Nama Lengkap</label>
            <div class="relative">
                <i class="pi pi-user input-icon" aria-hidden="true" />
                <input
                    id="nama_lengkap"
                    v-model="form.nama_lengkap"
                    type="text"
                    placeholder="Masukkan nama lengkap"
                    autocomplete="name"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                    aria-required="true"
                    :aria-invalid="!!fieldError.nama_lengkap"
                />
            </div>
            <p v-if="fieldError.nama_lengkap" class="error-hint">
                {{ fieldError.nama_lengkap }}
            </p>
        </div>

        <!-- NIK -->
        <div class="space-y-1.5">
            <label for="nik" class="field-label"
                >NIK
                <span
                    class="text-xs font-normal"
                    style="color: var(--color-text-muted)"
                    >(16 digit)</span
                ></label
            >
            <div class="relative">
                <i class="pi pi-id-card input-icon" aria-hidden="true" />
                <input
                    id="nik"
                    v-model="form.nik"
                    type="text"
                    placeholder="1234567890123456"
                    inputmode="numeric"
                    maxlength="16"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm font-mono"
                    aria-required="true"
                    :aria-invalid="!!fieldError.nik"
                    @input="form.nik = form.nik.replace(/\D/g, '')"
                />
            </div>
            <p v-if="fieldError.nik" class="error-hint">{{ fieldError.nik }}</p>
        </div>

        <!-- Email -->
        <div class="space-y-1.5">
            <label for="email_ot" class="field-label">Email</label>
            <div class="relative">
                <i class="pi pi-envelope input-icon" aria-hidden="true" />
                <input
                    id="email_ot"
                    v-model="form.email"
                    type="email"
                    placeholder="nama@email.com"
                    autocomplete="email"
                    :disabled="loading || isEdit"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                    :aria-required="!isEdit"
                    :aria-invalid="!!fieldError.email"
                />
            </div>
            <p v-if="fieldError.email" class="error-hint">
                {{ fieldError.email }}
            </p>
            <p
                v-else-if="isEdit"
                class="text-xs m-0"
                style="color: var(--color-text-muted)"
            >
                Email akun tidak dapat diubah dari data master.
            </p>
        </div>

        <!-- Password -->
        <div v-if="!isEdit" class="space-y-1.5">
            <label for="password_ot" class="field-label"
                >Password
                <span
                    class="text-xs font-normal"
                    style="color: var(--color-text-muted)"
                    >(min. 6 karakter)</span
                ></label
            >
            <div class="relative">
                <i class="pi pi-lock input-icon" aria-hidden="true" />
                <input
                    id="password_ot"
                    v-model="form.password"
                    :type="showPassword ? 'text' : 'password'"
                    placeholder="••••••••"
                    :disabled="loading"
                    maxlength="72"
                    class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                    aria-required="true"
                    :aria-invalid="!!fieldError.password"
                />
                <button
                    type="button"
                    class="absolute right-3 top-1/2 -translate-y-1/2 bg-transparent border-0 cursor-pointer p-0 leading-none"
                    style="color: var(--color-text-muted)"
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
                        aria-hidden="true"
                    />
                </button>
            </div>
            <p v-if="fieldError.password" class="error-hint">
                {{ fieldError.password }}
            </p>
        </div>

        <!-- No HP -->
        <div class="space-y-1.5">
            <label for="no_hp" class="field-label">No. HP</label>
            <div class="relative">
                <i class="pi pi-phone input-icon" aria-hidden="true" />
                <input
                    id="no_hp"
                    v-model="form.no_hp"
                    type="tel"
                    placeholder="08xxxxxxxxxx"
                    inputmode="tel"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                    aria-required="true"
                    :aria-invalid="!!fieldError.no_hp"
                    @input="form.no_hp = form.no_hp.replace(/[^\d+]/g, '')"
                />
            </div>
            <p v-if="fieldError.no_hp" class="error-hint">
                {{ fieldError.no_hp }}
            </p>
        </div>

        <!-- Alamat -->
        <div class="space-y-1.5">
            <label for="alamat" class="field-label">Alamat</label>
            <textarea
                id="alamat"
                v-model="form.alamat"
                placeholder="Masukkan alamat lengkap"
                rows="3"
                :disabled="loading"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm resize-none"
                aria-required="true"
                :aria-invalid="!!fieldError.alamat"
            />
            <p v-if="fieldError.alamat" class="error-hint">
                {{ fieldError.alamat }}
            </p>
        </div>

        <!-- Tombol aksi -->
        <div class="flex gap-3 pt-2">
            <button
                type="button"
                :disabled="loading"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold transition-colors border"
                style="
                    background: white;
                    color: var(--color-text-body);
                    border-color: var(--color-input-border);
                "
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                :disabled="loading || !isValid"
                class="btn-submit flex-1 py-2.5 rounded-xl text-sm font-semibold text-white transition-all flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed"
            >
                <i
                    v-if="loading"
                    class="pi pi-spin pi-spinner"
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
        form.no_hp = data?.no_hp || "";
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
        e.no_hp = "Format nomor HP tidak valid";
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
        if (!e.no_hp && !form.no_hp.trim()) e.no_hp = "No. HP wajib diisi";
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
