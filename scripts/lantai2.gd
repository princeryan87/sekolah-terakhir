extends "res://scripts/dunia.gd"

# Gedung sekolah lantai 2 (Misi 3).
# Denah (meter): lorong x -1.5..1.5, z 0..-26. Ruang Musik (kiri depan), Kelas 8A (kanan depan),
# Kelas 8B (kiri belakang), Arsip (kanan belakang). Kotak sekering dan pintu perpustakaan di ujung.
# Id: sekering_1..3, kotak_sekering, pintu_perpus, dok_4, dok_5, lemari_musik/_8a/_8b/_arsip, loker_0..6

const TITIK_AWAL = Vector3(0.0, 0.05, -1.2)

var led_kotak = null


func _bangun():
    teks_dokumen = {
        "dok_4": "BUKU HARIAN SISWI\n\nSetiap malam jam 12, bel berbunyi tiga kali. Lalu mereka datang satu per satu. Yang pertama selalu yang paling besar, yang tinggal di lantai dua. Dia benci terang. Aku selalu menyalakan senter sebelum dia mendekat.",
        "dok_5": "SURAT EDARAN KEPALA SEKOLAH\n\nSeluruh siswa dilarang keluar gedung setelah bel ketiga. Ini perintah demi penjagaan sekolah. Siapa pun yang melanggar akan dicatat di Buku Besar.\n\n- Kepala Sekolah"
    }
    komentar_dokumen = {
        "dok_4": "Raka: Dia benci terang... Berarti senter bisa mengusirnya.",
        "dok_5": "Raka: Buku Besar? Kepala sekolah ini mengatur semuanya..."
    }
    _buat_bangunan()
    _buat_ruang_musik()
    _buat_kelas_8a()
    _buat_kelas_8b()
    _buat_arsip()
    _buat_lorong()
    _atur_peta()
    titik_ulang = TITIK_AWAL
    yaw_ulang = 0.0
    guru_ulang = Vector3(0.0, 0.0, -23.0)
    pesan_tangkap = "Genderuwo menemukanmu.\n\nIngat: dia takut cahaya. Sorot dia dengan senter lalu menjauhlah. Bersembunyilah di lemari atau loker."
    pesan_ulang = "Raka: Tenang... sorot dia dengan senter kalau dia dekat."
    _lampu_padam()


func _lampu_nyala():
    for l in lampu_listrik:
        l.visible = true
    env.ambient_light_energy = 0.5
    env.fog_light_color = Color(0.05, 0.06, 0.09)
    env.fog_density = 0.07


func _atur_peta():
    peta_node = {
        "K1": Vector3(0.0, 0.0, -2.5),
        "K2": Vector3(0.0, 0.0, -6.0),
        "K3": Vector3(0.0, 0.0, -10.0),
        "K4": Vector3(0.0, 0.0, -14.0),
        "K5": Vector3(0.0, 0.0, -18.0),
        "K6": Vector3(0.0, 0.0, -23.0),
        "DM": Vector3(-1.5, 0.0, -6.0),
        "M1": Vector3(-3.0, 0.0, -6.0),
        "M2": Vector3(-3.0, 0.0, -3.4),
        "M3": Vector3(-3.0, 0.0, -8.8),
        "DA": Vector3(1.5, 0.0, -6.0),
        "A1": Vector3(3.0, 0.0, -6.0),
        "A2": Vector3(3.0, 0.0, -3.4),
        "A3": Vector3(3.0, 0.0, -8.8),
        "DB": Vector3(-1.5, 0.0, -18.0),
        "B1": Vector3(-3.0, 0.0, -18.0),
        "B2": Vector3(-3.0, 0.0, -15.2),
        "B3": Vector3(-3.0, 0.0, -20.8),
        "DR": Vector3(1.5, 0.0, -18.0),
        "R1": Vector3(3.0, 0.0, -18.0),
        "R2": Vector3(3.0, 0.0, -15.2),
        "R3": Vector3(3.0, 0.0, -20.8)
    }
    peta_sisi = [
        ["K1", "K2"], ["K2", "K3"], ["K3", "K4"], ["K4", "K5"], ["K5", "K6"],
        ["K2", "DM"], ["DM", "M1"], ["M1", "M2"], ["M1", "M3"],
        ["K2", "DA"], ["DA", "A1"], ["A1", "A2"], ["A1", "A3"],
        ["K5", "DB"], ["DB", "B1"], ["B1", "B2"], ["B1", "B3"],
        ["K5", "DR"], ["DR", "R1"], ["R1", "R2"], ["R1", "R3"]
    ]
    peta_patroli = ["K1", "K3", "K6", "M2", "M3", "A2", "A3", "B2", "B3", "R2", "R3"]
    peta_pintu = {"DM": "pintu_musik", "DA": "pintu_8a", "DB": "pintu_8b", "DR": "pintu_arsip"}


