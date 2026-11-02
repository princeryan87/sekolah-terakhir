extends Node

# MISI 4: Perpustakaan. Pintu masuk menutup sendiri. Temukan 3 catatan petunjuk, hitung meja baca,
# masukkan kode gembok (3916) di pintu arsip terlarang. Hantu siswi bersenandung dan berbisik
# (bisikannya sering berbohong).
# Kode: bel tiap malam = 3, kelas 9-X = 9, jumlah siswa = 1, meja baca = 6.

const JUDUL = "Perpustakaan"
const RINGKAS = "Cari petunjuk kode gembok. Jangan percaya bisikan siapa pun."
const KODE_BENAR = "3916"
const BISIKAN = [
    "Bisikan: ...tujuh kali... bel itu berbunyi tujuh kali...",
    "Bisikan: ...kelas itu... sembilan...",
    "Bisikan: ...dua murid... hanya dua...",
    "Bisikan: ...delapan meja... hitung lagi...",
    "Bisikan: ...tiga... bel itu tiga...",
    "Bisikan: ...enam... hitunglah dengan benar...",
    "Bisikan: ...satu... dia sendirian..."
]

const Perpus = preload("res://scripts/perpustakaan.gd")
const Siswi = preload("res://scripts/hantu_siswi.gd")
const KeypadScript = preload("res://scripts/keypad.gd")

var main
var dunia
var pemain
var hud
var keypad
var kode_terbuka = false
var selesai = false
var salah = 0
var petunjuk = -1
var keypad_aktif = false
var _bisikan = []
var _idx_bisik = 0
var _kedip_t = 6.0
var _buku_t = 20.0


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Perpus)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    _bisikan = BISIKAN.duplicate()
    _bisikan.shuffle()
    keypad = KeypadScript.new()
    keypad.layer = 30
    add_child(keypad)
    keypad.kode_dimasukkan.connect(_cek_kode)
    keypad.ditutup.connect(_tutup_keypad)
    pemain.global_position = Perpus.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.senter_ada = true
    pemain.senter.visible = false
    pemain.terkunci = true
    hud.senter_tersedia = true
    var p = dunia.pintu["pintu_masuk"]
    p["terbuka"] = true
    p["pivot"].rotation_degrees.y = p["derajat"]
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 4: PERPUSTAKAAN", 2.4)
    await hud.fade(0.0, 1.4)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.bicara("Raka: Perpustakaan ini masih terawat. Seperti ada yang menjaganya.", 4.0)
    await get_tree().create_timer(4.5).timeout
    dunia._ayun_pintu("pintu_masuk", false, 0.0)
    await get_tree().create_timer(1.0).timeout
    Sfx.putar("pintu_terkunci", 0.0)
    hud.bicara("Raka: Pintu masuknya menutup sendiri! Ada pintu lain di ujung, dengan gembok angka.", 5.0)
    await get_tree().create_timer(6.0).timeout
    var mulai_di = Vector3(0.0, 0.0, -18.0)
    if pemain.global_position.z < -9.0:
        mulai_di = Vector3(0.0, 0.0, -2.5)
    var g = dunia.munculkan_guru(mulai_di, Siswi)
    g.bisikan.connect(_on_bisikan)
    Sfx.putar("hantu_siswi_nyanyi", -8.0)
    hud.bicara("Raka: Senandung itu... ada anak perempuan di sini.", 4.0)


func _process(delta):
    if dunia == null or hud == null:
        return
    var n = 0
    for id in ["dok_6", "dok_7", "dok_8"]:
        if dunia.dokumen_dibaca.has(id):
            n += 1
    if n != petunjuk and not kode_terbuka:
        petunjuk = n
        hud.misi("Cari petunjuk kode (%d/3), lalu buka gembok di ujung ruangan" % n)
    if keypad_aktif and (dunia.mati or selesai):
        _tutup_keypad()
    if dunia.sedang_adegan or dunia.mati or selesai:
        return
    _kedip_t -= delta
    if _kedip_t <= 0.0:
        _kedip_t = randf_range(6.0, 12.0)
        _kedip()
    _buku_t -= delta
    if _buku_t <= 0.0:
        _buku_t = randf_range(18.0, 32.0)
        Sfx.putar("buku_jatuh", -10.0)


func _kedip():
    var i = (randi() % 4) * 2
    var a = dunia.lampu_listrik[i]
    var b = dunia.lampu_listrik[i + 1]
    a.visible = false
    b.visible = false
    await get_tree().create_timer(0.15).timeout
    a.visible = true
    b.visible = true


func _on_bisikan():
    Sfx.putar("hantu_siswi_bisik", -4.0)
    hud.bicara(_bisikan[_idx_bisik % _bisikan.size()], 4.0)
    _idx_bisik += 1


func _aksi(id, node):
    if id == "gembok_kode":
        if kode_terbuka:
            hud.bicara("Gembok sudah terbuka.", 2.0)
        else:
            _buka_keypad()
        return true
    if id == "pintu_masuk":
        Sfx.putar("pintu_terkunci", -4.0)
        hud.bicara("Terkunci dari luar. Tidak bisa dibuka.", 3.0)
        return true
    if id == "pintu_terlarang":
        if not kode_terbuka:
            Sfx.putar("pintu_terkunci", -2.0)
            hud.bicara("Terkunci. Ada gembok angka di sampingnya.", 3.5)
        else:
            _selesai_misi()
        return true
    return false


func _buka_keypad():
    keypad_aktif = true
    pemain.terkunci = true
    hud.tampil_kontrol(false)
    keypad.buka()


func _tutup_keypad():
    if not keypad_aktif:
        return
    keypad_aktif = false
    keypad.tutup()
    if not dunia.mati and not selesai:
        pemain.terkunci = false
        hud.tampil_kontrol(true)


func _cek_kode(k):
    if k == KODE_BENAR:
        Sfx.putar("keypad_benar", -2.0)
        kode_terbuka = true
        _tutup_keypad()
        hud.misi("Buka pintu arsip terlarang")
        hud.bicara("Raka: Klik! Gembok terbuka.", 3.0)
        return
    Sfx.putar("keypad_salah", -2.0)
    keypad.tampil_pesan("KODE SALAH")
    salah += 1
    if salah >= 3:
        salah = 0
        keypad.tampil_pesan("ALARM KECIL BERBUNYI!")
        if dunia.guru != null:
            dunia.guru.curiga(Vector3(0.0, 0.0, -18.5))
        hud.bicara("Raka: Bunyi alarm kecil... dia pasti mendengarnya!", 3.5)


func _selesai_misi():
    if selesai:
        return
    selesai = true
    dunia.selesai = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    if dunia.guru != null:
        dunia.guru.berhenti()
    hud.set_waspada(0.0, false)
    Sfx.putar("pintu_buka", 0.0, 0.8)
    var p = dunia.pintu["pintu_terlarang"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", 80.0, 1.6)
    hud.bicara("Raka: Terbuka... dan di baliknya hanya ada gelap yang panjang.", 3.6)
    await tw.finished
    await get_tree().create_timer(1.2).timeout
    await hud.fade(1.0, 1.4)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(4)
    hud.tampil_kontrol(false)
    var isi = "Di balik pintu arsip terlarang ada lorong yang sangat panjang dan gelap. Di ujungnya berdiri sesuatu yang terbungkus kain putih.\n\nDokumen ditemukan: %d dari 8\n\nMisi 5: Lorong Pocong akan segera tiba." % dunia.dokumen_dibaca.size()
    await hud.layar_akhir("MISI 4 SELESAI", isi, "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
