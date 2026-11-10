extends "res://scripts/dunia.gd"

# Toilet lantai dua (Misi 7). Aula x -8..8, z 0..-18. Pintu ke lapangan di dinding belakang (z -18).
# Id: cermin_1..4 (tutup), baterai_1..5, dok_13, dok_14, pintu_lapangan, bilik_k1..k4 dan bilik_r1..r4 (sembunyi).

const TITIK_AWAL = Vector3(0.0, 0.05, -1.5)


func _bangun():
    teks_dokumen = {
        "dok_13": "CATATAN PETUGAS KEBERSIHAN\n\nDi toilet lantai dua ada murid perempuan yang dulu menangis sendirian sebelum bel ketiga. Dia melihat sesuatu di cermin. Tutup semua cermin, dan dia berhenti melihat.",
        "dok_14": "CATATAN PETUGAS KEBERSIHAN (2)\n\nBaterai senter selalu kutinggalkan di beberapa tempat sekitar sini. Hemat. Matikan senter saat tak perlu, sebab dia mengejar cahaya."
    }
    komentar_dokumen = {
        "dok_13": "Raka: Cermin-cermin itu bersinar sendiri. Harus ditutup semuanya.",
        "dok_14": "Raka: Dia mengejar cahaya... Senter harus dihemat."
    }
    env.ambient_light_energy = 0.14
    env.fog_light_color = Color(0.02, 0.03, 0.04)
    env.fog_density = 0.1
    _buat_bangunan()
    _buat_bilik()
    _buat_cermin()
    _buat_barang()
    _atur_peta()
    titik_ulang = Vector3(0.0, 0.05, -3.0)
    yaw_ulang = 0.0
    guru_ulang = Vector3(0.0, 0.0, -16.0)
    pesan_tangkap = "Kuntilanak menangkapmu.\n\nIngat: dia mengejar cahaya dan suara. Matikan senter bila perlu, bersembunyi di bilik, dan hemat baterai."
    pesan_ulang = "Raka: Hemat senter... jangan berisik."


func _atur_peta():
    peta_node = {
        "S": Vector3(0.0, 0.0, -2.5),
        "H1": Vector3(-3.0, 0.0, -5.0),
        "H2": Vector3(3.0, 0.0, -5.0),
        "H3": Vector3(0.0, 0.0, -8.0),
        "H4": Vector3(-3.0, 0.0, -11.0),
        "H5": Vector3(3.0, 0.0, -11.0),
        "H6": Vector3(0.0, 0.0, -14.0),
        "B1": Vector3(-4.5, 0.0, -16.0),
        "B2": Vector3(4.5, 0.0, -16.0),
        "ML": Vector3(-6.0, 0.0, -12.5),
        "MR": Vector3(6.0, 0.0, -12.5)
    }
    peta_sisi = [
        ["S", "H1"], ["S", "H2"], ["H1", "H3"], ["H2", "H3"], ["H3", "H4"], ["H3", "H5"],
        ["H4", "H6"], ["H5", "H6"], ["H6", "B1"], ["H6", "B2"], ["H4", "ML"], ["H5", "MR"]
    ]
    peta_patroli = ["S", "H1", "H2", "H4", "H5", "B1", "B2", "ML", "MR"]
    peta_pintu = {}


func _buat_bangunan():
    var dinding = Color(0.4, 0.5, 0.52)
    Util.kotak(self, Vector3(0.0, -0.1, -9.0), Vector3(16.6, 0.2, 18.6), Color(0.45, 0.5, 0.5))
    Util.kotak(self, Vector3(0.0, 3.1, -9.0), Vector3(16.6, 0.2, 18.6), Color(0.35, 0.37, 0.37))
    _dinding_z(-8.1, -18.1, 0.1, 3.0, dinding)
    _dinding_z(8.1, -18.1, 0.1, 3.0, dinding)
    _dinding_x(0.1, -8.2, 8.2, 3.0, dinding)
    _dinding_x(-18.1, -8.2, 8.2, 3.0, dinding, -0.6, 0.6)
    _buat_pintu("pintu_lapangan", Vector3(-0.6, 0.0, -18.1), 1.2, false, 85.0)
    _tulisan3d("KE LAPANGAN", Vector3(0.0, 2.6, -18.0), 0.0)
    _tulisan3d("TOILET LANTAI 2", Vector3(0.0, 2.4, -0.1), 180.0)
    for z in [-9.0, -14.0]:
        Util.kotak(self, Vector3(-8.0, 2.4, z), Vector3(0.04, 0.7, 1.4), Color(0.25, 0.35, 0.6), false, 0.6)
        Util.kotak(self, Vector3(8.0, 2.4, z), Vector3(0.04, 0.7, 1.4), Color(0.25, 0.35, 0.6), false, 0.6)


