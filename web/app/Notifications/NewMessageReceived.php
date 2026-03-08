<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewMessageReceived extends Notification
{
    use Queueable;

    protected $chatMessage;

    /**
     * Create a new notification instance.
     */
    public function __construct($chatMessage)
    {
        $this->chatMessage = $chatMessage;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return [\App\Channels\FcmChannel::class];
    }

    /**
     * Get the FCM representation of the notification.
     */
    public function toFcm(object $notifiable): array
    {
        return [
            'title' => $this->chatMessage->sender->username,
            'body' => $this->chatMessage->content,
            'data' => [
                'type' => 'new_message',
                'conversation_id' => (string) $this->chatMessage->conversation_id,
                'sender_id' => (string) $this->chatMessage->sender_id,
            ],
        ];
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'message_id' => $this->chatMessage->id,
            'conversation_id' => $this->chatMessage->conversation_id,
            'content' => $this->chatMessage->content,
        ];
    }
}
