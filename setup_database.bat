@echo off
title SportLife Database Setup
color 0C

set PHP_PATH=C:\laragon\bin\php\php-8.3.26-Win32-vs16-x64\php.exe
set BACKEND_PATH=%~dp0backend

echo ============================================
echo    SPORTLIFE DATABASE SETUP
echo ============================================
echo.
echo Auto-updating database with REAL data...

cd /d "%BACKEND_PATH%"

echo.
echo [1/3] Running migrations...
%PHP_PATH% artisan migrate:fresh --force

echo.
echo [2/3] Seeding database...
echo       (This will populate REAL WORLD data: Premier League, V.League, Players, Matches...)
%PHP_PATH% artisan db:seed --force

echo.
echo [3/3] Clearing cache...
%PHP_PATH% artisan cache:clear
%PHP_PATH% artisan config:clear
%PHP_PATH% artisan route:clear

echo.
echo ============================================
echo    DATABASE SETUP COMPLETED!
echo ============================================
echo.
echo Created accounts:
echo.
echo   Admin:
echo   Email:    admin@sportlife.vn
echo   Password: password123
echo.
echo   Demo User:
echo   Email:    demo@sportlife.vn
echo   Password: demo123
echo.
echo   Test Users:
echo   vana@gmail.com, thib@gmail.com, etc.
echo   Password: password123
echo.
pause
