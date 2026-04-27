# Dokumen Requirements

## Pendahuluan

NutriBunda adalah aplikasi mobile Flutter yang berfungsi sebagai asisten pendamping ibu dalam memantau gizi MPASI (Makanan Pendamping ASI) anak usia 6–24 bulan, sekaligus mendukung program diet pemulihan pasca-melahirkan bagi ibu. Aplikasi ini menggunakan backend mandiri berbasis Golang dengan PostgreSQL, autentikasi JWT, dan mengintegrasikan berbagai fitur seperti chatbot AI, sensor perangkat, peta lokasi, notifikasi, serta mini game edukatif.

---

## Glosarium

- **NutriBunda**: Nama aplikasi mobile yang dikembangkan dengan Flutter.
- **Pengguna**: Ibu yang menggunakan aplikasi NutriBunda.
- **Bayi**: Anak usia 6–24 bulan yang sedang menjalani program MPASI.
- **MPASI**: Makanan Pendamping ASI, makanan yang diberikan kepada bayi usia 6–24 bulan selain ASI.
- **Auth_Service**: Komponen backend Golang yang menangani autentikasi, registrasi, dan manajemen sesi JWT.
- **JWT**: JSON Web Token, token berbasis standar RFC 7519 yang digunakan sebagai bukti autentikasi sesi pengguna.
- **Secure_Storage**: Penyimpanan terenkripsi di perangkat Flutter (flutter_secure_storage) untuk menyimpan JWT.
- **Biometric_Service**: Komponen Flutter yang menggunakan paket local_auth untuk autentikasi sidik jari dan Face ID.
- **Database_Service**: Komponen yang mengelola koneksi dan operasi ke PostgreSQL di backend dan SQLite lokal di perangkat.
- **Food_Database**: Kumpulan data makanan beserta kandungan nutrisinya (Kalori, Protein, Karbohidrat, Lemak) yang di-generate oleh AI dan disimpan di PostgreSQL.
- **Nutrition_Tracker**: Komponen yang menghitung dan merangkum asupan nutrisi harian bayi dan ibu.
- **Food_Diary**: Fitur pencatatan makanan harian untuk bayi dan ibu.
- **Diet_Plan**: Fitur rekomendasi dan pemantauan kalori harian ibu berdasarkan kondisi tubuh dan aktivitas fisik, menggunakan kalkulasi BMR dan TDEE.
- **BMR**: Basal Metabolic Rate, jumlah kalori minimum yang dibutuhkan tubuh untuk menjalankan fungsi dasar saat istirahat total.
- **TDEE**: Total Daily Energy Expenditure, total kalori yang dibutuhkan tubuh per hari berdasarkan BMR dan tingkat aktivitas fisik.
- **Pedometer_Service**: Komponen Flutter yang membaca data langkah kaki dari sensor perangkat.
- **Accelerometer_Service**: Komponen Flutter yang membaca data akselerometer dari sensor perangkat.
- **LBS_Service**: Komponen Location-Based Service yang menggunakan GPS untuk mendapatkan lokasi pengguna dan membuka Google Maps eksternal melalui deep link untuk pencarian fasilitas kesehatan terdekat.
- **TanyaBunda_AI**: Fitur chatbot berbasis LLM (Gemini API) sebagai konsultan gizi dan validator mitos/fakta MPASI.
- **Notification_Service**: Komponen yang mengelola pengiriman notifikasi lokal menggunakan flutter_local_notifications.
- **Quiz_Game**: Fitur mini game trivia "Kuis Gizi Bunda" untuk edukasi gizi.
- **Profile_Service**: Komponen yang mengelola data profil pengguna termasuk foto profil.
- **Zona_Waktu**: Zona waktu Indonesia yang didukung: WIB (UTC+7), WITA (UTC+8), WIT (UTC+9).

---

## Requirements

### Requirement 1: Registrasi dan Login Pengguna

**User Story:** Sebagai ibu baru, saya ingin mendaftar dan masuk ke aplikasi dengan aman, sehingga data pribadi dan data gizi anak saya terlindungi.