func _lemari(x: float, z: float, id: String):
    # lemari menempel di dinding, menghadap ke arah -z
    var b = _benda(Vector3(x, 0.9, z), Vector3(0.9, 1.8, 0.6), Color(0.3, 0.22, 0.15), id, "Sembunyi", Vector3(0.9, 1.8, 0.6))
    Util.kotak(b, Vector3(0.0, 0.0, -0.31), Vector3(0.02, 1.6, 0.02), Color(0.1, 0.07, 0.05), false)
    Util.kotak(b, Vector3(0.1, 0.0, -0.32), Vector3(0.05, 0.14, 0.03), Color(0.7, 0.6, 0.3), false)
    _daftar_tempat(id, Vector3(x, 0.05, z), Vector3(x, 0.05, z - 1.0), Vector3(x, 0.0, z - 0.8), 0.0)


# ---------- bangunan ----------

func _buat_bangunan():
    var dinding = Color(0.5, 0.48, 0.4)
    Util.kotak(self, Vector3(0.0, -0.1, -12.8), Vector3(19.8, 0.2, 27.0), Color(0.28, 0.28, 0.25))
    Util.kotak(self, Vector3(0.0, 3.1, -12.8), Vector3(19.8, 0.2, 27.0), Color(0.4, 0.4, 0.38))
    Util.kotak(self, Vector3(0.0, 0.005, -13.0), Vector3(2.8, 0.01, 25.0), Color(0.2, 0.22, 0.2), false)
    for z in [-6.0, -18.0]:
        Util.kotak(self, Vector3(-5.55, 0.005, z), Vector3(8.0, 0.01, 8.0), Color(0.33, 0.24, 0.15), false)
        Util.kotak(self, Vector3(5.55, 0.005, z), Vector3(8.0, 0.01, 8.0), Color(0.33, 0.24, 0.15), false)
    # dinding lorong, dua celah pintu di tiap sisi
    for x in [-1.5, 1.5]:
        _dinding_z(x, -26.0, -12.0, 3.0, dinding, -18.6, -17.4)
        _dinding_z(x, -12.0, 0.0, 3.0, dinding, -6.6, -5.4)
    _dinding_x(0.1, -1.6, 1.6, 3.0, dinding)
    _dinding_x(-26.1, -1.6, 1.6, 3.0, dinding, -0.6, 0.6)
    # dinding empat ruangan
    for z in [-1.9, -10.1, -13.9, -22.1]:
        _dinding_x(z, -9.7, -1.6, 3.0, dinding)
        _dinding_x(z, 1.6, 9.7, 3.0, dinding)
    _dinding_z(-9.6, -10.1, -1.9, 3.0, dinding)
    _dinding_z(-9.6, -22.1, -13.9, 3.0, dinding)
    _dinding_z(9.6, -10.1, -1.9, 3.0, dinding)
    _dinding_z(9.6, -22.1, -13.9, 3.0, dinding)
    # jendela bercahaya bulan
    for z in [-4.0, -8.0, -16.0, -20.0]:
        Util.kotak(self, Vector3(-9.49, 1.7, z), Vector3(0.04, 1.1, 1.6), Color(0.25, 0.35, 0.6), false, 0.7)
        Util.kotak(self, Vector3(9.49, 1.7, z), Vector3(0.04, 1.1, 1.6), Color(0.25, 0.35, 0.6), false, 0.7)


