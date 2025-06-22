@echo off
cd /d "%~dp0"

:: === BACA ANGKA DARI CONFIG.INI ===
if not exist config.ini (
    echo [ERROR] File config.ini tidak ditemukan. Jalankan launcher.bat dulu.
    pause
    exit /b
)

for /f "tokens=2 delims==" %%A in ('findstr "kepribadian" config.ini') do set MODE_NUM=%%A

:: === KONVERSI ANGKA KE MODE & SET WARNA ===
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

:: === CEK AKSES ADMIN ===
>nul 2>&1 net session
if %errorLevel% NEQ 0 (
    echo [INFO] Script ini membutuhkan akses Administrator.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [INFO] Akses admin terdeteksi.
echo.

:: === CARI PATH PYTHON.EXE ===
where python > temp_path.txt 2>nul
set /p PYEXE=<temp_path.txt
del temp_path.txt

if "%PYEXE%"=="" (
    echo [ERROR] Python tidak ditemukan. Pastikan sudah diinstal.
    pause
    exit /b
)
echo [PYTHON] Ketemu: %PYEXE%

:: === CEK FIREWALL ===
netsh advfirewall firewall show rule name="Flask Upload Python" | findstr /i "Rule Name" >nul
if %errorlevel% NEQ 0 (
    echo [FIREWALL] Menambahkan rule firewall untuk Python...
    netsh advfirewall firewall add rule name="Flask Upload Python" ^
    dir=in action=allow program="%PYEXE%" enable=yes profile=any protocol=TCP localport=5000
) else (
    echo [FIREWALL] Rule firewall sudah ada.
)

:: === DETEKSI WARP ===
echo.
echo [CHECK] Cek VPN / WARP...
netsh interface show interface | findstr /i "cloudflare warp" >nul
if %errorlevel% EQU 0 (
    echo [ERROR] Cloudflare WARP terdeteksi. Matikan dulu.
    pause
    exit /b
)

:: === CEK & INSTALL MODULE PYTHON ===
echo.
echo [INFO] Cek dan install Flask, QRCode, Pillow, Waitress, Requests...

python -c "import flask" 2>NUL || pip install flask
python -c "import qrcode" 2>NUL || pip install qrcode
python -c "from PIL import Image" 2>NUL || pip install pillow
python -c "import waitress" 2>NUL || pip install waitress
python -c "import requests" 2>NUL || pip install requests

:: === JALANKAN SERVER ===
echo.
echo [INFO] Menjalankan server...
python app.py

pause
