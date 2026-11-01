extends Node3D

# Seluruh sekolah dan alur cerita Tahap 1 dibuat di sini.
# Denah (satuan meter): lorong di tengah (x -1.5..1.5, z 0..-24),
# Kelas 9B di kiri, Kelas 9A di kanan, pintu lobi di ujung lorong (z -24).

const Util = preload("res://scripts/util.gd")

var pemain
var hud
var env
var lampu_listrik = []
var pintu = {}
var jam_label
var sampah_terkumpul = 0
var tahap = "bersih"
var punya_kunci = false
var sedang_adegan = false
var penampakan_selesai = false
var _timer_acak = 30.0


func _ready():
    _buat_lingkungan()
    _buat_bangunan()
    _buat_kelas_9b()
    _buat_kelas_9a()
    _buat_lorong()
    GameState.interaksi_ditekan.connect(_on_interaksi)


func siapkan(p, h):
    pemain = p
    hud = h
    pemain.kamera.environment = env
    pemain.global_position = Vector3(-5.5, 0.05, -2.8)
    pemain.yaw = 0.0
    pemain.terkunci = true


# ---------- lingkungan dan lampu ----------

func _buat_lingkungan():
    env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.02, 0.02, 0.04)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.32, 0.34, 0.46)
    env.ambient_light_energy = 0.55
    env.fog_enabled = true
    env.fog_light_color = Color(0.05, 0.06, 0.09)
    env.fog_density = 0.07


func _lampu(posisi: Vector3, warna: Color, energi: float, jangkauan: float, bisa_padam: bool):
    var l = OmniLight3D.new()
    l.position = posisi
    l.light_color = warna
    l.light_energy = energi
    l.omni_range = jangkauan
    l.shadow_enabled = false
    add_child(l)
    if bisa_padam:
        lampu_listrik.append(l)
        var v = Util.kotak(self, Vector3(posisi.x, 2.95, posisi.z), Vector3(0.9, 0.06, 0.3), Color(0.9, 0.9, 0.8), false, 0.9)
        lampu_listrik.append(v)
    return l


func _lampu_padam():
    for l in lampu_listrik:
        l.visible = false
    env.ambient_light_energy = 0.16
    env.fog_light_color = Color(0.01, 0.015, 0.03)
    env.fog_density = 0.1


# ---------- bangunan ----------

func _dinding_z(x: float, z_min: float, z_max: float, tinggi: float, warna: Color, celah_min: float = 0.0, celah_max: float = 0.0):
    if celah_max <= celah_min:
        Util.kotak(self, Vector3(x, tinggi / 2.0, (z_min + z_max) / 2.0), Vector3(0.2, tinggi, z_max - z_min), warna)
        return
    Util.kotak(self, Vector3(x, tinggi / 2.0, (z_min + celah_min) / 2.0), Vector3(0.2, tinggi, celah_min - z_min), warna)
    Util.kotak(self, Vector3(x, tinggi / 2.0, (celah_max + z_max) / 2.0), Vector3(0.2, tinggi, z_max - celah_max), warna)
    Util.kotak(self, Vector3(x, (2.2 + tinggi) / 2.0, (celah_min + celah_max) / 2.0), Vector3(0.2, tinggi - 2.2, celah_max - celah_min), warna)


func _dinding_x(z: float, x_min: float, x_max: float, tinggi: float, warna: Color, celah_min: float = 0.0, celah_max: float = 0.0):
    if celah_max <= celah_min:
        Util.kotak(self, Vector3((x_min + x_max) / 2.0, tinggi / 2.0, z), Vector3(x_max - x_min, tinggi, 0.2), warna)
        return
    Util.kotak(self, Vector3((x_min + celah_min) / 2.0, tinggi / 2.0, z), Vector3(celah_min - x_min, tinggi, 0.2), warna)
    Util.kotak(self, Vector3((celah_max + x_max) / 2.0, tinggi / 2.0, z), Vector3(x_max - celah_max, tinggi, 0.2), warna)
    Util.kotak(self, Vector3((celah_min + celah_max) / 2.0, (2.2 + tinggi) / 2.0, z), Vector3(celah_max - celah_min, tinggi - 2.2, 0.2), warna)


