extends Node3D

# Dasar dunia: layanan umum (lampu, pintu, tempat sembunyi, dokumen, Sang Guru, tertangkap).
# Gedung/lantai tertentu dibuat oleh skrip turunan (lantai1.gd, dst.) lewat _bangun().

const Util = preload("res://scripts/util.gd")
const GuruScript = preload("res://scripts/guru.gd")

var pemain
var hud
var env
var guru = null
var lampu_listrik = []
var pintu = {}
var tempat = {}
var teks_dokumen = {}
var komentar_dokumen = {}
var dokumen_dibaca = []
var sedang_adegan = false
var mati = false
var selesai = false
var sembunyi_id = ""
var sembunyi_pos = Vector3.ZERO
var guru_tahu = false
var acak_aktif = false
var hook_aksi = Callable()
var kembali_menu = Callable()
var titik_ulang = Vector3(0.0, 0.05, 0.0)
var yaw_ulang = 0.0
var guru_ulang = Vector3.ZERO
var pesan_ulang = "Raka: Aku harus lebih hati-hati..."
var pesan_tangkap = "Sang Guru menemukanmu.\n\nIngat: sembunyi di loker atau lemari, jangan berlari saat dia dekat, dan matikan senter bila perlu."
var peta_node = {}
var peta_sisi = []
var peta_patroli = []
var peta_pintu = {}
var _timer_acak = 30.0


func _ready():
    for d in GameState.data.get("dokumen", []):
        dokumen_dibaca.append(str(d))
    _buat_lingkungan()
    _bangun()
    GameState.interaksi_ditekan.connect(_on_interaksi)


func _bangun():
    pass


func siapkan(p, h):
    pemain = p
    hud = h
    pemain.kamera.environment = env
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


# ---------- bangun benda ----------

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


func _daftar_tempat(id: String, dalam: Vector3, keluar: Vector3, depan: Vector3, yaw: float):
    tempat[id] = {"dalam": dalam, "keluar": keluar, "depan": depan, "yaw": yaw}


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


# ---------- proses dan interaksi ----------

func _process(delta):
    if pemain == null or hud == null:
        return
    if guru != null:
        var jarak = guru.global_position.distance_to(pemain.global_position)
        var dekat = clampf(1.0 - jarak / 14.0, 0.0, 1.0)
        var nada = 1.0 + 0.6 * dekat
        if guru.state == "kejar":
            nada += 0.25
        Sfx.atur_loop("detak_jantung", -38.0 + 32.0 * dekat, nada)
        hud.set_waspada(guru.waspada, guru.state == "kejar")
        # suara langkah Raka bisa didengar Sang Guru
        if sembunyi_id == "" and not pemain.terkunci and not mati:
            var kec = Vector2(pemain.velocity.x, pemain.velocity.z).length()
            if kec > 0.4:
                var radius = 3.5
                if kec > 3.5:
                    radius = 8.0
                guru.dengar(pemain.global_position, radius)
    elif acak_aktif and not sedang_adegan:
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


func _on_interaksi():
    if pemain == null or mati:
        return
    if sembunyi_id != "":
        _keluar_sembunyi()
        return
    if pemain.terkunci or sedang_adegan:
        return
    var s = pemain.sasaran
    if s == null or not is_instance_valid(s):
        return
    var id = str(s.get_meta("id", ""))
    if hook_aksi.is_valid():
        if hook_aksi.call(id, s):
            return
    if id.begins_with("dok_"):
        _baca(id)
    elif tempat.has(id):
        _mulai_sembunyi(id)
    elif pintu.has(id):
        _pintu_aksi(id)


# ---------- pintu ----------

func _ayun_pintu(id: String, buka: bool, suara_db: float):
    var p = pintu[id]
    if p["sibuk"] or p["terbuka"] == buka:
        return
    p["terbuka"] = buka
    p["sibuk"] = true
    Sfx.putar("pintu_buka", suara_db, randf_range(0.9, 1.1))
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


func guru_buka(id: String):
    var p = pintu[id]
    if p["terbuka"] or p["sibuk"]:
        return
    var d = 0.0
    if pemain != null:
        d = p["pivot"].global_position.distance_to(pemain.global_position)
    _ayun_pintu(id, true, clampf(-2.0 - d * 1.5, -40.0, -2.0))


