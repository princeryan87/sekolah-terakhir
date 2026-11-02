extends "res://scripts/guru.gd"

# Hantu siswi: bersenandung (suaranya jadi petunjuk jaraknya) dan sesekali berbisik.
# Misi mendengarkan sinyal bisikan untuk menampilkan petunjuk yang kadang menyesatkan.

signal bisikan

var _senandung_t = 2.0
var _bisik_t = 14.0


func _buat_model():
    kec_patroli = 1.5
    kec_curiga = 2.3
    kec_cari = 2.2
    kec_kejar = 3.7
    jarak_lihat = 6.0
    jarak_lihat_senter = 9.0
    suara_langkah = "langkah_jalan"
    suara_raung = "hantu_siswi_bisik"

    var putih = Color(0.82, 0.82, 0.78)
    var rok = Color(0.1, 0.12, 0.25)
    var kulit = Color(0.7, 0.7, 0.66)
    var rambut = Color(0.02, 0.02, 0.02)
    Util.kotak(self, Vector3(-0.09, 0.35, 0.0), Vector3(0.12, 0.7, 0.14), kulit, false)
    Util.kotak(self, Vector3(0.09, 0.35, 0.0), Vector3(0.12, 0.7, 0.14), kulit, false)
    Util.kotak(self, Vector3(-0.09, 0.05, -0.03), Vector3(0.14, 0.1, 0.24), Color(0.03, 0.03, 0.03), false)
    Util.kotak(self, Vector3(0.09, 0.05, -0.03), Vector3(0.14, 0.1, 0.24), Color(0.03, 0.03, 0.03), false)
    Util.kotak(self, Vector3(0.0, 0.85, 0.0), Vector3(0.5, 0.5, 0.34), rok, false)
    Util.kotak(self, Vector3(0.0, 1.3, 0.0), Vector3(0.44, 0.55, 0.3), putih, false)
    var kepala = Util.kotak(self, Vector3(0.0, 1.72, -0.02), Vector3(0.3, 0.3, 0.28), kulit, false)
    kepala.rotation_degrees.z = 12.0
    Util.kotak(self, Vector3(0.0, 1.5, 0.1), Vector3(0.36, 0.8, 0.2), rambut, false)
    Util.kotak(self, Vector3(0.0, 1.85, -0.04), Vector3(0.34, 0.14, 0.3), rambut, false)
    Util.kotak(self, Vector3(-0.2, 1.2, -0.02), Vector3(0.07, 0.65, 0.07), rambut, false)
    Util.kotak(self, Vector3(0.2, 1.2, -0.02), Vector3(0.07, 0.65, 0.07), rambut, false)
    Util.kotak(self, Vector3(-0.07, 1.72, -0.16), Vector3(0.08, 0.07, 0.02), Color(0.0, 0.0, 0.0), false)
    Util.kotak(self, Vector3(0.07, 1.72, -0.16), Vector3(0.08, 0.07, 0.02), Color(0.0, 0.0, 0.0), false)
    Util.kotak(self, Vector3(-0.07, 1.72, -0.175), Vector3(0.025, 0.025, 0.01), Color(0.9, 0.95, 1.0), false, 2.0)
    Util.kotak(self, Vector3(0.07, 1.72, -0.175), Vector3(0.025, 0.025, 0.01), Color(0.9, 0.95, 1.0), false, 2.0)
    Util.kotak(self, Vector3(-0.3, 1.1, -0.05), Vector3(0.08, 0.6, 0.08), kulit, false)
    Util.kotak(self, Vector3(0.3, 1.1, -0.05), Vector3(0.08, 0.6, 0.08), kulit, false)
    var cahaya = OmniLight3D.new()
    cahaya.position = Vector3(0.0, 1.7, -0.8)
    cahaya.light_color = Color(0.7, 0.8, 1.0)
    cahaya.light_energy = 0.6
    cahaya.omni_range = 3.0
    cahaya.shadow_enabled = false
    add_child(cahaya)


func _ganti_proses(delta):
    _senandung_t -= delta
    if _senandung_t <= 0.0:
        _senandung_t = 4.0
        var d = global_position.distance_to(pemain.global_position)
        if d < 24.0:
            Sfx.putar("hantu_siswi_nyanyi", clampf(-4.0 - d * 1.1, -40.0, -4.0), randf_range(0.97, 1.03))
    _bisik_t -= delta
    if _bisik_t <= 0.0:
        _bisik_t = randf_range(16.0, 28.0)
        if state != "kejar" and global_position.distance_to(pemain.global_position) < 10.0:
            bisikan.emit()
    return false
