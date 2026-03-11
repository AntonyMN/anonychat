<?php

/**
 * AnonyChat Installation Wizard
 * A standalone script to help users set up the application.
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

define('ROOT_DIR', dirname(__DIR__));
define('ENV_FILE', ROOT_DIR . '/.env');
define('EXAMPLE_ENV_FILE', ROOT_DIR . '/.env.example');

$step = isset($_GET['step']) ? (int)$_GET['step'] : 1;
$message = '';
$error = '';

// Check if .env already exists (except for the last step or if we're just checking)
if (file_exists(ENV_FILE) && $step < 5 && !isset($_GET['force'])) {
    $step = 0; // Show "Already Installed" message
}

/**
 * Helper to run shell commands
 */
function run_command($command) {
    $output = [];
    $return_var = 0;
    exec($command . ' 2>&1', $output, $return_var);
    return [
        'success' => $return_var === 0,
        'output' => implode("\n", $output)
    ];
}

/**
 * Check system requirements
 */
function check_requirements() {
    $requirements = [
        'PHP Version >= 8.2' => version_compare(PHP_VERSION, '8.2.0', '>='),
        'BCMath Extension' => extension_loaded('bcmath'),
        'Ctype Extension' => extension_loaded('ctype'),
        'Fileinfo Extension' => extension_loaded('fileinfo'),
        'JSON Extension' => extension_loaded('json'),
        'Mbstring Extension' => extension_loaded('mbstring'),
        'OpenSSL Extension' => extension_loaded('openssl'),
        'PDO Extension' => extension_loaded('pdo'),
        'Tokenizer Extension' => extension_loaded('tokenizer'),
        'XML Extension' => extension_loaded('xml'),
        'CURL Extension' => extension_loaded('curl'),
        'Storage Directory Writable' => is_writable(ROOT_DIR . '/storage'),
        'Bootstrap/Cache Writable' => is_writable(ROOT_DIR . '/bootstrap/cache'),
    ];
    return $requirements;
}

// Logic for handling form submission in Step 3
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $step === 3) {
    $env_data = $_POST['env'];
    $env_content = file_get_contents(EXAMPLE_ENV_FILE);

    foreach ($env_data as $key => $value) {
        $env_content = preg_replace("/^{$key}=.*/m", "{$key}={$value}", $env_content);
    }

    if (file_put_contents(ENV_FILE, $env_content)) {
        header('Location: index.php?step=4');
        exit;
    } else {
        $error = "Failed to write .env file. Please check permissions.";
    }
}

