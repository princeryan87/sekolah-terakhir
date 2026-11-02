extends Node

# MISI 3: Lantai Atas. Lantai dua gelap. Kumpulkan 3 sekering, pasang di kotak sekering
# di ujung lorong, lalu buka pintu perpustakaan. Genderuwo berkeliaran (takut senter).

const JUDUL = "Lantai Atas"
const RINGKAS = "Nyalakan listrik lantai dua. Genderuwo takut cahaya."

const Lantai2 = preload("res://scripts/lantai2.gd")
const Genderuwo = preload("res://scripts/genderuwo.gd")

var main
var dunia
var pemain
var hud
var sekering = 0
var listrik = false
var selesai = false


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Lantai2)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    pemain.global_position = Lantai2.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.senter_ada = true
    pemain.senter.visible = true
    pemain.terkunci = true
    hud.senter_tersedia = true
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 3: LANTAI ATAS", 2.4)
    await hud.fade(0.0, 1.4)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Cari 3 sekering (0/3)")
    hud.bicara("Raka: Tangga tadi membawaku ke lantai dua. Gelap total...", 4.0)
    await get_tree().create_timer(4.5).timeout
    hud.bicara("Raka: Kotak sekering pasti ada di ujung lorong. Aku butuh 3 sekering.", 4.2)
    await get_tree().create_timer(5.0).timeout
    var mulai_di = Vector3(0.0, 0.0, -23.0)
    if pemain.global_position.z < -12.0:
        mulai_di = Vector3(0.0, 0.0, -2.5)
    dunia.munculkan_guru(mulai_di, Genderuwo)
    Sfx.putar("genderuwo_geram", -6.0)
    hud.bicara("Raka: Suara apa itu...? Geramannya berat sekali.", 3.6)
    await get_tree().create_timer(4.0).timeout
    hud.bicara("Genderuwo takut cahaya. Sorot dia dengan senter, lalu menjauhlah.", 6.0)


func _aksi(id, node):
    if id.begins_with("sekering_"):
        _ambil_sekering(node)
        return true
    if id == "kotak_sekering":
        _kotak()
        return true
    if id == "pintu_perpus":
        _perpus()
        return true
    return false


func _ambil_sekering(node):
    node.queue_free()
    sekering += 1
    Sfx.putar("kunci_ambil")
    if sekering < 3:
        hud.misi("Cari 3 sekering (%d/3)" % sekering)
    else:
        hud.misi("Pasang sekering di kotak (ujung lorong)")
        hud.bicara("Raka: Tiga sekering! Sekarang pasang di kotaknya.", 3.5)


func _kotak():
    if listrik:
        return
    if sekering < 3:
        Sfx.putar("pintu_terkunci", -6.0)
        hud.bicara("Kotak sekering. Butuh 3 sekering (baru %d)." % sekering, 3.5)
        return
    _nyalakan()


func _nyalakan():
    listrik = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    Sfx.putar("listrik_nyala", 0.0)
    for i in range(4):
        for l in dunia.lampu_listrik:
            l.visible = (i % 2 == 1)
        await get_tree().create_timer(0.12).timeout
    dunia._lampu_nyala()
    Sfx.putar("bel_sekolah", -2.0)
    hud.misi("Buka pintu perpustakaan (ujung lorong)")
    hud.bicara("Raka: Listriknya nyala! Tapi bel itu berbunyi lagi. Cepat buka pintu perpustakaan!", 4.5)
    var g = dunia.guru
    if g != null:
        g.kec_kejar += 0.5
        g.curiga(Vector3(0.0, 0.0, -24.0))
    dunia.sedang_adegan = false
    pemain.terkunci = false


func _perpus():
    if not listrik:
        Sfx.putar("pintu_terkunci", 0.0)
        hud.bicara("Terkunci. Kunci elektrik pintu ini mati. Nyalakan listrik dulu.", 3.8)
        return
    _buka_perpus()


func _buka_perpus():
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
    var p = dunia.pintu["pintu_perpus"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", 80.0, 1.6)
    hud.bicara("Raka: Perpustakaan... dan ada yang bersenandung di dalam.", 3.6)
    await tw.finished
    await get_tree().create_timer(1.2).timeout
    await hud.fade(1.0, 1.4)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(3)
    hud.tampil_kontrol(false)
    var isi = "Pintu perpustakaan terbuka. Dari dalam tercium bau buku tua, dan terdengar senandung anak perempuan.\n\nDokumen ditemukan: %d dari 5\n\nMisi 4: Perpustakaan akan segera tiba." % dunia.dokumen_dibaca.size()
    await hud.layar_akhir("MISI 3 SELESAI", isi, "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
