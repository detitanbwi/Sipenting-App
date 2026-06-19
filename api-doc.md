# SiPenting API Documentation (Hosted)

> Dokumentasi lengkap API **SiPenting** — Sistem Informasi Kesehatan Ibu dan Anak Kabupaten Bondowoso.
>
> API ini menyediakan layanan manajemen data kesehatan meliputi autentikasi pengguna, profil ibu, data bayi, kalkulator gizi, informasi posyandu, deteksi risiko stunting, serta artikel kesehatan.

---

## 📌 Base URL

| Variabel | URL | Keterangan |
|---|---|---|
| `{{baseURL}}` | `https://sipenting.bondowosokab.go.id/api` | Base URL utama |
| `{{domain1}}` | Sama dengan `{{baseURL}}` | Alias untuk beberapa endpoint |

> ⚠️ **Catatan:** Semua request menggunakan format **`form-data`** pada body, kecuali dinyatakan lain.

---

## 🔐 Autentikasi

Sebagian besar endpoint memerlukan autentikasi menggunakan **Bearer Token (JWT)**.
Tambahkan header berikut pada setiap request yang memerlukan autentikasi:

```http
Authorization: Bearer <token>
```

Token diperoleh setelah melakukan login melalui endpoint `POST /login`.

> ℹ️ **Endpoint yang TIDAK memerlukan autentikasi:** `register`, `login`, `kecamatan`, `desa`

---

## 📁 1. Auth
Endpoint untuk manajemen autentikasi pengguna.

### 1.1 Register
| Properti | Detail |
|---|---|
| **Nama** | domainregister |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/register` |
| **Auth** | ❌ Tidak diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `username` | string | NIK pengguna | `3511200804020002` |
| `namaIbu` | string | Nama ibu | `Royan` |
| `id_desa` | string | ID desa domisili | `3511170015` |

---

### 1.2 Login
| Properti | Detail |
|---|---|
| **Nama** | domainsignin |
| **Method** | `POST` |
| **URL** | `https://sipenting.bondowosokab.go.id/api/login` |
| **Auth** | ❌ Tidak diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `username` | string | NIK pengguna | `3511200904020002` |

---

### 1.3 Logout
| Properti | Detail |
|---|---|
| **Nama** | domainlogout |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/logout` |
| **Auth** | ✅ Bearer Token diperlukan |

---

### 1.4 Konsultasi / Kontak
| Properti | Detail |
|---|---|
| **Nama** | Konsultasi Chat Copy |
| **Method** | `GET` |
| **URL** | `{{baseURL}}/kontak` |
| **Auth** | ✅ Bearer Token diperlukan |

---

### 1.5 Daftar Kecamatan
| Properti | Detail |
|---|---|
| **Nama** | kecamatan |
| **Method** | `GET` |
| **URL** | `{{baseURL}}/kecamatan` |
| **Auth** | ❌ Tidak diperlukan |

---

### 1.6 Daftar Desa
| Properti | Detail |
|---|---|
| **Nama** | desa |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/desa` |
| **Auth** | ❌ Tidak diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `id_kecamatan` | string | ID kecamatan | `3511031` |

---

## 📁 2. Profile
Endpoint untuk manajemen profil pengguna (ibu).

### 2.1 Update Profil
| Properti | Detail |
|---|---|
| **Nama** | updateProfile |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/updateProfile` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `username` | string | NIK pengguna | `3510161409020002` |
| `tanggalLahir` | string | Tanggal lahir (YYYY-MM-DD) | `2002-04-09` |
| `namaIbu` | string | Nama ibu | `ando` |
| `bbPraHamil` | string | Berat badan pra-hamil (kg) | `77` |
| `tinggiBadan` | string | Tinggi badan (cm) | `160` |

---

### 2.2 Get User
| Properti | Detail |
|---|---|
| **Nama** | getUser |
| **Method** | `GET` |
| **URL** | `https://sipenting.bondowosokab.go.id/api/getuser` |
| **Auth** | ✅ Bearer Token diperlukan |

---

