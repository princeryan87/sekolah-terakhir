extends "res://scripts/dunia.gd"

# Lorong lama di bawah sekolah (Misi 5).
# Lorong lurus x -1.5..1.5, z 0..-44. Ruang A (kiri, z -10), ruang B (kanan, z -22), ruang C (kiri, z -34).
# Id: kunci_1..3, pintu_besi, dok_9, dok_10. Tidak ada tempat sembunyi (Pocong dilawan dengan senter).

const TITIK_AWAL = Vector3(0.0, 0.05, -2.0)


func _bangun():
    teks_dokumen = {
        "dok_9": "CATATAN PENJAGA SEKOLAH\n\nDi lorong bawah ada yang menunggu. Dia tidak pernah berlari. Dia hanya melompat, dan hanya bila tak ada cahaya yang menyorotnya.\n\nJangan biarkan senter lepas darinya.",
        "dok_10": "BUKU BESAR (HALAMAN ROBEK)\n\nTiga kunci besi disimpan di tiga ruangan lorong bawah, supaya tak seorang pun bisa pergi tanpa izin Kepala Sekolah."
    }
    komentar_dokumen = {
        "dok_9": "Raka: Hanya bergerak kalau tidak tersorot cahaya... Senter adalah kuncinya.",
        "dok_10": "Raka: Tiga kunci, tiga ruangan. Semua demi izin Kepala Sekolah?"
    }
    env.ambient_light_energy = 0.18
    env.fog_light_color = Color(0.02, 0.025, 0.04)
    env.fog_density = 0.09
    _buat_bangunan()
    _buat_ruangan()
    _buat_hiasan()
    _atur_peta()
    titik_ulang = TITIK_AWAL
    yaw_ulang = 0.0
    guru_ulang = Vector3(0.0, 0.0, -40.0)
    pesan_tangkap = "Pocong menangkapmu.\n\nIngat: dia hanya bergerak saat tidak tersorot. Jangan biarkan cahaya senter lepas darinya, dan jangan berhenti terlalu lama di satu tempat."
    pesan_ulang = "Raka: Sorot dia terus... jangan sampai lepas."


func _atur_peta():
    peta_node = {}
    peta_sisi = []
    for i in range(11):
        peta_node["K%d" % i] = Vector3(0.0, 0.0, -2.0 - 4.0 * i)
        if i > 0:
            peta_sisi.append(["K%d" % (i - 1), "K%d" % i])
    peta_node["DL1"] = Vector3(-1.5, 0.0, -10.0)
    peta_node["RL1"] = Vector3(-4.5, 0.0, -10.0)
    peta_node["DR"] = Vector3(1.5, 0.0, -22.0)
    peta_node["RR"] = Vector3(4.5, 0.0, -22.0)
    peta_node["DL3"] = Vector3(-1.5, 0.0, -34.0)
    peta_node["RL3"] = Vector3(-4.5, 0.0, -34.0)
    peta_sisi.append(["K2", "DL1"])
    peta_sisi.append(["DL1", "RL1"])
    peta_sisi.append(["K5", "DR"])
    peta_sisi.append(["DR", "RR"])
    peta_sisi.append(["K8", "DL3"])
    peta_sisi.append(["DL3", "RL3"])
    peta_patroli = ["K0", "K5", "K10"]
    peta_pintu = {}


func _buat_bangunan():
    var dinding = Color(0.3, 0.28, 0.25)
    Util.kotak(self, Vector3(0.0, -0.1, -22.2), Vector3(16.2, 0.2, 44.8), Color(0.18, 0.18, 0.17))
    Util.kotak(self, Vector3(0.0, 3.1, -22.2), Vector3(16.2, 0.2, 44.8), Color(0.25, 0.24, 0.22))
    # dinding lorong (celah ruangan berupa lengkungan terbuka tanpa pintu)
    _dinding_z(-1.5, -44.0, -24.0, 3.0, dinding, -34.8, -33.2)
    _dinding_z(-1.5, -24.0, 0.0, 3.0, dinding, -10.8, -9.2)
    _dinding_z(1.5, -44.0, 0.0, 3.0, dinding, -22.8, -21.2)
    _dinding_x(0.1, -1.6, 1.6, 3.0, dinding)
    _dinding_x(-44.1, -1.6, 1.6, 3.0, dinding, -0.6, 0.6)
    # ruang A (kiri, z -10)
    _dinding_z(-7.6, -13.1, -6.9, 3.0, dinding)
    _dinding_x(-6.9, -7.7, -1.6, 3.0, dinding)
    _dinding_x(-13.1, -7.7, -1.6, 3.0, dinding)
    # ruang B (kanan, z -22)
    _dinding_z(7.6, -25.1, -18.9, 3.0, dinding)
    _dinding_x(-18.9, 1.6, 7.7, 3.0, dinding)
    _dinding_x(-25.1, 1.6, 7.7, 3.0, dinding)
    # ruang C (kiri, z -34)
    _dinding_z(-7.6, -37.1, -30.9, 3.0, dinding)
    _dinding_x(-30.9, -7.7, -1.6, 3.0, dinding)
    _dinding_x(-37.1, -7.7, -1.6, 3.0, dinding)
    _buat_pintu("pintu_besi", Vector3(-0.6, 0.0, -44.1), 1.2, false, 85.0)
    _tulisan3d("PINTU BESI", Vector3(0.0, 2.6, -44.0), 0.0)
    Util.kotak(self, Vector3(1.0, 1.3, -43.95), Vector3(0.5, 0.6, 0.1), Color(0.25, 0.25, 0.28), false)


