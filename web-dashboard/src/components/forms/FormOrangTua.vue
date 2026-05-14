<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <!-- Error dari API -->
        <Transition name="slide-down">
            <div
                v-if="error"
                class="flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
                style="
                    background: #fef2f2;
                    border: 1px solid #fecaca;
                    color: #b91c1c;
                "
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
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                    aria-required="true"
                    :aria-invalid="!!fieldError.email"
                />
            </div>
            <p v-if="fieldError.email" class="error-hint">
                {{ fieldError.email }}
            </p>
        </div>

        <!-- Password -->
        <div class="space-y-1.5">
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
                <span>{{ loading ? "Menyimpan..." : "Simpan" }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { ref, computed, reactive } from "vue";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
});
const emit = defineEmits(["submit", "cancel"]);

const showPassword = ref(false);

const form = reactive({
    nama_lengkap: "",
    nik: "",
    email: "",
    password: "",
    no_hp: "",
    alamat: "",
});

/* ── Validasi per field ──────────────────────────────────────────── */
const fieldError = computed(() => {
    const e = {};
    if (form.nama_lengkap && form.nama_lengkap.trim().length < 3)
        e.nama_lengkap = "Nama minimal 3 karakter";
    if (form.nik && !/^\d{16}$/.test(form.nik))
        e.nik = "NIK harus tepat 16 digit angka";
    if (form.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email))
        e.email = "Format email tidak valid";
    if (form.password && form.password.length < 6)
        e.password = "Password minimal 6 karakter";
    if (form.no_hp && !/^(\+62|08)\d{7,12}$/.test(form.no_hp))
        e.no_hp = "Format nomor HP tidak valid";
    return e;
});

/* ── Form valid jika semua field terisi dan tidak ada error ──────── */
const isValid = computed(
    () =>
        form.nama_lengkap.trim() &&
        /^\d{16}$/.test(form.nik) &&
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email) &&
        form.password.length >= 6 &&
        form.no_hp.trim() &&
        form.alamat.trim() &&
        Object.keys(fieldError.value).length === 0,
);

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = () => {
    if (!isValid.value || props.loading) return;
    emit("submit", {
        nama_lengkap: form.nama_lengkap.trim(),
        nik: form.nik,
        email: form.email.trim(),
        password: form.password,
        no_hp: form.no_hp.trim(),
        alamat: form.alamat.trim(),
    });
};
</script>

<style scoped>
.field-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 600;
    margin-left: 0.25rem;
    color: var(--color-text-body);
}

.input-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    font-size: 0.85rem;
    color: var(--color-text-muted);
    pointer-events: none;
}

.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
    font-family: "Poppins", sans-serif;
}
.input-field::placeholder {
    color: var(--color-text-muted);
    font-size: 0.82rem;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.input-field:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.error-hint {
    font-size: 0.72rem;
    color: #dc2626;
    margin: 0 0 0 0.25rem;
}

.btn-submit {
    background: linear-gradient(
        135deg,
        var(--color-green-600),
        var(--color-green-800)
    );
    box-shadow: 0 2px 8px var(--color-shadow-green);
}
.btn-submit:hover:not(:disabled) {
    filter: brightness(1.08);
}
.btn-submit:active:not(:disabled) {
    transform: scale(0.97);
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
</style>
