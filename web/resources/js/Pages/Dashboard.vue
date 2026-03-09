<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import InputLabel from '@/Components/InputLabel.vue';
import { Head, Link, useForm, usePage } from '@inertiajs/vue3';
import { ref, onMounted, computed, watch } from 'vue';
import axios from 'axios';

const props = defineProps({
    conversations: Array,
    friendRequests: Array,
    friends: Array,
    activeChatId: [String, Number],
});

const user = usePage().props.auth.user;
const globalNotifications = computed(() => usePage().props.auth.notifications?.friendRequests || []);
const friendRequestsList = computed(() => {
    const all = [...props.friendRequests, ...globalNotifications.value];
    const unique = [];
    const seen = new Set();
    for (const item of all) {
        if (!seen.has(item.id)) {
            seen.add(item.id);
            unique.push(item);
        }
    }
    return unique;
});

const onlineUsers = ref(new Set());
const activeChat = ref(null);
const messages = ref([]);
const newMessage = ref('');
const searchQuery = ref('');
const searchResults = ref([]);
const showNewChatModal = ref(false);
const messageContainer = ref(null);
const fileInput = ref(null);
const attachments = ref([]);

const sortedConversations = computed(() => {
    return [...props.conversations].sort((a, b) => {
        const dateA = a.last_message ? new Date(a.last_message.created_at) : new Date(a.created_at);
        const dateB = b.last_message ? new Date(b.last_message.created_at) : new Date(b.created_at);
        return dateB - dateA;
    });
});

const selectChat = async (conversation) => {
    activeChat.value = conversation;
    try {
        const response = await axios.get(route('chat.show', conversation.id));
        messages.value = response.data.messages;
        scrollToBottom();
        markAsRead(conversation.id);
    } catch (e) {
        console.error(e);
    }
};

const markAsRead = async (conversationId) => {
    try {
        await axios.post(route('chat.read', conversationId));
    } catch (e) {
        console.error(e);
    }
};

const sendMessage = async () => {
    if (!newMessage.value.trim() && attachments.value.length === 0) return;

    const formData = new FormData();
    formData.append('content', newMessage.value);
    attachments.value.forEach((file) => {
        formData.append('attachments[]', file);
    });

    try {
        const response = await axios.post(route('chat.message.send', activeChat.value.id), formData);
        messages.value.push(response.data);
        newMessage.value = '';
        attachments.value = [];
        scrollToBottom();
    } catch (e) {
        console.error(e);
    }
};

const handleSearch = async () => {
    if (searchQuery.value.length < 2) {
        searchResults.value = [];
        return;
    }
    const response = await axios.get(route('friends.search', { query: searchQuery.value }));
    searchResults.value = response.data;
};

const startChat = (friendId) => {
    useForm({ user_id: friendId }).post(route('chat.start'), {
        onSuccess: () => {
            showNewChatModal.value = false;
        }
    });
};

const acceptRequest = (requestId) => {
    useForm({}).post(route('friends.request.accept', requestId));
};

const declineRequest = (requestId) => {
    useForm({}).post(route('friends.request.decline', requestId));
};

const sendFriendRequest = (receiverId) => {
    useForm({ receiver_id: receiverId }).post(route('friends.request.send'), {
        onSuccess: () => {
            handleSearch(); // Refresh search results to show "Sent"
        }
    });
};

const scrollToBottom = () => {
    setTimeout(() => {
        if (messageContainer.value) {
            messageContainer.value.scrollTop = messageContainer.value.scrollHeight;
        }
    }, 100);
};

const triggerFileInput = () => {
    fileInput.value.click();
};

const handleFileChange = (e) => {
    attachments.value = Array.from(e.target.files);
};

// Real-time listener
onMounted(() => {
    // Global notifications listener
    if (window.Echo) {
        window.Echo.private(`notifications.${user.id}`)
            .listen('FriendRequestSent', (e) => {
                props.friendRequests.push(e.friendRequest);
            });

        // Presence listener
        window.Echo.join('online')
            .here((users) => {
                users.forEach(u => onlineUsers.value.add(u.id));
            })
            .joining((u) => {
                onlineUsers.value.add(u.id);
            })
            .leaving((u) => {
                onlineUsers.value.delete(u.id);
            });
    }
});