#### Acceptance Criteria

1. THE Auth_Service SHALL menerima data registrasi berupa nama lengkap, alamat email, dan password dari pengguna.
2. WHEN pengguna mendaftar, THE Auth_Service SHALL mem-hash password menggunakan algoritma bcrypt sebelum menyimpannya ke PostgreSQL.
3. WHEN pengguna melakukan login dengan email dan password yang valid, THE Auth_Service SHALL menerbitkan JWT dengan masa berlaku yang ditentukan dan mengembalikannya ke aplikasi.
4. WHEN JWT diterima oleh aplikasi, THE Secure_Storage SHALL menyimpan JWT di penyimpanan terenkripsi perangkat.
5. IF pengguna memasukkan email atau password yang tidak valid saat login, THEN THE Auth_Service SHALL mengembalikan pesan kesalahan yang deskriptif tanpa mengungkap detail keamanan internal.
6. WHEN JWT pengguna telah kedaluwarsa, THE Auth_Service SHALL menolak permintaan API dan mengembalikan status tidak terautentikasi sehingga aplikasi mengarahkan pengguna ke halaman login.
7. WHEN pengguna menekan tombol Logout, THE Secure_Storage SHALL menghapus JWT dari penyimpanan terenkripsi dan aplikasi SHALL mengarahkan pengguna ke halaman login.

---

### Requirement 2: Autentikasi Biometrik

**User Story:** Sebagai ibu yang sering menggendong bayi, saya ingin masuk ke aplikasi menggunakan sidik jari atau Face ID, sehingga saya bisa mengakses aplikasi hanya dengan satu tangan.

#### Acceptance Criteria

1. WHEN pengguna membuka aplikasi setelah sesi sebelumnya aktif, THE Biometric_Service SHALL menawarkan opsi autentikasi biometrik jika perangkat mendukung sidik jari atau Face ID.
2. WHEN pengguna berhasil terautentikasi melalui biometrik, THE Biometric_Service SHALL mengambil JWT yang tersimpan dari Secure_Storage dan melanjutkan sesi pengguna.
3. IF perangkat tidak mendukung autentikasi biometrik, THEN THE Biometric_Service SHALL menonaktifkan opsi biometrik dan menampilkan hanya opsi login dengan email dan password.
4. IF autentikasi biometrik gagal sebanyak 3 kali berturut-turut, THEN THE Biometric_Service SHALL menonaktifkan sementara opsi biometrik dan mengarahkan pengguna ke login dengan email dan password.
5. WHERE pengguna mengaktifkan fitur biometrik di pengaturan, THE Biometric_Service SHALL meminta konfirmasi password sekali sebelum mengaktifkan autentikasi biometrik.

---

### Requirement 3: Database Makanan dan Nutrisi

**User Story:** Sebagai pengguna, saya ingin mengakses database makanan MPASI beserta kandungan nutrisinya, sehingga saya dapat memilih makanan yang tepat untuk bayi dan diri saya sendiri.

#### Acceptance Criteria

1. THE Food_Database SHALL menyimpan data makanan yang mencakup minimal: nama makanan, kategori (MPASI/makanan ibu), Kalori (kkal), Protein (gram), Karbohidrat (gram), dan Lemak (gram) per 100 gram sajian.
2. WHEN pengguna mencari makanan berdasarkan nama, THE Database_Service SHALL mengembalikan daftar makanan yang relevan dari Food_Database dalam waktu kurang dari 2 detik.
3. WHILE perangkat tidak terhubung ke internet, THE Database_Service SHALL melayani permintaan pencarian makanan dari salinan lokal Food_Database yang tersimpan di SQLite perangkat.
4. WHEN aplikasi pertama kali dijalankan setelah instalasi dan perangkat terhubung ke internet, THE Database_Service SHALL mengunduh dan menyimpan salinan Food_Database ke SQLite lokal perangkat.
5. WHEN Food_Database di server diperbarui dan perangkat terhubung ke internet, THE Database_Service SHALL menyinkronkan salinan lokal dengan data terbaru dari server.

