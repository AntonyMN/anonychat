<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

defineProps({
    status: { type: String },
});

const form = useForm({ email: '' });

const submit = () => {
    form.post(route('password.email'));
};
</script>

<template>
    <GuestLayout>
        <Head title="Reset Password — AnonyChat" />

        <div class="text-center mb-8">
            <div class="w-16 h-16 bg-amber-500/10 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <i class="bx bx-key text-3xl text-amber-400"></i>
            </div>
            <h1 class="text-2xl font-black tracking-tight mb-2">Forgot your password?</h1>
            <p class="text-slate-400 text-sm">Enter your email and we'll send you a reset link.</p>
        </div>

        <div v-if="status" class="mb-6 text-sm font-medium text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 rounded-xl px-4 py-3">
            {{ status }}
        </div>

        <form @submit.prevent="submit" class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-slate-300 mb-1.5" for="email">Email Address</label>
                <div class="relative">
                    <i class="bx bx-envelope absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500 text-lg"></i>
                    <input
                        id="email"
                        type="email"
                        v-model="form.email"
                        required
                        autofocus
                        autocomplete="email"
                        placeholder="you@example.com"
                        class="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-amber-500 focus:bg-white/10 transition-all"
                    />
                </div>
                <InputError class="mt-1.5 text-red-400 text-xs" :message="form.errors.email" />
            </div>

            <button
                type="submit"
                :disabled="form.processing"
                class="w-full py-3.5 bg-gradient-to-r from-amber-500 to-orange-600 rounded-xl font-bold text-white shadow-lg shadow-amber-500/20 hover:shadow-amber-500/40 transition-all duration-300 hover:-translate-y-0.5 disabled:opacity-50 mt-2"
            >
                <span v-if="!form.processing">Send Reset Link</span>
                <span v-else>Sending...</span>
            </button>
        </form>

        <p class="mt-6 text-center text-sm text-slate-500">
            Remember your password?
            <Link :href="route('login')" class="text-cyan-400 font-semibold hover:text-cyan-300 transition-colors ml-1">Sign in</Link>
        </p>
    </GuestLayout>
</template>
