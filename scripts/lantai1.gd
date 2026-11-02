extends "res://scripts/dunia.gd"

# Gedung sekolah lantai 1.
# Denah (meter): lorong di tengah (x -1.5..1.5, z 0..-24), Kelas 9B di kiri,
# Kelas 9A di kanan, pintu lobi di ujung lorong (z -24).

const TITIK_AWAL = Vector3(-5.5, 0.05, -2.8)

var jam_label
var sampah_node = []
var kunci_node = null


func _bangun():
    teks_dokumen = {
        "dok_1": "SURAT PENUTUPAN SEKOLAH\n\nDengan berat hati, sekolah ini ditutup untuk selamanya. Seluruh siswa dan guru wajib meninggalkan gedung sebelum pukul 00:00.\n\n(Surat ini bertanggal lima belas tahun yang lalu.)",
        "dok_2": "CATATAN GURU PIKET\n\nAda satu siswa yang tidak pernah pulang. Sejak itu semua foto di dinding berganti menjadi wajah yang sama.\n\nJangan menatap matanya terlalu lama.",
        "dok_3": "DAFTAR HADIR\nKelas 9-X (tidak tercatat di denah sekolah)\n\nJumlah siswa: 1\nNama: RAKA\n\nStatus: belum pulang"
    }
    komentar_dokumen = {
        "dok_1": "Raka: Lima belas tahun lalu? Tapi tadi sore sekolah ini masih ramai...",
        "dok_2": "Raka: Foto-foto di lorong itu... wajahnya sama semua.",
        "dok_3": "Raka: Namaku...? Kenapa namaku ada di sini?!"
    }
    _buat_bangunan()
    _buat_kelas_9b()
    _buat_kelas_9a()
    _buat_lorong()
    _atur_peta()
    titik_ulang = Vector3(3.0, 0.05, -6.0)
    yaw_ulang = PI / 2.0
    guru_ulang = Vector3(0.0, 0.0, -21.5)


func _atur_peta():
    peta_node = {
        "K1": Vector3(0.0, 0.0, -2.5),
        "K2": Vector3(0.0, 0.0, -6.0),
        "K3": Vector3(0.0, 0.0, -10.0),
        "K4": Vector3(0.0, 0.0, -14.0),
        "K5": Vector3(0.0, 0.0, -18.0),
        "K6": Vector3(0.0, 0.0, -21.5),
        "DB": Vector3(-1.5, 0.0, -6.0),
        "B1": Vector3(-3.0, 0.0, -6.0),
        "B2": Vector3(-3.0, 0.0, -3.4),
        "B3": Vector3(-3.0, 0.0, -8.8),
        "DA": Vector3(1.5, 0.0, -6.0),
        "A1": Vector3(3.0, 0.0, -6.0),
        "A2": Vector3(3.0, 0.0, -3.4),
        "A3": Vector3(3.0, 0.0, -8.8)
    }
    peta_sisi = [
        ["K1", "K2"], ["K2", "K3"], ["K3", "K4"], ["K4", "K5"], ["K5", "K6"],
        ["K2", "DB"], ["DB", "B1"], ["B1", "B2"], ["B1", "B3"],
        ["K2", "DA"], ["DA", "A1"], ["A1", "A2"], ["A1", "A3"]
    ]
    peta_patroli = ["K1", "K3", "K5", "K6", "B2", "B3", "A2", "A3"]
    peta_pintu = {"DB": "pintu_9b", "DA": "pintu_9a"}


# Keadaan setelah listrik mati (dipakai misi 1 saat lanjut, dan misi 2)
func kondisi_gelap():
    for n in sampah_node:
        if is_instance_valid(n):
            n.queue_free()
    _lampu_padam()
    jam_label.text = "00:00"


# Keadaan setelah kunci lobi diambil: kunci hilang, pintu 9A terbuka
func kondisi_kunci():
    if is_instance_valid(kunci_node):
        kunci_node.queue_free()
    var p = pintu["pintu_9a"]
    p["terbuka"] = true
    p["pivot"].rotation_degrees.y = p["derajat"]
    p["badan"].set_meta("label", "Tutup pintu")


# ---------- bangunan ----------

