<script setup>
import DemoBanner from '@/Components/DemoBanner.vue';
import { onMounted, ref } from 'vue';
import axios from 'axios';

const demoConfig = ref(null);

onMounted(async () => {
    try {
        const response = await axios.get('/api/config');
        if (response.data.app_env === 'demo') {
            demoConfig.value = response.data;
        }
    } catch (e) {
        console.error('Failed to load demo config');
    }
});
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

const form = useForm({
    username: '',
    email: '',
    password: '',
    password_confirmation: '',
});

const emailAvailable = ref(true);
const usernameAvailable = ref(true);
const checkingEmail = ref(false);
const checkingUsername = ref(false);

const checkUniqueness = async (field, value) => {
    if (!value) return;
    if (field === 'email') checkingEmail.value = true;
    else checkingUsername.value = true;

    try {
        const response = await axios.get('/api/check-uniqueness', {
            params: { [field]: value }
        });
        if (field === 'email') emailAvailable.value = response.data.available;
        else usernameAvailable.value = response.data.available;
    } catch (e) {
        console.error('Uniqueness check failed');
    } finally {
        if (field === 'email') checkingEmail.value = false;
        else checkingUsername.value = false;
    }
};

let debounceTimeout = null;
const debouncedCheck = (field, value) => {
    clearTimeout(debounceTimeout);
    debounceTimeout = setTimeout(() => {
        checkUniqueness(field, value);
    }, 500);
};

const submit = () => {
    if (!emailAvailable.value || !usernameAvailable.value) return;
    form.post(route('register'), {
        onFinish: () => form.reset('password', 'password_confirmation'),
    });
};
</script>

<template>
    <GuestLayout>
        <DemoBanner v-if="demoConfig" :nextResetAt="demoConfig.next_reset_at" />
        <Head title="Create Account — AnonyChat" />

        <!-- Header -->
        <div class="text-center mb-8">
            <h1 class="text-3xl font-black tracking-tight mb-2">Create your identity</h1>
            <p class="text-slate-400 text-sm">Join AnonyChat and start connecting</p>
        </div>

        <form @submit.prevent="submit" class="space-y-4">
            <!-- Username -->
            <div>
                <label class="block text-sm font-medium text-slate-300 mb-1.5" for="username">Username</label>
                <div class="relative">
                    <i class="bx bx-at absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500 text-lg"></i>
                    <input
                        id="username"
                        type="text"
                        v-model="form.username"
                        @input="debouncedCheck('username', form.username)"
                        required
                        autofocus
                        autocomplete="username"
                        placeholder="choose_a_username"
                        :class="{'border-red-500': !usernameAvailable}"
                        class="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 focus:bg-white/10 transition-all"
                    />
                </div>
                <div v-if="!usernameAvailable && !checkingUsername" class="mt-1 text-red-500 text-xs">This username is already taken.</div>
                <div v-if="checkingUsername" class="mt-1 text-slate-500 text-xs">Checking availability...</div>
                <InputError class="mt-1.5 text-red-400 text-xs" :message="form.errors.username" />
            </div>

            <!-- Email (Optional) -->
            <div>
                <label class="block text-sm font-medium text-slate-300 mb-1.5" for="email">
                    Email Address
                </label>
                <div class="relative">
                    <i class="bx bx-envelope absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500 text-lg"></i>
                    <input
                        id="email"
                        type="email"
                        v-model="form.email"
                        @input="debouncedCheck('email', form.email)"
                        required
                        autocomplete="email"
                        placeholder="you@example.com"
                        :class="{'border-red-500': !emailAvailable}"
                        class="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 focus:bg-white/10 transition-all"
                    />
                </div>
                <div v-if="!emailAvailable && !checkingEmail" class="mt-1 text-red-500 text-xs">This email is already registered.</div>
                <div v-if="checkingEmail" class="mt-1 text-slate-500 text-xs">Checking availability...</div>
                <InputError class="mt-1.5 text-red-400 text-xs" :message="form.errors.email" />
            </div>

            <!-- Password -->
            <div>
                <label class="block text-sm font-medium text-slate-300 mb-1.5" for="password">Password</label>
                <div class="relative">
                    <i class="bx bx-lock-open-alt absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500 text-lg"></i>
                    <input
                        id="password"
                        type="password"
                        v-model="form.password"
                        required
                        autocomplete="new-password"
                        placeholder="••••••••"
                        class="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 focus:bg-white/10 transition-all"
                    />
                </div>
                <InputError class="mt-1.5 text-red-400 text-xs" :message="form.errors.password" />
            </div>

            <!-- Confirm Password -->
            <div>
                <label class="block text-sm font-medium text-slate-300 mb-1.5" for="password_confirmation">Confirm Password</label>
                <div class="relative">
                    <i class="bx bx-lock-alt absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500 text-lg"></i>
                    <input
                        id="password_confirmation"
                        type="password"
                        v-model="form.password_confirmation"
                        required
                        autocomplete="new-password"
                        placeholder="••••••••"
                        class="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 focus:bg-white/10 transition-all"
                    />
                </div>
                <InputError class="mt-1.5 text-red-400 text-xs" :message="form.errors.password_confirmation" />
            </div>

            <!-- Submit -->
            <button
                type="submit"
                :disabled="form.processing"
                class="w-full py-3.5 bg-gradient-to-r from-purple-500 to-blue-600 rounded-xl font-bold text-white shadow-lg shadow-purple-500/20 hover:shadow-purple-500/40 transition-all duration-300 hover:-translate-y-0.5 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:translate-y-0 mt-2"
            >
                <span v-if="!form.processing">Create Account</span>
                <span v-else class="flex items-center justify-center gap-2">
                    <svg class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                    </svg>
                    Creating account...
                </span>
            </button>
        </form>

        <!-- Footer link -->
        <p class="mt-6 text-center text-sm text-slate-500">
            Already have an account?
            <Link :href="route('login')" class="text-purple-400 font-semibold hover:text-purple-300 transition-colors ml-1">Sign in</Link>
        </p>
    </GuestLayout>
</template>
