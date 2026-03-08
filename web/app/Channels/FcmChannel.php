<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;

class FcmChannel
{
    protected $messaging;

    public function __construct(Messaging $messaging)
    {
        $this->messaging = $messaging;
    }

    public function send($notifiable, Notification $notification)
    {
        $token = $notifiable->fcm_token;

        if (!$token) {
            return;
        }

        $data = $notification->toFcm($notifiable);

        $message = CloudMessage::fromArray([
            'token' => $token,
            'notification' => [
                'title' => $data['title'],
                'body' => $data['body'],
            ],
            'data' => $data['data'] ?? [],
        ]);

        try {
            $this->messaging->send($message);
        } catch (\Exception $e) {
            \Log::error('FCM Send Error: ' . $e->getMessage());
        }
    }
}
