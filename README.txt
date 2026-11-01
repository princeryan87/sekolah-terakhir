SEKOLAH TERAKHIR: jam 00:00  (Tahap 0 + 1, prototype)
======================================================

ISI
- Proyek Godot 4.3 (renderer Compatibility), semua objek dibuat lewat kode.
- Alur prototype: bersihkan kelas 9B (3 sampah) -> listrik mati, jam 00:00 ->
  cari kunci lobi di kelas 9A -> jumpscare Kuntilanak -> buka pintu lobi -> tamat.

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
