<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProfileController as ApiProfileController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\FriendController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Public Config Route
Route::get('/config', function () {
    return response()->json([
        'app_env' => config('app.env'),
        'timezone' => config('app.timezone'),
        'next_reset_at' => now('Africa/Nairobi')->tomorrow()->startOfDay()->toIso8601String(),
    ]);
});

// Auth Routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/check-uniqueness', [AuthController::class, 'checkUniqueness']);

// Broadcasting auth for API/Mobile
use Illuminate\Support\Facades\Broadcast;
Broadcast::routes(['middleware' => ['auth:sanctum']]);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/profile/update', [ApiProfileController::class, 'update']);

    // Dashboard & Conversations
    Route::get('/dashboard', [ChatController::class, 'dashboard']);
    Route::get('/chat/{conversation}', [ChatController::class, 'show']);
    Route::post('/chat/start', [ChatController::class, 'start']);
    Route::post('/chat/{conversation}/message', [ChatController::class, 'sendMessage']);
    Route::post('/chat/{conversation}/read', [ChatController::class, 'markAsRead']);

    // Friends & Searches
    Route::get('/friends/search', [FriendController::class, 'search']);
    Route::post('/friends/request', [FriendController::class, 'sendRequest']);
    Route::post('/friends/request/{friendRequest}/accept', [FriendController::class, 'acceptRequest']);
    Route::post('/friends/request/{friendRequest}/decline', [FriendController::class, 'declineRequest']);
    Route::post('/friends/{friend}/alias', [FriendController::class, 'setAlias']);

    // Notifications
    Route::post('/fcm-token', [\App\Http\Controllers\Api\NotificationController::class, 'registerToken']);
});
