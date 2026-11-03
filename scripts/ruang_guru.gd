extends "res://scripts/dunia.gd"

# Ruang guru (Misi 6). Kantor x -9.5..9.5, z 0..-18. Blok rapat di tengah (bisa dikelilingi: jalur melingkar).
# Id: denah_1..3 (potongan denah), papan_denah, dok_11, dok_12, lemari_g1..g4.

const TITIK_AWAL = Vector3(0.0, 0.05, -1.5)

var label_denah = null


func _bangun():
    teks_dokumen = {
        "dok_11": "SALINAN BUKU BESAR KEPALA SEKOLAH\n\nSetiap murid yang melanggar dicatat, lalu dijadikan penghuni sekolah. Para guru bertugas menjaga mereka. Tuyul-tuyul dipelihara untuk mencuri jejak murid, supaya tak ada yang bisa kabur.",
        "dok_12": "SURAT PRIBADI SEORANG GURU\n\nAku tidak sanggup lagi menjaga mereka. Kelas 9-X tidak tercatat di denah karena sengaja dihapus. Jalan ke sana lewat toilet lantai dua, lalu lapangan.\n\nSemoga ada yang menemukan surat ini."
    }
    komentar_dokumen = {
        "dok_11": "Raka: Jadi tuyul itu peliharaan Kepala Sekolah...",
        "dok_12": "Raka: Kelas 9-X sengaja dihapus dari denah. Lewat toilet, lalu lapangan."
    }
    env.ambient_light_energy = 0.3
    _buat_bangunan()
    _buat_perabot()
    _atur_peta()
    titik_ulang = Vector3(0.0, 0.05, -3.0)
    yaw_ulang = 0.0
    guru_ulang = Vector3(0.0, 0.0, -15.5)
    pesan_tangkap = "Sang Guru menemukanmu.\n\nIngat: sembunyi di lemari saat dia dekat. Tuyul hanya mencuri barang, bahayanya adalah Sang Guru."
    pesan_ulang = "Raka: Tenang... jangan berisik, jangan biarkan Tuyul membuatku ketahuan."


func tampilkan_denah():
    if label_denah != null:
        label_denah.visible = true


func _atur_peta():
    peta_node = {
        "S1": Vector3(0.0, 0.0, -2.5),
        "P1": Vector3(-6.0, 0.0, -2.5),
        "P2": Vector3(6.0, 0.0, -2.5),
        "A": Vector3(-4.5, 0.0, -6.0),
        "B": Vector3(0.0, 0.0, -6.0),
        "C": Vector3(4.5, 0.0, -6.0),
        "D": Vector3(4.5, 0.0, -9.0),
        "E": Vector3(4.5, 0.0, -12.0),
        "F": Vector3(0.0, 0.0, -12.0),
        "G": Vector3(-4.5, 0.0, -12.0),
        "H": Vector3(-4.5, 0.0, -9.0),
        "N1": Vector3(0.0, 0.0, -15.5),
        "N2": Vector3(-5.5, 0.0, -15.5),
        "N3": Vector3(5.5, 0.0, -15.5)
    }
    peta_sisi = [
        ["S1", "B"], ["B", "A"], ["B", "C"], ["C", "D"], ["D", "E"], ["E", "F"], ["F", "G"], ["G", "H"], ["H", "A"],
        ["F", "N1"], ["N1", "N2"], ["N1", "N3"], ["G", "N2"], ["E", "N3"],
        ["S1", "P1"], ["S1", "P2"], ["P1", "A"], ["P2", "C"]
    ]
    peta_patroli = ["S1", "A", "C", "E", "G", "N2", "N3", "P1", "P2"]
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
    var dinding = Color(0.5, 0.46, 0.38)
    Util.kotak(self, Vector3(0.0, -0.1, -9.0), Vector3(19.8, 0.2, 18.6), Color(0.26, 0.26, 0.24))
    Util.kotak(self, Vector3(0.0, 3.1, -9.0), Vector3(19.8, 0.2, 18.6), Color(0.4, 0.4, 0.38))
    Util.kotak(self, Vector3(0.0, 0.005, -9.0), Vector3(19.0, 0.01, 18.0), Color(0.3, 0.2, 0.15), false)
    _dinding_z(-9.6, -18.1, 0.1, 3.0, dinding)
    _dinding_z(9.6, -18.1, 0.1, 3.0, dinding)
    _dinding_x(0.1, -9.7, 9.7, 3.0, dinding)
    _dinding_x(-18.1, -9.7, 9.7, 3.0, dinding)
    for z in [-4.0, -9.0, -14.0]:
        Util.kotak(self, Vector3(-9.49, 1.7, z), Vector3(0.04, 1.1, 1.6), Color(0.25, 0.35, 0.6), false, 0.7)
        Util.kotak(self, Vector3(9.49, 1.7, z), Vector3(0.04, 1.1, 1.6), Color(0.25, 0.35, 0.6), false, 0.7)
    for p in [Vector3(-4.0, 2.7, -4.0), Vector3(4.0, 2.7, -4.0), Vector3(-4.0, 2.7, -13.0), Vector3(4.0, 2.7, -13.0)]:
        _lampu(p, Color(1.0, 0.9, 0.7), 0.9, 9.0, true)


