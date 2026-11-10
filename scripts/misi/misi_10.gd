extends Node

# MISI 10: Ruang Kepala Sekolah (pertempuran terakhir, tamat Season 1).
# Kepala Sekolah (boss, dunia.guru) tidak bisa dilukai dengan cara biasa. Bunyikan 3 lonceng:
# tiap lonceng melemahkannya (lebih lambat). Lonceng 1 memanggil Kuntilanak, lonceng 2 memanggil Genderuwo,
# lonceng 3 melenyapkan semuanya. Lalu keluar lewat pintu besar di dinding kanan menuju gerbang sekolah.

const JUDUL = "Ruang Kepala Sekolah"
const RINGKAS = "Pertempuran terakhir. Bunyikan tiga lonceng, lalu keluar dari sekolah."

const Util = preload("res://scripts/util.gd")
const Ruang = preload("res://scripts/ruang_kepsek.gd")
const Kepsek = preload("res://scripts/kepsek.gd")
const Kuntilanak = preload("res://scripts/kuntilanak.gd")
const Genderuwo = preload("res://scripts/genderuwo.gd")

var main
var dunia
var pemain
var hud
var lonceng = 0
var bebas = false
var selesai = false
var _bawahan = []
var _mati_tadi = false


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Ruang)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    pemain.global_position = Ruang.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.senter_ada = true
    pemain.senter.visible = true
    pemain.terkunci = true
    hud.senter_tersedia = true
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 10: RUANG KEPALA SEKOLAH", 2.6)
    await hud.fade(0.0, 1.6)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Bunyikan 3 lonceng (0/3)")
    hud.bicara("Raka: Ruangan ini serba merah. Dan ada tiga lonceng, seperti bel yang kudengar tiap malam.", 5.0)
    await get_tree().create_timer(5.5).timeout
    var mulai_di = Vector3(0.0, 0.0, -21.0)
    if pemain.global_position.z < -12.0:
        mulai_di = Vector3(0.0, 0.0, -3.0)
    dunia.munculkan_guru(mulai_di, Kepsek)
    Sfx.putar("kepsek_geram", -4.0)
    hud.bicara("Kepala Sekolah: Raka... murid terakhirku. Kamu tidak akan pernah pulang.", 5.0)
    await get_tree().create_timer(5.5).timeout
    hud.bicara("Raka: Dia tidak bisa dilukai biasa. Lonceng-lonceng itu... mungkin kuncinya.", 5.0)


func _process(delta):
    if dunia == null or pemain == null:
        return
    if _mati_tadi and not dunia.mati:
        for g in _bawahan:
            if is_instance_valid(g):
                g.reset(_sudut_jauh())
    _mati_tadi = dunia.mati
    if _bawahan.is_empty() or dunia.mati or dunia.sedang_adegan or selesai:
        return
    if dunia.sembunyi_id != "" or pemain.terkunci:
        return
    # suara langkah Raka juga terdengar oleh hantu bawahan
    var kec = Vector2(pemain.velocity.x, pemain.velocity.z).length()
    if kec > 0.4:
        var radius = 3.5
        if kec > 3.5:
            radius = 8.0
        for g in _bawahan:
            if is_instance_valid(g):
                g.dengar(pemain.global_position, radius)


func _sudut_jauh() -> Vector3:
    var sudut = [Vector3(-7.0, 0.0, -3.0), Vector3(7.0, 0.0, -3.0), Vector3(-7.0, 0.0, -21.0), Vector3(7.0, 0.0, -21.0)]
    var terbaik = sudut[0]
    var jmax = -1.0
    for s in sudut:
        var d = s.distance_to(pemain.global_position)
        if d > jmax:
            jmax = d
            terbaik = s
    return terbaik


func _aksi(id, node):
    if id.begins_with("lonceng_") and id != "lonceng_bunyi":
        _bunyi(node)
        return true
    if id == "pintu_keluar":
        if not bebas:
            Sfx.putar("pintu_terkunci", -2.0)
            hud.bicara("Pintu besar ini terkunci rapat. Raka: Aku harus mengalahkan dia dulu.", 3.8)
        else:
            _selesai_misi()
        return true
    return false


func _panggil(skrip):
    var h = skrip.new()
    h.dunia = dunia
    h.pemain = pemain
    dunia.add_child(h)
    h.mulai(_sudut_jauh())
    _bawahan.append(h)
    Sfx.putar("kepsek_muncul", -4.0)