### 2.3 Get Subscriber OneSignal
| Properti | Detail |
|---|---|
| **Nama** | GetSubsOneSignal |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/getIdSubs` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `id_subs` | string | ID subscriber OneSignal | *(ID unik dari OneSignal)* |

---

## 📁 3. Bayi
Endpoint untuk manajemen data bayi.

### 3.1 Get Bayi
| Properti | Detail |
|---|---|
| **Nama** | getBayi |
| **Method** | `GET` |
| **URL** | `{{domain1}}/bayi` |
| **Auth** | ✅ Bearer Token diperlukan |

---

### 3.2 Tambah Bayi
| Properti | Detail |
|---|---|
| **Nama** | createBayi |
| **Method** | `POST` |
| **URL** | `{{domain1}}/bayi/storeBayi` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `nama` | string | Nama bayi | `iqbal ramadahn` |
| `tanggalLahir` | string | Tanggal lahir (YYYY-MM-DD) | `2023-05-01` |
| `kelamin` | string | Jenis kelamin (`L` = Laki-laki, `P` = Perempuan) | `L` |

---

### 3.3 Update Bayi
| Properti | Detail |
|---|---|
| **Nama** | updateBayi |
| **Method** | `POST` |
| **URL** | `{{domain1}}/bayi/updateBayi` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `nama` | string | Nama bayi | `iqbal ramadahn` |
| `tanggalLahir` | string | Tanggal lahir baru (YYYY-MM-DD) | `2025-11-01` |
| `kelamin` | string | Jenis kelamin (`L` / `P`) | `L` |
| `idBayi` | string | ID bayi yang akan diupdate | *(ID bayi)* |

---

### 3.4 Hapus Bayi
| Properti | Detail |
|---|---|
| **Nama** | deleteBayi |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/bayi/deleteBayi` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `idBayi` | string | ID bayi yang akan dihapus | *(ID bayi)* |

---

## 📁 4. Fitur Gizi
Endpoint untuk kalkulator dan pengecekan status gizi bayi.

### 4.1 Get Daftar Makanan
| Properti | Detail |
|---|---|
| **Nama** | getMakanan |
| **Method** | `GET` |
| **URL** | `{{baseURL}}/kalkulatorGizi` |
| **Auth** | ✅ Bearer Token diperlukan |

---

### 4.2 Cek Gizi (Bayi Terdaftar)
| Properti | Detail |
|---|---|
| **Nama** | cekGizi |
| **Method** | `POST` |
| **URL** | `{{domain1}}/kalkulatorGizi/cekGizi` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `data` | string | JSON array data konsumsi makanan `[[id_makanan, jumlah], ...]` | `[[1,5],[2,0],[3,1],[4,2],[5,9]]` |
| `idBayi` | string | ID bayi | `5577` |

---

### 4.3 Cek Gizi (Tamu / Tanpa Akun)
| Properti | Detail |
|---|---|
| **Nama** | cekGiziGuest |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/kalkulatorGizi/cekGiziGuest` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `data` | string | JSON array data konsumsi makanan `[[id_makanan, jumlah], ...]` | `[[1,11],[2,10],[3,10],[4,10],[5,4]]` |
| `tglLahir` | string | Tanggal lahir bayi (YYYY-M-D) | `2024-1-1` |

---

## 📁 5. Fitur Posyandu
Endpoint untuk manajemen data posyandu dan jadwal kegiatan.

### 5.1 Get Posyandu
| Properti | Detail |
|---|---|
| **Nama** | get posyandu |
| **Method** | `GET` |
| **URL** | `{{domain1}}/posyandu` |
| **Auth** | ✅ Bearer Token diperlukan |

---

### 5.2 Get Posyandu by Bidan
| Properti | Detail |
|---|---|
| **Nama** | get posyandu by bidan |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/posyandu/posyByBidan` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `id_bidan` | string | ID bidan | `5` |

---

### 5.3 Tambah Posyandu
| Properti | Detail |
|---|---|
| **Nama** | createPosyandu |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/posyandu/storePosyandu` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `nama` | string | Nama posyandu | `Posyandu Tamanan` |
| `kontak` | string | Nomor kontak | `81216532315` |
| `lokasi` | string | Lokasi posyandu | `Tamanan` |
| `lat` | string | *(Opsional)* Latitude | *(koordinat)* |
| `lng` | string | *(Opsional)* Longitude | *(koordinat)* |

---

### 5.4 Update Posyandu
| Properti | Detail |
|---|---|
| **Nama** | updatePosyandu |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/posyandu/updatePosyandu` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `nama` | string | Nama posyandu | *(nama baru)* |
| `lokasi` | string | Lokasi posyandu | *(lokasi baru)* |
| `lat` | string | Latitude | *(koordinat)* |
| `lng` | string | Longitude | *(koordinat)* |
| `kontak` | string | Nomor kontak | *(nomor baru)* |
| `idPosyandu` | string | ID posyandu yang diupdate | *(ID posyandu)* |

---