func _buat_bilik():
    var cat = Color(0.3, 0.4, 0.5)
    var putih = Color(0.8, 0.8, 0.78)
    for sisi in [-1.0, 1.0]:
        var huruf = "k"
        if sisi > 0.0:
            huruf = "r"
        for i in range(5):
            var zs = -2.0 - 1.2 * i
            Util.kotak(self, Vector3(7.45 * sisi, 1.0, zs), Vector3(1.3, 2.0, 0.06), cat)
        for i in range(4):
            var zc = -2.6 - 1.2 * i
            var nama = "bilik_%s%d" % [huruf, i + 1]
            Util.kotak(self, Vector3(7.7 * sisi, 0.2, zc), Vector3(0.5, 0.4, 0.45), putih, false)
            _benda(Vector3(6.8 * sisi, 0.95, zc), Vector3(0.06, 1.9, 1.15), Color(0.28, 0.38, 0.48), nama, "Sembunyi", Vector3(0.5, 1.9, 1.15))
            _daftar_tempat(nama, Vector3(7.3 * sisi, 0.05, zc), Vector3(6.2 * sisi, 0.05, zc), Vector3(6.3 * sisi, 0.0, zc), PI / 2.0 * sisi)


func _buat_cermin():
    var kaca = Color(0.55, 0.7, 0.85)
    var putih = Color(0.8, 0.8, 0.78)
    # dinding belakang
    Util.kotak(self, Vector3(-4.5, 0.45, -17.8), Vector3(1.6, 0.9, 0.5), putih)
    _benda(Vector3(-4.5, 1.7, -17.95), Vector3(1.6, 1.0, 0.05), kaca, "cermin_1", "Tutup cermin", Vector3(1.8, 1.2, 0.5), 1.0)
    Util.kotak(self, Vector3(4.5, 0.45, -17.8), Vector3(1.6, 0.9, 0.5), putih)
    _benda(Vector3(4.5, 1.7, -17.95), Vector3(1.6, 1.0, 0.05), kaca, "cermin_2", "Tutup cermin", Vector3(1.8, 1.2, 0.5), 1.0)
    # dinding samping
    Util.kotak(self, Vector3(-7.75, 0.45, -12.5), Vector3(0.5, 0.9, 1.6), putih)
    _benda(Vector3(-7.95, 1.7, -12.5), Vector3(0.05, 1.0, 1.6), kaca, "cermin_3", "Tutup cermin", Vector3(0.5, 1.2, 1.8), 1.0)
    Util.kotak(self, Vector3(7.75, 0.45, -12.5), Vector3(0.5, 0.9, 1.6), putih)
    _benda(Vector3(7.95, 1.7, -12.5), Vector3(0.05, 1.0, 1.6), kaca, "cermin_4", "Tutup cermin", Vector3(0.5, 1.2, 1.8), 1.0)


func _buat_barang():
    var bat = Color(0.9, 0.6, 0.1)
    var kertas = Color(0.9, 0.9, 0.85)
    # bangku tengah
    Util.kotak(self, Vector3(0.0, 0.25, -9.5), Vector3(1.6, 0.5, 0.5), Color(0.3, 0.22, 0.14))
    _benda(Vector3(-0.3, 0.52, -9.5), Vector3(0.3, 0.02, 0.22), kertas, "dok_13", "Baca catatan", Vector3(0.6, 0.3, 0.5), 0.25)
    _benda(Vector3(-7.75, 0.92, -11.8), Vector3(0.3, 0.02, 0.22), kertas, "dok_14", "Baca catatan", Vector3(0.6, 0.3, 0.5), 0.25)
    # baterai senter
    _benda(Vector3(-4.5, 1.03, -17.8), Vector3(0.12, 0.25, 0.12), bat, "baterai_1", "Ambil baterai", Vector3(0.6, 0.5, 0.6), 0.9)
    _benda(Vector3(4.5, 1.03, -17.8), Vector3(0.12, 0.25, 0.12), bat, "baterai_2", "Ambil baterai", Vector3(0.6, 0.5, 0.6), 0.9)
    _benda(Vector3(0.4, 0.63, -9.5), Vector3(0.12, 0.25, 0.12), bat, "baterai_3", "Ambil baterai", Vector3(0.6, 0.5, 0.6), 0.9)
    _benda(Vector3(-7.2, 0.13, -15.5), Vector3(0.12, 0.25, 0.12), bat, "baterai_4", "Ambil baterai", Vector3(0.6, 0.5, 0.6), 0.9)
    _benda(Vector3(6.0, 0.13, -1.2), Vector3(0.12, 0.25, 0.12), bat, "baterai_5", "Ambil baterai", Vector3(0.6, 0.5, 0.6), 0.9)
