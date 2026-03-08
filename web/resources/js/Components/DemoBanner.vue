<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const props = defineProps({
    nextResetAt: String
});

const countdown = ref('');
let interval = null;

const updateCountdown = () => {
    const now = new Date();
    const target = new Date(props.nextResetAt);
    const diff = target - now;

    if (diff <= 0) {
        countdown.value = 'Refreshing now...';
        return;
    }

    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);

    countdown.value = `${hours}h ${minutes}m ${seconds}s`;
};

onMounted(() => {
    updateCountdown();
    interval = setInterval(updateCountdown, 1000);
});

onUnmounted(() => {
    if (interval) clearInterval(interval);
});
</script>

<template>
    <div class="bg-amber-500/10 border-b border-amber-500/20 px-4 py-2 flex items-center justify-center gap-4 backdrop-blur-sm sticky top-0 z-[100]">
        <div class="flex items-center gap-2">
            <i class="bx bxs-info-circle text-amber-500 animate-pulse"></i>
            <span class="text-xs font-bold text-amber-900 dark:text-amber-200 uppercase tracking-wider">Demo Installation</span>
        </div>
        <div class="h-4 w-px bg-amber-500/20"></div>
        <p class="text-xs text-amber-800 dark:text-amber-300 font-medium">
            Database resets in: <span class="font-mono font-bold">{{ countdown }}</span>
        </p>
    </div>
</template>