func _buat_bangunan():
    var dinding = Color(0.52, 0.5, 0.42)
    # lantai dan plafon
    Util.kotak(self, Vector3(0.0, -0.1, -12.0), Vector3(19.8, 0.2, 24.8), Color(0.3, 0.3, 0.26))
    Util.kotak(self, Vector3(0.0, 3.1, -12.0), Vector3(19.8, 0.2, 24.8), Color(0.4, 0.4, 0.38))
    # ubin lorong dan lantai kayu kelas (hanya hiasan)
    Util.kotak(self, Vector3(0.0, 0.005, -12.0), Vector3(2.8, 0.01, 24.0), Color(0.22, 0.24, 0.2), false)
    Util.kotak(self, Vector3(-5.55, 0.005, -6.0), Vector3(8.0, 0.01, 8.0), Color(0.36, 0.26, 0.16), false)
    Util.kotak(self, Vector3(5.55, 0.005, -6.0), Vector3(8.0, 0.01, 8.0), Color(0.36, 0.26, 0.16), false)
    # dinding lorong (celah pintu kelas di z -6.6 sampai -5.4)
    _dinding_z(-1.5, -24.0, 0.0, 3.0, dinding, -6.6, -5.4)
    _dinding_z(1.5, -24.0, 0.0, 3.0, dinding, -6.6, -5.4)
    _dinding_x(0.1, -1.6, 1.6, 3.0, dinding)
    _dinding_x(-24.1, -1.6, 1.6, 3.0, dinding, -0.6, 0.6)
    # dinding Kelas 9B
    _dinding_z(-9.6, -10.1, -1.9, 3.0, dinding)
    _dinding_x(-1.9, -9.7, -1.6, 3.0, dinding)
    _dinding_x(-10.1, -9.7, -1.6, 3.0, dinding)
    # dinding Kelas 9A
    _dinding_z(9.6, -10.1, -1.9, 3.0, dinding)
    _dinding_x(-1.9, 1.6, 9.7, 3.0, dinding)
    _dinding_x(-10.1, 1.6, 9.7, 3.0, dinding)


func _meja(x: float, z: float):
    Util.kotak(self, Vector3(x, 0.375, z), Vector3(0.9, 0.75, 0.5), Color(0.45, 0.33, 0.2))
    Util.kotak(self, Vector3(x, 0.225, z + 0.6), Vector3(0.4, 0.45, 0.4), Color(0.2, 0.26, 0.32), false)


func _benda(posisi: Vector3, ukuran: Vector3, warna: Color, id: String, label: String, tabrak: Vector3, emisi: float = 0.0):
    var body = StaticBody3D.new()
    body.position = posisi
    var cs = CollisionShape3D.new()
    var bs = BoxShape3D.new()
    bs.size = tabrak
    cs.shape = bs
    body.add_child(cs)
    var mi = MeshInstance3D.new()
    var bm = BoxMesh.new()
    bm.size = ukuran
    mi.mesh = bm
    mi.material_override = Util.bahan(warna, emisi)
    body.add_child(mi)
    body.set_meta("id", id)
    body.set_meta("label", label)
    add_child(body)
    return body


func _sampah(posisi: Vector3, id: String):
    var b = _benda(posisi + Vector3(0.0, 0.12, 0.0), Vector3(0.55, 0.25, 0.45), Color(0.35, 0.28, 0.2), id, "Sapu sampah", Vector3(0.8, 0.4, 0.7))
    Util.kotak(b, Vector3(0.1, 0.15, 0.05), Vector3(0.22, 0.05, 0.26), Color(0.8, 0.8, 0.75), false)
    Util.kotak(b, Vector3(-0.12, 0.14, -0.08), Vector3(0.18, 0.05, 0.2), Color(0.7, 0.7, 0.65), false)


