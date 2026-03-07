<script setup>
import { Link } from '@inertiajs/vue3';
</script>

<template>
    <div class="min-h-screen bg-[#0f172a] text-white selection:bg-cyan-500 selection:text-white overflow-hidden relative flex items-center justify-center px-4">
        <!-- Background Blobs -->
        <div class="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-purple-600/20 blur-[120px] rounded-full animate-pulse pointer-events-none"></div>
        <div class="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] bg-cyan-600/20 blur-[120px] rounded-full animate-pulse pointer-events-none" style="animation-delay: 2s;"></div>

        <!-- Logo Link -->
        <div class="absolute top-6 left-8 z-10">
            <Link href="/" class="flex items-center gap-2 no-underline">
                <div class="bg-gradient-to-tr from-cyan-500 to-purple-600 p-1.5 rounded-lg shadow-lg shadow-cyan-500/20">
                    <i class="bx bxs-chat text-xl"></i>
                </div>
                <span class="text-lg font-bold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-white to-gray-400">
                    AnonyChat
                </span>
            </Link>
        </div>

        <!-- Card -->
        <div class="relative z-10 w-full max-w-md">
            <div class="bg-white/5 border border-white/10 backdrop-blur-xl rounded-3xl p-8 shadow-2xl">
                <slot />
            </div>
        </div>
    </div>
</template>
