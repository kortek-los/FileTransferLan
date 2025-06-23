::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFBheRwuQAE+/Fb4I5/jHwe+Q4ksSWOY6as+TiP2yBukf73H2dJg+0H9ItMoCMBJbcRzlZww7yQ==
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBheRwuQAE+/Fb4I5/jHwe+Q4ksSWOY6as+TiP2yBukf73H2dJg+0H9ItMoCMD1RchfrWh01p31Es3bFG8aS/Qr5Tyg=
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion
title LAUNCHER SERVER UPLOAD
color 0A

:: === DETEKSI WINDOWS 32-BIT / 64-BIT ===
if defined ProgramFiles(x86) (
    echo [INFO] Windows 64-bit terdeteksi.
) else (
    echo [INFO] Windows 32-bit terdeteksi.
)

:: === CEK PYTHON TERINSTAL ===
where python >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Python belum terpasang di sistem Anda.
    echo Silakan unduh Python dari situs resmi:
    echo https://www.python.org/downloads/windows/
    echo.
    echo Pastikan untuk mencentang "Add Python to PATH" saat instalasi!
    pause
    exit /b
)

:: === LANJUTKAN JIKA CONFIG.INI SUDAH ADA ===
if exist config.ini (
    echo [INFO] config.ini sudah ada. Menjalankan run_server.bat...
    call run_server.bat
    exit /b
)

:: === TAMPILKAN MENU PILIH MODE ===
:MENU
cls
echo ========================================
echo         PILIH GAYA SERVER UPLOAD        
echo ========================================
echo  [1] Bahasa Kasar (Hacker Style)
echo  [2] Bahasa Wibu Moe Moe
echo  [3] Bahasa Profesional Formal
echo ========================================
set /p MODE=Pilih mode (1/2/3): 

if "%MODE%"=="1" (
    set KEPRIBADIAN=1
) else if "%MODE%"=="2" (
    set KEPRIBADIAN=2
) else if "%MODE%"=="3" (
    set KEPRIBADIAN=3
) else (
    echo [ERROR] Pilihan tidak valid.
    pause
    goto MENU
)

:: === SIMPAN CONFIG.INI ===
(
    echo [DEFAULT]
    echo kepribadian=%KEPRIBADIAN%
) > config.ini

echo.
echo [INFO] Mode berhasil disimpan.
echo [INFO] Menjalankan server...
call run_server.bat