func _buat_kelas_9b():
    # papan tulis dan jam digital di dinding depan
    Util.kotak(self, Vector3(-5.5, 1.5, -9.95), Vector3(4.0, 1.1, 0.06), Color(0.1, 0.22, 0.16), false)
    Util.kotak(self, Vector3(-5.5, 2.5, -9.95), Vector3(2.0, 0.8, 0.06), Color(0.05, 0.05, 0.05), false)
    jam_label = Label3D.new()
    jam_label.text = "16:47"
    jam_label.font_size = 64
    jam_label.pixel_size = 0.008
    jam_label.modulate = Color(1.0, 0.15, 0.1)
    jam_label.position = Vector3(-5.5, 2.5, -9.9)
    add_child(jam_label)
    # jendela
    for z in [-4.0, -8.0]:
        Util.kotak(self, Vector3(-9.49, 1.7, z), Vector3(0.04, 1.1, 1.6), Color(0.25, 0.35, 0.6), false, 0.7)
    # meja murid
    for x in [-8.2, -6.2, -4.2]:
        for z in [-4.0, -5.8, -7.6]:
            _meja(x, z)
    # sampah yang harus dibersihkan
    _sampah(Vector3(-6.9, 0.0, -2.9), "sampah_1")
    _sampah(Vector3(-3.1, 0.0, -8.7), "sampah_2")
    _sampah(Vector3(-8.8, 0.0, -9.0), "sampah_3")
    # lampu kelas dan cahaya bulan dari jendela
    _lampu(Vector3(-5.5, 2.7, -6.0), Color(1.0, 0.9, 0.7), 1.4, 10.0, true)
    _lampu(Vector3(-8.6, 2.2, -6.0), Color(0.35, 0.45, 0.9), 0.6, 8.0, false)


func _buat_kelas_9a():
    Util.kotak(self, Vector3(5.5, 1.5, -9.95), Vector3(4.0, 1.1, 0.06), Color(0.1, 0.22, 0.16), false)
    var tulisan = Label3D.new()
    tulisan.text = "RAKA TIDAK BOLEH PULANG"
    tulisan.font_size = 48
    tulisan.pixel_size = 0.006
    tulisan.modulate = Color(0.85, 0.85, 0.85)
    tulisan.position = Vector3(5.5, 1.5, -9.9)
    add_child(tulisan)
    for z in [-4.0, -8.0]:
        Util.kotak(self, Vector3(9.49, 1.7, z), Vector3(0.04, 1.1, 1.6), Color(0.25, 0.35, 0.6), false, 0.7)
    for x in [4.2, 6.2, 8.2]:
        for z in [-3.8, -5.6, -7.4]:
            _meja(x, z)
    # meja guru + kunci lobi
    Util.kotak(self, Vector3(6.0, 0.375, -9.0), Vector3(1.8, 0.75, 0.7), Color(0.38, 0.27, 0.16))
    _benda(Vector3(6.0, 0.82, -9.0), Vector3(0.18, 0.03, 0.08), Color(0.95, 0.8, 0.2), "kunci_lobi", "Ambil kunci", Vector3(0.5, 0.3, 0.5), 0.6)
    _lampu(Vector3(8.6, 2.2, -6.0), Color(0.35, 0.45, 0.9), 0.6, 8.0, false)