func _buat_ruangan():
    var kayu = Color(0.3, 0.22, 0.14)
    var besi = Color(0.55, 0.55, 0.6)
    var kertas = Color(0.9, 0.9, 0.85)
    # ruang A: meja dengan kunci pertama
    Util.kotak(self, Vector3(-5.5, 0.375, -10.0), Vector3(1.2, 0.75, 0.8), kayu)
    _benda(Vector3(-5.5, 0.82, -10.0), Vector3(0.18, 0.03, 0.08), besi, "kunci_1", "Ambil kunci besi", Vector3(0.5, 0.3, 0.5), 0.8)
    Util.kotak(self, Vector3(-6.8, 0.25, -12.0), Vector3(0.5, 0.5, 0.5), kayu)
    Util.kotak(self, Vector3(-3.0, 0.2, -7.8), Vector3(0.4, 0.4, 0.4), kayu, false)
    # ruang B: peti kayu dengan kunci kedua dan catatan penjaga
    Util.kotak(self, Vector3(6.2, 0.35, -22.0), Vector3(0.7, 0.7, 0.7), kayu)
    _benda(Vector3(6.2, 0.75, -22.0), Vector3(0.18, 0.03, 0.08), besi, "kunci_2", "Ambil kunci besi", Vector3(0.5, 0.3, 0.5), 0.8)
    Util.kotak(self, Vector3(5.0, 0.35, -23.8), Vector3(0.7, 0.7, 0.7), kayu)
    _benda(Vector3(5.0, 0.72, -23.8), Vector3(0.3, 0.02, 0.22), kertas, "dok_9", "Baca catatan", Vector3(0.6, 0.3, 0.5), 0.25)
    # ruang C: keranda dengan kunci ketiga dan halaman buku besar
    Util.kotak(self, Vector3(-5.0, 0.3, -33.5), Vector3(0.7, 0.6, 2.0), kayu)
    _benda(Vector3(-5.0, 0.63, -33.5), Vector3(0.18, 0.03, 0.08), besi, "kunci_3", "Ambil kunci besi", Vector3(0.5, 0.3, 0.5), 0.8)
    Util.kotak(self, Vector3(-3.5, 0.35, -35.5), Vector3(0.7, 0.7, 0.7), kayu)
    _benda(Vector3(-3.5, 0.72, -35.5), Vector3(0.3, 0.02, 0.22), kertas, "dok_10", "Baca halaman robek", Vector3(0.6, 0.3, 0.5), 0.25)


func _buat_hiasan():
    # strip lampu darurat merah (hanya hiasan bercahaya, bukan sumber cahaya)
    for z in [-6.0, -14.0, -22.0, -30.0, -38.0]:
        Util.kotak(self, Vector3(0.0, 2.9, z), Vector3(0.5, 0.05, 0.2), Color(0.9, 0.1, 0.05), false, 1.2)
    # pipa dan puing di sepanjang lorong
    for z in [-4.0, -16.0, -28.0, -40.0]:
        Util.kotak(self, Vector3(-1.3, 2.6, z), Vector3(0.12, 0.12, 3.0), Color(0.25, 0.2, 0.18), false)
        Util.kotak(self, Vector3(1.1, 0.2, z - 3.0), Vector3(0.5, 0.4, 0.6), Color(0.22, 0.2, 0.18), false)
