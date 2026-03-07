<script setup>
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    canLogin: Boolean,
    canRegister: Boolean,
});
</script>

<template>
    <div class="min-h-screen bg-[#0f172a] text-white selection:bg-cyan-500 selection:text-white overflow-hidden relative">
        <Head title="AnonyChat - Express Yourself Freely" />
        <!-- Background Ornaments -->
        <div class="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-purple-600/20 blur-[120px] rounded-full animate-pulse"></div>
        <div class="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] bg-cyan-600/20 blur-[120px] rounded-full animate-pulse" style="animation-delay: 2s;"></div>
        <div class="absolute top-[20%] right-[10%] w-[30%] h-[30%] bg-pink-600/10 blur-[100px] rounded-full"></div>

        <!-- Navigation -->
        <nav class="relative z-10 flex items-center justify-between px-4 sm:px-6 py-6 mx-auto max-w-7xl">
            <div class="flex items-center gap-2">
                <div class="bg-gradient-to-tr from-cyan-500 to-purple-600 p-1.5 sm:p-2 rounded-xl shadow-lg shadow-cyan-500/20">
                    <i class="bx bxs-chat text-2xl sm:text-3xl"></i>
                </div>
                <span class="text-xl sm:text-2xl font-bold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-white to-gray-400">
                    AnonyChat
                </span>
            </div>

            <div v-if="canLogin" class="flex items-center gap-3 sm:gap-6">
                <Link v-if="$page.props.auth.user" :href="route('dashboard')" class="text-xs sm:text-sm font-semibold hover:text-cyan-400 transition-colors">
                    Dashboard
                </Link>
                <template v-else>
                    <Link :href="route('login')" class="text-xs sm:text-sm font-semibold hover:text-cyan-400 transition-colors">
                        Log in
                    </Link>
                    <Link v-if="canRegister" :href="route('register')" class="bg-white text-slate-900 px-3 py-2 sm:px-5 sm:py-2.5 rounded-full text-xs sm:text-sm font-bold hover:bg-cyan-400 hover:text-white transition-all duration-300 transform hover:scale-105 shadow-xl shadow-white/5">
                        <span class="hidden sm:inline">Get Started</span>
                        <span class="sm:hidden">Join</span>
                    </Link>
                </template>
            </div>
        </nav>

        <!-- Hero Section -->
        <main class="relative z-10 flex flex-col items-center justify-center px-6 pt-20 pb-32 mx-auto max-w-5xl text-center">
            <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 border border-white/10 mb-8 backdrop-blur-md animate-fade-in-up">
                <span class="relative flex h-2 w-2">
                    <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-cyan-400 opacity-75"></span>
                    <span class="relative inline-flex rounded-full h-2 w-2 bg-cyan-500"></span>
                </span>
                <span class="text-xs font-medium text-cyan-400 uppercase tracking-widest">Connect Instantly & Securely</span>
            </div>

            <h1 class="text-6xl md:text-8xl font-black mb-6 leading-tight tracking-tighter animate-fade-in-up" style="animation-delay: 0.1s;">
                Chat like <br/>
                <span class="bg-clip-text text-transparent bg-gradient-to-r from-cyan-400 via-blue-500 to-purple-600">
                    never before.
                </span>
            </h1>

            <p class="text-lg md:text-xl text-slate-400 mb-10 max-w-2xl mx-auto leading-relaxed animate-fade-in-up" style="animation-delay: 0.2s;">
                Experience the next generation of messaging. Secure, fast, and beautifully designed for your best conversations.
            </p>

            <div class="flex flex-col sm:flex-row gap-4 animate-fade-in-up" style="animation-delay: 0.3s;">
                <Link :href="route('register')" class="group relative px-8 py-4 bg-gradient-to-r from-cyan-500 to-blue-600 rounded-2xl font-bold text-lg shadow-2xl shadow-cyan-500/25 hover:shadow-cyan-500/40 transition-all duration-300 transform hover:-translate-y-1">
                    <span class="relative z-10 flex items-center gap-2">
                        Create Your Identity <i class="bx bx-right-arrow-alt text-2xl group-hover:translate-x-1 transition-transform"></i>
                    </span>
                    <div class="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 rounded-2xl"></div>
                </Link>
                <a href="/downloads/anonychat.apk" class="px-8 py-4 bg-white/5 border border-white/10 rounded-2xl font-bold text-lg hover:bg-white/10 transition-all backdrop-blur-sm flex items-center gap-2">
                    <i class="bx bxl-android text-2xl text-emerald-400"></i> Download APK
                </a>
                <a href="#features" class="px-8 py-4 text-slate-400 hover:text-white transition-all text-sm font-medium self-center">
                    Explore Features
                </a>
            </div>

            <!-- Dashboard Preview (Mockup) -->
            <div class="mt-24 relative group animate-fade-in-up" style="animation-delay: 0.4s;">
                <div class="absolute -inset-1 bg-gradient-to-r from-cyan-500 to-purple-600 rounded-[2.5rem] blur opacity-25 group-hover:opacity-50 transition duration-1000 group-hover:duration-200"></div>
                <div class="relative bg-[#1e293b] rounded-[2rem] border border-white/10 overflow-hidden shadow-2xl">
                    <div class="flex items-center gap-2 px-6 py-4 bg-[#0f172a]/50 border-b border-white/5">
                        <div class="flex gap-1.5">
                            <div class="w-3 h-3 rounded-full bg-red-500/50"></div>
                            <div class="w-3 h-3 rounded-full bg-yellow-500/50"></div>
                            <div class="w-3 h-3 rounded-full bg-green-500/50"></div>
                        </div>
                        <div class="flex-1 flex justify-center">
                            <div class="bg-white/5 px-4 py-1 rounded-lg text-[10px] text-slate-500">anonychat.app/dashboard</div>
                        </div>
                    </div>
                    <div class="p-4 grid grid-cols-12 gap-4 h-80">
                        <div class="col-span-3 border-r border-white/5 flex flex-col gap-3">
                            <div v-for="i in 4" :key="i" class="h-10 bg-white/5 rounded-xl w-full"></div>
                        </div>
                        <div class="col-span-9 flex flex-col gap-4">
                            <div class="self-start bg-cyan-500/20 p-3 rounded-2xl rounded-tl-none text-[12px] max-w-[60%]">Hey there! 👋 Excited to start chatting?</div>
                            <div class="self-end bg-purple-600/20 p-3 rounded-2xl rounded-tr-none text-[12px] max-w-[60%]">Absolutely! This interface looks premium. ✨</div>
                            <div class="mt-auto flex gap-2">
                                <div class="flex-1 h-10 bg-white/5 rounded-xl border border-white/10"></div>
                                <div class="w-10 h-10 bg-cyan-500 rounded-xl flex items-center justify-center">
                                    <i class="bx bxs-send"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- Features Section -->
        <section id="features" class="relative z-10 px-6 py-32 mx-auto max-w-7xl">
            <div class="grid md:grid-cols-3 gap-8">
                <div class="p-8 rounded-3xl bg-white/5 border border-white/10 backdrop-blur-sm hover:border-cyan-500/50 transition-colors group">
                    <div class="w-14 h-14 bg-cyan-500/10 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-cyan-500 transition-colors">
                        <i class="bx bxs-zap text-3xl text-cyan-400 group-hover:text-white transition-colors"></i>
                    </div>
                    <h3 class="text-2xl font-bold mb-4">Real-time Speed</h3>
                    <p class="text-slate-400 leading-relaxed">Powered by WebSockets for instantaneous message delivery without any refreshes.</p>
                </div>
                <div class="p-8 rounded-3xl bg-white/5 border border-white/10 backdrop-blur-sm hover:border-purple-500/50 transition-colors group">
                    <div class="w-14 h-14 bg-purple-500/10 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-purple-500 transition-colors">
                        <i class="bx bxs-key text-3xl text-purple-400 group-hover:text-white transition-colors"></i>
                    </div>
                    <h3 class="text-2xl font-bold mb-4">Safe & Unique</h3>
                    <p class="text-slate-400 leading-relaxed">Claim your unique username and connect with friends using aliases for more personal touch.</p>
                </div>
                <div class="p-8 rounded-3xl bg-white/5 border border-white/10 backdrop-blur-sm hover:border-pink-500/50 transition-colors group">
                    <div class="w-14 h-14 bg-pink-500/10 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-pink-500 transition-colors">
                        <i class="bx bxs-file-blank text-3xl text-pink-400 group-hover:text-white transition-colors"></i>
                    </div>
                    <h3 class="text-2xl font-bold mb-4">Rich Sharing</h3>
                    <p class="text-slate-400 leading-relaxed">Attach files, images, and more seamlessly within your conversations.</p>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer class="relative z-10 pt-20 pb-10 border-t border-white/5">
            <div class="max-w-7xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-8">
                <div class="flex items-center gap-2">
                    <i class="bx bxs-chat text-xl text-cyan-500"></i>
                    <span class="font-bold">AnonyChat</span>
                </div>
                <p class="text-slate-500 text-sm">© 2026 AnonyChat. Built for the modern web.</p>
                <div class="flex gap-6 text-slate-400">
                    <a href="#" class="hover:text-white transition-colors"><i class="bx bxl-github text-xl"></i></a>
                    <a href="#" class="hover:text-white transition-colors"><i class="bx bxl-twitter text-xl"></i></a>
                </div>
            </div>
        </footer>
    </div>
</template>

<style scoped>
@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.animate-fade-in-up {
    animation: fadeInUp 0.8s ease-out forwards;
}
</style>
