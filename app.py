from flask import Flask, request, render_template, jsonify, send_from_directory, send_file
from colorama import Fore, Style, init
from waitress import serve
import os
import socket
import qrcode
import datetime
import requests  # tambahan untuk webhook Discord

init(autoreset=True)
app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

DISCORD_WEBHOOK_URL = "https://discordapp.com/api/webhooks/1386398227624103987/d0VuE0pUbkQXRqMrw3WSkTkJtN95V8Tljf_E-qMhxBRJqmr5q7pF2XrVC_z6wW1pX3PW"

def load_language_mode():
    config_path = "config.ini"
    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            for line in f:
                if line.startswith("kepribadian="):
                    value = line.strip().split("=")[1]
                    if value == "1":
                        return "kasar"
                    elif value == "2":
                        return "wibu"
                    elif value == "3":
                        return "profesional"
    return "wibu"  # default

LANGUAGE_MODE = load_language_mode()

COLOR = {
    "kasar": Fore.LIGHTGREEN_EX,
    "wibu": Fore.LIGHTMAGENTA_EX,
    "profesional": Fore.LIGHTBLUE_EX
}.get(LANGUAGE_MODE, Fore.RESET)

def say(wibu, kasar, profesional):
    if LANGUAGE_MODE == "kasar":
        return kasar
    elif LANGUAGE_MODE == "wibu":
        return wibu
    else:
        return profesional

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        IP = s.getsockname()[0]
    except:
        IP = "127.0.0.1"
    finally:
        s.close()
    return IP

def generate_qr():
    ip = get_local_ip()
    url = f"http://{ip}:5000"
    qr = qrcode.QRCode(border=1)
    qr.add_data(url)
    qr.make(fit=True)

    print("\n" + COLOR + say(
        "(๑˃ᴗ˂)ﻭ Yatta~! Scan QR ini dari HP kamu ya~",
        "[SCAN] Nih QR Code buat lo, cepet scan pake HP!",
        "[INFO] QR Code tersedia untuk pemindaian melalui HP."
    ))
    qr.print_ascii(invert=True)
    print(f"\n{Style.RESET_ALL}📱 {say('Akses:', 'Buka:', 'Akses:')} {url}")

    img = qr.make_image()
    img.save("qr_upload.png")
    print(COLOR + say(
        "QR-nya udah aku simpan juga di file 'qr_upload.png'~",
        "[INFO] QR-nya disimpan di 'qr_upload.png'. Udah tuh.",
        "[INFO] QR Code telah disimpan sebagai 'qr_upload.png'."
    ))

def ajakan_gabung_discord():
    pesan_kasar = f"""
🔥 Yo! Gabung server Discord kita kalo gak mau ketinggalan info!

👉 https://discord.gg/WTAhZ8Z3rA
"""
    pesan_wibu = f"""
(づ｡◕‿‿◕｡)づ Halo~ Yuk gabung Discord kita biar makin seru!

🌸 Link: https://discord.gg/WTAhZ8Z3rA 🌸
"""
    pesan_profesional = f"""
📢 Undangan resmi: Silakan bergabung ke server Discord kami untuk informasi dan diskusi.

🔗 https://discord.gg/WTAhZ8Z3rA
"""
    if LANGUAGE_MODE == "kasar":
        print(Fore.LIGHTGREEN_EX + pesan_kasar)
    elif LANGUAGE_MODE == "wibu":
        print(Fore.LIGHTMAGENTA_EX + pesan_wibu)
    else:
        print(Fore.LIGHTBLUE_EX + pesan_profesional)

def kirim_notif_ke_discord(ip):
    waktu = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    pesan = (
        f"⚡ Server mulai berjalan!\n"
        f"IP: {ip}\n"
        f"Waktu: {waktu}\n\n"
        "⚠️ Perhatian: Discord kami akan mencatat IP dan waktu saat software digunakan."
    )
    data = {"content": pesan}
    try:
        response = requests.post(DISCORD_WEBHOOK_URL, json=data)
        if response.status_code == 204:
            print("✅ Notifikasi berhasil dikirim ke Discord.")
        else:
            print(f"❌ Gagal kirim notifikasi ke Discord, status: {response.status_code}")
    except Exception as e:
        print(f"❌ Error saat kirim notifikasi ke Discord: {e}")

@app.route('/')
def upload_form():
    file_list = os.listdir(UPLOAD_FOLDER)
    template_map = {
        "kasar": "hacker.html",
        "wibu": "wibu.html",
        "profesional": "pro.html"
    }
    template_name = template_map.get(LANGUAGE_MODE, "wibu.html")
    return render_template(template_name, files=file_list)

@app.route('/', methods=['POST'])
def upload_file():
    files = request.files.getlist('file')
    saved_files = []

    for file in files:
        if file and file.filename:
            filepath = os.path.join(UPLOAD_FOLDER, file.filename)
            file.save(filepath)
            saved_files.append(file.filename)
            print(COLOR + say(
                f"(✿◕‿◕) File '{file.filename}' berhasil di-upload~!",
                f"[UPLOAD] File '{file.filename}' udah nyampe.",
                f"[UPLOAD] File '{file.filename}' berhasil diunggah."
            ))

    return jsonify(saved_files)

@app.route('/uploads/<filename>')
def download_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename, as_attachment=True)

@app.route('/readme')
def readme():
    return send_file('README.md', mimetype='text/markdown')

if __name__ == '__main__':
    ip = get_local_ip()
    kirim_notif_ke_discord(ip)  # Kirim notif ke Discord saat server start
    generate_qr()
    ajakan_gabung_discord()
    print(COLOR + say(
        f"꒰｡•ᴗ•｡꒱っ 🌐 Server aktif di: http://{ip}:5000",
        f"[SERVER] Jalan di: http://{ip}:5000",
        f"[SERVER] Server berjalan di: http://{ip}:5000"
    ))
    serve(app, host="0.0.0.0", port=5000)
