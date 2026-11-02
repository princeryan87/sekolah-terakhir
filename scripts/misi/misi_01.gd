extends Node

# MISI 1: Hukuman Bersih-Bersih. Bersihkan kelas 9B, listrik mati, cari kunci lobi
# di kelas 9A, lalu Kuntilanak muncul. Misi selesai setelah jumpscare.

const JUDUL = "Hukuman Bersih-Bersih"
const RINGKAS = "Bersihkan kelas. Jangan sampai ada yang mengganggumu."

const Lantai1 = preload("res://scripts/lantai1.gd")

var main
var dunia
var pemain
var hud
var tahap = "bersih"
var sampah_terkumpul = 0


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Lantai1)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    pemain.global_position = Lantai1.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.terkunci = true
    hud.tampil_kontrol(false)
    if lanjut and GameState.ambil_cp(1) == "gelap":
        await _lanjut_gelap()
    else:
        await _awal()


func _awal():
    await hud.kartu("Raka dihukum membersihkan sekolah setelah jam pulang.", 3.4)
    await hud.kartu("Tinggal satu kelas lagi...", 2.6)
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    await hud.fade(0.0, 1.5)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Bersihkan kelas 9B (0/3)")
    hud.bicara("Raka: Kenapa harus aku yang bersihin semuanya...", 4.0)


func _lanjut_gelap():
    sampah_terkumpul = 3
    dunia.kondisi_gelap()
    tahap = "gelap"
    pemain.senter_ada = true
    pemain.senter.visible = true
    hud.senter_tersedia = true
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    hud.misi("Cari jalan keluar")
    await hud.fade(0.0, 1.2)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    dunia.acak_aktif = true
    hud.bicara("Raka: ...aku masih di sini.", 3.0)


# ---------- aksi khusus misi ini ----------

func _aksi(id, node):
    if id.begins_with("sampah"):
        _ambil_sampah(node)
        return true
    if id == "kunci_lobi":
        _ambil_kunci(node)
        return true
    if id == "pintu_9b" and sampah_terkumpul < 3 and not dunia.pintu["pintu_9b"]["terbuka"]:
        Sfx.putar("pintu_terkunci", -6.0)
        hud.bicara("Raka: Belum selesai. Kalau pulang sebelum bersih, bisa kena marah lagi.", 4.0)
        return true
    if id == "pintu_9a" and tahap != "gelap" and not dunia.pintu["pintu_9a"]["terbuka"]:
        Sfx.putar("pintu_terkunci", -2.0)
        hud.bicara("Dikunci. Raka: Kelas 9A sudah dikunci dari sore tadi.", 3.5)
        return true
    if id == "pintu_lobi":
        Sfx.putar("pintu_terkunci", 0.0)
        hud.bicara("Terkunci. Raka: Kuncinya pasti ada di suatu tempat...", 3.8)
        return true
    return false


func _ambil_sampah(node):
    Sfx.putar("sapu", -4.0, randf_range(0.9, 1.1))
    node.queue_free()
    sampah_terkumpul += 1
    if sampah_terkumpul < 3:
        hud.misi("Bersihkan kelas 9B (%d/3)" % sampah_terkumpul)
    else:
        hud.misi("Pulang")
        hud.bicara("Raka: Beres! Akhirnya bisa pulang.", 3.5)
        _mulai_pemadaman()


func _mulai_pemadaman():
    tahap = "pemadaman"
    await get_tree().create_timer(2.5).timeout
    Sfx.putar("listrik_mati", 0.0)
    for i in range(5):
        for l in dunia.lampu_listrik:
            l.visible = (i % 2 == 1)
        await get_tree().create_timer(randf_range(0.06, 0.16)).timeout
    dunia._lampu_padam()
    dunia.jam_label.text = "00:00"
    hud.bicara("Raka: Hah? Listriknya mati?!", 3.0)
    await get_tree().create_timer(3.2).timeout
    pemain.senter_ada = true
    hud.senter_tersedia = true
    pemain.senter.visible = true
    Sfx.putar("senter_klik", -4.0)
    hud.bicara("Raka: Untung ada senter di HP. (Tombol SENTER: nyala/mati)", 4.2)
    await get_tree().create_timer(4.6).timeout
    hud.bicara("Raka: Jam dinding itu... 00:00? Tadi masih sore!", 4.0)
    await get_tree().create_timer(4.4).timeout
    Sfx.putar("bel_sekolah", -2.0)
    hud.bicara("Raka: Bel masuk?! Tengah malam begini?", 3.5)
    await get_tree().create_timer(3.8).timeout
    Sfx.putar("langkah_atas", -4.0)
    hud.bicara("Raka: Itu... suara langkah kaki dari lantai atas.", 4.0)
    if tahap == "pemadaman":
        tahap = "gelap"
        dunia.acak_aktif = true
        hud.misi("Cari jalan keluar")
        GameState.set_cp(1, "gelap")


func _ambil_kunci(node):
    node.queue_free()
    Sfx.putar("kunci_ambil")
    hud.bicara("Raka: Kunci lobi! Akhirnya...", 2.5)
    dunia.sedang_adegan = true
    dunia.acak_aktif = false
    await get_tree().create_timer(1.6).timeout
    await _adegan_hantu()


func _adegan_hantu():
    pemain.terkunci = true
    pemain.senter.visible = false
    Sfx.mulai_loop("detak_jantung", -10.0)
    Sfx.putar("bisik", -2.0)
    hud.bicara("Raka: ...siapa di situ?", 2.6)
    await get_tree().create_timer(1.6).timeout
    Sfx.putar("kuntilanak_tawa", 0.0)
    await get_tree().create_timer(2.0).timeout

    var arah = -pemain.kamera.global_transform.basis.z
    arah.y = 0.0
    arah = arah.normalized()
    var hantu = dunia._buat_kuntilanak()
    dunia.add_child(hantu)
    hantu.global_position = pemain.global_position + arah * 2.6
    hantu.look_at(Vector3(pemain.global_position.x, hantu.global_position.y, pemain.global_position.z), Vector3.UP)
    await get_tree().create_timer(0.45).timeout

    Sfx.putar("jumpscare", 0.0)
    Input.vibrate_handheld(500)
    var tw = create_tween()
    tw.tween_property(hantu, "global_position", pemain.global_position + arah * 0.55, 0.22)
    await tw.finished
    hud.kilat(0.7)
    pemain.getar(0.45, 0.12)
    await get_tree().create_timer(0.12).timeout
    hantu.queue_free()
    await get_tree().create_timer(1.0).timeout

    hud.bicara("Raka: Aku harus keluar dari sini sekarang!", 3.5)
    await get_tree().create_timer(3.6).timeout
    await _selesai()


func _selesai():
    dunia.selesai = true
    await hud.fade(1.0, 1.2)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(1)
    hud.tampil_kontrol(false)
    await hud.layar_akhir("MISI 1 SELESAI", "Raka selamat dari Kuntilanak, tapi dari lorong terdengar langkah sepatu yang berat dan tegas.\n\nMisi 2 terbuka: Sang Guru.", "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
