SEKOLAH TERAKHIR: jam 00:00  (Tahap 0 + 1 + 2)
======================================================

ISI
- Proyek Godot 4.3 (renderer Compatibility), semua objek dibuat lewat kode.
- Alur: bersihkan kelas 9B (3 sampah) -> listrik mati, jam 00:00 -> cari kunci lobi
  di kelas 9A -> jumpscare Kuntilanak -> Sang Guru muncul dan berpatroli ->
  buka pintu lobi tanpa ketahuan -> tamat (bersambung ke Tahap 3).
- 3 dokumen cerita tersebar (kelas 9B, dinding lorong, meja guru 9A).

SANG GURU
- Berpatroli di lorong dan kedua kelas. Punya mata dan telinga.
- Mata: melihat lebih jauh jika senter menyala. Butuh beberapa detik menyadari
  kamu (bar DIAWASI di atas layar). Jika bar penuh, dia mengejar.
- Telinga: berlari terdengar jauh, berjalan terdengar dekat, diam tidak terdengar.
  Membuka pintu juga berisik.
- Sembunyi: loker di lorong kanan dan lemari di kelas (tombol AKSI). Jika dia
  melihatmu masuk, dia akan langsung memeriksa tempat itu. Jika tidak, kadang dia
  tetap memeriksa tempat sembunyi dekat tempat terakhir kamu terlihat.
- Berlari lebih cepat dari dia, tapi berisik. Detak jantung makin cepat saat dia dekat.
- Tertangkap: layar TERTANGKAP, lalu mencoba lagi dari kelas 9A.

PENGATUR KESULITAN (scripts/guru.gd, bagian atas)
- KEC_KEJAR = 3.9  (kecepatan kejar; kecepatan lari Raka 4.3)
- KEC_PATROLI = 1.6

CARA UNGGAH KE GITHUB
1. Buat repo baru (misal: sekolah-terakhir), kosong.
2. Ekstrak zip ini. Unggah SEMUA isinya (termasuk folder .github).
   Pastikan file .github/workflows/build.yml ikut terunggah.
3. Settings > Pages > Source: pilih "GitHub Actions".
4. Buka tab Actions. Build berjalan otomatis (butuh beberapa menit).
5. APK: buka build yang hijau > bagian Artifacts > sekolah-terakhir-apk.
   Versi Web: alamat GitHub Pages repo (untuk tes cepat di HP).

JIKA BUILD MERAH
Kirim bagian bawah log pada langkah yang merah.

PENGATURAN YANG BOLEH DIUBAH (edit di editor web GitHub)
- scripts/main.gd   : baris "const PENGECIL = 3"   (2 = lebih tajam, 4 = lebih kasar)
- scripts/util.gd   : baris "const EFEK_PS1 = true" -> ubah ke false jika kotak
                      tidak muncul / layar hitam (mematikan shader PS1)
- export_presets.cfg: package/unique_name (nama paket aplikasi)

KONTROL
- Joystick kiri: jalan. Geser layar kanan: melihat. Tombol AKSI: ambil/buka.
- LARI (tahan), SENTER (muncul setelah listrik mati).
- Tes di komputer: WASD jalan, panah melihat, E aksi, F senter, Shift lari.

SUARA
Lihat audio/list.txt. Semua suara dibuat lewat kode. Kalau kamu menaruh file
dengan nama yang sama di folder audio/, file itu dipakai saat build ulang.
