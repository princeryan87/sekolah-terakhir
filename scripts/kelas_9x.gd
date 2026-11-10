extends "res://scripts/dunia.gd"

# Kelas 9-X, ruang bawah tanah yang tidak tercatat di denah (Misi 9). Aula x -9.5..9.5, z 0..-20.
# Id: bangku_1..5 (ingatan), pintu_kepsek, lemari_x1..x6 (sembunyi).
# Misi memakai setel_bangku_aktif(n), tampilkan_baris(n), tampilkan_raka().

const TITIK_AWAL = Vector3(0.0, 0.05, -1.5)
const POSISI_BANGKU = [
    Vector3(-1.6, 0.0, -4.0), Vector3(1.6, 0.0, -7.0), Vector3(-1.6, 0.0, -10.0),
    Vector3(1.6, 0.0, -13.0), Vector3(-1.6, 0.0, -16.0)
]
const BARIS_TEKS = [
    "SARI - dikunci", "PAK MANDOR - dijadikan penjaga", "PAK DARTO - ditumbalkan",
    "DINA - dibungkam", "BU WALI - penjaga pintu", "RAKA - belum pulang"
]

var bangku = []
var baris = []
var foto_label = []


func _bangun():
    env.ambient_light_energy = 0.2
    env.fog_light_color = Color(0.03, 0.03, 0.05)
    env.fog_density = 0.08
    _buat_bangunan()
    _buat_bangku()
    _buat_papan_foto()
    _buat_tempat_sembunyi()
    _atur_peta()
    titik_ulang = Vector3(0.0, 0.05, -3.0)
    yaw_ulang = 0.0
    guru_ulang = Vector3(0.0, 0.0, -18.0)
    pesan_ulang = "Raka: Bertahanlah sampai dia menghilang."


func setel_bangku_aktif(n: int):
    for i in range(bangku.size()):
        if not is_instance_valid(bangku[i]):
            continue
        var warna = Color(0.4, 0.3, 0.2)
        var emisi = 0.0
        if i + 1 == n:
            warna = Color(0.9, 0.7, 0.2)
            emisi = 1.3
        elif i + 1 < n:
            warna = Color(0.22, 0.18, 0.14)
        bangku[i].get_child(1).material_override = Util.bahan(warna, emisi)


func tampilkan_baris(n: int):
    if n >= 1 and n <= baris.size():
        baris[n - 1].visible = true


func tampilkan_raka():
    for l in foto_label:
        l.text = "RAKA"
        l.modulate = Color(1.0, 0.2, 0.2)


func _atur_peta():
    peta_node = {}
    peta_sisi = []
    var zs = [-2.5, -6.0, -10.0, -14.0, -18.0]
    for i in range(5):
        var n = i + 1
        peta_node["C%d" % n] = Vector3(0.0, 0.0, zs[i])
        peta_node["L%d" % n] = Vector3(-5.75, 0.0, zs[i])
        peta_node["R%d" % n] = Vector3(5.75, 0.0, zs[i])
        peta_node["GL%d" % n] = Vector3(-3.0, 0.0, zs[i])
        peta_node["GR%d" % n] = Vector3(3.0, 0.0, zs[i])
        peta_sisi.append(["C%d" % n, "GL%d" % n])
        peta_sisi.append(["GL%d" % n, "L%d" % n])
        peta_sisi.append(["C%d" % n, "GR%d" % n])
        peta_sisi.append(["GR%d" % n, "R%d" % n])
        if i > 0:
            peta_sisi.append(["C%d" % i, "C%d" % n])
            peta_sisi.append(["L%d" % i, "L%d" % n])
            peta_sisi.append(["R%d" % i, "R%d" % n])
    peta_patroli = ["C1", "C3", "C5", "L1", "L3", "L5", "R1", "R3", "R5"]
    peta_pintu = {}


func _lemari_z(x: float, id: String):
    var b = _benda(Vector3(x, 0.9, -0.4), Vector3(0.9, 1.8, 0.6), Color(0.3, 0.22, 0.15), id, "Sembunyi", Vector3(0.9, 1.8, 0.6))
    Util.kotak(b, Vector3(0.0, 0.0, -0.31), Vector3(0.02, 1.6, 0.02), Color(0.1, 0.07, 0.05), false)
    _daftar_tempat(id, Vector3(x, 0.05, -0.4), Vector3(x, 0.05, -1.4), Vector3(x, 0.0, -1.2), 0.0)


func _lemari_x(x: float, z: float, hadap: float, id: String):
    var b = _benda(Vector3(x, 0.9, z), Vector3(0.6, 1.8, 0.9), Color(0.3, 0.22, 0.15), id, "Sembunyi", Vector3(0.6, 1.8, 0.9))
    Util.kotak(b, Vector3(0.31 * hadap, 0.0, 0.0), Vector3(0.02, 1.6, 0.02), Color(0.1, 0.07, 0.05), false)
    _daftar_tempat(id, Vector3(x, 0.05, z), Vector3(x + 1.0 * hadap, 0.05, z), Vector3(x + 0.8 * hadap, 0.0, z), -PI / 2.0 * hadap)


