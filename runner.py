import subprocess
import os

def run_launcher():
    # Pastikan path file .bat sesuai lokasi file launcher.bat
    bat_path = os.path.join(os.getcwd(), "launcher.bat")

    try:
        # Menjalankan launcher.bat dan menunggu selesai
        subprocess.run([bat_path], check=True, shell=True)
        print("launcher.bat berhasil dijalankan.")
    except subprocess.CalledProcessError as e:
        print(f"Terjadi kesalahan saat menjalankan launcher.bat: {e}")

if __name__ == "__main__":
    run_launcher()
