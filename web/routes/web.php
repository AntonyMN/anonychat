<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

use App\Http\Controllers\FriendController;
use App\Http\Controllers\ChatController;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', [ChatController::class, 'dashboard'])->name('dashboard');

    // Friends
    Route::get('/friends/search', [FriendController::class, 'search'])->name('friends.search');
    Route::post('/friends/request', [FriendController::class, 'sendRequest'])->name('friends.request.send');
    Route::post('/friends/request/{friendRequest}/accept', [FriendController::class, 'acceptRequest'])->name('friends.request.accept');
    Route::post('/friends/request/{friendRequest}/decline', [FriendController::class, 'declineRequest'])->name('friends.request.decline');
    Route::post('/friends/{friend}/alias', [FriendController::class, 'setAlias'])->name('friends.alias.set');

    // Profile
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::post('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // Chat
    Route::get('/chat/{conversation}', [ChatController::class, 'show'])->name('chat.show');
    Route::post('/chat/start', [ChatController::class, 'start'])->name('chat.start');
    Route::post('/chat/{conversation}/message', [ChatController::class, 'sendMessage'])->name('chat.message.send');
    Route::post('/chat/{conversation}/read', [ChatController::class, 'markAsRead'])->name('chat.read');
});

require __DIR__ . '/auth.php';