---

### Requirement 4: Food Diary – Pencatatan Makanan Harian

**User Story:** Sebagai pengguna, saya ingin mencatat makanan yang dikonsumsi bayi dan diri saya setiap hari, sehingga saya dapat memantau asupan nutrisi secara akurat.

#### Acceptance Criteria

1. THE Food_Diary SHALL memungkinkan pengguna mencatat makanan untuk dua profil terpisah: profil Bayi dan profil Ibu.
2. WHEN pengguna menambahkan entri makanan, THE Food_Diary SHALL memungkinkan pengguna memilih makanan dari Food_Database atau memasukkan data makanan secara manual beserta kandungan nutrisinya.
3. WHEN entri makanan ditambahkan, THE Nutrition_Tracker SHALL menghitung dan memperbarui total Kalori, Protein, Karbohidrat, dan Lemak harian untuk profil yang bersangkutan.
4. THE Food_Diary SHALL mengkategorikan entri makanan harian ke dalam slot waktu: Makan Pagi, Makan Siang, Makan Malam, dan Makanan Selingan.
5. WHEN pengguna menghapus entri makanan, THE Nutrition_Tracker SHALL mengurangi total nutrisi harian sesuai dengan kandungan nutrisi entri yang dihapus.
6. THE Food_Diary SHALL menampilkan ringkasan nutrisi harian (Kalori, Protein, Karbohidrat, Lemak) di halaman Dashboard (Home).

---

### Requirement 5: Diet Plan Ibu Pasca-Melahirkan

**User Story:** Sebagai ibu pasca-melahirkan, saya ingin memantau aktivitas fisik dan asupan kalori saya berdasarkan kondisi tubuh saya yang sebenarnya, sehingga saya dapat menjalani program pemulihan berat badan secara sehat dan aman.

#### Acceptance Criteria

1. WHEN pengguna mengaktifkan fitur Diet Plan, THE Diet_Plan SHALL menghitung BMR (Basal Metabolic Rate) menggunakan formula Mifflin-St Jeor berdasarkan berat badan (kg), tinggi badan (cm), dan usia (tahun) pengguna dengan rumus: BMR = (10 × berat_badan_kg) + (6,25 × tinggi_badan_cm) − (5 × usia_tahun) − 161.
2. WHEN BMR berhasil dihitung, THE Diet_Plan SHALL menghitung TDEE (Total Daily Energy Expenditure) dengan mengalikan BMR dengan faktor aktivitas fisik yang dipilih pengguna: Sedentary (×1,2), Lightly Active (×1,375), atau Moderately Active (×1,55).
3. WHEN TDEE berhasil dihitung, THE Diet_Plan SHALL menetapkan target kalori harian dengan menerapkan defisit kalori yang aman sebesar maksimal 500 kkal di bawah TDEE, sehingga target kalori minimum tidak kurang dari TDEE dikurangi 500 kkal.
4. WHERE pengguna mengaktifkan status menyusui, THE Diet_Plan SHALL menambahkan 300 hingga 500 kkal ke target kalori harian untuk memenuhi kebutuhan energi tambahan selama menyusui.
5. WHEN pengguna memperbarui data berat badan, tinggi badan, usia, tingkat aktivitas, atau status menyusui di profil, THE Diet_Plan SHALL menghitung ulang BMR, TDEE, dan target kalori harian secara otomatis.
6. WHILE fitur Diet Plan aktif, THE Pedometer_Service SHALL menghitung jumlah langkah kaki pengguna secara real-time menggunakan sensor perangkat.
7. WHEN data langkah kaki diperbarui, THE Diet_Plan SHALL menghitung estimasi kalori yang terbakar berdasarkan jumlah langkah kaki dan berat badan pengguna menggunakan formula standar (1 langkah ≈ 0,04 kkal per kg berat badan).
8. THE Diet_Plan SHALL menampilkan ringkasan harian yang mencakup: target kalori (hasil kalkulasi TDEE dan defisit), nilai BMR, nilai TDEE, kalori dari makanan (dari Food_Diary ibu), kalori terbakar dari langkah kaki, dan sisa kalori.
9. THE Diet_Plan SHALL menampilkan progress bar visual kalori harian yang menunjukkan persentase kalori yang telah dikonsumsi terhadap target kalori, dengan kode warna: hijau (0–80% target), kuning (81–100% target), dan merah (lebih dari 100% target).
10. IF total kalori dari makanan melebihi target kalori harian, THEN THE Diet_Plan SHALL menampilkan peringatan visual kepada pengguna beserta selisih kalori yang melebihi target.
11. IF data berat badan, tinggi badan, atau usia pengguna belum tersedia di profil, THEN THE Diet_Plan SHALL menampilkan pesan yang mengarahkan pengguna untuk melengkapi data profil sebelum fitur Diet Plan dapat digunakan.

