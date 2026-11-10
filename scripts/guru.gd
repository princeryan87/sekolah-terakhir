extends Node3D

# Sang Guru. Bergerak lewat titik-titik jalur (tanpa fisika), punya mata dan telinga.
# Status: patroli, tunggu, curiga, kejar, cari, periksa, berhenti

const Util = preload("res://scripts/util.gd")

# Pengaturan kesulitan (misi boleh mengubah setelah guru dibuat)
var kec_patroli = 1.6
var kec_curiga = 2.4
var kec_cari = 2.2
var kec_kejar = 3.9
var jarak_lihat = 5.5
var jarak_lihat_senter = 10.0
var suara_langkah = "langkah_guru"
var suara_raung = "guru_kejar"

# Peta jalur diambil dari dunia (dunia.peta_node, peta_sisi, peta_patroli, peta_pintu)
var NODE = {}
var SISI = []
var TUJUAN_PATROLI = []
var PINTU_NODE = {}

var dunia
var pemain
var state = "patroli"
var jeda = false
var waspada = 0.0
var melihat_sekarang = false
var tak_terlihat = 0.0
var terakhir_terlihat = Vector3.ZERO
var jalur = []
var graf = {}
var timer = 0.0
var _langkah_t = 0.0
var _cek_tempat = false
var _ke_spot = false
var _jalur_hilang = false


func _ready():
    NODE = dunia.peta_node
    SISI = dunia.peta_sisi
    TUJUAN_PATROLI = dunia.peta_patroli
    PINTU_NODE = dunia.peta_pintu
    for n in NODE:
        graf[n] = []
    for s in SISI:
        graf[s[0]].append(s[1])
        graf[s[1]].append(s[0])
    _buat_model()


func _buat_model():
    var jas = Color(0.14, 0.12, 0.1)
    var celana = Color(0.05, 0.05, 0.06)
    var kulit = Color(0.78, 0.76, 0.7)
    Util.kotak(self, Vector3(-0.12, 0.45, 0.0), Vector3(0.18, 0.9, 0.2), celana, false)
    Util.kotak(self, Vector3(0.12, 0.45, 0.0), Vector3(0.18, 0.9, 0.2), celana, false)
    Util.kotak(self, Vector3(0.0, 1.35, 0.0), Vector3(0.62, 0.95, 0.34), jas, false)
    Util.kotak(self, Vector3(0.0, 2.0, -0.02), Vector3(0.27, 0.42, 0.28), kulit, false)
    Util.kotak(self, Vector3(-0.08, 2.05, -0.16), Vector3(0.09, 0.06, 0.02), Color(0.02, 0.02, 0.02), false)
    Util.kotak(self, Vector3(0.08, 2.05, -0.16), Vector3(0.09, 0.06, 0.02), Color(0.02, 0.02, 0.02), false)
    Util.kotak(self, Vector3(-0.08, 2.05, -0.175), Vector3(0.03, 0.03, 0.01), Color(1.0, 0.1, 0.05), false, 2.0)
    Util.kotak(self, Vector3(0.08, 2.05, -0.175), Vector3(0.03, 0.03, 0.01), Color(1.0, 0.1, 0.05), false, 2.0)
    Util.kotak(self, Vector3(0.0, 1.88, -0.16), Vector3(0.14, 0.02, 0.02), Color(0.03, 0.0, 0.0), false)
    var l1 = Util.kotak(self, Vector3(-0.4, 1.3, -0.12), Vector3(0.1, 1.0, 0.1), jas, false)
    var l2 = Util.kotak(self, Vector3(0.4, 1.3, -0.12), Vector3(0.1, 1.0, 0.1), jas, false)
    l1.rotation_degrees.x = -18.0
    l2.rotation_degrees.x = -18.0
    Util.kotak(self, Vector3(0.4, 0.8, -0.3), Vector3(0.09, 0.12, 0.09), kulit, false)
    Util.kotak(self, Vector3(0.4, 0.85, -0.85), Vector3(0.03, 0.03, 1.3), Color(0.5, 0.35, 0.15), false)
    var cahaya = OmniLight3D.new()
    cahaya.position = Vector3(0.0, 1.6, -0.7)
    cahaya.light_color = Color(0.9, 0.25, 0.2)
    cahaya.light_energy = 0.6
    cahaya.omni_range = 3.0
    cahaya.shadow_enabled = false
    add_child(cahaya)


# Kait untuk hantu turunan: kembalikan true jika perilaku normal harus dilewati.
func _ganti_proses(_delta):
    return false


# ---------- perintah dari luar ----------