// Logic for Step 4 (Execution)
if ($step === 4) {
    // This step might take a while, normally we'd use AJAX but for a simple script we'll just run it.
    // In a real scenario, we might want to trigger these one by one.
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AnonyChat Installation Wizard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --primary-dark: #4f46e5;
            --bg: #0f172a;
            --card-bg: #1e293b;
            --text: #f8fafc;
            --text-muted: #94a3b8;
            --success: #10b981;
            --error: #ef4444;
            --border: #334155;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg);
            color: var(--text);
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            line-height: 1.6;
        }

        .container {
            width: 100%;
            max-width: 600px;
            padding: 2rem;
        }

        .card {
            background: var(--card-bg);
            border-radius: 1rem;
            padding: 2.5rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            border: 1px solid var(--border);
            backdrop-filter: blur(10px);
        }

        h1 {
            margin-top: 0;
            font-size: 1.875rem;
            font-weight: 600;
            background: linear-gradient(to right, #818cf8, #c084fc);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
        }

        p {
            color: var(--text-muted);
            margin-bottom: 2rem;
        }

        .step-indicator {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 2rem;
        }

        .step-dot {
            height: 4px;
            flex: 1;
            background: var(--border);
            border-radius: 2px;
            transition: background 0.3s;
        }

        .step-dot.active {
            background: var(--primary);
        }

        .requirement-item {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 0;
            border-bottom: 1px solid var(--border);
        }

        .requirement-item:last-child {
            border-bottom: none;
        }

        .status-ok { color: var(--success); }
        .status-fail { color: var(--error); }

        .form-group {
            margin-bottom: 1.5rem;
        }

        label {
            display: block;
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text-muted);
        }

        input {
            width: 100%;
            padding: 0.75rem;
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 0.5rem;
            color: var(--text);
            font-size: 1rem;
            transition: border-color 0.3s, box-shadow 0.3s;
        }

        input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
        }

        .btn {
            display: inline-block;
            width: 100%;
            padding: 0.875rem;
            background: var(--primary);
            color: white;
            text-align: center;
            border-radius: 0.5rem;
            text-decoration: none;
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: background 0.3s, transform 0.1s;
        }

        .btn:hover {
            background: var(--primary-dark);
        }

        .btn:active {
            transform: translateY(1px);
        }

        .btn-secondary {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text);
            margin-top: 1rem;
        }

        .btn-secondary:hover {
            background: var(--border);
        }

        .alert {
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 2rem;
            font-size: 0.875rem;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success);
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            color: var(--error);
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        code {
            background: #000;
            padding: 0.2rem 0.4rem;
            border-radius: 0.25rem;
            font-family: monospace;
            font-size: 0.9rem;
        }

        .terminal {
            background: #000;
            color: #fff;
            padding: 1rem;
            border-radius: 0.5rem;
            font-family: 'Courier New', Courier, monospace;
            font-size: 0.875rem;
            margin-bottom: 1.5rem;
            max-height: 200px;
            overflow-y: auto;
            white-space: pre-wrap;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <?php if ($step === 0): ?>
            <h1>Already Installed</h1>
            <p>The application already has a <code>.env</code> file configured.</p>
            <div class="alert alert-success">
                Installation successful! You can now use the application.
            </div>
            <a href="/" class="btn">Go to Dashboard</a>
            <a href="?step=1&force=1" class="btn btn-secondary">Re-install (Caution: Overwrites .env)</a>

        <?php elseif ($step === 1): ?>
            <div class="step-indicator">
                <div class="step-dot active"></div>
                <div class="step-dot"></div>
                <div class="step-dot"></div>
                <div class="step-dot"></div>
            </div>
            <h1>Welcome to AnonyChat</h1>
            <p>This wizard will guide you through the installation process of your new anonymous chat application.</p>
            <div class="alert alert-success">
                No environment file detected. Let's set things up!
            </div>
            <a href="?step=2" class="btn">Start Installation</a>

        <?php elseif ($step === 2): ?>
            <div class="step-indicator">
                <div class="step-dot active"></div>
                <div class="step-dot active"></div>
                <div class="step-dot"></div>
                <div class="step-dot"></div>
            </div>
            <h1>System Check</h1>
            <p>We need to make sure your server meets the requirements to run AnonyChat.</p>
            
            <div style="margin-bottom: 2rem;">
                <?php 
                $reqs = check_requirements();
                $all_ok = true;
                foreach ($reqs as $name => $ok): 
                    if (!$ok) $all_ok = false;
                ?>
                    <div class="requirement-item">
                        <span><?php echo $name; ?></span>
                        <span class="<?php echo $ok ? 'status-ok' : 'status-fail'; ?>">
                            <?php echo $ok ? '✔' : '✘'; ?>
                        </span>
                    </div>
                <?php endforeach; ?>
            </div>

            <?php if ($all_ok): ?>
                <div class="alert alert-success">
                    All systems go! Your server is ready.
                </div>
                <a href="?step=3" class="btn">Next: Configuration</a>
            <?php else: ?>
                <div class="alert alert-error">
                    Some requirements are missing. Please install them and refresh this page.
                </div>
                <p style="font-size: 0.875rem;">
                    Hint: Use <code>sudo apt install php-bcmath php-mbstring php-xml</code> etc. on Ubuntu/Debian.
                </p>
                <a href="?step=2" class="btn">Refresh Check</a>
            <?php endif; ?>

        <?php elseif ($step === 3): ?>
            <div class="step-indicator">
                <div class="step-dot active"></div>
                <div class="step-dot active"></div>
                <div class="step-dot active"></div>
                <div class="step-dot"></div>
            </div>
            <h1>Configuration</h1>
            <p>Setup your database and basic application settings.</p>

            <form method="POST">
                <div class="form-group">
                    <label>App Name</label>
                    <input type="text" name="env[APP_NAME]" value="AnonyChat" required>
                </div>
                <div class="form-group">
                    <label>App URL</label>
                    <input type="text" name="env[APP_URL]" value="http://<?php echo $_SERVER['HTTP_HOST']; ?>" required>
                </div>
                <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">
                <div class="form-group">
                    <label>Database Connection</label>
                    <select name="env[DB_CONNECTION]" style="width: 100%; padding: 0.75rem; background: var(--bg); border: 1px solid var(--border); border-radius: 0.5rem; color: var(--text);">
                        <option value="mysql">MySQL / MariaDB</option>
                        <option value="sqlite">SQLite (Requires database/database.sqlite)</option>
                        <option value="pgsql">PostgreSQL</option>
                        <option value="sqlsrv">SQL Server (IIS Integration)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Database Host</label>
                    <input type="text" name="env[DB_HOST]" value="127.0.0.1" required>
                </div>
                <div class="form-group">
                    <label>Database Port</label>
                    <input type="text" name="env[DB_PORT]" value="3306" required>
                </div>
                <div class="form-group">
                    <label>Database Name</label>
                    <input type="text" name="env[DB_DATABASE]" placeholder="anonychat" required>
                </div>
                <div class="form-group">
                    <label>Database Username</label>
                    <input type="text" name="env[DB_USERNAME]" value="root" required>
                </div>
                <div class="form-group">
                    <label>Database Password</label>
                    <input type="password" name="env[DB_PASSWORD]">
                </div>

                <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">
                <h3 style="color: var(--primary); font-size: 1rem;">Real-time Messaging (Laravel Reverb)</h3>
                <p style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 1rem;">
                    Reverb provides blazing-fast WebSocket communication. Configure your connection details below.
                </p>
                <div class="form-group">
                    <label>Reverb App ID</label>
                    <input type="text" name="env[REVERB_APP_ID]" value="<?php echo rand(100000, 999999); ?>" required>
                </div>
                <div class="form-group">
                    <label>Reverb App Key</label>
                    <input type="text" name="env[REVERB_APP_KEY]" value="<?php echo bin2hex(random_bytes(10)); ?>" required>
                </div>
                <div class="form-group">
                    <label>Reverb App Secret</label>
                    <input type="text" name="env[REVERB_APP_SECRET]" value="<?php echo bin2hex(random_bytes(16)); ?>" required>
                </div>
                <div class="form-group">
                    <label>Reverb Host (e.g., chat.example.com)</label>
                    <input type="text" name="env[REVERB_HOST]" value="<?php echo $_SERVER['HTTP_HOST']; ?>" required>
                </div>
                <div class="form-group">
                    <label>Reverb Port (Usually 443 for HTTPS/WSS, or 8080 for local)</label>
                    <input type="text" name="env[REVERB_PORT]" value="443" required>
                </div>
                <div class="form-group">
                    <label>Reverb Scheme (https or http)</label>
                    <select name="env[REVERB_SCHEME]" style="width: 100%; padding: 0.75rem; background: var(--bg); border: 1px solid var(--border); border-radius: 0.5rem; color: var(--text);">
                        <option value="https">https (Required for WSS)</option>
                        <option value="http">http (WS - Local testing only)</option>
                    </select>
                </div>
                
                <button type="submit" class="btn">Save & Continue</button>
            </form>

        <?php elseif ($step === 4): ?>
            <div class="step-indicator">
                <div class="step-dot active"></div>
                <div class="step-dot active"></div>
                <div class="step-dot active"></div>
                <div class="step-dot active"></div>
            </div>
            <h1>Installing Components</h1>
            <p>We're running migrations and generating keys. This may take a moment.</p>

            <div class="terminal" id="terminal-out">
Running setup...
<?php
    $commands = [
        'php artisan key:generate',
        'php artisan migrate --force'
    ];
    
    // Check for composer
    if (!is_dir(ROOT_DIR . '/vendor')) {
        echo "> Notice: vendor directory not found. Attempting 'composer install --no-dev'...\n";
        $res = run_command("cd " . ROOT_DIR . " && composer install --no-dev --optimize-autoloader");
        echo $res['output'] . "\n";
    }

    foreach ($commands as $cmd) {
        echo "> " . $cmd . "\n";
        $res = run_command("cd " . ROOT_DIR . " && " . $cmd);
        echo $res['output'] . "\n";
        if (!$res['success']) echo "!! Command failed.\n";
    }

    // Check for npm build
    if (!is_dir(ROOT_DIR . '/public/build')) {
        echo "> Notice: Vite build not found. Attempting 'npm install && npm run build'...\n";
        $res = run_command("cd " . ROOT_DIR . " && npm install && npm run build");
        echo $res['output'] . "\n";
    }
?>
Done.
            </div>

            <a href="?step=5" class="btn">Finalize Installation</a>

        <?php elseif ($step === 5): ?>
            <h1>Installation Successful!</h1>
            <p>AnonyChat is now ready for deployment. Follow these notes for your OS/Server.</p>
            
            <div class="alert alert-success">
                The <code>.env</code> file has been created and the database is migrated.
            </div>

            <div style="text-align: left; font-size: 0.875rem;">
                <h3 style="color: var(--primary);">Apache (Linux/Windows)</h3>
                <p>1. Enable <code>mod_rewrite</code>: <code>sudo a2enmod rewrite</code>.</p>
                <p>2. Set <code>AllowOverride All</code> in your VirtualHost for the <code>public/</code> directory.</p>
                
                <h3 style="color: var(--primary);">Nginx (Linux)</h3>
                <p>Add this to your server block:</p>
                <div class="terminal" style="max-height: none;">
location / {
    try_files $uri $uri/ /index.php?$query_string;
}</div>

                <h3 style="color: var(--primary);">IIS (Windows)</h3>
                <p>1. Install the <a href="https://www.iis.net/downloads/microsoft/url-rewrite" style="color: var(--primary);">URL Rewrite</a> extension.</p>
                <p>2. Laravel will automatically use the <code>public/web.config</code> if present.</p>
                <p>3. Ensure <code>IIS_IUSRS</code> has write permission to <code>storage</code> and <code>bootstrap/cache</code>.</p>

                <h3 style="color: var(--primary);">WebSockets & SSL Guide (WS vs WSS)</h3>
                <p>Establishing a secure WebSocket connection is critical for production:</p>
                <ul style="padding-left: 1.25rem;">
                    <li><strong>WS (ws://)</strong>: Unencrypted. Only use for local development (e.g., <code>localhost</code>). Browsers will block <code>ws://</code> on <code>https://</code> sites (Mixed Content Error).</li>
                    <li><strong>WSS (wss://)</strong>: Encrypted and secure. <strong>Mandatory</strong> for production sites running on HTTPS.</li>
                </ul>

                <p><strong>Common Troubleshooting:</strong></p>
                <div style="background: rgba(255,255,255,0.05); padding: 1rem; border-radius: 0.5rem; border-left: 4px solid var(--primary);">
                    1. <strong>SSL Termination:</strong> If using Nginx, ensure it handles the SSL and proxies the traffic to the Reverb port (default 8080).<br>
                    2. <strong>Ports:</strong> If <code>REVERB_SCHEME</code> is <code>https</code>, ensure <code>REVERB_PORT</code> is set to <code>443</code> (the standard HTTPS port) so the client connects via WSS correctly.<br>
                    3. <strong>Firewall:</strong> Ensure the Reverb port (e.g. 8080) is open if you are not proxying through port 443.
                </div>

                <h3 style="color: var(--primary); margin-top: 1.5rem;">Running the WebSocket Server</h3>
                <p>Run this command to start the real-time engine:</p>
                <div class="terminal">php artisan reverb:start</div>
                <p>For production, use <strong>Supervisor</strong> to ensure Reverb restarts automatically if it crashes or the server reboots.</p>
            </div>

            <a href="/" class="btn" style="margin-top: 2rem;">Finish & Launch App</a>
            <p style="text-align: center; margin-top: 1rem; font-size: 0.75rem;">
                Security Tip: You should delete the <code>install/</code> directory after installation is complete.
            </p>
        <?php endif; ?>

    </div>
</div>

<script>
    // Simple script to auto-scroll terminal
    const terminal = document.getElementById('terminal-out');
    if (terminal) {
        terminal.scrollTop = terminal.scrollHeight;
    }
</script>

</body>
</html>