---

### Requirement 6: Shake-to-Recipe (Sensor Akselerometer)

**User Story:** Sebagai pengguna, saya ingin mendapatkan rekomendasi resep MPASI secara acak dengan menggoyangkan smartphone, sehingga saya mendapat inspirasi menu baru dengan cara yang menyenangkan.

#### Acceptance Criteria

1. WHILE aplikasi aktif di layar depan (foreground), THE Accelerometer_Service SHALL memantau data akselerometer perangkat secara terus-menerus.
2. WHEN akselerasi perangkat melebihi ambang batas 15 m/s² pada salah satu sumbu selama minimal 300 milidetik, THE Accelerometer_Service SHALL memicu peristiwa "shake terdeteksi".
3. WHEN peristiwa "shake terdeteksi" dipicu, THE NutriBunda SHALL menampilkan satu resep MPASI yang dipilih secara acak dari Food_Database.
4. THE NutriBunda SHALL menampilkan detail resep yang mencakup: nama resep, bahan-bahan, langkah memasak, dan informasi nutrisi per sajian.
5. WHEN resep ditampilkan setelah shake, THE NutriBunda SHALL memungkinkan pengguna menyimpan resep tersebut ke daftar resep favorit.
6. IF peristiwa "shake terdeteksi" dipicu dalam waktu kurang dari 3 detik setelah shake sebelumnya, THEN THE Accelerometer_Service SHALL mengabaikan peristiwa tersebut untuk mencegah pemicu berulang yang tidak disengaja.

---

### Requirement 7: Resep Favorit

**User Story:** Sebagai pengguna, saya ingin menyimpan resep MPASI favorit saya, sehingga saya dapat mengaksesnya kembali dengan mudah kapan saja.

#### Acceptance Criteria

1. WHEN pengguna menekan tombol simpan pada sebuah resep, THE Database_Service SHALL menyimpan resep tersebut ke daftar resep favorit pengguna di PostgreSQL.
2. THE NutriBunda SHALL menampilkan daftar semua resep favorit yang telah disimpan oleh pengguna.
3. WHEN pengguna menghapus resep dari daftar favorit, THE Database_Service SHALL menghapus entri resep tersebut dari daftar favorit pengguna.
4. WHILE perangkat tidak terhubung ke internet, THE Database_Service SHALL menampilkan resep favorit dari salinan lokal yang tersimpan di SQLite perangkat.

---

### Requirement 8: Location-Based Service (LBS) – Pencarian Fasilitas Kesehatan

**User Story:** Sebagai pengguna, saya ingin menemukan fasilitas kesehatan terdekat seperti Posyandu dan Puskesmas, sehingga saya dapat dengan mudah mengakses layanan kesehatan untuk bayi dan diri saya.

#### Acceptance Criteria

