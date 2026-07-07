# UAS Mobile — Setup dari Nol

## 1. Buat project Flutter baru

```bash
flutter create uas_mobile
cd uas_mobile
```

Ini bikin folder `uas_mobile` isi file bawaan Flutter (`lib/main.dart`, `pubspec.yaml`, `android/`, `ios/`, dll).

## 2. Timpa dengan file dari folder ini

Download folder yang saya kasih, lalu **copy semua isi `lib/` dan `pubspec.yaml` di sini**, TIMPA yang ada di project barumu. Struktur akhirnya harus seperti ini:

```
uas_mobile/
 ├─ lib/
 │   ├─ main.dart                     # Entry point + pengecekan auto-login
 │   ├─ models/
 │   │   └─ user.dart                 # Bentuk data User
 │   ├─ services/
 │   │   ├─ api_service.dart          # Satu-satunya file yang panggil http
 │   │   ├─ storage_service.dart      # Simpan token di HP
 │   │   └─ auth_provider.dart        # State management modul Auth
 │   ├─ screens/
 │   │   ├─ auth/
 │   │   │   ├─ register_screen.dart
 │   │   │   ├─ login_screen.dart
 │   │   │   └─ profile_screen.dart
 │   │   └─ home/
 │   │       └─ home_screen.dart      # Shell bottom-nav (tab lain nanti Soal 2-4)
 │   └─ utils/
 │       └─ constants.dart            # Base URL & path endpoint
 ├─ test/
 │   └─ widget_test.dart
 └─ pubspec.yaml
```

(Folder `android/`, `ios/`, `web/`, dll biarkan bawaan dari `flutter create`, tidak usah diubah.)

## 3. Install dependency

```bash
flutter pub get
```

## 4. WAJIB — atur base URL dulu

Buka `lib/utils/constants.dart`. Di situ ada 3 opsi base URL (online / lokal-emulator / lokal-HP-fisik). Aktifkan salah satu sesuai server yang kamu pakai sekarang. Baca komentar di file itu.

## 5. Jalankan

Pilih Android Emulator sebagai device (bukan Chrome — web sering bermasalah dan hasil akhir tugas ini kan APK):

```bash
flutter run
```

## Kenapa strukturnya dipisah begini? (biar kamu paham, bukan hafal)

| Folder | Isi | Aturan |
|---|---|---|
| `models/` | Bentuk data (User, nanti Product, Order, dst) | Tidak boleh ada `http` atau widget di sini |
| `services/` | Logika: manggil API, simpan token, state management | Tidak boleh ada widget (`Widget build()`) di sini |
| `screens/` | Tampilan UI | Tidak boleh panggil `http` langsung — selalu lewat `services` |
| `utils/` | Konstanta & helper kecil (format Rupiah, dll nanti) | Dipakai lapisan manapun |

Alurnya selalu: **screen** memanggil fungsi di **service**, **service** memanggil `ApiService`, `ApiService` yang urus HTTP request dan baca format response `{success, message, data}` dari backend, hasilnya dibungkus jadi **model**, lalu dikembalikan ke screen untuk ditampilkan.

## Yang sudah jadi (Soal 1 — 15 poin)

- [x] Register — validasi form, panggil API, redirect ke Login
- [x] Login — simpan token, auto-login, redirect ke Home
- [x] Profile — tampilkan data, edit nama/telepon, logout

## Sebelum lanjut ke Soal 2

Jalankan dulu, coba Register lalu Login pakai server kamu (online atau lokal). Kalau ada error, screenshot pesan error dan log `flutter run`, kirim ke saya biar dicek dulu sebelum lanjut ke modul berikutnya.
