<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class FriendRequestAccepted extends Notification
{
    use Queueable;

    protected $acceptor;

    /**
     * Create a new notification instance.
     */
    public function __construct($acceptor)
    {
        $this->acceptor = $acceptor;
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
            'title' => 'Friend Request Accepted',
            'body' => $this->acceptor->username . ' accepted your friend request.',
            'data' => [
                'type' => 'friend_request_accepted',
                'acceptor_id' => (string) $this->acceptor->id,
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
            'acceptor_id' => $this->acceptor->id,
            'acceptor_username' => $this->acceptor->username,
        ];
    }
}
