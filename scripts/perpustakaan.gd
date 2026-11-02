extends "res://scripts/dunia.gd"

# Perpustakaan sekolah (Misi 4).
# Aula x -9.5..9.5, z 0..-20. Pintu masuk di z 0 (menutup sendiri), pintu arsip terlarang di z -20.
# Ada tepat 6 meja baca (jawaban salah satu angka kode). Id: dok_6..8, gembok_kode,
# pintu_masuk, pintu_terlarang, lemari_*.

const TITIK_AWAL = Vector3(0.0, 0.05, -2.0)

var led_gembok = null


func _bangun():
    teks_dokumen = {
        "dok_6": "PETUNJUK GEMBOK (1/3)\n\nAngka pertama: berapa kali bel berbunyi setiap malam?\nAngka kedua: kelas tempat nama Raka tertulis di daftar hadir.",
        "dok_7": "PETUNJUK GEMBOK (2/3)\n\nAngka ketiga: jumlah siswa pada daftar hadir kelas itu.",
        "dok_8": "PETUNJUK GEMBOK (3/3)\n\nAngka keempat: jumlah meja baca di perpustakaan ini.\n\nSusun keempat angka secara berurutan.\nJangan percaya bisikan siapa pun."
    }
    komentar_dokumen = {
        "dok_6": "Raka: Bel tiap malam... itu tertulis di buku harian lantai dua.",
        "dok_7": "Raka: Jumlah siswa pada daftar hadir itu...",
        "dok_8": "Raka: Jadi aku harus menghitung meja baca di sini."
    }
    env.ambient_light_energy = 0.3
    _buat_bangunan()
    _buat_rak()
    _buat_meja_baca()
    _buat_ujung()
    _atur_peta()
    titik_ulang = TITIK_AWAL
    yaw_ulang = 0.0
    guru_ulang = Vector3(0.0, 0.0, -18.0)
    pesan_tangkap = "Hantu siswi menemukanmu.\n\nIngat: bisikannya sering berbohong. Bersembunyilah saat senandungnya mendekat, dan percayalah pada catatan, bukan bisikan."
    pesan_ulang = "Raka: Jangan percaya bisikan... percaya catatan."


func _atur_peta():
    var zc = [-2.5, -6.0, -10.0, -14.0, -18.0]
    var zl = [-3.0, -6.0, -10.0, -14.0, -18.0]
    peta_node = {}
    peta_sisi = []
    for i in range(5):
        var n = i + 1
        peta_node["C%d" % n] = Vector3(0.0, 0.0, zc[i])
        peta_node["L%d" % n] = Vector3(-5.5, 0.0, zl[i])
        peta_node["R%d" % n] = Vector3(5.5, 0.0, zl[i])
        if i > 0:
            peta_sisi.append(["C%d" % i, "C%d" % n])
            peta_sisi.append(["L%d" % i, "L%d" % n])
            peta_sisi.append(["R%d" % i, "R%d" % n])
    for n in [2, 3, 4]:
        peta_node["GL%d" % n] = Vector3(-3.0, 0.0, zl[n - 1])
        peta_node["GR%d" % n] = Vector3(3.0, 0.0, zl[n - 1])
        peta_sisi.append(["C%d" % n, "GL%d" % n])
        peta_sisi.append(["GL%d" % n, "L%d" % n])
        peta_sisi.append(["C%d" % n, "GR%d" % n])
        peta_sisi.append(["GR%d" % n, "R%d" % n])
    peta_patroli = ["C1", "C3", "C5", "L1", "L3", "L5", "R1", "R3", "R5"]
    peta_pintu = {}


# lemari menempel di dinding depan (z 0), menghadap -z
func _lemari_z(x: float, id: String):
    var b = _benda(Vector3(x, 0.9, -0.4), Vector3(0.9, 1.8, 0.6), Color(0.3, 0.22, 0.15), id, "Sembunyi", Vector3(0.9, 1.8, 0.6))
    Util.kotak(b, Vector3(0.0, 0.0, -0.31), Vector3(0.02, 1.6, 0.02), Color(0.1, 0.07, 0.05), false)
    _daftar_tempat(id, Vector3(x, 0.05, -0.4), Vector3(x, 0.05, -1.4), Vector3(x, 0.0, -1.2), 0.0)


# lemari menempel di dinding samping; hadap = 1 menghadap +x, -1 menghadap -x
func _lemari_x(x: float, z: float, hadap: float, id: String):
    var b = _benda(Vector3(x, 0.9, z), Vector3(0.6, 1.8, 0.9), Color(0.3, 0.22, 0.15), id, "Sembunyi", Vector3(0.6, 1.8, 0.9))
    Util.kotak(b, Vector3(0.31 * hadap, 0.0, 0.0), Vector3(0.02, 1.6, 0.02), Color(0.1, 0.07, 0.05), false)
    _daftar_tempat(id, Vector3(x, 0.05, z), Vector3(x + 1.0 * hadap, 0.05, z), Vector3(x + 0.8 * hadap, 0.0, z), -PI / 2.0 * hadap)


