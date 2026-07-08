# 🛒 UAS Praktikum Pemrograman Mobile - E-Commerce App

Aplikasi E-Commerce berbasis **Flutter** yang menggunakan **REST API**, **Node.js**, dan **Supabase** sebagai backend dan database.

---

# 👨‍🎓 Identitas Mahasiswa

| Keterangan | Data |
|------------|------|
| **Nama** | Rosdiana Putri Purwani |
| **NIM** | 2306003 |
| **Mata Kuliah** | Praktikum Pemrograman Mobile |
| **Universitas** | Institut Teknologi Garut |

---

# 📖 Deskripsi Aplikasi

Aplikasi ini merupakan sistem **E-Commerce** yang dikembangkan menggunakan Flutter sebagai frontend, Node.js sebagai backend, dan Supabase sebagai database.

Aplikasi memungkinkan pengguna melakukan proses belanja secara online mulai dari registrasi akun, melihat katalog produk, menambahkan produk ke keranjang, checkout, melihat riwayat pesanan, hingga mengelola profil pengguna.

Selain itu tersedia dashboard admin yang dapat digunakan untuk melihat statistik aplikasi dan mengelola status pesanan pelanggan.

---

# ✨ Fitur Aplikasi

## 👤 User

- Login
- Register akun
- Logout
- Melihat katalog produk
- Pencarian produk
- Filter kategori produk
- Detail produk
- Menambahkan produk ke keranjang
- Mengubah jumlah produk
- Menghapus produk dari keranjang
- Checkout
- Riwayat pesanan
- Melihat status pesanan
- Edit profil
- Update nomor telepon

---

## 👨‍💼 Admin

- Dashboard Statistik
- Total Produk
- Total Pesanan
- Total Pendapatan
- Total Pelanggan
- Manajemen Pesanan
- Filter Status Pesanan
- Update Status Pesanan
- Logout

---

# 🛠️ Teknologi

### Frontend

- Flutter
- Dart
- Provider

### Backend

- Node.js
- Express.js

### Database

- Supabase PostgreSQL

### API

- REST API

---

# 📱 Screenshot Aplikasi

## Register

![Register](screenshots/register.png)

---

## Katalog Produk

![Katalog Produk](screenshots/katalog_produk.png)

---

## Keranjang

![Keranjang](screenshots/keranjang.png)

---

## Riwayat Pesanan

![Riwayat Pesanan](screenshots/riwayat_pesanan.png)

---

## Profil

![Profil](screenshots/profil.png)

---

## Edit Profil

![Edit Profil](screenshots/edit_profil.png)

---

## Dashboard Admin

![Dashboard Admin](screenshots/admin_dashboard.png)

---

## Manajemen Pesanan Admin

![Manajemen Pesanan](screenshots/manajemen_pesanan.png)

---

## Logout Admin

![Logout Admin](screenshots/logout_admin.png)

---

# 🚀 Cara Menjalankan Aplikasi

## 1. Clone Repository

```bash
git clone https://github.com/RosdianaPutri01/2306003_UAS_MOBILE_ROSDIANA.git
```

## 2. Masuk ke Folder Project

```bash
cd 2306003_UAS_MOBILE_ROSDIANA
```

## 3. Install Dependency Flutter

```bash
flutter pub get
```

## 4. Install Dependency Backend

```bash
cd backend
npm install
```

## 5. Jalankan Backend

```bash
npm start
```

## 6. Jalankan Flutter

```bash
flutter run
```

> **Catatan**
>
> Jika menggunakan emulator Android atau perangkat fisik, ubah `baseUrl` pada file konfigurasi API agar sesuai dengan alamat IP server backend.

---

# 📂 Struktur Project

```
2306003_UAS_MOBILE_ROSDIANA
│
├── backend/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── utils/
│   ├── server.js
│   └── package.json
│
├── lib/
│   ├── models/
│   ├── screens/
│   ├── providers/
│   ├── services/
│   ├── widgets/
│   ├── utils/
│   └── main.dart
│
├── assets/
├── screenshots/
├── pubspec.yaml
└── README.md
```

---

# ✅ Hasil Implementasi

Aplikasi berhasil diimplementasikan menggunakan Flutter dengan arsitektur REST API. Seluruh proses utama seperti autentikasi pengguna, katalog produk, keranjang belanja, checkout, riwayat pesanan, pengelolaan profil, dashboard admin, dan manajemen pesanan telah berjalan sesuai kebutuhan aplikasi.

---

# 📌 Repository

Repository GitHub:

**https://github.com/RosdianaPutri01/2306003_UAS_MOBILE_ROSDIANA**

---

# 👩‍💻 Author

**Rosdiana Putri Purwani**

**NIM : 2306003**

Institut Teknologi Garut

Praktikum Pemrograman Mobile