func _buat_bangunan():
    var dinding = Color(0.52, 0.5, 0.42)
    Util.kotak(self, Vector3(0.0, -0.1, -12.0), Vector3(19.8, 0.2, 24.8), Color(0.3, 0.3, 0.26))
    Util.kotak(self, Vector3(0.0, 3.1, -12.0), Vector3(19.8, 0.2, 24.8), Color(0.4, 0.4, 0.38))
    Util.kotak(self, Vector3(0.0, 0.005, -12.0), Vector3(2.8, 0.01, 24.0), Color(0.22, 0.24, 0.2), false)
    Util.kotak(self, Vector3(-5.55, 0.005, -6.0), Vector3(8.0, 0.01, 8.0), Color(0.36, 0.26, 0.16), false)
    Util.kotak(self, Vector3(5.55, 0.005, -6.0), Vector3(8.0, 0.01, 8.0), Color(0.36, 0.26, 0.16), false)
    _dinding_z(-1.5, -24.0, 0.0, 3.0, dinding, -6.6, -5.4)
    _dinding_z(1.5, -24.0, 0.0, 3.0, dinding, -6.6, -5.4)
    _dinding_x(0.1, -1.6, 1.6, 3.0, dinding)
    _dinding_x(-24.1, -1.6, 1.6, 3.0, dinding, -0.6, 0.6)
    _dinding_z(-9.6, -10.1, -1.9, 3.0, dinding)
    _dinding_x(-1.9, -9.7, -1.6, 3.0, dinding)
    _dinding_x(-10.1, -9.7, -1.6, 3.0, dinding)
    _dinding_z(9.6, -10.1, -1.9, 3.0, dinding)
    _dinding_x(-1.9, 1.6, 9.7, 3.0, dinding)
    _dinding_x(-10.1, 1.6, 9.7, 3.0, dinding)


func _sampah(posisi: Vector3, id: String):
    var b = _benda(posisi + Vector3(0.0, 0.12, 0.0), Vector3(0.55, 0.25, 0.45), Color(0.35, 0.28, 0.2), id, "Sapu sampah", Vector3(0.8, 0.4, 0.7))
    Util.kotak(b, Vector3(0.1, 0.15, 0.05), Vector3(0.22, 0.05, 0.26), Color(0.8, 0.8, 0.75), false)
    Util.kotak(b, Vector3(-0.12, 0.14, -0.08), Vector3(0.18, 0.05, 0.2), Color(0.7, 0.7, 0.65), false)
    sampah_node.append(b)


func _lemari(x: float, id: String):
    # lemari menempel di dinding z -2, menghadap ke dalam kelas (arah -z)
    var b = _benda(Vector3(x, 0.9, -2.4), Vector3(0.9, 1.8, 0.6), Color(0.3, 0.22, 0.15), id, "Sembunyi", Vector3(0.9, 1.8, 0.6))
    Util.kotak(b, Vector3(0.0, 0.0, -0.31), Vector3(0.02, 1.6, 0.02), Color(0.1, 0.07, 0.05), false)
    Util.kotak(b, Vector3(0.1, 0.0, -0.32), Vector3(0.05, 0.14, 0.03), Color(0.7, 0.6, 0.3), false)
    _daftar_tempat(id, Vector3(x, 0.05, -2.4), Vector3(x, 0.05, -3.4), Vector3(x, 0.0, -3.2), 0.0)


