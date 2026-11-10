extends "res://scripts/dunia.gd"

# Lapangan sekolah malam hari berkabut (Misi 8). Lapangan x -20..20, z 0..-50.
# Gudang olahraga di ujung (z -36..-44), tutup got di tengah (z -20).
# Id: linggis, tutup_got, pintu_gudang, dok_15, dok_16, lemari_gd1..4.

const TITIK_AWAL = Vector3(0.0, 0.05, -2.0)


func _bangun():
    teks_dokumen = {
        "dok_15": "CATATAN PENJAGA LAPANGAN\n\nKelas 9-X ada di bawah tanah, tepat di bawah lapangan ini. Pintunya berupa tutup got besi di tengah lapangan. Linggis untuk membukanya disimpan di gudang olahraga.\n\nDua penjaga berkeliaran di sini setiap malam.",
        "dok_16": "CATATAN KAPTEN OLAHRAGA\n\nPenjaga yang besar takut cahaya terang. Penjaga yang berkafan akan membeku bila kau terus menyorotnya. Keduanya tak bisa dilawan, hanya ditahan sebentar."
    }
    komentar_dokumen = {
        "dok_15": "Raka: Di bawah lapangan... linggis di gudang. Itu jalannya.",
        "dok_16": "Raka: Senter menahan keduanya. Jangan sampai cahayanya lepas."
    }
    env.ambient_light_energy = 0.22
    env.fog_light_color = Color(0.05, 0.06, 0.08)
    env.fog_density = 0.06
    _buat_lapangan()
    _buat_gudang()
    _buat_cahaya()
    _atur_peta()
    titik_ulang = Vector3(0.0, 0.05, -3.0)
    yaw_ulang = 0.0
    guru_ulang = Vector3(15.0, 0.0, -28.0)
    pesan_tangkap = "Penjaga lapangan menangkapmu.\n\nIngat: senter menahan keduanya (Pocong membeku, Genderuwo mundur). Bersembunyilah di lemari gudang, dan jangan berlari tanpa tujuan."
    pesan_ulang = "Raka: Sorot mereka dengan senter, jangan berhenti bergerak."


func _atur_peta():
    var xs = [-15.0, -7.5, 0.0, 7.5, 15.0]
    var zs = [-4.0, -10.0, -16.0, -22.0, -28.0, -34.0]
    peta_node = {}
    peta_sisi = []
    for r in range(6):
        for c in range(5):
            var nama = "R%dC%d" % [r + 1, c + 1]
            peta_node[nama] = Vector3(xs[c], 0.0, zs[r])
            if c > 0:
                peta_sisi.append(["R%dC%d" % [r + 1, c], nama])
            if r > 0:
                peta_sisi.append(["R%dC%d" % [r, c + 1], nama])
    peta_node["GD"] = Vector3(0.0, 0.0, -36.0)
    peta_node["GI0"] = Vector3(0.0, 0.0, -40.0)
    peta_node["GIL"] = Vector3(-5.0, 0.0, -40.0)
    peta_node["GIR"] = Vector3(5.0, 0.0, -40.0)
    peta_sisi.append(["R6C3", "GD"])
    peta_sisi.append(["GD", "GI0"])
    peta_sisi.append(["GI0", "GIL"])
    peta_sisi.append(["GI0", "GIR"])
    peta_patroli = ["R1C1", "R1C5", "R2C3", "R3C1", "R3C5", "R4C3", "R5C1", "R5C5", "R6C3", "GI0"]
    peta_pintu = {"GD": "pintu_gudang"}


func _lemari_gudang(x: float, id: String):
    # lemari menempel di dinding selatan gudang bagian dalam, menghadap -z
    var b = _benda(Vector3(x, 0.9, -36.45), Vector3(0.9, 1.8, 0.6), Color(0.3, 0.22, 0.15), id, "Sembunyi", Vector3(0.9, 1.8, 0.6))
    Util.kotak(b, Vector3(0.0, 0.0, -0.31), Vector3(0.02, 1.6, 0.02), Color(0.1, 0.07, 0.05), false)
    _daftar_tempat(id, Vector3(x, 0.05, -36.45), Vector3(x, 0.05, -37.45), Vector3(x, 0.0, -37.25), 0.0)


