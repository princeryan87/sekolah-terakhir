extends Node

# MISI 5: Lorong Pocong. Lorong bawah tanah panjang dan gelap. Kumpulkan 3 kunci besi di 3 ruangan,
# lalu buka pintu besi di ujung. Pocong terus mendekat dengan melompat, tapi membeku saat tersorot senter.
# Setiap kunci yang diambil membuat Pocong sedikit lebih cepat.

const JUDUL = "Lorong Pocong"
const RINGKAS = "Kumpulkan 3 kunci. Jangan lepaskan senter dari Pocong."

const Lorong = preload("res://scripts/lorong_lama.gd")
const Pocong = preload("res://scripts/pocong.gd")

var main
var dunia
var pemain
var hud
var kunci = 0
var selesai = false


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Lorong)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    pemain.global_position = Lorong.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.senter_ada = true
    pemain.senter.visible = true
    pemain.terkunci = true
    hud.senter_tersedia = true
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 5: LORONG POCONG", 2.4)
    await hud.fade(0.0, 1.4)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Kumpulkan 3 kunci besi (0/3)")
    hud.bicara("Raka: Lorong ini panjang sekali... dan dingin.", 4.0)
    await get_tree().create_timer(4.5).timeout
    hud.bicara("Raka: Ada tiga ruangan di sisi lorong. Dan pintu besi di ujung sana.", 4.2)
    await get_tree().create_timer(5.0).timeout
    var mulai_di = Vector3(0.0, 0.0, -40.0)
    if pemain.global_position.z < -30.0:
        mulai_di = Vector3(0.0, 0.0, -2.5)
    dunia.munculkan_guru(mulai_di, Pocong)
    Sfx.putar("pocong_erang", -8.0)
    hud.bicara("Raka: Ada sosok putih di ujung lorong... melompat-lompat ke sini!", 4.0)
    await get_tree().create_timer(4.5).timeout
    hud.bicara("Sorot dia dengan senter, dan dia akan berhenti. Jangan sampai cahayanya lepas.", 6.0)


func _aksi(id, node):
    if id.begins_with("kunci_"):
        _ambil_kunci(node)
        return true
    if id == "pintu_besi":
        _pintu_besi()
        return true
    return false


func _ambil_kunci(node):
    node.queue_free()
    kunci += 1
    Sfx.putar("kunci_besi", -2.0)
    if dunia.guru != null:
        dunia.guru.kec_kejar += 0.25
    if kunci < 3:
        hud.misi("Kumpulkan 3 kunci besi (%d/3)" % kunci)
        hud.bicara("Raka: Satu kunci. Pocong itu terasa makin cepat...", 3.0)
    else:
        hud.misi("Buka pintu besi di ujung lorong")
        hud.bicara("Raka: Tiga kunci! Cepat ke pintu besi!", 3.5)


func _pintu_besi():
    if kunci < 3:
        Sfx.putar("pintu_terkunci", -2.0)
        hud.bicara("Pintu besi dengan tiga lubang kunci. Aku baru punya %d kunci." % kunci, 3.5)
        return
    _selesai_misi()


func _selesai_misi():
    if selesai:
        return
    selesai = true
    dunia.selesai = true
    dunia.sedang_adegan = true
    pemain.terkunci = true
    if dunia.guru != null:
        dunia.guru.berhenti()
    hud.set_waspada(0.0, false)
    Sfx.putar("pintu_besi", 0.0)
    var p = dunia.pintu["pintu_besi"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", 80.0, 1.8)
    hud.bicara("Raka: Terbuka! Ada tangga naik di baliknya.", 3.6)
    await tw.finished
    await get_tree().create_timer(1.2).timeout
    await hud.fade(1.0, 1.4)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(5)
    hud.tampil_kontrol(false)
    var isi = "Pintu besi terbuka. Di baliknya ada tangga naik menuju ruang guru, dan dari atas terdengar tawa anak kecil yang mencuri-curi.\n\nDokumen ditemukan: %d dari 10\n\nMisi 6: Ruang Guru akan segera tiba." % dunia.dokumen_dibaca.size()
    await hud.layar_akhir("MISI 5 SELESAI", isi, "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
