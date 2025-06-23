from flask import Flask, request, render_template, jsonify, send_file
from colorama import Fore, Style, init
from waitress import serve
import os, socket, qrcode, datetime, requests, configparser
from dotenv import load_dotenv
from io import BytesIO

# === Inisialisasi & Konfigurasi Awal ===
init(autoreset=True)
load_dotenv()
app = Flask(__name__)

UPLOAD_FOLDER = "uploads"
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

DISCORD_WEBHOOK_URL = os.getenv("DISCORD_WEBHOOK_URL")

def get_language_mode():
    config = configparser.ConfigParser()
    config.read("config.ini")
    return {
        "1": "kasar",
        "2": "wibu",
        "3": "profesional"
    }.get(config["DEFAULT"].get("kepribadian", "2"), "wibu")

def get_color():
    return {
        "kasar": Fore.LIGHTGREEN_EX,
        "wibu": Fore.LIGHTMAGENTA_EX,
        "profesional": Fore.LIGHTBLUE_EX
    }.get(get_language_mode(), Fore.RESET)

def say(wibu, kasar, profesional):
    mode = get_language_mode()
    if mode == "kasar": return kasar
    if mode == "wibu": return wibu
    return profesional

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        ip = s.getsockname()[0]
    except:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

def generate_qr():
    ip = get_local_ip()
    url = f"http://{ip}:5000"
    qr = qrcode.QRCode(border=1)
    qr.add_data(url)
    qr.make(fit=True)

    print("\n" + get_color() + say(
        "(๑˃ᴗ˂)ﻭ Yatta~! Scan QR ini dari HP kamu ya~",
        "[SCAN] Nih QR Code buat lo, cepet scan pake HP!",
        "[INFO] QR Code tersedia untuk pemindaian melalui HP."
    ))
    qr.print_ascii(invert=True)
    print(f"\n{Style.RESET_ALL}📱 {say('Akses:', 'Buka:', 'Akses:')} {url}")

def ajakan_gabung_discord():
    if get_language_mode() == "kasar":
        print(Fore.LIGHTGREEN_EX + "🔥 Yo! Gabung server Discord kita!\n👉 https://discord.gg/WTAhZ8Z3rA")
    elif get_language_mode() == "wibu":
        print(Fore.LIGHTMAGENTA_EX + "(づ｡◕‿‿◕｡)づ Yuk gabung Discord!\n🌸 https://discord.gg/WTAhZ8Z3rA 🌸")
    else:
        print(Fore.LIGHTBLUE_EX + "📢 Gabung ke server Discord:\n🔗 https://discord.gg/WTAhZ8Z3rA")

def kirim_notif_ke_discord(ip):
    if not DISCORD_WEBHOOK_URL:
        print("[DISCORD] Webhook kosong atau tidak diatur.")
        return
    waktu = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    data = {
        "content": f"⚡ Server dimulai\nIP: {ip}\nWaktu: {waktu}\n⚠️ Info ini dicatat oleh Discord Webhook"
    }
    try:
        res = requests.post(DISCORD_WEBHOOK_URL, json=data)
        if res.status_code == 204:
            print("✅ Notif ke Discord berhasil.")
        else:
            print(f"❌ Gagal kirim Discord. Status: {res.status_code}")
    except Exception as e:
        print(f"❌ Error webhook: {e}")

@app.route('/')
def upload_form():
    files = os.listdir(UPLOAD_FOLDER)
    template_map = {
        "kasar": "hacker.html",
        "wibu": "wibu.html",
        "profesional": "pro.html"
    }
    template_name = template_map.get(get_language_mode(), "wibu.html")
    return render_template(template_name, files=files)

@app.route('/', methods=['POST'])
def upload_file():
    files = request.files.getlist('file')
    processed = []

    for file in files:
        if file and file.filename:
            filename = file.filename
            filepath = os.path.join(UPLOAD_FOLDER, filename)
            file.save(filepath)
            processed.append(filename)
            print(get_color() + say(
                f"(✿◕‿◕) File '{filename}' disimpan ke '{UPLOAD_FOLDER}/'",
                f"[UPLOAD] '{filename}' disimpan di folder '{UPLOAD_FOLDER}/'",
                f"[UPLOAD] File '{filename}' berhasil disimpan."
            ))

    return jsonify(processed)

@app.route('/readme')
def readme():
    return send_file('README.md', mimetype='text/markdown')

if __name__ == '__main__':
    ip = get_local_ip()
    kirim_notif_ke_discord(ip)
    generate_qr()
    ajakan_gabung_discord()
    print(get_color() + say(
        f"꒰｡•ᴗ•｡꒱っ 🌐 Server aktif di: http://{ip}:5000",
        f"[SERVER] Jalan di: http://{ip}:5000",
        f"[SERVER] Server berjalan di: http://{ip}:5000"
    ))
    serve(app, host="0.0.0.0", port=5000)