func _buat_pintu(id: String, engsel: Vector3, lebar: float, searah_z: bool, derajat: float):
    var pivot = Node3D.new()
    pivot.position = engsel
    add_child(pivot)
    var ukuran = Vector3(lebar, 2.2, 0.1)
    var offset = Vector3(lebar / 2.0, 1.1, 0.0)
    var gagang = Vector3(lebar - 0.15, 1.0, 0.07)
    if searah_z:
        ukuran = Vector3(0.1, 2.2, lebar)
        offset = Vector3(0.0, 1.1, -lebar / 2.0)
        gagang = Vector3(0.07, 1.0, -lebar + 0.15)
    var badan = Util.kotak(pivot, offset, ukuran, Color(0.42, 0.27, 0.15))
    badan.set_meta("id", id)
    badan.set_meta("label", "Buka pintu")
    Util.kotak(pivot, gagang, Vector3(0.08, 0.08, 0.08), Color(0.8, 0.7, 0.3), false)
    pintu[id] = {"pivot": pivot, "badan": badan, "terbuka": false, "derajat": derajat, "sibuk": false}


func _buat_lorong():
    # pintu
    _buat_pintu("pintu_9b", Vector3(-1.5, 0.0, -5.4), 1.2, true, 90.0)
    _buat_pintu("pintu_9a", Vector3(1.5, 0.0, -5.4), 1.2, true, -90.0)
    _buat_pintu("pintu_lobi", Vector3(-0.6, 0.0, -24.1), 1.2, false, 85.0)
    # papan nama
    var t1 = _tulisan3d("KELAS 9B", Vector3(-1.38, 2.6, -6.0), 90.0)
    var t2 = _tulisan3d("KELAS 9A", Vector3(1.38, 2.6, -6.0), -90.0)
    var t3 = _tulisan3d("LOBI", Vector3(0.0, 2.6, -24.0), 0.0)
    # foto siswa di dinding kiri: semuanya berwajah sama
    for i in range(6):
        _foto(-12.0 - 2.0 * i)
    # loker di dinding kanan
    for i in range(8):
        var z = -12.5 - 1.0 * i
        Util.kotak(self, Vector3(1.15, 0.95, z), Vector3(0.5, 1.9, 0.8), Color(0.25, 0.32, 0.4))
        Util.kotak(self, Vector3(0.89, 0.95, z), Vector3(0.02, 1.6, 0.62), Color(0.15, 0.2, 0.26), false)
        Util.kotak(self, Vector3(0.87, 1.1, z + 0.2), Vector3(0.03, 0.12, 0.04), Color(0.6, 0.6, 0.6), false)
    # lampu lorong
    _lampu(Vector3(0.0, 2.7, -4.0), Color(0.85, 0.95, 0.85), 1.0, 9.0, true)
    _lampu(Vector3(0.0, 2.7, -16.0), Color(0.85, 0.95, 0.85), 1.0, 9.0, true)


func _tulisan3d(teks: String, posisi: Vector3, putar_y: float):
    var t = Label3D.new()
    t.text = teks
    t.font_size = 40
    t.pixel_size = 0.006
    t.modulate = Color(0.9, 0.9, 0.8)
    t.position = posisi
    t.rotation_degrees.y = putar_y
    add_child(t)
    return t


func _foto(z: float):
    Util.kotak(self, Vector3(-1.375, 1.7, z), Vector3(0.05, 0.55, 0.42), Color(0.3, 0.2, 0.12), false)
    Util.kotak(self, Vector3(-1.335, 1.7, z), Vector3(0.03, 0.4, 0.32), Color(0.6, 0.58, 0.5), false)
    Util.kotak(self, Vector3(-1.315, 1.76, z - 0.08), Vector3(0.02, 0.06, 0.07), Color(0.04, 0.04, 0.04), false)
    Util.kotak(self, Vector3(-1.315, 1.76, z + 0.08), Vector3(0.02, 0.06, 0.07), Color(0.04, 0.04, 0.04), false)
    Util.kotak(self, Vector3(-1.315, 1.6, z), Vector3(0.02, 0.03, 0.14), Color(0.25, 0.05, 0.05), false)


# ---------- hantu ----------

