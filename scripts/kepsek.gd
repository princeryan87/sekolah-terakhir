extends "res://scripts/guru.gd"

# Kepala Sekolah, bos terakhir. Berpatroli, melihat jauh, dan mengejar seperti Sang Guru tetapi lebih cepat.
# Jika terlalu lama kehilangan jejak, dia berteleportasi ke dekat Raka (tidak saat Raka bersembunyi).
# Misi melemahkannya dengan menurunkan kec_kejar setiap lonceng dibunyikan.

var _tak_t = 0.0


func _buat_model():
    kec_patroli = 1.8
    kec_curiga = 2.8
    kec_cari = 2.6
    kec_kejar = 3.9
    jarak_lihat = 7.0
    jarak_lihat_senter = 12.0
    suara_langkah = "langkah_guru"
    suara_raung = "kepsek_geram"

    var jas = Color(0.12, 0.12, 0.15)
    var kulit = Color(0.75, 0.74, 0.7)
    var emas = Color(0.95, 0.75, 0.2)
    Util.kotak(self, Vector3(-0.14, 0.6, 0.0), Vector3(0.2, 1.2, 0.22), Color(0.05, 0.05, 0.07), false)
    Util.kotak(self, Vector3(0.14, 0.6, 0.0), Vector3(0.2, 1.2, 0.22), Color(0.05, 0.05, 0.07), false)
    Util.kotak(self, Vector3(0.0, 1.75, 0.0), Vector3(0.8, 1.2, 0.42), jas, false)
    Util.kotak(self, Vector3(0.0, 1.9, -0.22), Vector3(0.2, 0.7, 0.02), Color(0.9, 0.9, 0.88), false)
    Util.kotak(self, Vector3(0.0, 1.75, -0.23), Vector3(0.08, 0.6, 0.02), Color(0.7, 0.05, 0.05), false)
    Util.kotak(self, Vector3(0.22, 2.0, -0.23), Vector3(0.1, 0.06, 0.02), emas, false, 1.5)
    Util.kotak(self, Vector3(0.0, 2.55, 0.0), Vector3(0.38, 0.44, 0.34), kulit, false)
    Util.kotak(self, Vector3(0.0, 2.82, 0.0), Vector3(0.42, 0.16, 0.38), Color(0.85, 0.85, 0.85), false)
    Util.kotak(self, Vector3(-0.09, 2.58, -0.18), Vector3(0.12, 0.09, 0.02), Color(0.02, 0.02, 0.02), false)
    Util.kotak(self, Vector3(0.09, 2.58, -0.18), Vector3(0.12, 0.09, 0.02), Color(0.02, 0.02, 0.02), false)
    Util.kotak(self, Vector3(-0.09, 2.58, -0.195), Vector3(0.04, 0.04, 0.01), Color(1.0, 0.1, 0.05), false, 2.5)
    Util.kotak(self, Vector3(0.09, 2.58, -0.195), Vector3(0.04, 0.04, 0.01), Color(1.0, 0.1, 0.05), false, 2.5)
    Util.kotak(self, Vector3(0.0, 2.42, -0.18), Vector3(0.18, 0.03, 0.02), Color(0.03, 0.0, 0.0), false)
    var l1 = Util.kotak(self, Vector3(-0.52, 1.7, -0.05), Vector3(0.14, 1.2, 0.14), jas, false)
    var l2 = Util.kotak(self, Vector3(0.52, 1.7, -0.05), Vector3(0.14, 1.2, 0.14), jas, false)
    l1.rotation_degrees.x = -15.0
    l2.rotation_degrees.x = -15.0
    Util.kotak(self, Vector3(0.6, 0.95, -0.35), Vector3(0.05, 1.9, 0.05), emas, false, 0.6)
    # mahkota bayangan penguasa kerajaan hantu
    for i in range(5):
        var sudut = TAU * i / 5.0
        Util.kotak(self, Vector3(sin(sudut) * 0.17, 3.1, cos(sudut) * 0.17), Vector3(0.05, 0.22, 0.05), emas, false, 1.5)
    var cahaya = OmniLight3D.new()
    cahaya.position = Vector3(0.0, 2.0, -0.8)
    cahaya.light_color = Color(1.0, 0.2, 0.1)
    cahaya.light_energy = 1.5
    cahaya.omni_range = 6.0
    cahaya.shadow_enabled = false
    add_child(cahaya)


func _ganti_proses(delta):
    if melihat_sekarang or state == "kejar":
        _tak_t = 0.0
    else:
        _tak_t += delta
        if _tak_t > 14.0 and dunia.sembunyi_id == "":
            _tak_t = 0.0
            _teleport()
    return false


func _teleport():
    var kandidat = []
    for n in NODE:
        var d = NODE[n].distance_to(pemain.global_position)
        if d >= 8.0 and d <= 16.0:
            kandidat.append(n)
    if kandidat.is_empty():
        return
    var pilih = kandidat[randi() % kandidat.size()]
    var d_awal = global_position.distance_to(pemain.global_position)
    global_position = NODE[pilih]
    Sfx.putar("kepsek_muncul", clampf(-4.0 - d_awal * 0.5, -30.0, -4.0))
    curiga(pemain.global_position)