func _pintu_aksi(id: String):
    var p = pintu[id]
    if p["sibuk"]:
        return
    _ayun_pintu(id, not p["terbuka"], -3.0)
    if guru != null:
        guru.dengar(p["pivot"].global_position, 7.0)


# ---------- dokumen ----------

func _baca(id: String):
    if not teks_dokumen.has(id):
        return
    sedang_adegan = true
    pemain.terkunci = true
    if guru != null:
        guru.jeda = true
    await hud.fade(0.8, 0.2)
    await hud.kartu(teks_dokumen[id], 16.0)
    await hud.fade(0.0, 0.2)
    if not dokumen_dibaca.has(id):
        dokumen_dibaca.append(id)
        GameState.data["dokumen"] = dokumen_dibaca
        GameState.simpan()
    pemain.terkunci = false
    sedang_adegan = false
    if guru != null:
        guru.jeda = false
    if komentar_dokumen.has(id):
        hud.bicara(komentar_dokumen[id], 4.0)


# ---------- bersembunyi ----------

func _mulai_sembunyi(id: String):
    var s = tempat[id]
    guru_tahu = false
    if guru != null and guru.state == "kejar":
        if guru.melihat_sekarang or guru.tak_terlihat < 1.0:
            guru_tahu = true
    sembunyi_id = id
    sembunyi_pos = s["depan"]
    pemain.global_position = s["dalam"]
    pemain.yaw = s["yaw"]
    pemain.pitch = 0.0
    pemain.velocity = Vector3.ZERO
    pemain.terkunci = true
    pemain.beku = true
    hud.set_celah(true)
    Sfx.putar("pintu_buka", -12.0, 1.3)


func _keluar_sembunyi():
    var s = tempat[sembunyi_id]
    pemain.global_position = s["keluar"]
    pemain.beku = false
    pemain.terkunci = false
    sembunyi_id = ""
    hud.set_celah(false)
    Sfx.putar("pintu_buka", -12.0, 1.3)


# ---------- Sang Guru dan tertangkap ----------

func munculkan_guru(pos: Vector3, skrip = null):
    if skrip == null:
        skrip = GuruScript
    guru = skrip.new()
    guru.dunia = self
    guru.pemain = pemain
    add_child(guru)
    guru.mulai(pos)
    return guru


func tertangkap():
    if mati or selesai:
        return
    mati = true
    pemain.terkunci = true
    pemain.beku = false
    if guru != null:
        guru.berhenti()
        var d = guru.global_position - pemain.global_position
        pemain.yaw = atan2(-d.x, -d.z)
        pemain.pitch = 0.2
    hud.set_celah(false)
    hud.set_waspada(0.0, false)
    var raung = "guru_kejar"
    if guru != null:
        raung = guru.suara_raung
    Sfx.putar(raung, 0.0)
    Sfx.putar("jumpscare", 0.0)
    Input.vibrate_handheld(600)
    hud.kilat(0.5)
    pemain.getar(0.6, 0.1)
    await get_tree().create_timer(1.0).timeout
    await hud.fade(1.0, 0.5)
    Sfx.henti_loop("detak_jantung")
    hud.tampil_kontrol(false)
    await hud.layar_akhir("TERTANGKAP", pesan_tangkap, "Sentuh KIRI untuk mencoba lagi   |   Sentuh KANAN untuk kembali ke menu")
    if hud.pilihan_menu == "kanan" and kembali_menu.is_valid():
        kembali_menu.call()
        return
    _ulangi()


func _ulangi():
    hud.judul_sembunyi()
    sembunyi_id = ""
    pemain.beku = false
    pemain.global_position = titik_ulang
    pemain.yaw = yaw_ulang
    pemain.pitch = 0.0
    pemain.velocity = Vector3.ZERO
    if pemain.senter_ada:
        pemain.senter.visible = true
    if guru != null:
        guru.reset(guru_ulang)
    Sfx.mulai_loop("detak_jantung", -38.0)
    mati = false
    await hud.fade(0.0, 0.8)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.bicara(pesan_ulang, 3.0)