func _buat_kuntilanak():
    var h = Node3D.new()
    var gaun = Color(0.85, 0.85, 0.8)
    var kulit = Color(0.72, 0.72, 0.66)
    var rambut = Color(0.02, 0.02, 0.02)
    Util.kotak(h, Vector3(0.0, 0.75, 0.0), Vector3(0.62, 1.5, 0.34), gaun, false)
    Util.kotak(h, Vector3(0.0, 1.62, 0.0), Vector3(0.5, 0.35, 0.3), gaun, false)
    Util.kotak(h, Vector3(0.0, 1.85, -0.04), Vector3(0.3, 0.32, 0.28), kulit, false)
    Util.kotak(h, Vector3(0.0, 1.46, 0.08), Vector3(0.46, 1.2, 0.34), rambut, false)
    Util.kotak(h, Vector3(0.0, 1.98, -0.07), Vector3(0.36, 0.12, 0.3), rambut, false)
    Util.kotak(h, Vector3(-0.17, 1.8, -0.13), Vector3(0.05, 0.5, 0.1), rambut, false)
    Util.kotak(h, Vector3(0.17, 1.8, -0.13), Vector3(0.05, 0.5, 0.1), rambut, false)
    Util.kotak(h, Vector3(-0.07, 1.83, -0.19), Vector3(0.05, 0.04, 0.02), Color(1.0, 0.1, 0.05), false, 1.5)
    Util.kotak(h, Vector3(0.07, 1.83, -0.19), Vector3(0.05, 0.04, 0.02), Color(1.0, 0.1, 0.05), false, 1.5)
    Util.kotak(h, Vector3(0.0, 1.72, -0.19), Vector3(0.1, 0.03, 0.02), Color(0.02, 0.0, 0.0), false)
    var l1 = Util.kotak(h, Vector3(-0.38, 1.05, -0.08), Vector3(0.1, 0.8, 0.1), kulit, false)
    var l2 = Util.kotak(h, Vector3(0.38, 1.05, -0.08), Vector3(0.1, 0.8, 0.1), kulit, false)
    l1.rotation_degrees.x = -20.0
    l2.rotation_degrees.x = -20.0
    var cahaya = OmniLight3D.new()
    cahaya.position = Vector3(0.0, 1.9, -1.0)
    cahaya.light_color = Color(0.75, 0.85, 1.0)
    cahaya.light_energy = 1.8
    cahaya.omni_range = 4.5
    cahaya.shadow_enabled = false
    h.add_child(cahaya)
    return h


# ---------- alur permainan ----------

func mulai():
    pemain.terkunci = true
    hud.tampil_kontrol(false)
    await hud.kartu("Raka dihukum membersihkan sekolah setelah jam pulang.", 3.4)
    await hud.kartu("Tinggal satu kelas lagi...", 2.6)
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    await hud.fade(0.0, 1.5)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Bersihkan kelas 9B (0/3)")
    hud.bicara("Raka: Kenapa harus aku yang bersihin semuanya...", 4.0)


func _process(delta):
    if pemain == null or hud == null:
        return
    if tahap == "gelap" or tahap == "lari":
        if not sedang_adegan:
            _timer_acak -= delta
            if _timer_acak <= 0.0:
                _timer_acak = randf_range(14.0, 26.0)
                var r = randi() % 3
                if r == 0:
                    Sfx.putar("bisik", -12.0)
                elif r == 1:
                    Sfx.putar("langkah_atas", -9.0)
                else:
                    Sfx.putar("pintu_terkunci", -14.0)
    if tahap == "lari" and not penampakan_selesai and not sedang_adegan:
        var p = pemain.global_position
        if p.z < -12.0 and absf(p.x) < 1.6:
            penampakan_selesai = true
            _penampakan_lorong()