func mulai(pos: Vector3):
    global_position = pos
    _pilih_patroli()


func reset(pos: Vector3):
    global_position = pos
    waspada = 0.0
    tak_terlihat = 0.0
    jeda = false
    jalur.clear()
    _pilih_patroli()


func berhenti():
    state = "berhenti"


func dengar(pos: Vector3, radius: float):
    if state == "kejar" or state == "periksa" or state == "berhenti":
        return
    if global_position.distance_to(pos) > radius:
        return
    if state == "curiga" and not jalur.is_empty():
        if jalur[jalur.size() - 1].distance_to(pos) < 2.5:
            return
    _jalur_ke(pos)
    state = "curiga"


# Membuat hantu menuju satu titik untuk memeriksa (dipakai misi untuk memancing hantu).
func curiga(pos: Vector3):
    dengar(pos, 1000000.0)


# ---------- jalur ----------

func _node_terdekat(p: Vector3) -> String:
    var terbaik = NODE.keys()[0]
    var jarak_min = 1000000.0
    for n in NODE:
        var d = NODE[n].distance_to(Vector3(p.x, 0.0, p.z))
        if d < jarak_min:
            jarak_min = d
            terbaik = n
    return terbaik


func _rute(dari: String, ke: String) -> Array:
    var jarak = {}
    var asal = {}
    var belum = []
    for n in NODE:
        jarak[n] = 1000000.0
        belum.append(n)
    jarak[dari] = 0.0
    while belum.size() > 0:
        var u = belum[0]
        for n in belum:
            if jarak[n] < jarak[u]:
                u = n
        belum.erase(u)
        if u == ke:
            break
        for v in graf[u]:
            var alt = jarak[u] + NODE[u].distance_to(NODE[v])
            if alt < jarak[v]:
                jarak[v] = alt
                asal[v] = u
    var hasil = []
    var cur = ke
    while true:
        hasil.push_front(NODE[cur])
        if cur == dari or not asal.has(cur):
            break
        cur = asal[cur]
    return hasil


func _jalur_ke(target: Vector3):
    var a = _node_terdekat(global_position)
    var b = _node_terdekat(target)
    jalur = _rute(a, b)
    jalur.append(Vector3(target.x, 0.0, target.z))
    if jalur.size() > 1:
        if global_position.distance_to(jalur[1]) < jalur[0].distance_to(jalur[1]):
            jalur.remove_at(0)


func _pilih_patroli():
    var kandidat = TUJUAN_PATROLI.duplicate()
    kandidat.shuffle()
    var tujuan = kandidat[0]
    if NODE[tujuan].distance_to(global_position) < 2.0:
        tujuan = kandidat[1]
    _jalur_ke(NODE[tujuan])
    state = "patroli"


func _maju(delta: float, kec: float) -> bool:
    if jalur.is_empty():
        return true
    var tgt = jalur[0]
    var d = tgt - global_position
    d.y = 0.0
    var jarak = d.length()
    if jarak < 0.15:
        jalur.remove_at(0)
        return jalur.is_empty()
    var arah = d / jarak
    global_position += arah * minf(kec * delta, jarak)
    _hadap(arah, delta)
    return false


func _hadap(arah: Vector3, delta: float):
    var target = atan2(-arah.x, -arah.z)
    rotation.y = lerp_angle(rotation.y, target, minf(10.0 * delta, 1.0))


func _hadap_ke(pos: Vector3, delta: float):
    var d = pos - global_position
    d.y = 0.0
    if d.length() > 0.05:
        _hadap(d.normalized(), delta)


func _buka_pintu_depan():
    if jalur.is_empty():
        return
    var w = jalur[0]
    for n in PINTU_NODE:
        if w.distance_to(NODE[n]) < 0.1 and global_position.distance_to(w) < 3.2:
            dunia.guru_buka(PINTU_NODE[n])


# ---------- indra ----------

func _bisa_melihat(jarak_datar: float) -> bool:
    if dunia.sembunyi_id != "":
        return false
    var mata = global_position + Vector3(0.0, 1.75, 0.0)
    var target = pemain.global_position + Vector3(0.0, 1.3, 0.0)
    var ke = target - mata
    var jarak = ke.length()
    var batas = jarak_lihat
    if pemain.senter.visible:
        batas = jarak_lihat_senter
    if jarak > batas:
        return false
    var depan = Vector3(-sin(rotation.y), 0.0, -cos(rotation.y))
    var datar = Vector3(ke.x, 0.0, ke.z)
    if datar.length() > 0.01:
        datar = datar.normalized()
        if depan.dot(datar) < 0.3 and jarak > 1.8:
            return false
    var q = PhysicsRayQueryParameters3D.create(mata, target)
    q.exclude = [pemain.get_rid()]
    var h = get_world_3d().direct_space_state.intersect_ray(q)
    return h.is_empty()


