@echo off
title SportLife Mobile App
color 0E

set MOBILE_PATH=%~dp0mobile

echo ============================================
echo    SPORTLIFE MOBILE APP
echo ============================================
echo.

cd /d "%MOBILE_PATH%"

echo Starting Flutter app on Edge (Web)...
echo.
flutter run -d edge

pause
