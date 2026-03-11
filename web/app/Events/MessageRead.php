<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageRead implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $conversationId;
    public $lastReadId;

    public function __construct($conversationId, $lastReadId)
    {
        $this->conversationId = $conversationId;
        $this->lastReadId = $lastReadId;
    }

    public function broadcastOn(): array
    {
        $channels = [
            new PrivateChannel('conversation.' . $this->conversationId),
        ];

        // Also broadcast to notification channels for sidebar unread badge updates
        $conversation = \App\Models\Conversation::find($this->conversationId);
        if ($conversation) {
            foreach ($conversation->users as $user) {
                $channels[] = new PrivateChannel('notifications.' . $user->id);
            }
        }

        return $channels;
    }

    public function broadcastAs(): string
    {
        return 'MessageRead';
    }
}
