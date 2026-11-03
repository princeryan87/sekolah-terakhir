extends "res://scripts/guru.gd"

# Tuyul: anak kecil nakal. Saat Raka membawa barang (target_aktif), dia mengendap mendekat lalu mencuri
# (on_curi() harus mengembalikan true). Setelah itu kabur sambil membawa barang. Rebut kembali dengan
# mendekat < 1,3 meter (on_rebut()). Setelah 35 detik membawa, dia menjatuhkannya (on_jatuh(pos)).
# Perilaku guru.gd dilewati seluruhnya lewat _ganti_proses().

var on_curi = Callable()
var on_rebut = Callable()
var on_jatuh = Callable()
var target_aktif = false
var membawa = false
var _mode = "mengintai"
var _timer = 2.0
var _rep_t = 0.0
var _giggle_t = 6.0
var _bawa_t = 0.0
var _bergerak = false
var _kilau = null


func _buat_model():
    kec_patroli = 2.0
    kec_kejar = 3.6
    suara_langkah = "tuyul_langkah"
    suara_raung = "tuyul_tawa"
    var kulit = Color(0.45, 0.5, 0.38)
    var kain = Color(0.35, 0.2, 0.12)
    Util.kotak(self, Vector3(0.0, 0.55, 0.0), Vector3(0.28, 0.4, 0.2), kulit, false)
    Util.kotak(self, Vector3(-0.07, 0.2, 0.0), Vector3(0.08, 0.4, 0.08), kulit, false)
    Util.kotak(self, Vector3(0.07, 0.2, 0.0), Vector3(0.08, 0.4, 0.08), kulit, false)
    Util.kotak(self, Vector3(0.0, 0.38, -0.01), Vector3(0.3, 0.15, 0.22), kain, false)
    Util.kotak(self, Vector3(0.0, 0.95, 0.0), Vector3(0.36, 0.34, 0.32), kulit, false)
    Util.kotak(self, Vector3(-0.2, 0.98, 0.0), Vector3(0.06, 0.14, 0.06), kulit, false)
    Util.kotak(self, Vector3(0.2, 0.98, 0.0), Vector3(0.06, 0.14, 0.06), kulit, false)
    Util.kotak(self, Vector3(-0.08, 0.98, -0.17), Vector3(0.07, 0.08, 0.02), Color(1.0, 1.0, 0.8), false, 1.5)
    Util.kotak(self, Vector3(0.08, 0.98, -0.17), Vector3(0.07, 0.08, 0.02), Color(1.0, 1.0, 0.8), false, 1.5)
    Util.kotak(self, Vector3(-0.08, 0.98, -0.18), Vector3(0.03, 0.04, 0.01), Color(0.0, 0.0, 0.0), false)
    Util.kotak(self, Vector3(0.08, 0.98, -0.18), Vector3(0.03, 0.04, 0.01), Color(0.0, 0.0, 0.0), false)
    Util.kotak(self, Vector3(0.0, 0.85, -0.17), Vector3(0.2, 0.04, 0.02), Color(0.02, 0.0, 0.0), false)
    Util.kotak(self, Vector3(0.0, 0.855, -0.175), Vector3(0.16, 0.02, 0.01), Color(0.9, 0.9, 0.8), false)
    Util.kotak(self, Vector3(-0.2, 0.55, 0.0), Vector3(0.06, 0.35, 0.06), kulit, false)
    Util.kotak(self, Vector3(0.2, 0.55, 0.0), Vector3(0.06, 0.35, 0.06), kulit, false)
    _kilau = Util.kotak(self, Vector3(0.0, 1.3, 0.0), Vector3(0.3, 0.02, 0.22), Color(0.8, 0.85, 0.95), false, 1.5)
    _kilau.visible = false


