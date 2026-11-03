extends "res://scripts/guru.gd"

# Pocong: terus mendekat dengan melompat, tetapi MEMBEKU selama disorot senter
# (atau terlihat langsung dari jarak sangat dekat). Menangkap jika sudah berada < 1 meter.
# Perilaku guru.gd dilewati seluruhnya lewat _ganti_proses().

var _lompat = 0.0
var _rep_t = 0.0
var membeku = false


func _buat_model():
    kec_kejar = 2.2
    suara_langkah = "pocong_lompat"
    suara_raung = "pocong_erang"
    var kain = Color(0.85, 0.82, 0.72)
    var kotor = Color(0.45, 0.35, 0.22)
    Util.kotak(self, Vector3(0.0, 0.95, 0.0), Vector3(0.52, 1.9, 0.42), kain, false)
    Util.kotak(self, Vector3(0.0, 1.95, 0.0), Vector3(0.36, 0.34, 0.34), kain, false)
    Util.kotak(self, Vector3(0.0, 2.2, 0.0), Vector3(0.12, 0.14, 0.12), kain, false)
    Util.kotak(self, Vector3(0.0, 1.76, 0.0), Vector3(0.4, 0.06, 0.38), kotor, false)
    Util.kotak(self, Vector3(0.0, 0.5, 0.0), Vector3(0.54, 0.06, 0.44), kotor, false)
    Util.kotak(self, Vector3(0.0, 0.08, 0.0), Vector3(0.4, 0.14, 0.34), kain, false)
    Util.kotak(self, Vector3(0.12, 1.2, -0.22), Vector3(0.2, 0.3, 0.02), kotor, false)
    Util.kotak(self, Vector3(0.0, 1.97, -0.18), Vector3(0.24, 0.2, 0.02), Color(0.05, 0.03, 0.03), false)
    Util.kotak(self, Vector3(-0.06, 2.0, -0.2), Vector3(0.04, 0.04, 0.02), Color(1.0, 0.2, 0.1), false, 2.0)
    Util.kotak(self, Vector3(0.06, 2.0, -0.2), Vector3(0.04, 0.04, 0.02), Color(1.0, 0.2, 0.1), false, 2.0)
    var cahaya = OmniLight3D.new()
    cahaya.position = Vector3(0.0, 1.8, -0.8)
    cahaya.light_color = Color(0.8, 0.85, 1.0)
    cahaya.light_energy = 0.5
    cahaya.omni_range = 2.5
    cahaya.shadow_enabled = false
    add_child(cahaya)


func _ganti_proses(delta):
    if state == "berhenti":
        return true
    var dist = global_position.distance_to(pemain.global_position)
    waspada = clampf(1.0 - dist / 14.0, 0.0, 1.0)
    membeku = _disorot()
    if membeku:
        _hadap_ke(pemain.global_position, delta)
        global_position.y = 0.0
        return true
    _rep_t -= delta
    if _rep_t <= 0.0:
        _rep_t = 0.5
        _jalur_ke(pemain.global_position)
    _maju(delta, kec_kejar)
    _lompat += delta / 0.6
    if _lompat >= 1.0:
        _lompat -= 1.0
        if dist < 24.0:
            Sfx.putar(suara_langkah, clampf(-6.0 - dist * 1.4, -40.0, -6.0), randf_range(0.9, 1.1))
    global_position.y = absf(sin(_lompat * PI)) * 0.4
    if dist < 1.0:
        dunia.tertangkap()
    return true


func _disorot() -> bool:
    var titik = global_position + Vector3(0.0, 1.0, 0.0)
    var asal = pemain.kamera.global_position
    var ke = titik - asal
    var jarak = ke.length()
    if jarak < 0.05:
        return false
    var depan = -pemain.kamera.global_transform.basis.z
    var sudut = depan.dot(ke.normalized())
    var terlihat = false
    if pemain.senter.visible and jarak <= 14.0 and sudut > 0.86:
        terlihat = true
    elif jarak <= 2.5 and sudut > 0.7:
        terlihat = true
    if not terlihat:
        return false
    var q = PhysicsRayQueryParameters3D.create(asal, titik)
    q.exclude = [pemain.get_rid()]
    return get_world_3d().direct_space_state.intersect_ray(q).is_empty()