func _buat_bangunan():
    var dinding = Color(0.46, 0.4, 0.32)
    Util.kotak(self, Vector3(0.0, -0.1, -10.0), Vector3(19.8, 0.2, 20.6), Color(0.3, 0.24, 0.17))
    Util.kotak(self, Vector3(0.0, 3.7, -10.0), Vector3(19.8, 0.2, 20.6), Color(0.35, 0.33, 0.3))
    Util.kotak(self, Vector3(0.0, 0.005, -10.0), Vector3(3.0, 0.01, 20.0), Color(0.4, 0.12, 0.12), false)
    _dinding_z(-9.6, -20.1, 0.1, 3.6, dinding)
    _dinding_z(9.6, -20.1, 0.1, 3.6, dinding)
    _dinding_x(0.1, -9.7, 9.7, 3.6, dinding, -0.6, 0.6)
    _dinding_x(-20.1, -9.7, 9.7, 3.6, dinding, -0.6, 0.6)
    for z in [-5.0, -10.0, -15.0]:
        Util.kotak(self, Vector3(-9.49, 2.0, z), Vector3(0.04, 1.4, 1.4), Color(0.25, 0.35, 0.6), false, 0.7)
        Util.kotak(self, Vector3(9.49, 2.0, z), Vector3(0.04, 1.4, 1.4), Color(0.25, 0.35, 0.6), false, 0.7)
    for z in [-3.0, -8.0, -13.0, -18.0]:
        _lampu(Vector3(0.0, 2.8, z), Color(1.0, 0.9, 0.7), 1.0, 9.0, true)


func _buat_rak():
    var kayu = Color(0.25, 0.17, 0.1)
    var buku = [Color(0.5, 0.1, 0.1), Color(0.1, 0.25, 0.4), Color(0.2, 0.35, 0.15), Color(0.45, 0.35, 0.1)]
    var k = 0
    for x in [-7.0, -4.0, 4.0, 7.0]:
        for z in [-4.0, -8.0, -12.0, -16.0]:
            Util.kotak(self, Vector3(x, 1.2, z), Vector3(0.5, 2.4, 3.0), kayu)
            for sisi in [-1.0, 1.0]:
                for y in [0.6, 1.2, 1.8]:
                    Util.kotak(self, Vector3(x + 0.26 * sisi, y, z), Vector3(0.03, 0.3, 2.6), buku[k % 4], false)
                    k += 1
    _lemari_z(-3.2, "lemari_p1")
    _lemari_z(3.2, "lemari_p2")
    _lemari_x(-9.2, -6.0, 1.0, "lemari_p3")
    _lemari_x(-9.2, -14.0, 1.0, "lemari_p4")
    _lemari_x(9.2, -6.0, -1.0, "lemari_p5")
    _lemari_x(9.2, -14.0, -1.0, "lemari_p6")


func _buat_meja_baca():
    # TEPAT 6 meja baca (jawaban angka keempat)
    for x in [-2.0, 2.0]:
        for z in [-5.0, -9.0, -13.0]:
            Util.kotak(self, Vector3(x, 0.375, z), Vector3(1.4, 0.75, 0.9), Color(0.35, 0.25, 0.15))
            Util.kotak(self, Vector3(x, 0.225, z + 0.8), Vector3(0.4, 0.45, 0.4), Color(0.2, 0.26, 0.32), false)
            Util.kotak(self, Vector3(x + 0.5, 0.9, z), Vector3(0.2, 0.3, 0.2), Color(0.1, 0.35, 0.15), false, 0.4)
    _benda(Vector3(-2.0, 0.77, -9.0), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_6", "Baca petunjuk", Vector3(0.6, 0.3, 0.5), 0.25)
    # peti kecil di lajur kiri dengan petunjuk kedua
    Util.kotak(self, Vector3(-5.5, 0.3, -12.0), Vector3(0.5, 0.6, 0.5), Color(0.4, 0.3, 0.2))
    _benda(Vector3(-5.5, 0.63, -12.0), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_7", "Baca petunjuk", Vector3(0.6, 0.3, 0.5), 0.25)
    # meja pustakawan (bukan meja baca) dengan petunjuk ketiga
    Util.kotak(self, Vector3(0.0, 0.45, -17.5), Vector3(2.2, 0.9, 0.8), Color(0.28, 0.2, 0.12))
    _benda(Vector3(0.0, 0.93, -17.5), Vector3(0.3, 0.02, 0.22), Color(0.9, 0.9, 0.85), "dok_8", "Baca petunjuk", Vector3(0.6, 0.3, 0.5), 0.25)
    _tulisan3d("PUSTAKAWAN", Vector3(0.0, 1.5, -17.8), 0.0)


func _buat_ujung():
    _buat_pintu("pintu_masuk", Vector3(-0.6, 0.0, 0.1), 1.2, false, 85.0)
    _buat_pintu("pintu_terlarang", Vector3(-0.6, 0.0, -20.1), 1.2, false, 85.0)
    _tulisan3d("ARSIP TERLARANG", Vector3(0.0, 2.9, -20.0), 0.0)
    _tulisan3d("HARAP TENANG", Vector3(0.0, 2.9, -0.0), 180.0)
    var kotak = _benda(Vector3(1.1, 1.3, -19.85), Vector3(0.4, 0.5, 0.15), Color(0.2, 0.2, 0.22), "gembok_kode", "Masukkan kode", Vector3(0.6, 0.7, 0.5), 0.3)
    led_gembok = Util.kotak(kotak, Vector3(0.12, 0.18, 0.09), Vector3(0.06, 0.06, 0.03), Color(1.0, 0.1, 0.05), false, 1.5)
