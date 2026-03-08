<?php

use App\Models\User;
use App\Models\Conversation;
use App\Http\Controllers\ChatController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

// Bootstrap Laravel
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$kernel->handle(Illuminate\Http\Request::capture());

// Simulate Auth
$user = User::find(1);
Auth::login($user);

// Simulate Request
$conversation = Conversation::find(1);
$request = Request::create('/chat/1/message', 'POST', [
    'content' => 'Test debug message at ' . date('Y-m-d H:i:s'),
]);

$controller = new ChatController();

try {
    echo "Attempting to send message...\n";
    $response = $controller->sendMessage($request, $conversation);
    echo "Response: " . json_encode($response->getData()) . "\n";
} catch (\Throwable $e) {
    echo "Caught Exception: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . "\n";
    echo "Line: " . $e->getLine() . "\n";
    echo "Stack Trace:\n" . $e->getTraceAsString() . "\n";
}