func _bunyi(node):
    lonceng += 1
    node.set_meta("id", "lonceng_bunyi")
    node.set_meta("label", "")
    node.get_child(1).material_override = Util.bahan(Color(0.3, 0.25, 0.1), 0.0)
    Sfx.putar("lonceng_besar", 0.0)
    Input.vibrate_handheld(200)
    hud.kilat(0.3)
    var g = dunia.guru
    if g != null:
        g.kec_kejar = maxf(2.6, g.kec_kejar - 0.4)
        g.curiga(node.global_position)
    if lonceng == 1:
        hud.misi("Bunyikan 3 lonceng (1/3)")
        hud.bicara("Kepala Sekolah: Berani sekali! Kuntilanak, kemari!", 3.5)
        _panggil(Kuntilanak)
    elif lonceng == 2:
        hud.misi("Bunyikan 3 lonceng (2/3)")
        hud.bicara("Kepala Sekolah: Genderuwo! Tangkap dia!", 3.5)
        _panggil(Genderuwo)
    else:
        _kalah()


func _kalah():
    dunia.sedang_adegan = true
    pemain.terkunci = true
    for h in _bawahan:
        if is_instance_valid(h):
            h.berhenti()
    if dunia.guru != null:
        dunia.guru.berhenti()
    hud.set_waspada(0.0, false)
    hud.bicara("Kepala Sekolah: Tidak... lonceng itu... Aku penguasa kerajaan ini!", 4.5)
    for i in range(6):
        for l in dunia.lampu_listrik:
            l.visible = (i % 2 == 1)
        await get_tree().create_timer(0.14).timeout
    Sfx.putar("lonceng_besar", 0.0)
    await get_tree().create_timer(1.0).timeout
    Sfx.putar("lonceng_besar", 0.0)
    await get_tree().create_timer(1.0).timeout
    Sfx.putar("lonceng_besar", 0.0)
    var tw = create_tween()
    tw.set_parallel(true)
    if dunia.guru != null:
        tw.tween_property(dunia.guru, "scale", Vector3(0.01, 0.01, 0.01), 2.0)
    for h in _bawahan:
        if is_instance_valid(h):
            tw.tween_property(h, "scale", Vector3(0.01, 0.01, 0.01), 2.0)
    await get_tree().create_timer(2.2).timeout
    for h in _bawahan:
        if is_instance_valid(h):
            h.queue_free()
    _bawahan.clear()
    if dunia.guru != null and is_instance_valid(dunia.guru):
        dunia.guru.queue_free()
    dunia.guru = null
    Sfx.henti_loop("detak_jantung")
    for l in dunia.lampu_listrik:
        l.visible = true
    Sfx.putar("gerbang_buka", -2.0)
    bebas = true
    hud.misi("Keluar dari sekolah lewat pintu besar di dinding kanan")
    hud.bicara("Raka: Selesai... sekolah ini akhirnya sunyi. Waktunya pulang.", 5.0)
    dunia.sedang_adegan = false
    pemain.terkunci = false


func _selesai_misi():
    if selesai:
        return
    selesai = true
    dunia.selesai = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    Sfx.putar("gerbang_buka", 0.0)
    var p = dunia.pintu["pintu_keluar"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", -85.0, 2.2)
    hud.bicara("Raka: Udara malam... dingin. Gerbang sekolah ada di depan sana.", 4.5)
    await tw.finished
    await get_tree().create_timer(2.0).timeout
    await hud.fade(1.0, 2.5)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(10)
    hud.tampil_kontrol(false)
    var info = "Dokumen: %d/16. Sentuh layar untuk kembali ke menu" % dunia.dokumen_dibaca.size()
    if dunia.dokumen_dibaca.size() >= 16:
        info = "Semua dokumen terkumpul! Sentuh layar untuk kembali ke menu"
    var isi = "Raka melangkah keluar dari gerbang sekolah. Untuk pertama kalinya dalam lima belas tahun, sekolah itu sunyi.\n\nTetapi jam di tangannya masih menunjuk 00:00, dan jalan pulang di depannya gelap dan tak dikenal.\n\nPerjalanan pulang baru dimulai...\n\nBERSAMBUNG DI SEASON 2"
    await hud.layar_akhir("TAMAT: SEASON 1", isi, info)
    main.kembali_ke_menu()
