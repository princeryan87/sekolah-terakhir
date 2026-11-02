THE LAST (jam 00:00) - Zip Fondasi (Menu 10 misi + Misi 1 + Misi 2)
====================================================================

PENTING (SEKALI SAJA): UNINSTALL APK LAMA
APK sebelumnya ditandatangani kunci yang berbeda tiap build. Mulai versi ini kunci TETAP
(debug.keystore di repo). Uninstall aplikasi lama sekali, lalu pasang APK baru.
Setelah itu update berikutnya bisa langsung menimpa tanpa uninstall, dan progres misi
tersimpan. Jangan ganti debug.keystore dan jangan ubah package/unique_name.

CARA UNGGAH (juga untuk zip misi berikutnya)
1. Ekstrak zip. Buka repo GitHub > Add file > Upload files.
2. Seret SEMUA isi hasil ekstrak (termasuk folder .github). File bernama sama tertimpa.
3. Commit SEKALI. Build berjalan otomatis di tab Actions.
4. APK: build hijau > Artifacts > sekolah-terakhir-apk.
File lama yang tidak ada di zip dibiarkan (tidak dihapus). Folder audio/ milikmu aman.
Catatan: scripts/pemain.gd, scripts/util.gd, shaders/ps1.gdshader, main.tscn tidak berubah.
File lama icon.svg boleh dibiarkan atau dihapus.

APA YANG BARU
- Nama THE LAST dan ikon dari gambarmu.
- Menu 10 misi: misi terkunci diberi gembok. Selesaikan misi untuk membuka misi berikutnya.
  Misi yang filenya belum ada tampil "SEGERA". Misi baru muncul otomatis tiap zip misi diunggah.
- Simpan per misi: misi yang punya titik simpan menampilkan pilihan LANJUTKAN / ULANGI DARI AWAL.
- Tertangkap: KIRI = coba lagi, KANAN = kembali ke menu.
- Kode dipecah modular. Lihat PANDUAN_KODE.txt (tempel ke chat baru bila perlu).

KONTROL
Joystick kiri: jalan. Geser layar kanan: melihat. AKSI: ambil/buka/sembunyi. LARI: tahan. SENTER.
Tes di komputer: WASD, panah (lihat), E aksi, F senter, Shift lari.

PENGATURAN (edit di editor web GitHub)
- scripts/main.gd  : const PENGECIL = 3  (2 lebih tajam, 4 lebih kasar)
- scripts/util.gd  : const EFEK_PS1 = true -> false jika kotak tidak muncul / layar hitam
- scripts/guru.gd  : kec_kejar, kec_patroli, jarak_lihat (kesulitan Sang Guru)

SUARA
Semua suara dibuat lewat kode. Taruh file bernama sama di audio/ untuk menggantikan.
Daftar nama: audio/list.txt (tidak ada suara baru di zip ini).