func _ganti_proses(delta):
    if state == "berhenti":
        return true
    var dist = global_position.distance_to(pemain.global_position)
    _giggle_t -= delta
    if _giggle_t <= 0.0:
        _giggle_t = randf_range(6.0, 11.0)
        if dist < 22.0:
            Sfx.putar("tuyul_tawa", clampf(-6.0 - dist * 1.2, -40.0, -6.0), randf_range(1.1, 1.3))
    _rep_t -= delta
    _bergerak = false
    if _mode == "mengintai":
        _mengintai(delta, dist)
    elif _mode == "kabur":
        _kabur(delta, dist)
    else:
        _reda(delta)
    if _bergerak:
        _langkah_t -= delta
        if _langkah_t <= 0.0:
            _langkah_t = 0.3
            if dist < 16.0:
                Sfx.putar(suara_langkah, clampf(-10.0 - dist * 1.5, -40.0, -10.0), randf_range(0.9, 1.2))
    return true


func _mengintai(delta: float, dist: float):
    if not target_aktif:
        if jalur.is_empty():
            _timer -= delta
            if _timer <= 0.0:
                _timer = randf_range(1.0, 3.0)
                _pilih_patroli()
        else:
            _maju(delta, kec_patroli)
            _bergerak = true
        return
    if dist > 1.5 and _dipandang():
        _hadap_ke(pemain.global_position, delta)
        return
    if _rep_t <= 0.0:
        _rep_t = 0.6
        _jalur_ke(pemain.global_position)
    var kec = 2.6
    if dist < 3.5:
        kec = 4.2
    _maju(delta, kec)
    _bergerak = true
    if dist < 0.9:
        var ok = false
        if on_curi.is_valid():
            ok = on_curi.call()
        if ok:
            membawa = true
            _bawa_t = 0.0
            _kilau.visible = true
            _mode = "kabur"
            _jalur_menjauh()
            _rep_t = 0.5
            Sfx.putar("tuyul_tawa", -2.0, 1.3)


func _kabur(delta: float, dist: float):
    _bergerak = true
    _bawa_t += delta
    if _rep_t <= 0.0:
        _rep_t = 0.5
        if dist < 7.0 or jalur.is_empty():
            _jalur_menjauh()
    _maju(delta, kec_kejar)
    if dist < 1.3:
        membawa = false
        _kilau.visible = false
        if on_rebut.is_valid():
            on_rebut.call()
        _mode = "reda"
        _timer = 10.0
        _jalur_menjauh()
        Sfx.putar("tuyul_tawa", -2.0, 1.4)
        return
    if _bawa_t > 35.0:
        membawa = false
        _kilau.visible = false
        if on_jatuh.is_valid():
            on_jatuh.call(global_position)
        _mode = "reda"
        _timer = 12.0
        _jalur_menjauh()


func _reda(delta: float):
    _bergerak = true
    _timer -= delta
    if jalur.is_empty() or _rep_t <= 0.0:
        _rep_t = 0.7
        _jalur_menjauh()
    _maju(delta, kec_kejar)
    if _timer <= 0.0:
        _mode = "mengintai"
        _timer = 2.0


func _dipandang() -> bool:
    var titik = global_position + Vector3(0.0, 0.7, 0.0)
    var asal = pemain.kamera.global_position
    var ke = titik - asal
    var jarak = ke.length()
    if jarak > 12.0 or jarak < 0.05:
        return false
    var depan = -pemain.kamera.global_transform.basis.z
    if depan.dot(ke.normalized()) < 0.8:
        return false
    var q = PhysicsRayQueryParameters3D.create(asal, titik)
    q.exclude = [pemain.get_rid()]
    return get_world_3d().direct_space_state.intersect_ray(q).is_empty()


# pilih tujuan yang jauh dari pemain tetapi tidak terlalu jauh dari Tuyul sendiri
func _jalur_menjauh():
    var terbaik = TUJUAN_PATROLI[0]
    var skor_max = -1000000.0
    for n in TUJUAN_PATROLI:
        var skor = NODE[n].distance_to(pemain.global_position) - 0.5 * NODE[n].distance_to(global_position)
        if skor > skor_max:
            skor_max = skor
            terbaik = n
    _jalur_ke(NODE[terbaik])
