<script setup>
import { ref, computed } from 'vue';
import { Link, usePage, useForm } from '@inertiajs/vue3';

const showingNavigationDropdown = ref(false);
const user = usePage().props.auth.user;
const friendRequests = computed(() => usePage().props.auth.notifications?.friendRequests || []);

const showNotifications = ref(false);
const showSettings = ref(false);

const acceptRequest = (requestId) => {
    useForm({}).post(route('friends.request.accept', requestId), {
        onSuccess: () => showNotifications.value = false
    });
};

const declineRequest = (requestId) => {
    useForm({}).post(route('friends.request.decline', requestId), {
        onSuccess: () => showNotifications.value = false
    });
};
</script>

<template>
    <div @click="showNotifications = false; showSettings = false" class="min-h-screen bg-slate-50 dark:bg-[#0f172a] selection:bg-cyan-500 selection:text-white">
        <!-- Modern Navbar -->
        <nav class="bg-white/80 dark:bg-[#0f172a]/80 backdrop-blur-md border-b border-slate-200 dark:border-white/5 sticky top-0 z-50">
            <div class="max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between h-16">
                    <div class="flex items-center gap-8">
                        <!-- Logo -->
                        <Link :href="route('dashboard')" class="flex items-center gap-2 group">
                            <div class="bg-gradient-to-tr from-cyan-500 to-purple-600 p-1.5 rounded-lg shadow-lg shadow-cyan-500/10 group-hover:scale-110 transition-transform">
                                <i class="bx bxs-chat text-xl text-white"></i>
                            </div>
                            <span class="text-lg font-black tracking-tighter dark:text-white">AnonyChat</span>
                        </Link>
                    </div>

                    <div class="flex items-center gap-4">
                        <!-- User Actions -->
                        <div class="flex items-center gap-2 pr-4 border-r border-slate-200 dark:border-white/5">
                            <div class="relative">
                                <button 
                                    @click.stop="showNotifications = !showNotifications; showSettings = false"
                                    class="p-2 text-slate-400 hover:text-cyan-500 transition-colors relative"
                                >
                                    <i class="bx bx-bell text-xl"></i>
                                    <span v-if="friendRequests.length > 0" class="absolute top-2 right-2 w-2 h-2 bg-pink-500 rounded-full border-2 border-white dark:border-[#0f172a]"></span>
                                </button>
                                
                                <!-- Notifications Dropdown -->
                                <div v-if="showNotifications" @click.stop class="absolute right-0 mt-2 w-80 bg-white dark:bg-[#1e293b] rounded-2xl shadow-2xl border border-slate-200 dark:border-white/5 overflow-hidden z-[60]">
                                    <div class="p-4 border-b border-slate-100 dark:border-white/5 flex justify-between items-center">
                                        <h4 class="font-bold dark:text-white text-sm">Notifications</h4>
                                        <span class="text-[10px] bg-cyan-500 text-white px-2 py-0.5 rounded-full">{{ friendRequests.length }} New</span>
                                    </div>
                                    <div class="max-h-96 overflow-y-auto">
                                        <div v-for="req in friendRequests" :key="req.id" class="p-4 hover:bg-slate-50 dark:hover:bg-white/5 transition-colors border-b border-slate-50 dark:border-white/5 last:border-0">
                                            <div class="flex items-start gap-3">
                                                <img :src="req.sender.profile_image ? '/storage/' + req.sender.profile_image : 'https://ui-avatars.com/api/?name=' + req.sender.username" class="w-10 h-10 rounded-xl" />
                                                <div class="flex-1">
                                                    <p class="text-xs dark:text-slate-200">
                                                        <span class="font-bold">{{ req.sender.username }}</span> sent you a friend request.
                                                    </p>
                                                    <div class="flex gap-2 mt-2">
                                                        <button @click="acceptRequest(req.id)" class="px-3 py-1.5 bg-cyan-500 text-white text-[10px] font-bold rounded-lg hover:bg-cyan-600 transition-colors">Accept</button>
                                                        <button @click="declineRequest(req.id)" class="px-3 py-1.5 bg-slate-100 dark:bg-white/10 dark:text-slate-300 text-[10px] font-bold rounded-lg hover:bg-slate-200 transition-colors">Decline</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div v-if="friendRequests.length === 0" class="p-8 text-center">
                                            <i class="bx bx-bell-off text-3xl text-slate-300 mb-2"></i>
                                            <p class="text-xs text-slate-500">No new notifications</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="relative">
                                <button 
                                    @click.stop="showSettings = !showSettings; showNotifications = false"
                                    class="p-2 text-slate-400 hover:text-cyan-500 transition-colors"
                                >
                                    <i class="bx bx-cog text-xl"></i>
                                </button>
                                
                                <!-- Settings Dropdown -->
                                <div v-if="showSettings" @click.stop class="absolute right-0 mt-2 w-48 bg-white dark:bg-[#1e293b] rounded-2xl shadow-2xl border border-slate-200 dark:border-white/5 py-2 z-[60]">
                                    <Link :href="route('profile.edit')" class="flex items-center gap-2 px-4 py-2.5 text-sm text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-white/5 transition-colors">
                                        <i class="bx bx-user"></i> My Profile
                                    </Link>
                                    <button class="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-white/5 transition-colors">
                                        <i class="bx bx-palette"></i> Appearance
                                    </button>
                                    <div class="h-px bg-slate-100 dark:bg-white/5 my-1 mx-2"></div>
                                    <Link :href="route('logout')" method="post" as="button" class="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-pink-500 hover:bg-pink-50 dark:hover:bg-pink-500/10 transition-colors font-bold">
                                        <i class="bx bx-log-out"></i> Log Out
                                    </Link>
                                </div>
                            </div>
                        </div>

                        <!-- Profile Info (Mini) -->
                        <div class="flex items-center gap-3 p-1.5 rounded-xl">
                            <div class="text-right hidden sm:block">
                                <p class="text-xs font-bold dark:text-white leading-none mb-1">{{ user.username }}</p>
                                <p class="text-[10px] text-slate-500 leading-none capitalize">Online</p>
                            </div>
                            <img 
                                :src="user.profile_image ? '/storage/' + user.profile_image : 'https://ui-avatars.com/api/?name=' + user.username" 
                                class="w-9 h-9 rounded-xl object-cover border border-slate-200 dark:border-white/10"
                            />
                        </div>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Main Content -->
        <main class="max-w-[1600px] mx-auto">
            <slot />
        </main>

        <!-- Mobile Nav (Simple Bottom Bar) -->
        <div class="md:hidden fixed bottom-0 left-0 right-0 h-16 bg-white dark:bg-[#0f172a] border-t border-slate-200 dark:border-white/5 flex items-center justify-around px-6 z-50">
            <Link :href="route('dashboard')" class="text-slate-400" :class="{ 'text-cyan-500': route().current('dashboard') }">
                <i class="bx bxs-chat text-2xl"></i>
            </Link>
            <button class="w-12 h-12 bg-cyan-500 text-white rounded-2xl shadow-lg shadow-cyan-500/20 flex items-center justify-center -translate-y-4">
                <i class="bx bx-plus text-2xl"></i>
            </button>
            <Link :href="route('profile.edit')" class="text-slate-400" :class="{ 'text-cyan-500': route().current('profile.edit') }">
                <i class="bx bxs-user-circle text-2xl"></i>
            </Link>
        </div>
    </div>
</template>
