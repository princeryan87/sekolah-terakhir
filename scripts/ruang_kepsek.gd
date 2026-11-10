extends "res://scripts/dunia.gd"

# Ruang Kepala Sekolah (Misi 10). Aula x -10..10, z 0..-24, berpilar, berkarpet merah.
# Id: lonceng_1..3, pintu_keluar (di dinding kanan), lemari_k1..k4 (sembunyi).

const TITIK_AWAL = Vector3(0.0, 0.05, -1.5)


func _bangun():
    env.ambient_light_color = Color(0.5, 0.3, 0.3)
    env.ambient_light_energy = 0.25
    env.fog_light_color = Color(0.12, 0.03, 0.03)
    env.fog_density = 0.06
    _buat_bangunan()
    _buat_perabot()
    _buat_lonceng()
    _buat_tempat_sembunyi()
    _atur_peta()
    titik_ulang = Vector3(0.0, 0.05, -3.0)
    yaw_ulang = 0.0
    guru_ulang = Vector3(0.0, 0.0, -21.0)
    pesan_tangkap = "Kepala Sekolah menangkapmu.\n\nIngat: bunyikan ketiga lonceng untuk melemahkannya. Bersembunyilah di lemari dan jangan berdiam di satu tempat terlalu lama."
    pesan_ulang = "Raka: Tiga lonceng. Hanya itu yang bisa melukainya."


func _atur_peta():
    var xs = [-7.0, 0.0, 7.0]
    var zs = [-3.0, -8.0, -13.0, -18.0, -21.0]
    peta_node = {}
    peta_sisi = []
    for r in range(5):
        for c in range(3):
            var nama = "N%d%d" % [r + 1, c + 1]
            peta_node[nama] = Vector3(xs[c], 0.0, zs[r])
            if c > 0:
                peta_sisi.append(["N%d%d" % [r + 1, c], nama])
            if r > 0:
                peta_sisi.append(["N%d%d" % [r, c + 1], nama])
    peta_patroli = ["N11", "N13", "N22", "N31", "N33", "N42", "N51", "N52", "N53"]
    peta_pintu = {}


func _lemari_x(x: float, z: float, hadap: float, id: String):
    var b = _benda(Vector3(x, 0.9, z), Vector3(0.6, 1.8, 0.9), Color(0.3, 0.18, 0.15), id, "Sembunyi", Vector3(0.6, 1.8, 0.9))
    Util.kotak(b, Vector3(0.31 * hadap, 0.0, 0.0), Vector3(0.02, 1.6, 0.02), Color(0.1, 0.05, 0.05), false)
    _daftar_tempat(id, Vector3(x, 0.05, z), Vector3(x + 1.0 * hadap, 0.05, z), Vector3(x + 0.8 * hadap, 0.0, z), -PI / 2.0 * hadap)


func _buat_bangunan():
    var dinding = Color(0.35, 0.18, 0.16)
    Util.kotak(self, Vector3(0.0, -0.1, -12.0), Vector3(20.8, 0.2, 24.6), Color(0.22, 0.12, 0.1))
    Util.kotak(self, Vector3(0.0, 3.5, -12.0), Vector3(20.8, 0.2, 24.6), Color(0.2, 0.12, 0.1))
    Util.kotak(self, Vector3(0.0, 0.01, -12.0), Vector3(4.0, 0.02, 23.0), Color(0.5, 0.05, 0.05), false)
    _dinding_z(-10.1, -24.1, 0.1, 3.4, dinding)
    _dinding_z(10.1, -24.1, 0.1, 3.4, dinding, -13.8, -12.2)
    _dinding_x(0.1, -10.2, 10.2, 3.4, dinding)
    _dinding_x(-24.1, -10.2, 10.2, 3.4, dinding)
    _buat_pintu("pintu_keluar", Vector3(10.1, 0.0, -12.2), 1.6, true, -90.0)
    _tulisan3d("KE GERBANG", Vector3(9.98, 2.7, -13.0), -90.0)
    for p in [Vector3(-6.0, 2.9, -6.0), Vector3(6.0, 2.9, -6.0), Vector3(-6.0, 2.9, -16.0), Vector3(6.0, 2.9, -16.0)]:
        _lampu(p, Color(1.0, 0.35, 0.2), 0.9, 9.0, true)
    # pilar
    for x in [-4.5, 4.5]:
        for z in [-6.0, -12.0, -18.0]:
            Util.kotak(self, Vector3(x, 1.7, z), Vector3(0.8, 3.4, 0.8), Color(0.28, 0.15, 0.13))


func _buat_perabot():
    var kayu = Color(0.2, 0.1, 0.07)
    # meja tahta di belakang
    Util.kotak(self, Vector3(0.0, 0.5, -22.8), Vector3(4.0, 1.0, 1.2), kayu)
    Util.kotak(self, Vector3(0.0, 1.1, -23.7), Vector3(1.4, 2.2, 0.4), Color(0.15, 0.07, 0.05))
    _tulisan3d("KEPALA SEKOLAH", Vector3(0.0, 2.9, -23.9), 0.0)
    # potret besar di dinding belakang
    Util.kotak(self, Vector3(0.0, 2.0, -23.95), Vector3(2.0, 1.4, 0.06), Color(0.55, 0.45, 0.15), false, 0.4)
    Util.kotak(self, Vector3(0.0, 2.0, -23.9), Vector3(1.8, 1.2, 0.04), Color(0.08, 0.06, 0.06), false)


func _buat_lonceng():
    var emas = Color(0.95, 0.75, 0.2)
    var gelap = Color(0.12, 0.08, 0.06)
    var tempat_lonceng = [Vector3(-8.0, 0.0, -8.0), Vector3(8.0, 0.0, -15.0), Vector3(0.0, 0.0, -20.5)]
    for i in range(3):
        var p = tempat_lonceng[i]
        # tiang penyangga
        Util.kotak(self, Vector3(p.x - 0.4, 0.8, p.z), Vector3(0.1, 1.6, 0.1), gelap, false)
        Util.kotak(self, Vector3(p.x + 0.4, 0.8, p.z), Vector3(0.1, 1.6, 0.1), gelap, false)
        Util.kotak(self, Vector3(p.x, 1.65, p.z), Vector3(0.9, 0.1, 0.1), gelap, false)
        _benda(Vector3(p.x, 1.2, p.z), Vector3(0.5, 0.6, 0.5), emas, "lonceng_%d" % (i + 1), "Bunyikan lonceng", Vector3(1.2, 1.6, 1.2), 1.0)


func _buat_tempat_sembunyi():
    _lemari_x(-9.7, -9.0, 1.0, "lemari_k1")
    _lemari_x(-9.7, -16.0, 1.0, "lemari_k2")
    _lemari_x(9.7, -6.0, -1.0, "lemari_k3")
    _lemari_x(9.7, -17.0, -1.0, "lemari_k4")
