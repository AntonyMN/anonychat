<?php

namespace App\Events;

use App\Models\Message;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;

    public function __construct(Message $message)
    {
        $this->message = $message->load(['sender']);
    }

    public function broadcastOn(): array
    {
        $channels = [
            new PrivateChannel('conversation.' . $this->message->conversation_id),
        ];

        // Also broadcast to other users in the conversation for sidebar updates
        $otherUsers = $this->message->conversation->users->where('id', '!=', $this->message->sender_id);
        foreach ($otherUsers as $user) {
            $channels[] = new PrivateChannel('notifications.' . $user->id);
        }

        return $channels;
    }

    public function broadcastAs(): string
    {
        return 'MessageSent';
    }
}