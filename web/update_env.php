<?php
$envPath = '/var/www/anonychat/web/.env';
$content = file_get_contents($envPath);

$replacements = [
    'REVERB_HOST=' => 'REVERB_HOST=127.0.0.1',
    'REVERB_PORT=' => 'REVERB_PORT=8080',
    'REVERB_SCHEME=' => 'REVERB_SCHEME=http',
    'VITE_REVERB_HOST=' => 'VITE_REVERB_HOST=chat.orellepos.com',
    'VITE_REVERB_PORT=' => 'VITE_REVERB_PORT=443',
    'VITE_REVERB_SCHEME=' => 'VITE_REVERB_SCHEME=https',
];

foreach ($replacements as $key => $value) {
    $content = preg_replace('/^' . preg_quote($key) . '.*$/m', $value, $content);
}

file_put_contents($envPath, $content);
echo "Successfully updated .env\n";