func _mulai_kejar():
    state = "kejar"
    waspada = 1.0
    _ke_spot = false
    _jalur_hilang = false
    Sfx.putar(suara_raung, -1.0)
    Input.vibrate_handheld(150)


func _mulai_cari():
    state = "cari"
    timer = 5.0
    waspada = 0.4
    jalur.clear()
    _cek_tempat = randf() < 0.45


# ---------- perilaku ----------

func _process(delta):
    if dunia == null or pemain == null:
        return
    if jeda or dunia.sedang_adegan or dunia.mati or state == "berhenti":
        return
    if _ganti_proses(delta):
        return
    var dist = global_position.distance_to(pemain.global_position)
    melihat_sekarang = _bisa_melihat(dist)
    if melihat_sekarang:
        terakhir_terlihat = pemain.global_position
        tak_terlihat = 0.0
        _jalur_hilang = false
        _ke_spot = false
    else:
        tak_terlihat += delta

    if state != "kejar":
        if melihat_sekarang:
            var laju = 0.7
            if dist < 4.0:
                laju = 1.4
            waspada = minf(waspada + laju * delta, 1.0)
            if waspada >= 1.0:
                _mulai_kejar()
        else:
            waspada = maxf(waspada - 0.35 * delta, 0.0)

    _buka_pintu_depan()
    var bergerak = false

    match state:
        "patroli":
            if melihat_sekarang and waspada > 0.3:
                _hadap_ke(pemain.global_position, delta)
            elif _maju(delta, kec_patroli):
                state = "tunggu"
                timer = randf_range(2.0, 4.0)
            else:
                bergerak = true
        "tunggu":
            timer -= delta
            rotation.y += sin(timer * 1.5) * 0.7 * delta
            if melihat_sekarang and waspada > 0.3:
                _hadap_ke(pemain.global_position, delta)
            if timer <= 0.0:
                _pilih_patroli()
        "curiga":
            if melihat_sekarang and waspada > 0.3:
                _hadap_ke(pemain.global_position, delta)
            elif _maju(delta, kec_curiga):
                state = "tunggu"
                timer = 3.0
            else:
                bergerak = true
        "kejar":
            bergerak = true
            if melihat_sekarang:
                jalur = [Vector3(pemain.global_position.x, 0.0, pemain.global_position.z)]
                _maju(delta, kec_kejar)
                if dist < 1.0:
                    dunia.tertangkap()
            elif dunia.sembunyi_id != "" and dunia.guru_tahu:
                if not _ke_spot:
                    _ke_spot = true
                    _jalur_ke(dunia.sembunyi_pos)
                _maju(delta, kec_kejar)
                if global_position.distance_to(dunia.sembunyi_pos) < 1.4:
                    dunia.tertangkap()
            else:
                if not _jalur_hilang:
                    _jalur_hilang = true
                    _jalur_ke(terakhir_terlihat)
                var tiba = _maju(delta, kec_kejar)
                if tiba or tak_terlihat > 6.0:
                    _mulai_cari()
        "cari":
            if not jalur.is_empty():
                _maju(delta, kec_cari)
                bergerak = true
            else:
                var dekat_spot = dunia.sembunyi_id != "" and global_position.distance_to(dunia.sembunyi_pos) < 6.0
                if _cek_tempat and dekat_spot:
                    _cek_tempat = false
                    _jalur_ke(dunia.sembunyi_pos)
                    state = "periksa"
                else:
                    timer -= delta
                    rotation.y += sin(timer * 2.0) * 0.9 * delta
                    if timer <= 0.0:
                        waspada = 0.0
                        _pilih_patroli()
            if melihat_sekarang and waspada > 0.3:
                _hadap_ke(pemain.global_position, delta)
        "periksa":
            bergerak = true
            _maju(delta, 1.8)
            if global_position.distance_to(dunia.sembunyi_pos) < 1.4:
                if dunia.sembunyi_id != "":
                    dunia.tertangkap()
                else:
                    state = "cari"
                    timer = 3.0

    if bergerak:
        _langkah_t -= delta
        if _langkah_t <= 0.0:
            if state == "kejar":
                _langkah_t = 0.34
            else:
                _langkah_t = 0.62
            if dist < 20.0:
                Sfx.putar(suara_langkah, clampf(-4.0 - dist * 1.6, -40.0, -4.0), randf_range(0.9, 1.1))