func _on_interaksi():
    if pemain == null or pemain.terkunci or sedang_adegan:
        return
    var s = pemain.sasaran
    if s == null or not is_instance_valid(s):
        return
    var id = str(s.get_meta("id", ""))
    if id.begins_with("sampah"):
        _ambil_sampah(s)
    elif id == "kunci_lobi":
        _ambil_kunci(s)
    elif pintu.has(id):
        _pintu_aksi(id)


func _ambil_sampah(node):
    Sfx.putar("sapu", -4.0, randf_range(0.9, 1.1))
    node.queue_free()
    sampah_terkumpul += 1
    if sampah_terkumpul < 3:
        hud.misi("Bersihkan kelas 9B (%d/3)" % sampah_terkumpul)
    else:
        hud.misi("Pulang")
        hud.bicara("Raka: Beres! Akhirnya bisa pulang.", 3.5)
        _mulai_pemadaman()


func _mulai_pemadaman():
    tahap = "pemadaman"
    await get_tree().create_timer(2.5).timeout
    Sfx.putar("listrik_mati", 0.0)
    for i in range(5):
        for l in lampu_listrik:
            l.visible = (i % 2 == 1)
        await get_tree().create_timer(randf_range(0.06, 0.16)).timeout
    _lampu_padam()
    jam_label.text = "00:00"
    hud.bicara("Raka: Hah? Listriknya mati?!", 3.0)
    await get_tree().create_timer(3.2).timeout
    pemain.senter_ada = true
    hud.senter_tersedia = true
    pemain.senter.visible = true
    Sfx.putar("senter_klik", -4.0)
    hud.bicara("Raka: Untung ada senter di HP. (Tombol SENTER: nyala/mati)", 4.2)
    await get_tree().create_timer(4.6).timeout
    hud.bicara("Raka: Jam dinding itu... 00:00? Tadi masih sore!", 4.0)
    await get_tree().create_timer(4.4).timeout
    Sfx.putar("bel_sekolah", -2.0)
    hud.bicara("Raka: Bel masuk?! Tengah malam begini?", 3.5)
    await get_tree().create_timer(3.8).timeout
    Sfx.putar("langkah_atas", -4.0)
    hud.bicara("Raka: Itu... suara langkah kaki dari lantai atas.", 4.0)
    if tahap == "pemadaman":
        tahap = "gelap"
        _timer_acak = 20.0
        hud.misi("Cari jalan keluar")


