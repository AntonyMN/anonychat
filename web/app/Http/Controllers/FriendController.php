<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\User;
use App\Models\FriendRequest;
use App\Models\Friend;
use Inertia\Inertia;
use Illuminate\Support\Facades\Auth;

class FriendController extends Controller
{
    public function search(Request $request)
    {
        $query = $request->get('query');
        if (!$query)
            return response()->json([]);

        $users = User::where('username', 'LIKE', "%{$query}%")
            ->where('id', '!=', Auth::id())
            ->limit(10)
            ->get(['id', 'username', 'profile_image']);

        $loggedInUser = Auth::user();
        $authId = Auth::id();
        $users->each(function ($user) use ($loggedInUser, $authId) {
            $user->is_friend = $loggedInUser->friends()->where('friend_id', $user->id)->exists();

            $request = FriendRequest::where(function ($q) use ($user, $authId) {
                $q->where('sender_id', $authId)->where('receiver_id', $user->id);
            })->orWhere(function ($q) use ($user, $authId) {
                $q->where('sender_id', $user->id)->where('receiver_id', $authId);
            })->where('status', 'pending')->first();

            $user->request_sent = $request && $request->sender_id == $authId;
            $user->request_received = $request && $request->receiver_id == $authId;
        });

        return response()->json($users);
    }

    public function sendRequest(Request $request)
    {
        $request->validate(['receiver_id' => 'required|exists:users,id']);

        $senderId = Auth::id();
        $receiverId = $request->receiver_id;

        if ($senderId == $receiverId) {
            return back()->withErrors(['message' => 'You cannot friend yourself.']);
        }

        // Check if already friends
        if (Friend::where('user_id', $senderId)->where('friend_id', $receiverId)->exists()) {
            return back()->withErrors(['message' => 'Already friends.']);
        }

        // Check if request already exists
        $existing = FriendRequest::where(function ($q) use ($senderId, $receiverId) {
            $q->where('sender_id', $senderId)->where('receiver_id', $receiverId);
        })->orWhere(function ($q) use ($senderId, $receiverId) {
            $q->where('sender_id', $receiverId)->where('receiver_id', $senderId);
        })->first();

        if ($existing) {
            return back()->withErrors(['message' => 'Request already pending.']);
        }

        $friendRequest = FriendRequest::create([
            'sender_id' => $senderId,
            'receiver_id' => $receiverId,
            'status' => 'pending'
        ]);

        // Notify the receiver
        $receiver = User::find($receiverId);
        if ($receiver) {
            $receiver->notify(new \App\Notifications\FriendRequestReceived(Auth::user()));
        }

        broadcast(new \App\Events\FriendRequestSent($friendRequest))->toOthers();


        if (request()->wantsJson()) {
            return response()->json(['status' => 'success', 'message' => 'Request sent.', 'friendRequest' => $friendRequest->load('sender')]);
        }

        return back()->with('status', 'Request sent.');
    }

    public function acceptRequest(FriendRequest $friendRequest)
    {
        if ($friendRequest->receiver_id != Auth::id()) {
            abort(403);
        }

        $friendRequest->update(['status' => 'accepted']);

        // Create bidirectional friendship
        Friend::create(['user_id' => $friendRequest->sender_id, 'friend_id' => $friendRequest->receiver_id]);
        Friend::create(['user_id' => $friendRequest->receiver_id, 'friend_id' => $friendRequest->sender_id]);

        // Notify the sender that their request was accepted
        $sender = User::find($friendRequest->sender_id);
        if ($sender) {
            $sender->notify(new \App\Notifications\FriendRequestAccepted(Auth::user()));
        }

        if (request()->wantsJson()) {
            return response()->json(['status' => 'success', 'message' => 'Request accepted.']);
        }

        return back()->with('status', 'Request accepted.');
    }

    public function declineRequest(FriendRequest $friendRequest)
    {
        if ($friendRequest->receiver_id != Auth::id()) {
            abort(403);
        }

        $friendRequest->delete();

        if (request()->wantsJson()) {
            return response()->json(['status' => 'success', 'message' => 'Request declined.']);
        }

        return back()->with('status', 'Request declined.');
    }

    public function setAlias(Request $request, User $friend)
    {
        $request->validate(['alias' => 'nullable|string|max:255']);

        Friend::where('user_id', Auth::id())
            ->where('friend_id', $friend->id)
            ->update(['alias' => $request->alias]);

        if (request()->wantsJson()) {
            return response()->json(['status' => 'success', 'message' => 'Alias updated.']);
        }

        return back()->with('status', 'Alias updated.');
    }
}
