extends Node

# MISI 2: Sang Guru. Raka sudah memegang kunci lobi. Lolos dari Sang Guru yang
# berpatroli, lalu buka pintu lobi di ujung lorong.

const JUDUL = "Sang Guru"
const RINGKAS = "Lolos dari guru yang berpatroli. Sembunyi dan jangan berisik."

const Lantai1 = preload("res://scripts/lantai1.gd")

var main
var dunia
var pemain
var hud
var selesai = false


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Lantai1)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    dunia.kondisi_gelap()
    dunia.kondisi_kunci()
    pemain.global_position = Vector3(3.0, 0.05, -6.0)
    pemain.yaw = PI / 2.0
    pemain.senter_ada = true
    pemain.senter.visible = true
    pemain.terkunci = true
    hud.senter_tersedia = true
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 2: SANG GURU", 2.4)
    await hud.fade(0.0, 1.2)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Buka pintu lobi (ujung lorong)")
    hud.bicara("Raka: Bel lagi... dan langkah itu menuruni tangga. Ada yang datang ke lorong!", 4.2)
    Sfx.putar("bel_sekolah", -2.0)
    await get_tree().create_timer(3.5).timeout
    var mulai_di = Vector3(0.0, 0.0, -21.5)
    if pemain.global_position.z < -12.0:
        mulai_di = Vector3(0.0, 0.0, -2.5)
    dunia.munculkan_guru(mulai_di)
    Sfx.putar("guru_kejar", -8.0)
    await get_tree().create_timer(2.0).timeout
    hud.bicara("Sembunyi di loker atau lemari kalau dia dekat. Senter dan berlari membuatmu mudah ketahuan.", 6.0)


func _aksi(id, node):
    if id == "pintu_lobi":
        _buka_lobi()
        return true
    return false


func _buka_lobi():
    if selesai:
        return
    selesai = true
    dunia.selesai = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    if dunia.guru != null:
        dunia.guru.berhenti()
    hud.set_waspada(0.0, false)
    Sfx.putar("pintu_buka", 0.0, 0.8)
    var p = dunia.pintu["pintu_lobi"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", 80.0, 1.6)
    hud.bicara("Raka: Terbuka! Tapi di baliknya hanya tangga gelap ke lantai atas...", 3.6)
    await tw.finished
    Sfx.putar("langkah_atas", -2.0)
    await get_tree().create_timer(1.2).timeout
    await hud.fade(1.0, 1.4)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(2)
    hud.tampil_kontrol(false)
    var isi = "Pintu lobi terbuka, tetapi di baliknya bukan jalan keluar. Hanya tangga gelap menuju lantai atas, tempat bel sekolah terus berbunyi.\n\nDokumen ditemukan: %d dari 3\n\nMisi 3: Lantai Atas akan segera tiba." % dunia.dokumen_dibaca.size()
    await hud.layar_akhir("MISI 2 SELESAI", isi, "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