### 5.5 Hapus Posyandu
| Properti | Detail |
|---|---|
| **Nama** | deletePosyandu |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/posyandu/deletePosyandu` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `idPosyandu` | string | ID posyandu yang dihapus | *(ID posyandu)* |

---

### 5.6 Get Jadwal Posyandu
| Properti | Detail |
|---|---|
| **Nama** | get Jadwal |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/posyandu/jadwal` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `id_posyandu` | string | ID posyandu | *(ID posyandu)* |

---

### 5.7 Tambah Jadwal
| Properti | Detail |
|---|---|
| **Nama** | createJadwal |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/posyandu/storeJadwal` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `tanggal` | string | Tanggal jadwal (YYYY-MM-D) | `2024-11-1` |
| `waktu` | string | Waktu jadwal (HH:MM:SS) | `10:40:00` |
| `deskripsi` | string | Deskripsi kegiatan | `Halo Ibu, waktunya posyandu!` |
| `idPosyandu` | string | ID posyandu | *(ID posyandu)* |

---

### 5.8 Update Jadwal
| Properti | Detail |
|---|---|
| **Nama** | updateJadwal |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/posyandu/updateJadwal` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `tanggal` | string | Tanggal jadwal (YYYY-MM-DD) | `2024-07-01` |
| `waktu` | string | Waktu jadwal (HH:MM:SS) | `14:30:00` |
| `deskripsi` | string | Deskripsi kegiatan | *(deskripsi baru)* |
| `idPosyandu` | string | ID posyandu | *(ID posyandu)* |
| `idJadwal` | string | ID jadwal yang diupdate | *(ID jadwal)* |

---

### 5.9 Hapus Jadwal
| Properti | Detail |
|---|---|
| **Nama** | deleteJadwal |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/posyandu/deleteJadwal` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `idJadwal` | string | ID jadwal yang dihapus | *(ID jadwal)* |

---

## 📁 6. Fitur Stunting
Endpoint untuk deteksi dan kalkulasi risiko stunting pada ibu dan anak.

### 6.1 Cek Stunting Ibu
| Properti | Detail |
|---|---|
| **Nama** | cekStuntingIbu |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/kalkulatorStunting/cekStuntingIbu` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `lila` | string | Lingkar lengan atas (cm) | `23` |
| `hb` | string | Kadar hemoglobin (g/dL) | `4` |
| `bbNow` | string | Berat badan sekarang (kg) | `100` |

---

### 6.2 Cek Stunting Anak (Bayi Terdaftar)
| Properti | Detail |
|---|---|
| **Nama** | cekStuntingAnak |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/kalkulatorStunting/cekStuntingAnak` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `tinggiBadan` | string | Tinggi badan anak (cm) | `87` |
| `idBayi` | string | ID bayi | `14` |

---

### 6.3 Cek Stunting Anak (Tamu / Tanpa Akun)
| Properti | Detail |
|---|---|
| **Nama** | cekStuntingAnakGuest |
| **Method** | `POST` |
| **URL** | `{{baseURL}}/kalkulatorStunting/cekStuntingAnakGuest` |
| **Auth** | ✅ Bearer Token diperlukan |

**Parameter Body (form-data):**
| Parameter | Tipe | Keterangan | Contoh |
|---|---|---|---|
| `tinggiBadan` | string | Tinggi badan anak (cm) | `11` |
| `tglLahir` | string | Tanggal lahir anak (YYYY-MM-DD) | `2024-01-01` |

---

## 📁 7. Artikel
Endpoint untuk mengambil konten artikel kesehatan.

### 7.1 Get Artikel
| Properti | Detail |
|---|---|
| **Nama** | get artikel |
| **Method** | `GET` |
| **URL** | `{{baseURL}}/artikel` |
| **Auth** | ✅ Bearer Token diperlukan |

---

## 📝 Catatan Umum

| Hal | Keterangan |
|---|---|
| **Format Body** | Semua request body menggunakan `multipart/form-data` |
| **Format Tanggal** | Umumnya `YYYY-MM-DD`, beberapa endpoint menggunakan `YYYY-M-D` (tanpa leading zero) |
| **Jenis Kelamin** | Gunakan `L` untuk Laki-laki dan `P` untuk Perempuan |
| **Token** | Token JWT diperoleh dari endpoint `/login` dan berlaku selama sesi aktif |
| **`{{domain1}}`** | Merupakan alias dari `{{baseURL}}`, keduanya mengarah ke URL yang sama |

---

*Dokumentasi ini dibuat untuk subfolder **hosted** pada koleksi **SiPenting**.*
*Production URL: `https://sipenting.bondowosokab.go.id/api`*
