# UAS Praktikum Pemrograman Mobile — E-Commerce App

## Identitas

| | |
|---|---|
| **Nama** | _(Rosdiana Putri Purwani)_ |
| **NIM** | _(2306003)_ |
| **Kelas** | _(A)_ |
| **Mata Kuliah** | Praktikum Pemrograman Mobile |
| **Tahun Akademik** | Genap 2025/2026 |

---

## Deskripsi Aplikasi

Aplikasi E-Commerce berbasis Flutter yang mengkonsumsi REST API (backend Node.js + Supabase) untuk fitur autentikasi, katalog produk, keranjang belanja, checkout, riwayat pesanan, dan dashboard admin.

---

## Screenshot Aplikasi

> Tempel screenshot di sini (minimal 5 halaman). Cara nambahin gambar di GitHub README:
> 1. Buat folder `screenshots/` di root project
> 2. Simpan screenshot HP kamu ke folder itu (misal `login.png`, `katalog.png`, dst)
> 3. Tampilkan pakai format: `![Nama Halaman](screenshots/nama_file.png)`

| Halaman | Screenshot |
|---|---|
| Login | ![Login](screenshots/login.png) |
| Katalog Produk | ![Katalog](screenshots/katalog.png) |
| Detail Produk | ![Detail Produk](screenshots/detail_produk.png) |
| Keranjang | ![Keranjang](screenshots/keranjang.png) |
| Checkout | ![Checkout](screenshots/checkout.png) |
| Riwayat Pesanan | ![Riwayat Pesanan](screenshots/riwayat_pesanan.png) |
| Admin Dashboard | ![Admin Dashboard](screenshots/admin_dashboard.png) |

---

## Cara Menjalankan Aplikasi

### 1. Persiapan
```bash
flutter pub get
```

### 2. Konfigurasi Base URL API
Buka `lib/utils/constants.dart`, 

### 3. Jalankan
```bash
flutter run
```

### 4. Build APK Release
```bash
flutter build apk --release
```
File APK ada di `build/app/outputs/flutter-apk/app-release.apk`

### Akun untuk testing
| Role | Email | Password |
|---|---|---|
| Admin | admin@admin.com | admin123 |
| Customer | mahasiswa@test.com | test123456 |

---

## Daftar Fitur yang Diimplementasikan

### Soal 1 — Autentikasi & Profil (15 poin)
- [x] Halaman Register — validasi nama/email/password, redirect ke Login setelah sukses
- [x] Halaman Login — simpan token JWT, auto-login, mode Guest (bisa browsing tanpa login)
- [x] Halaman Profil — lihat & edit profil, logout

### Soal 2 — Katalog Produk (25 poin)
- [x] Daftar Produk — GridView responsif, infinite scroll pagination, format Rupiah
- [x] Pencarian & Filter — search by nama, filter kategori (chip), sorting (termurah/termahal/terbaru)
- [x] Detail Produk — info lengkap, rating & ulasan, form tulis ulasan, tombol tambah ke keranjang

### Soal 3 — Keranjang Belanja (20 poin)
- [x] Halaman Keranjang — list item dengan gambar/harga/qty/subtotal, grand total
- [x] Interaksi Keranjang — tombol +/-, hapus item, kosongkan keranjang (dengan konfirmasi), badge counter, empty state

### Soal 4 — Checkout & Riwayat Pesanan (25 poin)
- [x] Checkout — ringkasan pesanan, form alamat & catatan, dialog konfirmasi, halaman sukses
- [x] Riwayat Pesanan — list dengan pagination, warna berbeda tiap status
- [x] Detail Pesanan — status, alamat, catatan, tanggal, daftar item, total

### Soal 5 — Admin Dashboard (Opsi A) (15 poin)
- [x] Halaman admin terpisah dari user biasa
- [x] Statistik — total produk/pesanan/pendapatan/pelanggan/pesanan pending
- [x] Produk Terlaris — bar chart
- [x] Manajemen Pesanan — filter status, ubah status dengan validasi transisi

---

## Struktur Folder

```
lib/
 ├─ main.dart
 ├─ models/          # Bentuk data (User, Product, Cart, Order, dll)
 ├─ services/        # Logika API & state management (Provider)
 ├─ screens/         # Semua halaman UI
 │   ├─ auth/
 │   ├─ products/
 │   ├─ cart/
 │   ├─ checkout/
 │   ├─ orders/
 │   ├─ admin/
 │   └─ home/
 ├─ widgets/         # Widget reusable
 └─ utils/           # Konstanta, formatter, helper
```

## Package yang Digunakan
`http`, `provider`, `shared_preferences`, `cached_network_image`, `intl`, `flutter_rating_bar`, `shimmer`, `fl_chart`


