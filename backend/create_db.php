<?php
// create_db.php
// Script to create the database if it doesn't exist, reading credentials from .env

$envFile = __DIR__ . '/.env';
$env = [];

if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        $line = trim($line);
        if (empty($line) || strpos($line, '#') === 0) continue;
        
        if (strpos($line, '=') !== false) {
            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);
            // Remove quotes if present
            if (preg_match('/^"(.*)"$/', $value, $m)) $value = $m[1];
            elseif (preg_match("/^'(.*)'$/", $value, $m)) $value = $m[1];
            
            $env[$key] = $value;
        }
    }
}

$host = $env['DB_HOST'] ?? '127.0.0.1';
$user = $env['DB_USERNAME'] ?? 'root';
$pass = $env['DB_PASSWORD'] ?? '';
$db   = $env['DB_DATABASE'] ?? 'sportlife';
$port = $env['DB_PORT'] ?? 3306;

echo "Connecting to MySQL at $host:$port as user '$user'...\n";

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

try {
    // Connect without selecting a database
    $conn = new mysqli($host, $user, $pass, '', (int)$port);
    
    echo "Checking database '$db'...\n";
    $conn->query("CREATE DATABASE IF NOT EXISTS `$db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    echo "Database '$db' is ready.\n";
    
    $conn->close();
    exit(0);
} catch (mysqli_sql_exception $e) {
    echo "\n[ERROR] Database connection failed!\n";
    echo "Message: " . $e->getMessage() . "\n";
    echo "---------------------------------------------------\n";
    echo "Troubleshooting:\n";
    echo "1. Check if MySQL is running in Laragon.\n";
    echo "2. Check your username and password in 'backend/.env'.\n";
    echo "   Current User: $user\n";
    echo "   Current Pass: " . ($pass ? '******' : '(empty)') . "\n";
    echo "---------------------------------------------------\n";
    exit(1);
} catch (Exception $e) {
    echo "[ERROR] An unexpected error occurred: " . $e->getMessage() . "\n";
    exit(1);
}
?>
