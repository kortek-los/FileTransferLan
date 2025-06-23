@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

:: === BACA MODE KEPRIBADIAN ===
if not exist config.ini (
    echo [ERROR] File config.ini tidak ditemukan. Jalankan launcher.bat dulu.
    pause
    exit /b
)
for /f "tokens=2 delims==" %%A in ('findstr "kepribadian" config.ini') do set MODE_NUM=%%A

:: === SET MODE, WARNA, TITLE ===
if "%MODE_NUM%"=="1" (
    set MODE=kasar
    color 0A
    title SERVER UPLOAD - MODE KASAR
) else if "%MODE_NUM%"=="2" (
    set MODE=wibu
    color 0D
    title SERVER UPLOAD - MODE WIBU
) else if "%MODE_NUM%"=="3" (
    set MODE=profesional
    color 0F
    title SERVER UPLOAD - MODE PROFESIONAL
) else (
    echo [ERROR] Nilai kepribadian tidak valid di config.ini
    pause
    exit /b
)

:: === CEK ADMIN ===
>nul 2>&1 net session
if %errorLevel% NEQ 0 (
    echo [INFO] Script butuh akses Administrator.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: === CEK PYTHON ===
where python > temp_path.txt 2>nul
set /p PYEXE=<temp_path.txt
del temp_path.txt
if "%PYEXE%"=="" (
    echo [ERROR] Python tidak ditemukan.
    pause
    exit /b
)
echo [PYTHON] Ketemu: %PYEXE%

:: === CEK CLOUDFLARE WARP ===
netsh interface show interface | findstr /i "cloudflare warp" >nul
if %errorlevel% EQU 0 (
    echo [ERROR] WARP aktif. Matikan dulu.
    pause
    exit /b
)

:: === CEK & INSTALL MODULE PYTHON ===
echo [INFO] Cek module Python...
python -c "import flask" 2>NUL || pip install flask
python -c "import qrcode" 2>NUL || pip install qrcode
python -c "from PIL import Image" 2>NUL || pip install pillow
python -c "import waitress" 2>NUL || pip install waitress
python -c "import requests" 2>NUL || pip install requests

:: === JALANKAN SERVER OTOMATIS ===
echo.
echo [INFO] Menyalakan server secara otomatis...
start /b "" python app.py

:: === SIMPAN PID ===
for /f "tokens=2" %%p in ('tasklist /fi "imagename eq python.exe" /fo csv /nh') do (
    echo %%~p>pid.txt
    goto AFTER_START
)

:AFTER_START
echo [INFO] Server berjalan di http://localhost:5000 (mode: %MODE%)
echo -------------------------------------------
goto MENU

:MENU
echo.
echo ==============================
echo         PILIH AKSI
echo ==============================
echo MODE: %MODE%
echo.
echo 1. Restart Server
echo 2. Ganti Kepribadian
echo.
set /p PILIH="Pilihan Anda: "

if "%PILIH%"=="1" goto RESTART
if "%PILIH%"=="2" goto GANTI
goto MENU


:RESTART
echo [INFO] Restart server...
if exist pid.txt (
    set /p PID=<pid.txt
    taskkill /pid !PID! /f >nul 2>&1
    del pid.txt
)
echo [INFO] Menyalakan ulang...
call "%~f0"
exit /b

:: === GANTI KEPRIBADIAN ===
:GANTI
echo.
echo ==============================
echo     PILIH KEPRIBADIAN BARU
echo ==============================
echo 1. Kasar
echo 2. Wibu
echo 3. Profesional
echo.
set /p NEWMODE="Masukkan nomor kepribadian: "

if "%NEWMODE%" NEQ "1" if "%NEWMODE%" NEQ "2" if "%NEWMODE%" NEQ "3" (
    echo [ERROR] Pilihan tidak valid.
    pause
    goto MENU
)

:: === UPDATE ANGKA KEPRIBADIAN DI CONFIG.INI ===
(for /f "usebackq delims=" %%L in ("config.ini") do (
    set "line=%%L"
    echo !line! | findstr /b /c:"kepribadian=" >nul
    if !errorlevel! equ 0 (
        echo kepribadian=%NEWMODE%
    ) else (
        echo !line!
    )
)) > config_temp.ini

move /y config_temp.ini config.ini >nul

:: === HENTIKAN SERVER LAMA ===
if exist pid.txt (
    set /p PID=<pid.txt
    taskkill /pid !PID! /f >nul 2>&1
    del pid.txt
)

echo [INFO] Kepribadian telah diganti. Menjalankan ulang script...
timeout /t 1 >nul
call "%~f0"
exit /b
