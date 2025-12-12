@echo off
title SportLife Backend Server
color 0B

set PHP_PATH=C:\laragon\bin\php\php-8.3.26-Win32-vs16-x64\php.exe
set BACKEND_PATH=%~dp0backend

echo ============================================
echo    SPORTLIFE BACKEND SERVER
echo ============================================
echo.

cd /d "%BACKEND_PATH%"

echo Starting Laravel server...
echo.
echo API URL: http://127.0.0.1:8000
echo.
echo Admin:  admin@sportlife.vn / password123
echo Demo:   demo@sportlife.vn / demo123

:: Open Admin Panel
start http://127.0.0.1:8000/admin
echo.
echo Press Ctrl+C to stop the server
echo ============================================
echo.

%PHP_PATH% artisan serve --host=127.0.0.1 --port=8000
