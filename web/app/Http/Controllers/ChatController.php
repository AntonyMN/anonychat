<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\User;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Attachment;
use App\Models\FriendRequest;
use Inertia\Inertia;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Events\MessageSent;
use App\Events\MessageRead;
use Illuminate\Support\Facades\Log;

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
            ->leftJoin('messages', function ($join) {
                $join->on('conversations.id', '=', 'messages.conversation_id')
                    ->on('messages.id', '=', DB::raw('(SELECT id FROM messages WHERE conversation_id = conversations.id ORDER BY created_at DESC LIMIT 1)'));
            })
            ->select('conversations.*')
            ->orderByRaw('COALESCE(messages.created_at, conversations.created_at) DESC')
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
            'activeChatId' => request('chat'),
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
        $request->validate([
            'user_id' => 'required|exists:users,id'
        ]);

        \Log::info("start conversation attempt", ["user_id" => $request->user_id, "auth_id" => Auth::id()]);

        $participantIds = [Auth::id(), $request->user_id];
        sort($participantIds);

        // Find or create conversation
        $conversation = Conversation::whereHas('users', function ($query) use ($participantIds) {
            $query->whereIn('users.id', $participantIds);
        }, '=', 2)->first();

        if (!$conversation) {
            \Log::info("creating new conversation");
            $conversation = Conversation::create();
            $conversation->users()->attach($participantIds);
        }

        if ($request->wantsJson()) {
            $recipientId = $request->user_id;
            try {
                broadcast(new \App\Events\ConversationStarted($conversation, $recipientId))->toOthers();
            } catch (\Throwable $e) {
                \Log::error('ConversationStarted broadcast failed: ' . $e->getMessage());
            }
            return response()->json($conversation->load('users', 'messages'));
        }

        return redirect()->route('dashboard', ['chat' => $conversation->id]);
    }

    public function sendMessage(Request $request, Conversation $conversation)
    {
        \Log::info('sendMessage method reached', [
            'conversation_id' => $conversation->id,
            'user_id' => Auth::id(),
            'has_content' => !empty($request->content),
            'has_file' => $request->hasFile('file')
        ]);

        try {
            $this->authorizeUserInConversation($conversation);
        } catch (\Throwable $e) {
            \Log::error('Authorization failed: ' . $e->getMessage());
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $request->validate([
            'content' => 'nullable|string',
            'file' => 'nullable|file|max:10240', // 10MB max
        ]);

        $type = 'text';
        $filePath = null;

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $mime = $file->getMimeType();
            $type = str_starts_with($mime, 'image/') ? 'image' : 'file';
            $filePath = $file->store('chat_attachments', 'public');
        }

        \Log::info('Creating message record');
        try {
            $message = $conversation->messages()->create([
                'sender_id' => Auth::id(),
                'content' => $request->content ?? '',
                'type' => $type,
                'file_path' => $filePath,
            ]);
        } catch (\Throwable $e) {
            \Log::error('Message creation failed: ' . $e->getMessage());
            throw $e; // Re-throw to see the 500
        }

        \Log::info('Broadcasting message');
        try {
            // Broadcast event
            broadcast(new \App\Events\MessageSent($message))->toOthers();
        } catch (\Throwable $e) {
            \Log::error('Broadcast failed: ' . $e->getMessage() . '\n' . $e->getTraceAsString());
        }

        \Log::info('Sending notifications');
        try {
            // Notify other users via push
            $otherUsers = $conversation->users()->where('users.id', '!=', Auth::id())->get();
            foreach ($otherUsers as $recipient) {
                $recipient->notify(new \App\Notifications\NewMessageReceived($message));
            }
        } catch (\Throwable $e) {
            \Log::error('Notification failed: ' . $e->getMessage() . '\n' . $e->getTraceAsString());
        }

        \Log::info('sendMessage completed');
        return response()->json($message->load(['sender']));
    }

    protected function authorizeUserInConversation(Conversation $conversation)
    {
        if (!$conversation->users()->where('users.id', Auth::id())->exists()) {
            abort(403);
        }
    }

    public function markAsRead(Conversation $conversation)
    {
        Log::info('markAsRead hit', ['conversation_id' => $conversation->id, 'user_id' => Auth::id()]);
        $this->authorizeUserInConversation($conversation);

        $lastMessage = $conversation->messages()
            ->where('sender_id', '!=', Auth::id())
            ->whereNull('read_at')
            ->latest()
            ->first();

        if ($lastMessage) {
            Log::info('Marking as read', ['last_message_id' => $lastMessage->id]);
            $conversation->messages()
                ->where('sender_id', '!=', Auth::id())
                ->whereNull('read_at')
                ->update(['read_at' => now()]);

            broadcast(new MessageRead($conversation->id, $lastMessage->id))->toOthers();
        } else {
            Log::info('No unread messages found to mark as read');
        }

        return response()->json(['status' => 'success']);
    }
}