// Watch for active chat changes to update Echo listener
watch(activeChat, (newChat, oldChat) => {
    if (oldChat && window.Echo) {
        window.Echo.leave(`conversation.${oldChat.id}`);
    }
    if (newChat && window.Echo) {
        window.Echo.private(`conversation.${newChat.id}`)
            .listen('MessageSent', (e) => {
                if (e.message.sender_id !== user.id) {
                    messages.value.push(e.message);
                    scrollToBottom();
                    markAsRead(newChat.id);
                }
            })
            .listen('MessageRead', (e) => {
                messages.value.forEach(msg => {
                    if (msg.sender_id === user.id && !msg.read_at) {
                        msg.read_at = new Date().toISOString();
                    }
                });
            });
    }
}, { immediate: true });

// Watch for activeChatId prop from Inertia
watch(() => props.activeChatId, (newId) => {
    if (newId) {
        const conv = props.conversations.find(c => c.id == newId);
        if (conv) selectChat(conv);
    }
}, { immediate: true });
</script>

<template>
    <AuthenticatedLayout>
        <Head title="Dashboard" />
        <div class="flex h-[calc(100vh-65px)] overflow-hidden bg-slate-50 dark:bg-[#0f172a]">
            <!-- Sidebar -->
            <div class="w-80 border-r border-slate-200 dark:border-white/5 flex flex-col bg-white dark:bg-[#0f172a]">
                <div class="p-4 border-b border-slate-200 dark:border-white/5 space-y-4">
                    <div class="flex items-center justify-between">
                        <h2 class="text-xl font-bold dark:text-white">Chats</h2>
                        <div class="flex gap-2">
                            <a 
                                href="/anonychat.apk" 
                                title="Download Mobile App"
                                class="p-2 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-500 rounded-xl transition-colors border border-emerald-500/20"
                            >
                                <i class="bx bxl-android text-xl"></i>
                            </a>
                            <button 
                                @click="showNewChatModal = true"
                                class="p-2 bg-cyan-500 hover:bg-cyan-600 text-white rounded-xl transition-colors shadow-lg shadow-cyan-500/20"
                            >
                                <i class="bx bx-plus text-xl"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Search Trigger -->
                    <div 
                        @click="showNewChatModal = true"
                        class="flex items-center bg-slate-100 dark:bg-white/5 px-4 py-2.5 rounded-xl border border-transparent hover:border-cyan-500/30 transition-all cursor-pointer"
                    >
                        <i class="bx bx-search text-slate-400 mr-2"></i>
                        <span class="text-xs text-slate-400">Search users or add friends...</span>
                    </div>

                    <!-- Pending Requests (if any) -->
                    <div v-if="friendRequestsList.length > 0" class="space-y-2">
                        <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Friend Requests</p>
                        <div v-for="request in friendRequestsList" :key="request.id" class="p-3 bg-cyan-500/5 border border-cyan-500/20 rounded-xl flex items-center justify-between">
                            <div class="flex items-center gap-2">
                                <img :src="request.sender.profile_image ? '/storage/' + request.sender.profile_image : 'https://ui-avatars.com/api/?name=' + request.sender.username" class="w-8 h-8 rounded-full border border-white/10" />
                                <span class="text-xs font-semibold dark:text-white">{{ request.sender.username }}</span>
                            </div>
                            <div class="flex gap-1">
                                <button @click="acceptRequest(request.id)" class="p-1 text-green-500 hover:bg-green-500/10 rounded-md transition-colors">
                                    <i class="bx bx-check text-lg"></i>
                                </button>
                                <button @click="declineRequest(request.id)" class="p-1 text-red-500 hover:bg-red-500/10 rounded-md transition-colors">
                                    <i class="bx bx-x text-lg"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Chat List -->
                <div class="flex-1 overflow-y-auto p-2 space-y-1">
                    <button 
                        v-for="conv in sortedConversations" 
                        :key="conv.id"
                        @click="selectChat(conv)"
                        class="w-full p-3 flex items-center gap-3 rounded-2xl transition-all"
                        :class="activeChat?.id === conv.id ? 'bg-cyan-500/10 dark:bg-cyan-500/20' : 'hover:bg-slate-100 dark:hover:bg-white/5'"
                    >
                        <div class="relative">
                            <img 
                                :src="conv.users[0].profile_image ? '/storage/' + conv.users[0].profile_image : 'https://ui-avatars.com/api/?name=' + conv.users[0].username" 
                                class="w-12 h-12 rounded-2xl object-cover" 
                            />
                            <div 
                                v-if="onlineUsers.has(conv.users[0].id)"
                                class="absolute -bottom-1 -right-1 w-3 h-3 rounded-full border-2 border-white dark:border-[#0f172a] bg-green-500"
                            ></div>
                        </div>
                        <div class="flex-1 text-left">
                            <div class="flex items-center justify-between">
                                <span class="font-bold text-sm dark:text-gray-200">{{ conv.users[0].username }}</span>
                                <span class="text-[10px] text-slate-400">12:30 PM</span>
                            </div>
                            <p class="text-xs text-slate-400 truncate max-w-[140px]">
                                {{ conv.last_message ? conv.last_message.content : 'Start a conversation...' }}
                            </p>
                        </div>
                    </button>
                    
                    <div v-if="sortedConversations.length === 0" class="flex flex-col items-center justify-center py-12 px-6 text-center">
                        <div class="bg-slate-100 dark:bg-white/5 p-4 rounded-3xl mb-4">
                            <i class="bx bx-chat text-4xl text-slate-300"></i>
                        </div>
                        <p class="text-sm font-medium text-slate-500">No chats yet. Search for friends to start chatting!</p>
                    </div>
                </div>
            </div>

            <!-- Main Chat Window -->
            <div class="flex-1 flex flex-col bg-white dark:bg-[#0f172a]">
                <template v-if="activeChat">
                    <!-- Chat Header -->
                    <div class="px-6 py-4 border-b border-slate-200 dark:border-white/5 flex items-center justify-between bg-white/80 dark:bg-[#0f172a]/80 backdrop-blur-md sticky top-0 z-20">
                        <div class="flex items-center gap-4">
                            <img 
                                :src="activeChat.users[0].profile_image ? '/storage/' + activeChat.users[0].profile_image : 'https://ui-avatars.com/api/?name=' + activeChat.users[0].username" 
                                class="w-10 h-10 rounded-xl object-cover" 
                            />
                            <div>
                                <h3 class="font-bold dark:text-white leading-tight capitalize">{{ activeChat.users[0].username }}</h3>
                                <div class="flex items-center gap-1.5">
                                    <div 
                                        class="w-1.5 h-1.5 rounded-full"
                                        :class="onlineUsers.has(activeChat.users[0].id) ? 'bg-green-500' : 'bg-slate-400'"
                                    ></div>
                                    <span class="text-[10px] text-slate-400 font-medium">
                                        {{ onlineUsers.has(activeChat.users[0].id) ? 'Online' : 'Offline' }}
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="flex gap-2">
                            <button class="p-2 rounded-xl text-slate-400 hover:bg-slate-100 dark:hover:bg-white/5 transition-colors">
                                <i class="bx bx-search text-xl"></i>
                            </button>
                            <button class="p-2 rounded-xl text-slate-400 hover:bg-slate-100 dark:hover:bg-white/5 transition-colors">
                                <i class="bx bx-dots-vertical-rounded text-xl"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Messages -->
                    <div 
                        ref="messageContainer"
                        class="flex-1 overflow-y-auto p-6 space-y-6 scroll-smooth bg-slate-50/50 dark:bg-transparent"
                    >
                        <div 
                            v-for="msg in messages" 
                            :key="msg.id"
                            class="flex flex-col"
                            :class="msg.sender_id === user.id ? 'items-end' : 'items-start'"
                        >
                            <div class="flex items-end gap-2 max-w-[75%]">
                                <img 
                                    v-if="msg.sender_id !== user.id"
                                    :src="msg.sender.profile_image ? '/storage/' + msg.sender.profile_image : 'https://ui-avatars.com/api/?name=' + msg.sender.username" 
                                    class="w-6 h-6 rounded-full border border-white/10 mb-1" 
                                />
                                <div 
                                    class="px-4 py-3 rounded-2xl shadow-sm text-sm leading-relaxed"
                                    :class="msg.sender_id === user.id 
                                        ? 'bg-cyan-500 text-white rounded-br-none' 
                                        : 'bg-white dark:bg-white/5 dark:text-slate-200 border border-slate-200 dark:border-white/5 rounded-bl-none'"
                                >
                                    {{ msg.content }}
                                    
                                    <div v-if="msg.attachments && msg.attachments.length > 0" class="mt-2 space-y-1">
                                        <div v-for="att in msg.attachments" :key="att.id" class="flex items-center gap-2 p-2 rounded-lg bg-black/5 dark:bg-white/5">
                                            <i class="bx bx-file text-lg"></i>
                                            <span class="text-xs truncate max-w-[150px]">{{ att.file_name }}</span>
                                            <a :href="'/storage/' + att.file_path" target="_blank" class="ml-auto p-1 hover:bg-black/10 rounded">
                                                <i class="bx bx-download"></i>
                                            </a>
                                        </div>
                                    </div>

                                    <!-- Read Status -->
                                    <div v-if="msg.sender_id === user.id" class="flex justify-end mt-1 -mr-1">
                                        <i class="bx text-[16px]" :class="msg.read_at ? 'bx-check-double text-cyan-200' : 'bx-check text-white/50'"></i>
                                    </div>
                                </div>
                            </div>
                            <span class="text-[10px] text-slate-400 mt-1.5 px-1">{{ new Date(msg.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) }}</span>
                        </div>
                    </div>

                    <!-- Input -->
                    <div class="p-6 bg-white dark:bg-[#0f172a] border-t border-slate-200 dark:border-white/5">
                        <div v-if="attachments.length > 0" class="mb-3 flex flex-wrap gap-2">
                            <div v-for="(file, idx) in attachments" :key="idx" class="px-3 py-1.5 bg-cyan-500/10 rounded-full border border-cyan-500/20 text-xs flex items-center gap-2 text-cyan-500">
                                <i class="bx bx-file"></i>
                                {{ file.name }}
                                <button @click="attachments = []" class="hover:text-cyan-700">
                                    <i class="bx bx-x"></i>
                                </button>
                            </div>
                        </div>

                        <div class="flex items-end gap-3 bg-slate-100 dark:bg-white/5 p-2 rounded-3xl border border-transparent focus-within:border-cyan-500/50 transition-all">
                            <button 
                                @click="triggerFileInput"
                                class="p-3 text-slate-400 hover:text-cyan-500 transition-colors"
                            >
                                <i class="bx bx-paperclip text-2xl"></i>
                            </button>
                            <input 
                                type="file" 
                                ref="fileInput" 
                                @change="handleFileChange" 
                                class="hidden" 
                                multiple
                            />
                            <textarea 
                                v-model="newMessage"
                                @keydown.enter.exact.prevent="sendMessage"
                                placeholder="Type your message..."
                                class="flex-1 bg-transparent border-none focus:ring-0 text-sm py-3 px-1 resize-none h-12 dark:text-white"
                            ></textarea>
                            <button class="p-3 text-slate-400 hover:text-cyan-500">
                                <i class="bx bx-smile text-2xl"></i>
                            </button>
                            <button 
                                @click="sendMessage"
                                class="p-3 bg-cyan-500 text-white rounded-2xl hover:bg-cyan-600 transition-all shadow-lg shadow-cyan-500/20"
                            >
                                <i class="bx bxs-send text-xl"></i>
                            </button>
                        </div>
                        <p class="text-[10px] text-slate-400 mt-2 ml-4">Press Enter to send message</p>
                    </div>
                </template>

                <div v-else class="flex-1 flex flex-col items-center justify-center text-center p-12 bg-slate-50 dark:bg-transparent">
                    <div class="relative mb-8">
                        <div class="absolute -inset-4 bg-cyan-500/20 blur-3xl rounded-full"></div>
                        <div class="relative bg-white dark:bg-white/5 p-8 rounded-[2.5rem] border border-slate-200 dark:border-white/5 shadow-2xl">
                            <i class="bx bxs-chat text-6xl text-cyan-500 animate-bounce"></i>
                        </div>
                    </div>
                    <h2 class="text-3xl font-black mb-4 dark:text-white tracking-tighter">Your Conversations</h2>
                    <p class="text-slate-400 max-w-xs mx-auto leading-relaxed">Select a conversation or start a new one to begin chatting freely.</p>
                    <button 
                        @click="showNewChatModal = true"
                        class="mt-8 px-8 py-3.5 bg-cyan-500 text-white rounded-2xl font-bold shadow-xl shadow-cyan-500/20 hover:scale-105 transition-transform"
                    >
                        Start New Chat
                    </button>
                </div>
            </div>
        </div>

        <!-- New Chat Modal -->
        <div v-if="showNewChatModal" class="fixed inset-0 z-50 flex items-center justify-center p-6 bg-slate-900/80 backdrop-blur-sm">
            <div class="w-full max-w-md bg-white dark:bg-[#1e293b] rounded-[2rem] shadow-2xl overflow-hidden border border-white/10">
                <div class="p-6 border-b border-slate-100 dark:border-white/5 flex items-center justify-between bg-white dark:bg-[#1e293b]">
                    <h3 class="text-xl font-bold text-slate-900 dark:text-white">New Chat</h3>
                    <button @click="showNewChatModal = false" class="text-slate-400 hover:text-slate-900 dark:hover:text-white transition-colors"><i class="bx bx-x text-2xl"></i></button>
                </div>
                <div class="p-6 space-y-6 text-slate-900 dark:text-white text-base">
                    <div class="space-y-2">
                        <InputLabel for="search" value="Search unique username" class="text-slate-700 dark:text-slate-300" />
                        <div class="relative">
                            <i class="bx bx-search absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-xl"></i>
                            <input 
                                id="search"
                                v-model="searchQuery"
                                @input="handleSearch"
                                placeholder="e.g. johndoe"
                                class="w-full pl-12 pr-4 py-3 bg-slate-100 dark:bg-white/5 border-none rounded-2xl focus:ring-2 focus:ring-cyan-500 transition-all text-slate-900 dark:text-white placeholder:text-slate-400"
                            />
                        </div>
                    </div>

                    <div class="space-y-3">
                        <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400 px-1">Search Results</p>
                        <div class="max-h-60 overflow-y-auto space-y-1">
                            <div 
                                v-for="res in searchResults" 
                                :key="res.id"
                                class="flex items-center justify-between p-3 rounded-2xl hover:bg-slate-100 dark:hover:bg-white/5 transition-all text-sm"
                            >
                                <div class="flex items-center gap-3">
                                    <img :src="res.profile_image ? '/storage/' + res.profile_image : 'https://ui-avatars.com/api/?name=' + res.username" class="w-10 h-10 rounded-xl" />
                                    <div class="flex flex-col">
                                        <span class="font-bold dark:text-slate-200">{{ res.username }}</span>
                                        <span v-if="res.is_friend" class="text-[10px] text-green-500 font-bold uppercase">Friend</span>
                                    </div>
                                </div>
                                <div class="flex gap-2">
                                    <button 
                                        v-if="res.is_friend"
                                        @click="startChat(res.id)"
                                        class="px-4 py-2 bg-cyan-500 text-white rounded-xl text-xs font-bold hover:bg-cyan-600 transition-colors"
                                    >
                                        Chat
                                    </button>
                                    <button 
                                        v-else-if="res.request_sent"
                                        disabled
                                        class="px-4 py-2 bg-slate-100 dark:bg-white/10 text-slate-400 rounded-xl text-xs font-bold cursor-not-allowed"
                                    >
                                        Sent
                                    </button>
                                    <button 
                                        v-else-if="res.request_received"
                                        @click="showNewChatModal = false; selectChat(null)" 
                                        class="px-4 py-2 bg-green-500 text-white rounded-xl text-xs font-bold hover:bg-green-600 transition-colors"
                                    >
                                        Pending
                                    </button>
                                    <button 
                                        v-else
                                        @click="sendFriendRequest(res.id)"
                                        class="px-4 py-2 bg-cyan-500 text-white rounded-xl text-xs font-bold hover:bg-cyan-600 transition-colors"
                                    >
                                        Add Friend
                                    </button>
                                </div>
                            </div>
                            <div v-if="searchQuery.length >= 2 && searchResults.length === 0" class="py-10 text-center text-slate-500">
                                No users found with this username.
                            </div>
                        </div>
                    </div>

                    <div class="space-y-3">
                        <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400 px-1">Your Friends</p>
                        <div class="max-h-40 overflow-y-auto space-y-1">
                            <div 
                                v-for="friend in friends" 
                                :key="friend.id"
                                class="flex items-center justify-between p-3 rounded-2xl hover:bg-white/5 transition-all text-sm"
                            >
                                <div class="flex items-center gap-3">
                                    <img :src="friend.profile_image ? '/storage/' + friend.profile_image : 'https://ui-avatars.com/api/?name=' + friend.username" class="w-8 h-8 rounded-lg" />
                                    <span class="font-bold dark:text-slate-200">{{ friend.pivot.alias || friend.username }}</span>
                                </div>
                                <button @click="startChat(friend.id)" class="text-cyan-500 font-bold hover:underline">Start</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
/* Custom scrollbar */
::-webkit-scrollbar {
    width: 6px;
}
::-webkit-scrollbar-track {
    background: transparent;
}
::-webkit-scrollbar-thumb {
    background: rgba(148, 163, 184, 0.1);
    border-radius: 10px;
}
::-webkit-scrollbar-thumb:hover {
    background: rgba(148, 163, 184, 0.2);
}
</style>
