extends Node

# MISI 9: Kelas 9-X. Ada 5 bangku. Duduki bangku yang menyala untuk membaca ingatannya; itu memanggil satu hantu.
# Bertahan 35 detik sampai hantu menghilang. Urutan hantu: Kuntilanak, Genderuwo, Pocong, hantu siswi, Sang Guru.
# Setelah kelima gelombang, kebenaran terungkap di papan tulis dan pintu ke ruang Kepala Sekolah terbuka.

const JUDUL = "Kelas 9-X"
const RINGKAS = "Kebenaran terungkap. Lima ingatan, lima hantu."

const DURASI = 35.0

const Kelas = preload("res://scripts/kelas_9x.gd")
const Kuntilanak = preload("res://scripts/kuntilanak.gd")
const Genderuwo = preload("res://scripts/genderuwo.gd")
const Pocong = preload("res://scripts/pocong.gd")
const Siswi = preload("res://scripts/hantu_siswi.gd")

const INGATAN = [
    "BANGKU 1: SARI\n\nSari murid pertama yang dikunci karena menolak aturan Kepala Sekolah. Ia menangis di depan cermin toilet sampai suaranya menyatu dengan dinding. Sejak itu cermin tak pernah berhenti bersinar.",
    "BANGKU 2: PAK MANDOR\n\nMandor yang membangun sekolah ini bersumpah menjaganya selamanya. Kepala Sekolah mengabulkannya, dengan harga tubuhnya. Kini ia tumbuh besar di lantai dua dan membenci cahaya.",
    "BANGKU 3: PAK DARTO\n\nPenjaga sekolah yang tahu terlalu banyak. Ia dikubur di lorong bawah, terbungkus kafan, dan diberi satu tugas: jangan biarkan siapa pun lewat saat tak ada yang mengawasinya.",
    "BANGKU 4: DINA\n\nDina menulis semua yang ia lihat di buku harian. Kepala Sekolah memotong suaranya, tetapi ia terus bernyanyi, dan bisikannya kini bercampur antara benar dan dusta.",
    "BANGKU 5: BU WALI KELAS\n\nIa mengira dirinya melindungi muridnya. Nyatanya ia hanya penjaga pintu. Lima belas tahun lalu, satu murid tidak pernah dijemput dan tidak pernah pulang. Murid itu duduk di bangku paling belakang, dan namanya tidak pernah dihapus."
]
const NAMA = ["Kuntilanak", "Genderuwo", "Pocong", "Hantu siswi", "Sang Guru"]
const TIP = [
    "Dia mengejar cahaya dan suara. Hemat senter dan bersembunyilah di lemari.",
    "Senter membuatnya mundur sebentar. Jangan biarkan dia menutup jalanmu.",
    "Jangan lepaskan senter dari dia, dan terus bergerak.",
    "Dengarkan senandungnya untuk tahu jaraknya. Bersembunyilah di lemari.",
    "Sembunyi di lemari, jangan berlari saat dia dekat."
]
const KOMENTAR = [
    "Raka: Sari... jadi itu asal cermin-cermin itu.",
    "Raka: Mandor itu mengorbankan dirinya demi sekolah.",
    "Raka: Pak Darto, penjaga lorong bawah.",
    "Raka: Dina masih bernyanyi, bahkan setelah mati.",
    "Raka: Bangku paling belakang... itu bangkuku?"
]

var main
var dunia
var pemain
var hud
var aktif = 1
var wave_aktif = false
var wave_t = 0.0
var selesai = false
var final_selesai = false
var _hantu = []
var _detik = -1
var _mati_tadi = false


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    _hantu = [Kuntilanak, Genderuwo, Pocong, Siswi, null]
    dunia = main.buat_dunia(Kelas)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    pemain.global_position = Kelas.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.senter_ada = true
    pemain.senter.visible = true
    pemain.terkunci = true
    hud.senter_tersedia = true
    dunia.setel_bangku_aktif(1)
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 9: KELAS 9-X", 2.4)
    await hud.fade(0.0, 1.4)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Duduki bangku yang menyala (0/5)")
    hud.bicara("Raka: Kelas 9-X... Ada lima bangku, dan satu menyala, seperti memanggilku.", 5.0)
    await get_tree().create_timer(5.5).timeout
    hud.bicara("Raka: Setiap bangku menyimpan ingatan. Dan mungkin memanggil sesuatu.", 4.5)


func _process(delta):
    if dunia == null or hud == null:
        return
    if _mati_tadi and not dunia.mati:
        wave_t = DURASI
    _mati_tadi = dunia.mati
    if not wave_aktif or dunia.mati or dunia.sedang_adegan or selesai:
        return
    wave_t -= delta
    var detik = int(ceil(maxf(wave_t, 0.0)))
    if detik != _detik:
        _detik = detik
        hud.misi("Bertahan sampai %s menghilang: %d detik" % [NAMA[aktif - 1], detik])
    if wave_t <= 0.0:
        _akhir_gelombang()