func _buat_kelas_9b():
    Util.kotak(self, Vector3(-5.5, 1.5, -9.95), Vector3(4.0, 1.1, 0.06), Color(0.1, 0.22, 0.16), false)
    Util.kotak(self, Vector3(-5.5, 2.5, -9.95), Vector3(2.0, 0.8, 0.06), Color(0.05, 0.05, 0.05), false)
    jam_label = Label3D.new()
    jam_label.text = "16:47"
    jam_label.font_size = 64
    jam_label.pixel_size = 0.008
    jam_label.modulate = Color(1.0, 0.15, 0.1)
    jam_label.position = Vector3(-5.5, 2.5, -9.9)
    add_child(jam_label)
    for z in [-4.0, -8.0]:
        Util.kotak(self, Vector3(-9.49, 1.7, z), Vector3(0.04, 1.1, 1.6), Color(0.25, 0.35, 0.6), false, 0.7)
    for x in [-8.2, -6.2, -4.2]:
        for z in [-4.0, -5.8, -7.6]:
            _meja(x, z)
    _sampah(Vector3(-6.9, 0.0, -2.9), "sampah_1")
    _sampah(Vector3(-3.1, 0.0, -8.7), "sampah_2")
    _sampah(Vector3(-8.8, 0.0, -9.0), "sampah_3")
    _benda(Vector3(-8.2, 0.77, -4.0), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_1", "Baca kertas", Vector3(0.6, 0.3, 0.5), 0.25)
    _lemari(-3.2, "lemari_9b")
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
    Util.kotak(self, Vector3(6.0, 0.375, -9.0), Vector3(1.8, 0.75, 0.7), Color(0.38, 0.27, 0.16))
    kunci_node = _benda(Vector3(6.0, 0.82, -9.0), Vector3(0.18, 0.03, 0.08), Color(0.95, 0.8, 0.2), "kunci_lobi", "Ambil kunci", Vector3(0.5, 0.3, 0.5), 0.6)
    _benda(Vector3(5.2, 0.77, -9.0), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_3", "Baca daftar hadir", Vector3(0.6, 0.3, 0.5), 0.25)
    _lemari(3.2, "lemari_9a")
    _lampu(Vector3(8.6, 2.2, -6.0), Color(0.35, 0.45, 0.9), 0.6, 8.0, false)


func _buat_lorong():
    _buat_pintu("pintu_9b", Vector3(-1.5, 0.0, -5.4), 1.2, true, 90.0)
    _buat_pintu("pintu_9a", Vector3(1.5, 0.0, -5.4), 1.2, true, -90.0)
    _buat_pintu("pintu_lobi", Vector3(-0.6, 0.0, -24.1), 1.2, false, 85.0)
    _tulisan3d("KELAS 9B", Vector3(-1.38, 2.6, -6.0), 90.0)
    _tulisan3d("KELAS 9A", Vector3(1.38, 2.6, -6.0), -90.0)
    _tulisan3d("LOBI", Vector3(0.0, 2.6, -24.0), 0.0)
    for i in range(6):
        _foto(-12.0 - 2.0 * i)
    # catatan di dinding kiri
    _benda(Vector3(-1.37, 1.5, -9.3), Vector3(0.02, 0.3, 0.22), Color(0.9, 0.9, 0.85), "dok_2", "Baca catatan", Vector3(0.2, 0.5, 0.5), 0.25)
    # loker di dinding kanan (bisa dipakai bersembunyi)
    for i in range(8):
        var z = -12.5 - 1.0 * i
        var nama = "loker_%d" % i
        var b = Util.kotak(self, Vector3(1.15, 0.95, z), Vector3(0.5, 1.9, 0.8), Color(0.25, 0.32, 0.4))
        b.set_meta("id", nama)
        b.set_meta("label", "Sembunyi")
        Util.kotak(self, Vector3(0.89, 0.95, z), Vector3(0.02, 1.6, 0.62), Color(0.15, 0.2, 0.26), false)
        Util.kotak(self, Vector3(0.87, 1.1, z + 0.2), Vector3(0.03, 0.12, 0.04), Color(0.6, 0.6, 0.6), false)
        _daftar_tempat(nama, Vector3(1.15, 0.05, z), Vector3(0.2, 0.05, z), Vector3(0.3, 0.0, z), PI / 2.0)
    _lampu(Vector3(0.0, 2.7, -4.0), Color(0.85, 0.95, 0.85), 1.0, 9.0, true)
    _lampu(Vector3(0.0, 2.7, -16.0), Color(0.85, 0.95, 0.85), 1.0, 9.0, true)


func _foto(z: float):
    Util.kotak(self, Vector3(-1.375, 1.7, z), Vector3(0.05, 0.55, 0.42), Color(0.3, 0.2, 0.12), false)
    Util.kotak(self, Vector3(-1.335, 1.7, z), Vector3(0.03, 0.4, 0.32), Color(0.6, 0.58, 0.5), false)
    Util.kotak(self, Vector3(-1.315, 1.76, z - 0.08), Vector3(0.02, 0.06, 0.07), Color(0.04, 0.04, 0.04), false)
    Util.kotak(self, Vector3(-1.315, 1.76, z + 0.08), Vector3(0.02, 0.06, 0.07), Color(0.04, 0.04, 0.04), false)
    Util.kotak(self, Vector3(-1.315, 1.6, z), Vector3(0.02, 0.03, 0.14), Color(0.25, 0.05, 0.05), false)
