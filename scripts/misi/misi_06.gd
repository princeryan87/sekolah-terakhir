extends Node

# MISI 6: Ruang Guru. Kumpulkan 3 potongan denah dan pasang di papan di dinding belakang.
# Tuyul mencuri potongan yang kamu bawa lalu kabur (rebut dengan mendekat). Sang Guru berpatroli
# dengan kecepatan sedikit lebih tinggi daripada di Misi 2. Denah yang lengkap menunjukkan jalan ke Kelas 9-X.

const JUDUL = "Ruang Guru"
const RINGKAS = "Kumpulkan potongan denah. Tuyul akan mencurinya."

const Ruang = preload("res://scripts/ruang_guru.gd")
const Tuyul = preload("res://scripts/tuyul.gd")

var main
var dunia
var pemain
var hud
var tuyul = null
var barang = 0
var selesai = false
var _jatuh_n = 0


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Ruang)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    pemain.global_position = Ruang.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.senter_ada = true
    pemain.senter.visible = false
    pemain.terkunci = true
    hud.senter_tersedia = true
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 6: RUANG GURU", 2.4)
    await hud.fade(0.0, 1.4)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    _update_misi()
    hud.bicara("Raka: Ruang guru. Di papan itu ada kotak-kotak kosong... seperti denah yang robek.", 4.5)
    await get_tree().create_timer(5.0).timeout
    hud.bicara("Raka: Potongan-potongannya pasti tersebar di meja-meja ini.", 4.0)
    await get_tree().create_timer(6.0).timeout
    var mulai_di = Vector3(0.0, 0.0, -15.5)
    if pemain.global_position.z < -9.0:
        mulai_di = Vector3(0.0, 0.0, -2.5)
    var g = dunia.munculkan_guru(mulai_di)
    g.kec_kejar = 4.0
    g.jarak_lihat_senter = 11.0
    Sfx.putar("guru_kejar", -8.0)
    hud.bicara("Raka: Langkah sepatu itu... Sang Guru kembali!", 3.6)
    await get_tree().create_timer(5.0).timeout
    tuyul = Tuyul.new()
    tuyul.dunia = dunia
    tuyul.pemain = pemain
    tuyul.on_curi = Callable(self, "_on_curi")
    tuyul.on_rebut = Callable(self, "_on_rebut")
    tuyul.on_jatuh = Callable(self, "_on_jatuh")
    dunia.add_child(tuyul)
    tuyul.mulai(Vector3(5.5, 0.0, -15.5))
    Sfx.putar("tuyul_tawa", -6.0)
    hud.bicara("Raka: Tawa cekikikan apa itu...? Barang yang kubawa harus kujaga.", 4.5)


func _process(_delta):
    if tuyul != null and is_instance_valid(tuyul):
        tuyul.target_aktif = barang > 0 and not selesai


func _update_misi():
    if barang >= 3:
        hud.misi("Pasang 3 potongan di papan denah (dinding belakang)")
    else:
        hud.misi("Kumpulkan 3 potongan denah (dibawa: %d/3), pasang di papan belakang" % barang)


func _aksi(id, node):
    if id.begins_with("denah_"):
        _ambil_denah(node)
        return true
    if id == "papan_denah":
        _papan()
        return true
    return false


func _ambil_denah(node):
    node.queue_free()
    barang += 1
    Sfx.putar("kertas_ambil", -2.0)
    _update_misi()
    if barang == 1 and tuyul == null:
        hud.bicara("Raka: Satu potongan denah. Simpan baik-baik.", 3.0)
    elif barang >= 3:
        hud.bicara("Raka: Tiga potongan lengkap! Pasang di papan belakang, cepat!", 3.5)


func _on_curi():
    if barang <= 0:
        return false
    barang -= 1
    _update_misi()
    hud.bicara("Tuyul mencuri sebuah potongan denah! Kejar dia, lihat kilau kertas di atas kepalanya!", 4.5)
    return true


func _on_rebut():
    barang += 1
    Sfx.putar("kertas_ambil", -2.0)
    _update_misi()
    hud.bicara("Raka: Dapat kembali! Awas, dia akan mencoba lagi.", 3.0)


func _on_jatuh(pos):
    _jatuh_n += 1
    dunia._benda(Vector3(pos.x, 0.05, pos.z), Vector3(0.3, 0.02, 0.22), Color(0.8, 0.85, 0.95), "denah_j%d" % _jatuh_n, "Ambil potongan denah", Vector3(0.7, 0.3, 0.7), 0.8)
    hud.bicara("Tuyul menjatuhkan potongan denah di dekat sini! Ambil sebelum dia kembali.", 4.0)


func _papan():
    if barang < 3:
        Sfx.putar("pintu_terkunci", -6.0)
        hud.bicara("Papan denah. Butuh 3 potongan (baru dibawa %d)." % barang, 3.5)
        return
    _selesai_misi()


func _selesai_misi():
    if selesai:
        return
    selesai = true
    dunia.selesai = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    if dunia.guru != null:
        dunia.guru.berhenti()
    if tuyul != null and is_instance_valid(tuyul):
        tuyul.berhenti()
    hud.set_waspada(0.0, false)
    Sfx.putar("denah_pasang", 0.0)
    dunia.tampilkan_denah()
    hud.bicara("Raka: Denahnya lengkap! Kelas 9-X... lewat toilet, lalu lapangan.", 4.5)
    await get_tree().create_timer(5.0).timeout
    await hud.fade(1.0, 1.4)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(6)
    hud.tampil_kontrol(false)
    var isi = "Denah yang utuh menunjukkan jalan ke Kelas 9-X: lewat toilet lantai dua, lalu lapangan. Dari luar jendela terdengar angin dan suara tawa anak kecil yang menjauh.\n\nDokumen ditemukan: %d dari 12\n\nMisi 7: Toilet Lantai Dua akan segera tiba." % dunia.dokumen_dibaca.size()
    await hud.layar_akhir("MISI 6 SELESAI", isi, "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