func _buat_lapangan():
    var pagar = Color(0.2, 0.2, 0.22)
    Util.kotak(self, Vector3(0.0, -0.1, -25.0), Vector3(40.4, 0.2, 50.4), Color(0.14, 0.2, 0.12))
    Util.kotak(self, Vector3(-20.2, 1.5, -25.0), Vector3(0.4, 3.0, 50.8), pagar)
    Util.kotak(self, Vector3(20.2, 1.5, -25.0), Vector3(0.4, 3.0, 50.8), pagar)
    Util.kotak(self, Vector3(0.0, 1.5, -50.2), Vector3(40.8, 3.0, 0.4), pagar)
    Util.kotak(self, Vector3(0.0, 1.5, 0.2), Vector3(40.8, 3.0, 0.4), Color(0.3, 0.28, 0.25))
    # garis lapangan
    for z in [-8.0, -25.0]:
        Util.kotak(self, Vector3(0.0, 0.01, z), Vector3(30.0, 0.01, 0.15), Color(0.5, 0.5, 0.5), false, 0.1)
    for x in [-15.0, 15.0]:
        Util.kotak(self, Vector3(x, 0.01, -16.5), Vector3(0.15, 0.01, 17.0), Color(0.5, 0.5, 0.5), false, 0.1)
    # gawang
    for z in [-12.0, -30.0]:
        Util.kotak(self, Vector3(-2.0, 1.0, z), Vector3(0.1, 2.0, 0.1), Color(0.8, 0.8, 0.8))
        Util.kotak(self, Vector3(2.0, 1.0, z), Vector3(0.1, 2.0, 0.1), Color(0.8, 0.8, 0.8))
        Util.kotak(self, Vector3(0.0, 2.0, z), Vector3(4.1, 0.1, 0.1), Color(0.8, 0.8, 0.8), false)
    # bangku dan tiang bendera
    for p in [Vector3(-18.0, 0.25, -15.0), Vector3(18.0, 0.25, -15.0), Vector3(-18.0, 0.25, -30.0), Vector3(18.0, 0.25, -30.0)]:
        Util.kotak(self, p, Vector3(0.5, 0.5, 1.6), Color(0.3, 0.22, 0.14))
    Util.kotak(self, Vector3(-10.0, 3.0, -4.0), Vector3(0.12, 6.0, 0.12), Color(0.6, 0.6, 0.6))
    # bangku dekat awal dengan catatan kapten
    Util.kotak(self, Vector3(6.0, 0.25, -3.0), Vector3(1.6, 0.5, 0.5), Color(0.3, 0.22, 0.14))
    _benda(Vector3(6.0, 0.52, -3.0), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_16", "Baca catatan", Vector3(0.6, 0.3, 0.5), 0.25)
    # tutup got di tengah lapangan
    Util.kotak(self, Vector3(0.0, 0.02, -20.0), Vector3(2.0, 0.02, 2.0), Color(0.8, 0.2, 0.1), false, 0.6)
    _benda(Vector3(0.0, 0.07, -20.0), Vector3(1.4, 0.1, 1.4), Color(0.25, 0.25, 0.28), "tutup_got", "Buka tutup got", Vector3(1.6, 0.4, 1.6))


func _buat_gudang():
    var dinding = Color(0.3, 0.28, 0.25)
    _dinding_x(-36.0, -8.1, 8.1, 3.2, dinding, -0.8, 0.8)
    _dinding_x(-44.1, -8.1, 8.1, 3.2, dinding)
    _dinding_z(-8.0, -44.2, -35.9, 3.2, dinding)
    _dinding_z(8.0, -44.2, -35.9, 3.2, dinding)
    Util.kotak(self, Vector3(0.0, 3.3, -40.0), Vector3(16.4, 0.2, 8.4), Color(0.25, 0.24, 0.22))
    _buat_pintu("pintu_gudang", Vector3(-0.8, 0.0, -36.0), 1.6, false, 85.0)
    _tulisan3d("GUDANG OLAHRAGA", Vector3(0.0, 2.7, -35.9), 0.0)
    # rak dan peti
    for z in [-39.0, -42.0]:
        Util.kotak(self, Vector3(-7.4, 1.0, z), Vector3(0.6, 2.0, 2.6), Color(0.28, 0.24, 0.2))
        Util.kotak(self, Vector3(7.4, 1.0, z), Vector3(0.6, 2.0, 2.6), Color(0.28, 0.24, 0.2))
    Util.kotak(self, Vector3(-3.0, 0.4, -41.0), Vector3(0.8, 0.8, 0.8), Color(0.35, 0.25, 0.15))
    _benda(Vector3(-3.0, 0.82, -41.0), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_15", "Baca catatan", Vector3(0.6, 0.3, 0.5), 0.25)
    Util.kotak(self, Vector3(3.5, 0.3, -39.0), Vector3(0.6, 0.6, 0.6), Color(0.35, 0.25, 0.15), false)
    # meja dengan linggis
    Util.kotak(self, Vector3(0.0, 0.45, -43.2), Vector3(1.6, 0.9, 0.8), Color(0.3, 0.22, 0.14))
    _benda(Vector3(0.0, 0.95, -43.2), Vector3(0.08, 0.08, 0.7), Color(0.55, 0.55, 0.6), "linggis", "Ambil linggis", Vector3(0.8, 0.4, 0.9), 0.7)
    # tempat sembunyi
    _lemari_gudang(-6.0, "lemari_gd1")
    _lemari_gudang(-3.5, "lemari_gd2")
    _lemari_gudang(3.5, "lemari_gd3")
    _lemari_gudang(6.0, "lemari_gd4")


func _buat_cahaya():
    # lampu penanda di atas pintu gudang (terlihat dari jauh di tengah kabut)
    Util.kotak(self, Vector3(0.0, 2.75, -35.85), Vector3(0.6, 0.15, 0.2), Color(1.0, 0.9, 0.6), false, 3.0)
    _lampu(Vector3(0.0, 2.9, -34.8), Color(1.0, 0.85, 0.5), 1.4, 12.0, false)
    _lampu(Vector3(0.0, 2.5, -0.8), Color(1.0, 0.9, 0.7), 1.0, 8.0, false)
    var bulan = DirectionalLight3D.new()
    bulan.rotation_degrees = Vector3(-55.0, 30.0, 0.0)
    bulan.light_energy = 0.3
    bulan.light_color = Color(0.6, 0.7, 1.0)
    bulan.shadow_enabled = false
    add_child(bulan)
