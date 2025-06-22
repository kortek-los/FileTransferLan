import os

# Baca mode dari file
lang_mode = 'wibu'
if os.path.exists('language_mode.txt'):
    with open('language_mode.txt', 'r') as f:
        lang_mode = f.read().strip().lower()

# Ganti warna terminal tergantung mode
if os.name == 'nt':  # Hanya Windows
    if lang_mode == 'kasar':
        os.system('color 0A')  # Hijau terang di hitam
    else:
        os.system('color 0D')  # Pink di hitam
