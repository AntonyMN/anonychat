<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\User;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Attachment;
use App\Models\FriendRequest;
use Inertia\Inertia;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Events\MessageSent;
use App\Events\MessageRead;

class ChatController extends Controller
{
    public function dashboard()
    {
        $user = Auth::user();

        $conversations = $user->conversations()
            ->with([
                'users' => function ($q) use ($user) {
                    $q->where('users.id', '!=', $user->id);
                },
                'lastMessage'
            ])
            ->get();

        $friendRequests = FriendRequest::where('receiver_id', $user->id)
            ->where('status', 'pending')
            ->with('sender')
            ->get();

        $friends = $user->friends()->get();

        if (request()->wantsJson()) {
            return response()->json([
                'conversations' => $conversations,
                'friendRequests' => $friendRequests,
                'friends' => $friends,
            ]);
        }

        return Inertia::render('Dashboard', [
            'conversations' => $conversations,
            'friendRequests' => $friendRequests,
            'friends' => $friends,
        ]);
    }

    public function show(Conversation $conversation)
    {
        $this->authorizeUserInConversation($conversation);

        $messages = $conversation->messages()
            ->with(['sender', 'attachments'])
            ->oldest()
            ->get();

        return response()->json([
            'messages' => $messages,
            'other_user' => $conversation->users()->where('users.id', '!=', Auth::id())->first(),
        ]);
    }

    public function start(Request $request)
    {
        $request->validate(['user_id' => 'required|exists:users,id']);
        $otherUserId = $request->user_id;
        $authUserId = Auth::id();

        // Check if private conversation already exists
        $conversation = Conversation::where('type', 'private')
            ->whereHas('users', function ($q) use ($authUserId) {
                $q->where('users.id', $authUserId);
            })
            ->whereHas('users', function ($q) use ($otherUserId) {
                $q->where('users.id', $otherUserId);
            })
            ->first();

        if (!$conversation) {
            $conversation = Conversation::create(['type' => 'private']);
            $conversation->users()->attach([$authUserId, $otherUserId]);
        }

        if (request()->wantsJson()) {
            return response()->json($conversation->load(['users', 'lastMessage']));
        }

        return redirect()->route('dashboard', ['chat' => $conversation->id]);
    }

    public function sendMessage(Request $request, Conversation $conversation)
    {
        $this->authorizeUserInConversation($conversation);

        $request->validate([
            'content' => 'required_without:attachments|string|nullable',
            'attachments.*' => 'nullable|file|max:10240', // 10MB
        ]);

        $message = $conversation->messages()->create([
            'sender_id' => Auth::id(),
            'content' => $request->content,
            'type' => $request->hasFile('attachments') ? 'file' : 'text',
        ]);

        if ($request->hasFile('attachments')) {
            foreach ($request->file('attachments') as $file) {
                $path = $file->store('attachments', 'public');
                $message->attachments()->create([
                    'file_path' => $path,
                    'file_name' => $file->getClientOriginalName(),
                    'file_type' => $file->getClientMimeType(),
                ]);
            }
        }

        // Broadcast event
        broadcast(new MessageSent($message))->toOthers();

        // Notify other users via push
        $otherUsers = $conversation->users()->where('users.id', '!=', Auth::id())->get();
        foreach ($otherUsers as $recipient) {
            $recipient->notify(new \App\Notifications\NewMessageReceived($message));
        }

        return response()->json($message->load(['sender', 'attachments']));
    }

    protected function authorizeUserInConversation(Conversation $conversation)
    {
        if (!$conversation->users()->where('users.id', Auth::id())->exists()) {
            abort(403);
        }
    }

    public function markAsRead(Conversation $conversation)
    {
        $this->authorizeUserInConversation($conversation);

        $lastMessage = $conversation->messages()
            ->where('sender_id', '!=', Auth::id())
            ->whereNull('read_at')
            ->latest()
            ->first();

        if ($lastMessage) {
            $conversation->messages()
                ->where('sender_id', '!=', Auth::id())
                ->whereNull('read_at')
                ->update(['read_at' => now()]);

            broadcast(new MessageRead($conversation->id, $lastMessage->id))->toOthers();
        }

        return response()->json(['status' => 'success']);
    }
}
