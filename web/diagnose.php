<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Config;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "--- Reverb Configuration ---\n";
echo "REVERB_APP_KEY: " . env('REVERB_APP_KEY') . "\n";
echo "REVERB_HOST: " . env('REVERB_HOST') . "\n";
echo "REVERB_PORT: " . env('REVERB_PORT') . "\n";
echo "REVERB_SCHEME: " . env('REVERB_SCHEME') . "\n";

echo "\n--- Reverb Apps from Config ---\n";
$apps = config('reverb.apps.apps');
foreach ($apps as $index => $reverbApp) {
    echo "App $index:\n";
    echo "  Key: " . $reverbApp['key'] . "\n";
    echo "  Host (option): " . ($reverbApp['options']['host'] ?? 'N/A') . "\n";
    echo "  Port (option): " . ($reverbApp['options']['port'] ?? 'N/A') . "\n";
}

echo "\n--- Checking for fcm-token route ---\n";
$routeFound = false;
foreach (Route::getRoutes() as $route) {
    if (str_contains($route->uri(), 'fcm-token')) {
        echo "Found route: " . $route->methods()[0] . " " . $route->uri() . "\n";
        $routeFound = true;
    }
}
if (!$routeFound) {
    echo "Route 'api/fcm-token' NOT FOUND in current route list.\n";
}
