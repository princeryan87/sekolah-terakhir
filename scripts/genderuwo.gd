extends "res://scripts/guru.gd"

# Genderuwo: lebih lambat dari Sang Guru, tapi menutup pintu dan sulit dihindari.
# Kelemahan: takut cahaya. Jika disorot senter dari dekat, dia mundur beberapa detik.

var silau = 0.0
var _jeda_silau = 0.0
var _cek_pintu_t = 2.0


func _buat_model():
    kec_patroli = 1.3
    kec_curiga = 2.0
    kec_cari = 1.8
    kec_kejar = 3.3
    jarak_lihat = 7.0
    jarak_lihat_senter = 8.0
    suara_langkah = "genderuwo_langkah"
    suara_raung = "genderuwo_geram"

    var bulu = Color(0.1, 0.07, 0.05)
    var kulit = Color(0.16, 0.11, 0.09)
    Util.kotak(self, Vector3(-0.28, 0.6, 0.0), Vector3(0.38, 1.2, 0.4), bulu, false)
    Util.kotak(self, Vector3(0.28, 0.6, 0.0), Vector3(0.38, 1.2, 0.4), bulu, false)
    Util.kotak(self, Vector3(0.0, 1.7, 0.0), Vector3(1.0, 1.2, 0.65), bulu, false)
    Util.kotak(self, Vector3(0.0, 2.42, -0.1), Vector3(0.6, 0.55, 0.5), kulit, false)
    Util.kotak(self, Vector3(0.0, 2.78, -0.05), Vector3(0.7, 0.2, 0.55), bulu, false)
    Util.kotak(self, Vector3(-0.15, 2.5, -0.36), Vector3(0.1, 0.07, 0.03), Color(1.0, 0.35, 0.05), false, 2.5)
    Util.kotak(self, Vector3(0.15, 2.5, -0.36), Vector3(0.1, 0.07, 0.03), Color(1.0, 0.35, 0.05), false, 2.5)
    Util.kotak(self, Vector3(0.0, 2.27, -0.36), Vector3(0.3, 0.08, 0.03), Color(0.03, 0.0, 0.0), false)
    Util.kotak(self, Vector3(-0.1, 2.2, -0.37), Vector3(0.05, 0.12, 0.04), Color(0.9, 0.9, 0.8), false)
    Util.kotak(self, Vector3(0.1, 2.2, -0.37), Vector3(0.05, 0.12, 0.04), Color(0.9, 0.9, 0.8), false)
    var l1 = Util.kotak(self, Vector3(-0.72, 1.45, -0.12), Vector3(0.28, 1.5, 0.28), bulu, false)
    var l2 = Util.kotak(self, Vector3(0.72, 1.45, -0.12), Vector3(0.28, 1.5, 0.28), bulu, false)
    l1.rotation_degrees.x = -15.0
    l2.rotation_degrees.x = -15.0
    Util.kotak(self, Vector3(-0.72, 0.65, -0.3), Vector3(0.36, 0.3, 0.36), kulit, false)
    Util.kotak(self, Vector3(0.72, 0.65, -0.3), Vector3(0.36, 0.3, 0.36), kulit, false)
    var cahaya = OmniLight3D.new()
    cahaya.position = Vector3(0.0, 1.9, -0.8)
    cahaya.light_color = Color(1.0, 0.35, 0.15)
    cahaya.light_energy = 0.7
    cahaya.omni_range = 3.5
    cahaya.shadow_enabled = false
    add_child(cahaya)


func _ganti_proses(delta):
    _cek_pintu_t -= delta
    if _cek_pintu_t <= 0.0:
        _cek_pintu_t = 1.5
        _tutup_pintu_dekat()
    if _jeda_silau > 0.0:
        _jeda_silau -= delta
    if silau > 0.0:
        silau -= delta
        _maju(delta, 2.4)
        return true
    if pemain.senter.visible and dunia.sembunyi_id == "" and _jeda_silau <= 0.0 and _terkena_senter():
        silau = 3.0
        _jeda_silau = 8.0
        waspada = 0.0
        state = "patroli"
        _jalur_menjauh()
        Sfx.putar(suara_raung, -4.0, 1.3)
        return true
    return false


func _terkena_senter() -> bool:
    var titik = global_position + Vector3(0.0, 1.6, 0.0)
    var asal = pemain.kamera.global_position
    var ke = titik - asal
    var jarak = ke.length()
    if jarak > 9.0 or jarak < 0.5:
        return false
    var depan = -pemain.kamera.global_transform.basis.z
    if depan.dot(ke.normalized()) < 0.92:
        return false
    var q = PhysicsRayQueryParameters3D.create(asal, titik)
    q.exclude = [pemain.get_rid()]
    return get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func _jalur_menjauh():
    var terjauh = TUJUAN_PATROLI[0]
    var jmax = -1.0
    for n in TUJUAN_PATROLI:
        var d = NODE[n].distance_to(pemain.global_position)
        if d > jmax:
            jmax = d
            terjauh = n
    _jalur_ke(NODE[terjauh])


func _tutup_pintu_dekat():
    for id in dunia.pintu:
        if id == "pintu_perpus":
            continue
        var p = dunia.pintu[id]
        if p["terbuka"] and not p["sibuk"]:
            if p["pivot"].global_position.distance_to(global_position) < 2.8 and randf() < 0.3:
                var d = p["pivot"].global_position.distance_to(pemain.global_position)
                dunia._ayun_pintu(id, false, clampf(-2.0 - d * 1.5, -40.0, -2.0))
                break