1. WHEN pengguna membuka fitur LBS, THE LBS_Service SHALL meminta izin akses lokasi perangkat kepada pengguna.
2. WHEN izin lokasi diberikan, THE LBS_Service SHALL mendapatkan koordinat GPS pengguna saat ini menggunakan paket geolocator.
3. THE LBS_Service SHALL menampilkan antarmuka pemilihan kategori fasilitas kesehatan yang mencakup: Rumah Sakit, Puskesmas, Posyandu, dan Apotek.
4. WHEN pengguna memilih salah satu kategori fasilitas, THE LBS_Service SHALL membuka aplikasi Google Maps eksternal menggunakan deep link dengan query pencarian untuk kategori yang dipilih di sekitar lokasi GPS pengguna.
5. THE LBS_Service SHALL memformat deep link Google Maps dengan parameter: koordinat GPS pengguna dan query pencarian kategori fasilitas yang dipilih.
6. IF aplikasi Google Maps tidak terinstal di perangkat, THEN THE LBS_Service SHALL membuka Google Maps melalui browser web dengan parameter pencarian yang sama.
7. IF izin lokasi ditolak oleh pengguna, THEN THE LBS_Service SHALL menampilkan pesan yang menjelaskan bahwa izin lokasi diperlukan untuk menggunakan fitur ini dan mengarahkan pengguna ke pengaturan perangkat.

---

### Requirement 9: TanyaBunda AI – Chatbot Konsultan Gizi

**User Story:** Sebagai pengguna, saya ingin bertanya kepada asisten AI tentang gizi MPASI dan memvalidasi mitos seputar pemberian makan bayi, sehingga saya mendapat informasi yang akurat dan terpercaya.

#### Acceptance Criteria

1. THE TanyaBunda_AI SHALL menyediakan antarmuka percakapan (chat) di mana pengguna dapat mengirimkan pertanyaan dalam Bahasa Indonesia.
2. WHEN pengguna mengirimkan pertanyaan, THE TanyaBunda_AI SHALL mengirimkan pertanyaan beserta konteks sesi percakapan ke Gemini API dan menampilkan respons dalam waktu kurang dari 10 detik.
3. THE TanyaBunda_AI SHALL membatasi topik percakapan pada domain gizi MPASI, kesehatan bayi usia 6–24 bulan, dan diet pemulihan ibu pasca-melahirkan.
4. IF Gemini API tidak dapat dijangkau, THEN THE TanyaBunda_AI SHALL menampilkan pesan kesalahan yang informatif dan menyarankan pengguna untuk memeriksa koneksi internet.
5. THE TanyaBunda_AI SHALL menampilkan peringatan bahwa respons AI bukan pengganti konsultasi medis profesional pada setiap sesi percakapan baru.
6. THE TanyaBunda_AI SHALL menyimpan riwayat percakapan sesi aktif sehingga pengguna dapat menggulir ke atas untuk membaca percakapan sebelumnya.

---

### Requirement 10: Mini Game – Kuis Gizi Bunda

**User Story:** Sebagai pengguna, saya ingin bermain kuis tentang kandungan gizi makanan, sehingga saya dapat belajar tentang nutrisi dengan cara yang menyenangkan.

#### Acceptance Criteria

1. THE Quiz_Game SHALL menyajikan pertanyaan trivia pilihan ganda seputar kandungan gizi makanan yang bersumber dari Food_Database.
2. WHEN sesi kuis dimulai, THE Quiz_Game SHALL memilih 10 pertanyaan secara acak dari kumpulan pertanyaan yang tersedia.
3. WHEN pengguna menjawab pertanyaan dengan benar, THE Quiz_Game SHALL menambahkan 10 poin ke skor sesi berjalan.
4. WHEN pengguna menjawab pertanyaan dengan salah, THE Quiz_Game SHALL menampilkan jawaban yang benar beserta penjelasan singkat.
5. WHEN sesi kuis selesai (10 pertanyaan terjawab), THE Quiz_Game SHALL menampilkan skor akhir dan menyimpan skor tertinggi (high score) ke penyimpanan lokal perangkat.
6. THE Quiz_Game SHALL menampilkan papan skor lokal yang memuat riwayat 5 skor tertinggi pengguna.
7. WHEN pengguna memulai sesi kuis baru, THE Quiz_Game SHALL memastikan urutan dan pilihan pertanyaan berbeda dari sesi sebelumnya.

---

### Requirement 11: Notifikasi Pengingat