func _aksi(id, node):
    if id.begins_with("bangku_"):
        var n = int(id.substr(7))
        if wave_aktif:
            hud.bicara("Bertahanlah dulu sampai dia menghilang.", 2.5)
        elif final_selesai or n != aktif:
            Sfx.putar("pintu_terkunci", -8.0)
            hud.bicara("Bangku ini tidak menyala.", 2.5)
        else:
            _mulai_gelombang(n)
        return true
    if id == "pintu_kepsek":
        if not final_selesai:
            Sfx.putar("pintu_terkunci", -2.0)
            hud.bicara("Terkunci. Raka: Aku belum memahami semuanya.", 3.5)
        else:
            _selesai_misi()
        return true
    return false


func _mulai_gelombang(n: int):
    wave_aktif = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    Sfx.putar("pintu_buka", -6.0, 1.2)
    await hud.fade(0.8, 0.2)
    await hud.kartu(INGATAN[n - 1], 12.0)
    await hud.fade(0.0, 0.2)
    pemain.terkunci = false
    dunia.sedang_adegan = false
    dunia.pesan_tangkap = "%s menangkapmu.\n\n%s" % [NAMA[n - 1], TIP[n - 1]]
    var zs = -18.0
    if pemain.global_position.z < -9.0:
        zs = -2.5
    var g = dunia.munculkan_guru(Vector3(0.0, 0.0, zs), _hantu[n - 1])
    if n == 1:
        g.kec_kejar = 3.6
    elif n == 3:
        g.kec_kejar += 0.2
    elif n == 5:
        g.kec_kejar = 4.0
        g.jarak_lihat_senter = 11.0
    wave_t = DURASI
    _detik = -1
    Sfx.putar("guru_kejar", -8.0)
    hud.bicara("%s muncul! Bertahan %d detik." % [NAMA[n - 1], int(DURASI)], 3.5)


func _akhir_gelombang():
    wave_aktif = false
    var n = aktif
    if dunia.guru != null:
        dunia.guru.berhenti()
    Sfx.putar("bisik", -2.0)
    hud.set_waspada(0.0, false)
    await get_tree().create_timer(0.8).timeout
    if dunia.guru != null and is_instance_valid(dunia.guru):
        dunia.guru.queue_free()
    dunia.guru = null
    Sfx.atur_loop("detak_jantung", -38.0, 1.0)
    dunia.tampilkan_baris(n)
    hud.bicara(KOMENTAR[n - 1], 3.5)
    aktif = n + 1
    if n < 5:
        dunia.setel_bangku_aktif(aktif)
        hud.misi("Duduki bangku yang menyala (%d/5)" % n)
    else:
        dunia.setel_bangku_aktif(99)
        _akhir()


func _akhir():
    final_selesai = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    await get_tree().create_timer(3.0).timeout
    for i in range(5):
        for l in dunia.lampu_listrik:
            l.visible = (i % 2 == 1)
        await get_tree().create_timer(0.12).timeout
    Sfx.putar("bel_sekolah", -2.0)
    dunia.tampilkan_baris(6)
    dunia.tampilkan_raka()
    hud.bicara("Raka: Namaku di papan... dan di semua foto itu. Aku... aku yang paling terakhir.", 5.5)
    await get_tree().create_timer(6.0).timeout
    hud.misi("Buka pintu ke ruang Kepala Sekolah (kanan belakang)")
    hud.bicara("Raka: Pintu di belakang kelas terbuka sekarang. Dia menunggu di sana.", 4.5)
    dunia.sedang_adegan = false
    pemain.terkunci = false


func _selesai_misi():
    if selesai:
        return
    selesai = true
    dunia.selesai = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    hud.set_waspada(0.0, false)
    Sfx.putar("pintu_besi", 0.0, 0.8)
    var p = dunia.pintu["pintu_kepsek"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", 80.0, 1.8)
    hud.bicara("Raka: Lorong merah menuju ruang Kepala Sekolah...", 3.6)
    await tw.finished
    await get_tree().create_timer(1.2).timeout
    await hud.fade(1.0, 1.4)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(9)
    hud.tampil_kontrol(false)
    var isi = "Kelas 9-X mengungkap semuanya. Satu per satu murid dijadikan penjaga, dan Raka adalah murid terakhir yang namanya tidak pernah dihapus. Di balik pintu belakang, sebuah lorong merah memanjang menuju ruang Kepala Sekolah.\n\nDokumen ditemukan: %d dari 16\n\nMisi 10: Ruang Kepala Sekolah, pertempuran terakhir, akan segera tiba." % dunia.dokumen_dibaca.size()
    await hud.layar_akhir("MISI 9 SELESAI", isi, "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