func _buat_bangunan():
    var dinding = Color(0.3, 0.28, 0.25)
    Util.kotak(self, Vector3(0.0, -0.1, -10.0), Vector3(19.8, 0.2, 20.6), Color(0.2, 0.18, 0.15))
    Util.kotak(self, Vector3(0.0, 3.1, -10.0), Vector3(19.8, 0.2, 20.6), Color(0.25, 0.24, 0.22))
    _dinding_z(-9.6, -20.1, 0.1, 3.0, dinding)
    _dinding_z(9.6, -20.1, 0.1, 3.0, dinding)
    _dinding_x(0.1, -9.7, 9.7, 3.0, dinding)
    _dinding_x(-20.1, -9.7, 9.7, 3.0, dinding, 6.0, 7.2)
    _buat_pintu("pintu_kepsek", Vector3(6.0, 0.0, -20.1), 1.2, false, 85.0)
    _tulisan3d("KEPALA SEKOLAH", Vector3(6.6, 2.6, -20.0), 0.0)
    _tulisan3d("KELAS 9-X", Vector3(0.0, 2.5, -0.1), 180.0)
    _lampu(Vector3(0.0, 2.7, -5.0), Color(0.9, 0.85, 0.7), 0.6, 9.0, true)
    _lampu(Vector3(0.0, 2.7, -15.0), Color(0.9, 0.85, 0.7), 0.6, 9.0, true)
    # deretan meja murid di sisi kiri dan kanan
    for x in [-7.0, -4.5, 4.5, 7.0]:
        for z in [-5.0, -8.0, -11.0, -14.0]:
            Util.kotak(self, Vector3(x, 0.375, z), Vector3(0.9, 0.75, 0.5), Color(0.38, 0.28, 0.18))
            Util.kotak(self, Vector3(x, 0.225, z + 0.6), Vector3(0.4, 0.45, 0.4), Color(0.2, 0.26, 0.32), false)


func _buat_bangku():
    for i in range(5):
        var p = POSISI_BANGKU[i]
        var b = _benda(Vector3(p.x, 0.375, p.z), Vector3(0.9, 0.75, 0.5), Color(0.4, 0.3, 0.2), "bangku_%d" % (i + 1), "Duduki bangku", Vector3(1.0, 0.9, 0.7))
        bangku.append(b)
        Util.kotak(self, Vector3(p.x, 0.225, p.z + 0.6), Vector3(0.4, 0.45, 0.4), Color(0.2, 0.26, 0.32), false)
        _tulisan3d(str(i + 1), Vector3(p.x, 1.1, p.z), 0.0)
    setel_bangku_aktif(0)


func _buat_papan_foto():
    # papan tulis di dinding belakang, baris ingatan muncul bertahap
    Util.kotak(self, Vector3(0.0, 1.9, -19.95), Vector3(6.0, 1.9, 0.06), Color(0.1, 0.22, 0.16), false)
    for i in range(BARIS_TEKS.size()):
        var l = Label3D.new()
        l.text = BARIS_TEKS[i]
        l.font_size = 34
        l.pixel_size = 0.006
        l.modulate = Color(0.9, 0.9, 0.85)
        if i == 5:
            l.modulate = Color(1.0, 0.25, 0.2)
        l.position = Vector3(0.0, 2.6 - 0.28 * i, -19.88)
        l.visible = false
        add_child(l)
        baris.append(l)
    # foto di dinding kiri: wajah yang sama; setelah kebenaran terungkap tertulis RAKA
    for z in [-3.0, -5.5, -12.0, -18.0]:
        Util.kotak(self, Vector3(-9.425, 1.7, z), Vector3(0.05, 0.55, 0.42), Color(0.3, 0.2, 0.12), false)
        Util.kotak(self, Vector3(-9.385, 1.7, z), Vector3(0.03, 0.4, 0.32), Color(0.6, 0.58, 0.5), false)
        Util.kotak(self, Vector3(-9.365, 1.76, z - 0.08), Vector3(0.02, 0.06, 0.07), Color(0.04, 0.04, 0.04), false)
        Util.kotak(self, Vector3(-9.365, 1.76, z + 0.08), Vector3(0.02, 0.06, 0.07), Color(0.04, 0.04, 0.04), false)
        Util.kotak(self, Vector3(-9.365, 1.6, z), Vector3(0.02, 0.03, 0.14), Color(0.25, 0.05, 0.05), false)
        var l = Label3D.new()
        l.text = "?"
        l.font_size = 36
        l.pixel_size = 0.006
        l.modulate = Color(0.8, 0.8, 0.8)
        l.position = Vector3(-9.38, 1.25, z)
        l.rotation_degrees.y = 90.0
        add_child(l)
        foto_label.append(l)


func _buat_tempat_sembunyi():
    _lemari_z(-3.0, "lemari_x1")
    _lemari_z(3.0, "lemari_x2")
    _lemari_x(-9.2, -9.2, 1.0, "lemari_x3")
    _lemari_x(-9.2, -15.5, 1.0, "lemari_x4")
    _lemari_x(9.2, -9.2, -1.0, "lemari_x5")
    _lemari_x(9.2, -15.5, -1.0, "lemari_x6")
