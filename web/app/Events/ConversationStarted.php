<?php

namespace App\Events;

use App\Models\Conversation;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ConversationStarted implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $conversation;
    public $recipientId;

    public function __construct(Conversation $conversation, $recipientId)
    {
        $this->conversation = $conversation->load(['users', 'lastMessage']);
        $this->recipientId = $recipientId;
    }

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('notifications.' . $this->recipientId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'ConversationStarted';
    }
}