func _pintu_aksi(id: String):
    var p = pintu[id]
    if p["sibuk"]:
        return
    if id == "pintu_9b" and sampah_terkumpul < 3 and not p["terbuka"]:
        Sfx.putar("pintu_terkunci", -6.0)
        hud.bicara("Raka: Belum selesai. Kalau pulang sebelum bersih, bisa kena marah lagi.", 4.0)
        return
    if id == "pintu_9a" and (tahap == "bersih" or tahap == "pemadaman") and not p["terbuka"]:
        Sfx.putar("pintu_terkunci", -2.0)
        hud.bicara("Dikunci. Raka: Kelas 9A sudah dikunci dari sore tadi.", 3.5)
        return
    if id == "pintu_lobi" and not p["terbuka"]:
        if not punya_kunci:
            Sfx.putar("pintu_terkunci", 0.0)
            hud.bicara("Terkunci. Raka: Kuncinya pasti ada di suatu tempat...", 3.8)
            return
        _selesai_demo()
        return
    var buka = not p["terbuka"]
    p["terbuka"] = buka
    p["sibuk"] = true
    Sfx.putar("pintu_buka", -3.0, randf_range(0.9, 1.1))
    var tujuan = 0.0
    if buka:
        tujuan = p["derajat"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", tujuan, 0.8)
    await tw.finished
    p["sibuk"] = false
    if buka:
        p["badan"].set_meta("label", "Tutup pintu")
    else:
        p["badan"].set_meta("label", "Buka pintu")


func _ambil_kunci(node):
    node.queue_free()
    punya_kunci = true
    Sfx.putar("kunci_ambil")
    hud.misi("Buka pintu lobi (ujung lorong)")
    hud.bicara("Raka: Kunci lobi! Akhirnya...", 2.5)
    sedang_adegan = true
    await get_tree().create_timer(1.6).timeout
    await _adegan_hantu()


func _adegan_hantu():
    sedang_adegan = true
    pemain.terkunci = true
    var senter_tadi = pemain.senter.visible
    pemain.senter.visible = false
    Sfx.mulai_loop("detak_jantung", -10.0)
    Sfx.putar("bisik", -2.0)
    hud.bicara("Raka: ...siapa di situ?", 2.6)
    await get_tree().create_timer(1.6).timeout
    Sfx.putar("kuntilanak_tawa", 0.0)
    await get_tree().create_timer(2.0).timeout

    var arah = -pemain.kamera.global_transform.basis.z
    arah.y = 0.0
    arah = arah.normalized()
    var hantu = _buat_kuntilanak()
    add_child(hantu)
    hantu.global_position = pemain.global_position + arah * 2.6
    hantu.look_at(Vector3(pemain.global_position.x, hantu.global_position.y, pemain.global_position.z), Vector3.UP)
    await get_tree().create_timer(0.45).timeout

    Sfx.putar("jumpscare", 0.0)
    Input.vibrate_handheld(500)
    var tw = create_tween()
    tw.tween_property(hantu, "global_position", pemain.global_position + arah * 0.55, 0.22)
    await tw.finished
    hud.kilat(0.7)
    pemain.getar(0.45, 0.12)
    await get_tree().create_timer(0.12).timeout
    hantu.queue_free()
    await get_tree().create_timer(1.0).timeout

    pemain.senter.visible = senter_tadi
    Sfx.atur_loop("detak_jantung", -14.0, 1.0)
    get_tree().create_timer(8.0).timeout.connect(func(): Sfx.henti_loop("detak_jantung"))
    hud.bicara("Raka: Aku harus keluar dari sini sekarang!", 3.5)
    tahap = "lari"
    _timer_acak = 20.0
    sedang_adegan = false
    pemain.terkunci = false


func _penampakan_lorong():
    var h = _buat_kuntilanak()
    add_child(h)
    h.global_position = Vector3(0.0, 0.0, -21.5)
    h.look_at(Vector3(pemain.global_position.x, 0.0, pemain.global_position.z), Vector3.UP)
    Sfx.putar("bisik", -4.0)
    for i in range(6):
        pemain.senter.visible = (i % 2 == 1)
        await get_tree().create_timer(0.07).timeout
    pemain.senter.visible = true
    await get_tree().create_timer(1.5).timeout
    h.queue_free()
    Sfx.putar("kuntilanak_tawa", -8.0)


func _selesai_demo():
    sedang_adegan = true
    pemain.terkunci = true
    tahap = "selesai"
    Sfx.putar("pintu_buka", 0.0, 0.8)
    var p = pintu["pintu_lobi"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", 80.0, 1.6)
    hud.bicara("Raka: Terbuka! Tapi... suara langkah itu makin dekat.", 3.2)
    await tw.finished
    Sfx.putar("langkah_atas", -2.0)
    await get_tree().create_timer(1.2).timeout
    await hud.fade(1.0, 1.4)
    Sfx.henti_loop("ambience_sekolah")
    Sfx.henti_loop("detak_jantung")
    GameState.data["selesai"] = int(GameState.data.get("selesai", 0)) + 1
    GameState.simpan()
    hud.tampil_kontrol(false)
    await hud.layar_akhir("BERSAMBUNG...", "Pintu lobi terbuka, tetapi dari lantai atas terdengar langkah kaki yang mendekat.\n\nTahap 2: Sang Guru mulai mencari Raka.", "Sentuh layar untuk mengulang")
    get_tree().reload_current_scene()
