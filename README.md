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

<img width="653" height="912" alt="image" src="https://github.com/user-attachments/assets/38afd622-9ee0-433c-bda6-34fd5dc60c27" />


---

## Katalog Produk

<img width="658" height="912" alt="image" src="https://github.com/user-attachments/assets/710eb225-bf05-4d77-aaf3-3f468e701c9c" />


---

## Keranjang

<img width="652" height="911" alt="image" src="https://github.com/user-attachments/assets/18fd90d6-faab-4cd0-8ba4-764716b9804c" />


---

## Riwayat Pesanan

<img width="651" height="905" alt="image" src="https://github.com/user-attachments/assets/dbec0e59-7d08-4719-945d-56f757158f07" />


---

## Profil

<img width="658" height="911" alt="image" src="https://github.com/user-attachments/assets/52657667-ce9a-4427-9645-ead59dfea82f" />


---

## Edit Profil

<img width="658" height="913" alt="image" src="https://github.com/user-attachments/assets/b81981cf-1278-493f-ab4a-52968d218cbf" />


---

## Dashboard Admin

<img width="652" height="915" alt="image" src="https://github.com/user-attachments/assets/2af74258-b78b-4074-970f-d5c261a95512" />


---

## Manajemen Pesanan Admin

<img width="653" height="903" alt="image" src="https://github.com/user-attachments/assets/c9c1c25b-6c2e-4ade-8394-8d398a2c3f32" />


---

## Logout Admin

<img width="657" height="1013" alt="image" src="https://github.com/user-attachments/assets/3e992093-dc94-4dc9-adf4-17189a9b590f" />


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