func _buat_perabot():
    var kayu = Color(0.4, 0.28, 0.17)
    var kertas = Color(0.9, 0.9, 0.85)
    # blok rapat di tengah (hambatan agar bisa dikelilingi)
    Util.kotak(self, Vector3(0.0, 1.1, -9.0), Vector3(6.0, 2.2, 3.0), Color(0.3, 0.25, 0.2))
    _tulisan3d("RAPAT GURU", Vector3(0.0, 2.6, -7.45), 0.0)
    # deretan meja guru di tepi kiri dan kanan
    for x in [-8.0, 8.0]:
        for z in [-4.0, -8.0, -12.0]:
            Util.kotak(self, Vector3(x, 0.375, z), Vector3(0.8, 0.75, 1.4), kayu)
            Util.kotak(self, Vector3(x - 0.1 * (x / 8.0), 0.9, z), Vector3(0.05, 0.3, 0.5), Color(0.1, 0.1, 0.12), false)
    # potongan denah dan dokumen
    _benda(Vector3(-8.0, 0.77, -4.0), Vector3(0.3, 0.02, 0.22), Color(0.8, 0.85, 0.95), "denah_1", "Ambil potongan denah", Vector3(0.6, 0.3, 0.5), 0.6)
    _benda(Vector3(8.0, 0.77, -12.0), Vector3(0.3, 0.02, 0.22), Color(0.8, 0.85, 0.95), "denah_2", "Ambil potongan denah", Vector3(0.6, 0.3, 0.5), 0.6)
    _benda(Vector3(6.0, 0.05, -16.5), Vector3(0.3, 0.02, 0.22), Color(0.8, 0.85, 0.95), "denah_3", "Ambil potongan denah", Vector3(0.7, 0.3, 0.7), 0.6)
    _benda(Vector3(8.0, 0.77, -4.0), Vector3(0.3, 0.02, 0.22), kertas, "dok_11", "Baca salinan buku besar", Vector3(0.6, 0.3, 0.5), 0.25)
    _benda(Vector3(-8.0, 0.77, -12.0), Vector3(0.3, 0.02, 0.22), kertas, "dok_12", "Baca surat", Vector3(0.6, 0.3, 0.5), 0.25)
    # papan denah di dinding belakang
    _benda(Vector3(0.0, 1.6, -17.9), Vector3(3.0, 1.6, 0.1), Color(0.35, 0.3, 0.22), "papan_denah", "Pasang potongan denah", Vector3(3.2, 1.8, 0.6))
    for i in range(3):
        Util.kotak(self, Vector3(-0.9 + 0.9 * i, 1.6, -17.83), Vector3(0.7, 1.2, 0.02), Color(0.15, 0.13, 0.1), false)
    label_denah = Label3D.new()
    label_denah.text = "DENAH SEKOLAH\nKELAS 9-X\n(lewat toilet, lalu lapangan)"
    label_denah.font_size = 40
    label_denah.pixel_size = 0.006
    label_denah.modulate = Color(0.9, 0.95, 1.0)
    label_denah.position = Vector3(0.0, 1.6, -17.78)
    label_denah.visible = false
    add_child(label_denah)
    # tempat sembunyi
    _lemari_z(-6.0, "lemari_g1")
    _lemari_z(6.0, "lemari_g2")
    _lemari_x(-9.2, -15.0, 1.0, "lemari_g3")
    _lemari_x(9.2, -15.0, -1.0, "lemari_g4")
