@echo off
title SportLife - Application Launcher
color 0A

echo ============================================
echo    SPORTLIFE - APPLICATION LAUNCHER
echo ============================================
echo.

:: Set paths
set PHP_PATH=C:\laragon\bin\php\php-8.3.16-Win32-vs16-x64\php.exe
set BACKEND_PATH=%~dp0backend
set MOBILE_PATH=%~dp0mobile

:: Ensure Laravel bootstrap cache directory exists and is writable
if not exist "%BACKEND_PATH%\bootstrap\cache" (
    mkdir "%BACKEND_PATH%\bootstrap\cache"
)
copy nul "%BACKEND_PATH%\bootstrap\cache\write-test.tmp" >nul 2>&1
if errorlevel 1 (
    echo      [!] Cannot write to %BACKEND_PATH%\bootstrap\cache. Please check permissions.
    pause
    exit /b 1
)
del /f /q "%BACKEND_PATH%\bootstrap\cache\write-test.tmp" >nul 2>&1

:: Check if Laragon MySQL is running
echo [1/6] Checking MySQL service...
netstat -an | findstr ":3306" >nul
if %errorlevel% neq 0 (
    echo      [!] MySQL is not running. Please start Laragon first!
    echo      [!] Open Laragon and click "Start All"
    pause
    exit /b 1
)
echo      [OK] MySQL is running on port 3306

:: Check PHP
echo.
echo [2/6] Checking PHP...
if not exist "%PHP_PATH%" (
    echo      [!] PHP not found at %PHP_PATH%
    echo      [!] Please check your Laragon PHP version and update the path in this script.
    pause
    exit /b 1
)
echo      [OK] PHP found

:: Setup Environment File
echo.
echo [2.5/6] Setting up environment...
if not exist "%BACKEND_PATH%\.env" (
    echo      - Copying .env.example to .env...
    copy "%BACKEND_PATH%\.env.example" "%BACKEND_PATH%\.env" >nul
    
    echo      - Generating application key...
    cd /d "%BACKEND_PATH%"
    "%PHP_PATH%" artisan key:generate --force
)

:: Create Database if not exists
echo.
echo [2.8/6] Checking Database...
"%PHP_PATH%" "%BACKEND_PATH%\create_db.php"
if %errorlevel% neq 0 (
    echo      [!] Database setup failed.
    pause
    exit /b 1
)
echo      [OK] Database check passed.

:: Install Dependencies (Composer)
echo.
echo [2.9/6] Checking Dependencies...
if not exist "%BACKEND_PATH%\vendor\autoload.php" (
    echo      - Vendor directory not found. Installing dependencies...
    echo      - NOTE: Running 'composer update' to resolve PHP version mismatches...
    cd /d "%BACKEND_PATH%"
    "%PHP_PATH%" "C:\laragon\bin\composer\composer.phar" update --no-interaction --prefer-dist --optimize-autoloader --ignore-platform-req=ext-pcntl --ignore-platform-req=ext-zip --ignore-platform-req=ext-posix
    if %errorlevel% neq 0 (
        echo      [!] Composer install failed.
        pause
        exit /b 1
    )
)
echo      [OK] Dependencies are installed.

:: Run database migrations & seeders
echo.
echo [3/6] Preparing Laravel database (migrate + seed)...
cd /d "%BACKEND_PATH%"
echo      - Running migrations...
"%PHP_PATH%" artisan migrate --force
if %errorlevel% neq 0 (
    echo      [!] Migrations failed. Please review the error above.
    pause
    exit /b 1
)
echo      - Seeding database...
"%PHP_PATH%" artisan db:seed --force
if %errorlevel% neq 0 (
    echo      [!] Database seeding failed. Please review the error above.
    pause
    exit /b 1
)
echo      [OK] Database is up to date with latest seed data.

:: Start queue worker (prefer Horizon when Redis extension available)
echo.
echo [4/6] Starting queue worker...
%PHP_PATH% -m | findstr /I "redis" >nul
if %errorlevel%==0 (
    start "SportLife Queue" cmd /k "cd /d %BACKEND_PATH% && title SportLife Horizon && color 0C && %PHP_PATH% artisan horizon"
    echo      [OK] Horizon running with Redis backend.
) else (
    echo      [!] PHP Redis extension not found. Falling back to database queue worker.
    start "SportLife Queue" cmd /k "cd /d %BACKEND_PATH% && title SportLife Queue Worker && color 0C && %PHP_PATH% artisan queue:work --queue=default --sleep=3 --tries=1"
    echo      [OK] Database queue worker started.
)

:: Start Laravel Backend
echo.
echo [5/6] Starting Laravel Backend Server...
start "SportLife Backend" cmd /k "cd /d %BACKEND_PATH% && title SportLife Backend - http://127.0.0.1:8000 && color 0B && %PHP_PATH% artisan serve --host=127.0.0.1 --port=8000"
:: Use ping for delay instead of timeout to avoid input redirection errors
ping 127.0.0.1 -n 6 >nul
start http://127.0.0.1:8000/admin
echo      [OK] Backend started at http://127.0.0.1:8000
echo      [OK] Admin Panel opened at http://127.0.0.1:8000/admin

echo.
echo ============================================
echo    APPLICATION STARTED SUCCESSFULLY!
echo ============================================
echo.
echo    Backend API: http://127.0.0.1:8000
echo    API Docs:    http://127.0.0.1:8000/api/v1/
echo.
echo    Admin Login:
echo    Email:    admin@sportlife.vn
echo    Password: password123
echo.
echo    Demo User:
echo    Email:    demo@sportlife.vn
echo    Password: demo123
echo.
echo ============================================
echo.

:: Prepare Flutter project and start web build
echo.
echo [6/6] Preparing Flutter Mobile App...
cd /d "%MOBILE_PATH%"

:: Check for git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo      [!] Git is not found in PATH. Flutter requires Git.
    echo      [!] Please install Git or add it to your PATH.
    pause
    exit /b 1
)

call flutter pub get
if %errorlevel% neq 0 (
    echo      [!] flutter pub get failed. Trying to repair with 'flutter doctor'...
    call flutter doctor
    echo      - Retrying flutter pub get...
    call flutter pub get
    if %errorlevel% neq 0 (
        echo      [!] Still failed. Please check the error above.
        pause
        exit /b 1
    )
)
echo      - Running build_runner to generate code...
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo      [WARNING] build_runner failed. App may not work properly.
    echo      [WARNING] Continuing anyway...
)

echo.
echo      - Starting Flutter app on Edge browser...
echo      - NOTE: This window will now become the Flutter log window.
echo      - Press 'R' to reload the app.
echo      - Press 'q' to quit the app.
echo.

title SportLife Mobile - Flutter Web
color 0E
flutter run -d edge