**User Story:** Sebagai pengguna, saya ingin menerima pengingat jadwal makan MPASI bayi dan jadwal minum vitamin, sehingga saya tidak melewatkan waktu pemberian makan atau suplemen penting.

#### Acceptance Criteria

1. THE Notification_Service SHALL mengirimkan notifikasi lokal pengingat jadwal makan MPASI bayi pada waktu default: 07.00, 12.00, 17.00, dan 19.00 sesuai zona waktu yang dipilih pengguna.
2. THE Notification_Service SHALL mengirimkan notifikasi lokal pengingat minum vitamin ibu pada waktu yang dapat diatur oleh pengguna.
3. WHEN pengguna mengatur jadwal notifikasi, THE Notification_Service SHALL memungkinkan pengguna memilih zona waktu: WIB (UTC+7), WITA (UTC+8), atau WIT (UTC+9).
4. WHEN zona waktu dipilih, THE Notification_Service SHALL menyesuaikan waktu pengiriman semua notifikasi aktif sesuai zona waktu yang dipilih.
5. WHEN pengguna menonaktifkan notifikasi tertentu, THE Notification_Service SHALL membatalkan jadwal notifikasi tersebut tanpa memengaruhi notifikasi lain yang aktif.
6. IF izin notifikasi tidak diberikan oleh sistem operasi perangkat, THEN THE Notification_Service SHALL menampilkan panduan kepada pengguna untuk mengaktifkan izin notifikasi di pengaturan perangkat.

---

### Requirement 12: Profil Pengguna

**User Story:** Sebagai pengguna, saya ingin mengelola profil saya termasuk foto profil dan data pribadi, sehingga aplikasi dapat memberikan rekomendasi yang dipersonalisasi.

#### Acceptance Criteria

1. THE Profile_Service SHALL menampilkan halaman profil yang memuat: foto profil, nama lengkap, email, berat badan, tinggi badan, usia, dan status menyusui pengguna.
2. WHEN pengguna memperbarui foto profil, THE Profile_Service SHALL memungkinkan pengguna memilih gambar dari galeri perangkat atau mengambil foto langsung menggunakan kamera perangkat.
3. WHEN foto profil baru dipilih atau diambil, THE Profile_Service SHALL mengompresi gambar ke ukuran maksimal 500 KB sebelum menyimpannya ke server.
4. WHEN pengguna menyimpan perubahan data profil, THE Profile_Service SHALL memvalidasi bahwa berat badan berada dalam rentang 30–200 kg dan tinggi badan berada dalam rentang 100–250 cm sebelum menyimpan data.
5. IF data profil yang dimasukkan tidak valid, THEN THE Profile_Service SHALL menampilkan pesan kesalahan yang spesifik untuk setiap field yang tidak valid.

---

### Requirement 13: Navigasi Utama Aplikasi

**User Story:** Sebagai pengguna, saya ingin berpindah antar fitur utama aplikasi dengan mudah, sehingga saya dapat mengakses semua fungsi yang saya butuhkan secara efisien.

#### Acceptance Criteria

1. THE NutriBunda SHALL menampilkan bottom navigation bar yang memuat empat tab: Home (Dashboard), Diary (Pencatatan Makanan), Peta (LBS), dan Profil.
2. WHEN pengguna menekan tab Home, THE NutriBunda SHALL menampilkan dashboard yang memuat ringkasan nutrisi harian bayi, ringkasan Diet Plan ibu, dan akses cepat ke fitur TanyaBunda AI.
3. WHEN pengguna menekan tab Diary, THE NutriBunda SHALL menampilkan halaman Food_Diary dengan pilihan untuk beralih antara profil Bayi dan profil Ibu.
4. WHEN pengguna menekan tab Peta, THE NutriBunda SHALL menampilkan halaman LBS_Service dengan peta interaktif.
5. WHEN pengguna menekan tab Profil, THE NutriBunda SHALL menampilkan halaman profil pengguna beserta tombol Logout.
6. WHILE pengguna berada di halaman manapun dalam aplikasi, THE NutriBunda SHALL menampilkan bottom navigation bar secara konsisten.
