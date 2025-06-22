@echo off
cd /d "%~dp0"
title PILIH MODE SERVER
color 0A

:: CEK APAKAH FILE CONFIG.INI SUDAH ADA
if exist config.ini (
    echo [INFO] config.ini sudah ada. Langsung jalanin server.
    call run_server.bat
    exit /b
)

:: TAMPILKAN MENU
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

:: TULIS FILE config.ini (hanya jika belum ada)
(
    echo [DEFAULT]
    echo kepribadian=%KEPRIBADIAN%
) > config.ini

echo.
echo [INFO] Mode berhasil disimpan di config.ini
echo [INFO] Menjalankan server dengan run_server.bat...
echo.
call run_server.bat
