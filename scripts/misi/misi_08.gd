extends Node

# MISI 8: Lapangan dan Gudang. Malam berkabut. Seberangi lapangan ke gudang olahraga, ambil linggis,
# lalu buka tutup got di tengah lapangan. Genderuwo (dunia.guru) dan Pocong (dikelola misi) berjaga.
# Senter menahan keduanya. Mengambil linggis membuat keduanya lebih cepat.

const JUDUL = "Lapangan dan Gudang"
const RINGKAS = "Malam berkabut. Dua penjaga berjaga. Senter menahan keduanya."

const Lapangan = preload("res://scripts/lapangan.gd")
const Genderuwo = preload("res://scripts/genderuwo.gd")
const Pocong = preload("res://scripts/pocong.gd")

var main
var dunia
var pemain
var hud
var pocong = null
var linggis = false
var selesai = false
var _mati_tadi = false


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Lapangan)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    pemain.global_position = Lapangan.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.senter_ada = true
    pemain.senter.visible = true
    pemain.terkunci = true
    hud.senter_tersedia = true
    Sfx.mulai_loop("ambience_sekolah", -16.0)
    Sfx.mulai_loop("angin_lapangan", -10.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 8: LAPANGAN DAN GUDANG", 2.4)
    await hud.fade(0.0, 1.4)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Temukan linggis di gudang olahraga (ujung lapangan)")
    hud.bicara("Raka: Lapangan... kabutnya tebal sekali. Cahaya kuning di ujung sana pasti gudang.", 4.5)
    await get_tree().create_timer(5.0).timeout
    hud.bicara("Raka: Kelas 9-X ada di bawah lapangan ini. Aku butuh linggis untuk membuka tutup got.", 4.5)
    await get_tree().create_timer(7.0).timeout
    var zs = -28.0
    if pemain.global_position.z < -16.0:
        zs = -4.0
    dunia.munculkan_guru(Vector3(15.0, 0.0, zs), Genderuwo)
    pocong = Pocong.new()
    pocong.dunia = dunia
    pocong.pemain = pemain
    dunia.add_child(pocong)
    pocong.mulai(Vector3(-15.0, 0.0, zs))
    Sfx.putar("genderuwo_geram", -6.0)
    Sfx.putar("pocong_erang", -8.0)
    hud.bicara("Raka: Dua sosok di dalam kabut... yang besar, dan yang berkafan!", 4.0)
    await get_tree().create_timer(4.5).timeout
    hud.bicara("Senter menahan keduanya: Pocong membeku, Genderuwo mundur.", 5.0)


func _process(_delta):
    if dunia == null:
        return
    if pocong != null and is_instance_valid(pocong):
        if _mati_tadi and not dunia.mati:
            pocong.reset(Vector3(-15.0, 0.0, -28.0))
        _mati_tadi = dunia.mati


func _aksi(id, node):
    if id == "linggis":
        _ambil_linggis(node)
        return true
    if id == "tutup_got":
        if not linggis:
            Sfx.putar("pintu_terkunci", -2.0)
            hud.bicara("Tutup got besi, terkunci rapat. Butuh linggis untuk mencongkelnya.", 3.8)
        else:
            _selesai_misi()
        return true
    return false


func _ambil_linggis(node):
    node.queue_free()
    linggis = true
    Sfx.putar("kunci_besi", -2.0)
    hud.misi("Buka tutup got di tengah lapangan")
    hud.bicara("Raka: Dapat linggisnya! Sekarang ke tengah lapangan, cepat!", 3.8)
    Sfx.putar("bel_sekolah", -2.0)
    if dunia.guru != null:
        dunia.guru.kec_kejar += 0.3
    if pocong != null and is_instance_valid(pocong):
        pocong.kec_kejar += 0.3


func _selesai_misi():
    if selesai:
        return
    selesai = true
    dunia.selesai = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    if dunia.guru != null:
        dunia.guru.berhenti()
    if pocong != null and is_instance_valid(pocong):
        pocong.berhenti()
    hud.set_waspada(0.0, false)
    Sfx.putar("pintu_besi", 0.0)
    hud.bicara("Raka: Terbuka! Ada tangga besi menuju ruang bawah tanah.", 4.0)
    await get_tree().create_timer(3.0).timeout
    await hud.fade(1.0, 1.4)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(8)
    hud.tampil_kontrol(false)
    var isi = "Tutup got besi terbuka. Tangga berkarat turun ke ruang bawah tanah, ke tempat Kelas 9-X yang tidak tercatat di denah mana pun.\n\nDokumen ditemukan: %d dari 16\n\nMisi 9: Kelas 9-X akan segera tiba." % dunia.dokumen_dibaca.size()
    await hud.layar_akhir("MISI 8 SELESAI", isi, "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
