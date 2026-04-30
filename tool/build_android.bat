@echo off
setlocal
rem ===============================================================
rem  City Guide - Android build + install helper (Windows)
rem ===============================================================
rem  Usage:
rem     tool\build_android.bat            - builds a release APK
rem     tool\build_android.bat run        - builds + installs +
rem                                         runs on connected phone
rem     tool\build_android.bat install    - installs the APK on a
rem                                         connected phone (no rebuild)
rem ===============================================================

cd /d "%~dp0.."

set ACTION=%1
if "%ACTION%"=="" set ACTION=build

echo.
echo === Flutter doctor (short) ===
call flutter --version
if errorlevel 1 (
    echo Flutter is not on PATH. Install from https://docs.flutter.dev/get-started/install
    exit /b 1
)

if "%ACTION%"=="run" goto run
if "%ACTION%"=="install" goto install

:build
echo.
echo === flutter pub get ===
call flutter pub get
echo.
echo === flutter build apk --release ===
call flutter build apk --release
if errorlevel 1 exit /b 1
echo.
echo Release APK:
echo   build\app\outputs\flutter-apk\app-release.apk
echo.
echo Transfer this file to your phone, tap it, and allow
echo "Install from unknown sources" when Android prompts.
exit /b 0

:run
echo.
echo === Checking for connected devices ===
call flutter devices
echo.
echo === flutter run --release ===
call flutter run --release
exit /b 0

:install
echo.
echo === flutter install ===
call flutter install
exit /b 0
