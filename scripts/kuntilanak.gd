extends "res://scripts/guru.gd"

# Kuntilanak agresif (Misi 7): melayang (tanpa langkah kaki), tertawa dari jauh,
# lebih cepat daripada Sang Guru saat mengejar, dan pendengarannya 40 persen lebih tajam.
# Mengejar cahaya: jarak_lihat_senter besar.

var _tawa_t = 8.0
var _waktu = 0.0


func _buat_model():
    kec_patroli = 1.9
    kec_curiga = 2.8
    kec_cari = 2.8
    kec_kejar = 4.1
    jarak_lihat = 7.0
    jarak_lihat_senter = 12.0
    suara_langkah = "kuntilanak_melayang"
    suara_raung = "kuntilanak_tawa"

    var gaun = Color(0.85, 0.85, 0.8)
    var noda = Color(0.5, 0.05, 0.05)
    var kulit = Color(0.72, 0.72, 0.66)
    var rambut = Color(0.02, 0.02, 0.02)
    Util.kotak(self, Vector3(0.0, 0.9, 0.0), Vector3(0.62, 1.7, 0.34), gaun, false)
    Util.kotak(self, Vector3(0.0, 1.8, 0.0), Vector3(0.5, 0.35, 0.3), gaun, false)
    Util.kotak(self, Vector3(0.0, 2.05, -0.04), Vector3(0.3, 0.32, 0.28), kulit, false)
    Util.kotak(self, Vector3(0.0, 1.6, 0.08), Vector3(0.46, 1.5, 0.34), rambut, false)
    Util.kotak(self, Vector3(0.0, 2.18, -0.07), Vector3(0.36, 0.12, 0.3), rambut, false)
    Util.kotak(self, Vector3(-0.17, 2.0, -0.13), Vector3(0.05, 0.5, 0.1), rambut, false)
    Util.kotak(self, Vector3(0.17, 2.0, -0.13), Vector3(0.05, 0.5, 0.1), rambut, false)
    Util.kotak(self, Vector3(-0.07, 2.03, -0.19), Vector3(0.05, 0.04, 0.02), Color(1.0, 0.1, 0.05), false, 1.8)
    Util.kotak(self, Vector3(0.07, 2.03, -0.19), Vector3(0.05, 0.04, 0.02), Color(1.0, 0.1, 0.05), false, 1.8)
    Util.kotak(self, Vector3(0.0, 1.92, -0.19), Vector3(0.1, 0.03, 0.02), Color(0.02, 0.0, 0.0), false)
    Util.kotak(self, Vector3(0.1, 1.0, -0.18), Vector3(0.2, 0.35, 0.02), noda, false)
    Util.kotak(self, Vector3(-0.15, 0.5, -0.18), Vector3(0.15, 0.25, 0.02), noda, false)
    var l1 = Util.kotak(self, Vector3(-0.4, 1.2, -0.08), Vector3(0.1, 1.1, 0.1), kulit, false)
    var l2 = Util.kotak(self, Vector3(0.4, 1.2, -0.08), Vector3(0.1, 1.1, 0.1), kulit, false)
    l1.rotation_degrees.x = -25.0
    l2.rotation_degrees.x = -25.0
    var cahaya = OmniLight3D.new()
    cahaya.position = Vector3(0.0, 2.0, -1.0)
    cahaya.light_color = Color(0.75, 0.85, 1.0)
    cahaya.light_energy = 1.2
    cahaya.omni_range = 4.5
    cahaya.shadow_enabled = false
    add_child(cahaya)


func dengar(pos: Vector3, radius: float):
    super.dengar(pos, radius * 1.4)


func _ganti_proses(delta):
    _waktu += delta
    global_position.y = 0.3 + sin(_waktu * 2.0) * 0.08
    if state != "berhenti":
        _tawa_t -= delta
        if _tawa_t <= 0.0:
            _tawa_t = randf_range(12.0, 20.0)
            var d = global_position.distance_to(pemain.global_position)
            if d < 30.0:
                Sfx.putar("kuntilanak_tawa", clampf(-6.0 - d * 1.0, -40.0, -6.0), randf_range(0.95, 1.05))
    return false
