<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

defineProps({
    canResetPassword: { type: Boolean },
    status: { type: String },
});

const form = useForm({
    username: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post(route('login'), {
        onFinish: () => form.reset('password'),
    });
};
</script>

<template>
    <GuestLayout>
        <Head title="Sign In — AnonyChat" />

        <!-- Header -->
        <div class="text-center mb-8">
            <h1 class="text-3xl font-black tracking-tight mb-2">Welcome back</h1>
            <p class="text-slate-400 text-sm">Sign in to your AnonyChat account</p>
        </div>

        <div v-if="status" class="mb-6 text-sm font-medium text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 rounded-xl px-4 py-3">
            {{ status }}
        </div>

        <form @submit.prevent="submit" class="space-y-4">
            <!-- Username -->
            <div>
                <label class="block text-sm font-medium text-slate-300 mb-1.5" for="username">Username</label>
                <div class="relative">
                    <i class="bx bx-user absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500 text-lg"></i>
                    <input
                        id="username"
                        type="text"
                        v-model="form.username"
                        required
                        autofocus
                        autocomplete="username"
                        placeholder="your_username"
                        class="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500 focus:bg-white/10 transition-all"
                    />
                </div>
                <InputError class="mt-1.5 text-red-400 text-xs" :message="form.errors.username" />
            </div>

            <!-- Password -->
            <div>
                <label class="block text-sm font-medium text-slate-300 mb-1.5" for="password">Password</label>
                <div class="relative">
                    <i class="bx bx-lock-alt absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500 text-lg"></i>
                    <input
                        id="password"
                        type="password"
                        v-model="form.password"
                        required
                        autocomplete="current-password"
                        placeholder="••••••••"
                        class="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500 focus:bg-white/10 transition-all"
                    />
                </div>
                <InputError class="mt-1.5 text-red-400 text-xs" :message="form.errors.password" />
            </div>

            <!-- Remember + Forgot -->
            <div class="flex items-center justify-between">
                <label class="flex items-center gap-2 cursor-pointer">
                    <input
                        type="checkbox"
                        name="remember"
                        v-model="form.remember"
                        class="rounded border-white/20 bg-white/5 text-cyan-500 focus:ring-cyan-500"
                    />
                    <span class="text-sm text-slate-400">Remember me</span>
                </label>
                <Link
                    v-if="canResetPassword"
                    :href="route('password.request')"
                    class="text-sm text-cyan-400 hover:text-cyan-300 transition-colors"
                >
                    Forgot password?
                </Link>
            </div>

            <!-- Submit -->
            <button
                type="submit"
                :disabled="form.processing"
                class="w-full py-3.5 bg-gradient-to-r from-cyan-500 to-blue-600 rounded-xl font-bold text-white shadow-lg shadow-cyan-500/20 hover:shadow-cyan-500/40 transition-all duration-300 hover:-translate-y-0.5 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:translate-y-0 mt-2"
            >
                <span v-if="!form.processing">Sign In</span>
                <span v-else class="flex items-center justify-center gap-2">
                    <svg class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                    </svg>
                    Signing in...
                </span>
            </button>
        </form>

        <!-- Footer link -->
        <p class="mt-6 text-center text-sm text-slate-500">
            Don't have an account?
            <Link :href="route('register')" class="text-cyan-400 font-semibold hover:text-cyan-300 transition-colors ml-1">Create one</Link>
        </p>
    </GuestLayout>
</template>