func _buat_ruang_musik():
    # piano, bangku, dan buku harian
    Util.kotak(self, Vector3(-8.3, 0.5, -6.0), Vector3(0.8, 1.0, 1.6), Color(0.05, 0.05, 0.06))
    Util.kotak(self, Vector3(-7.3, 0.25, -6.0), Vector3(0.4, 0.5, 0.6), Color(0.2, 0.12, 0.08), false)
    _benda(Vector3(-8.3, 1.02, -6.0), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_4", "Baca buku harian", Vector3(0.6, 0.3, 0.5), 0.25)
    # drum dan pemegang partitur
    Util.kotak(self, Vector3(-6.2, 0.35, -8.6), Vector3(0.7, 0.7, 0.7), Color(0.35, 0.1, 0.1))
    Util.kotak(self, Vector3(-5.4, 0.3, -9.0), Vector3(0.5, 0.6, 0.5), Color(0.3, 0.08, 0.08))
    _benda(Vector3(-6.2, 0.78, -8.6), Vector3(0.1, 0.18, 0.1), Color(1.0, 0.7, 0.1), "sekering_1", "Ambil sekering", Vector3(0.5, 0.5, 0.5), 1.0)
    for z in [-3.5, -4.5]:
        Util.kotak(self, Vector3(-6.0, 0.6, z), Vector3(0.08, 1.2, 0.08), Color(0.1, 0.1, 0.1), false)
    _lemari(-3.2, -2.4, "lemari_musik")
    _lampu(Vector3(-5.5, 2.7, -6.0), Color(1.0, 0.9, 0.7), 1.3, 9.0, true)


func _buat_kelas_8a():
    Util.kotak(self, Vector3(5.5, 1.5, -9.95), Vector3(4.0, 1.1, 0.06), Color(0.1, 0.22, 0.16), false)
    for x in [5.0, 7.0, 9.0]:
        for z in [-3.8, -5.6, -7.4]:
            _meja(x, z)
    Util.kotak(self, Vector3(6.5, 0.375, -9.2), Vector3(1.8, 0.75, 0.7), Color(0.38, 0.27, 0.16))
    _benda(Vector3(6.5, 0.82, -9.2), Vector3(0.1, 0.18, 0.1), Color(1.0, 0.7, 0.1), "sekering_2", "Ambil sekering", Vector3(0.5, 0.5, 0.5), 1.0)
    _lemari(3.2, -2.4, "lemari_8a")
    _lampu(Vector3(5.5, 2.7, -6.0), Color(1.0, 0.9, 0.7), 1.3, 9.0, true)


func _buat_kelas_8b():
    Util.kotak(self, Vector3(-5.5, 1.5, -21.95), Vector3(4.0, 1.1, 0.06), Color(0.1, 0.22, 0.16), false)
    for x in [-9.0, -7.0, -5.0]:
        for z in [-16.2, -18.0, -19.8]:
            _meja(x, z)
    _lemari(-3.2, -14.4, "lemari_8b")
    _lampu(Vector3(-5.5, 2.7, -18.0), Color(1.0, 0.9, 0.7), 1.3, 9.0, true)


func _buat_arsip():
    # rak arsip tinggi dan peti
    for z in [-15.5, -18.0, -20.5]:
        Util.kotak(self, Vector3(9.2, 1.1, z), Vector3(0.5, 2.2, 2.0), Color(0.3, 0.26, 0.2))
    Util.kotak(self, Vector3(8.2, 0.35, -19.0), Vector3(0.6, 0.7, 0.6), Color(0.4, 0.3, 0.2))
    _benda(Vector3(8.2, 0.78, -19.0), Vector3(0.1, 0.18, 0.1), Color(1.0, 0.7, 0.1), "sekering_3", "Ambil sekering", Vector3(0.5, 0.5, 0.5), 1.0)
    Util.kotak(self, Vector3(5.8, 0.35, -20.6), Vector3(0.6, 0.7, 0.6), Color(0.4, 0.3, 0.2))
    _benda(Vector3(5.8, 0.72, -20.6), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_5", "Baca surat edaran", Vector3(0.6, 0.3, 0.5), 0.25)
    _lemari(3.2, -14.4, "lemari_arsip")
    _lampu(Vector3(5.5, 2.7, -18.0), Color(1.0, 0.9, 0.7), 1.3, 9.0, true)


func _buat_lorong():
    _buat_pintu("pintu_musik", Vector3(-1.5, 0.0, -5.4), 1.2, true, 90.0)
    _buat_pintu("pintu_8a", Vector3(1.5, 0.0, -5.4), 1.2, true, -90.0)
    _buat_pintu("pintu_8b", Vector3(-1.5, 0.0, -17.4), 1.2, true, 90.0)
    _buat_pintu("pintu_arsip", Vector3(1.5, 0.0, -17.4), 1.2, true, -90.0)
    _buat_pintu("pintu_perpus", Vector3(-0.6, 0.0, -26.1), 1.2, false, 85.0)
    _tulisan3d("RUANG MUSIK", Vector3(-1.38, 2.6, -6.0), 90.0)
    _tulisan3d("KELAS 8A", Vector3(1.38, 2.6, -6.0), -90.0)
    _tulisan3d("KELAS 8B", Vector3(-1.38, 2.6, -18.0), 90.0)
    _tulisan3d("ARSIP", Vector3(1.38, 2.6, -18.0), -90.0)
    _tulisan3d("PERPUSTAKAAN", Vector3(0.0, 2.6, -26.0), 0.0)
    _tulisan3d("LANTAI 2", Vector3(0.0, 2.4, -0.1), 180.0)
    # kotak sekering di ujung lorong
    var kotak = _benda(Vector3(1.0, 1.4, -25.85), Vector3(0.8, 1.0, 0.25), Color(0.35, 0.38, 0.35), "kotak_sekering", "Kotak sekering", Vector3(1.0, 1.2, 0.6))
    led_kotak = Util.kotak(kotak, Vector3(0.25, 0.3, 0.14), Vector3(0.08, 0.08, 0.03), Color(1.0, 0.1, 0.05), false, 1.5)
    # loker di dinding kanan (bisa dipakai bersembunyi)
    var zs = [-8.5, -9.5, -10.5, -11.5, -13.5, -14.5, -15.5]
    for i in range(zs.size()):
        var z = zs[i]
        var nama = "loker_%d" % i
        var b = Util.kotak(self, Vector3(1.15, 0.95, z), Vector3(0.5, 1.9, 0.8), Color(0.25, 0.32, 0.4))
        b.set_meta("id", nama)
        b.set_meta("label", "Sembunyi")
        Util.kotak(self, Vector3(0.89, 0.95, z), Vector3(0.02, 1.6, 0.62), Color(0.15, 0.2, 0.26), false)
        _daftar_tempat(nama, Vector3(1.15, 0.05, z), Vector3(0.2, 0.05, z), Vector3(0.3, 0.0, z), PI / 2.0)
    # lampu lorong (listrik)
    _lampu(Vector3(0.0, 2.7, -6.0), Color(0.85, 0.95, 0.85), 1.0, 9.0, true)
    _lampu(Vector3(0.0, 2.7, -19.0), Color(0.85, 0.95, 0.85), 1.0, 9.0, true)
