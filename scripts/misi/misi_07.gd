extends Node

# MISI 7: Toilet Lantai Dua. Baterai senter terbatas (habis dalam sekitar 55 detik pemakaian,
# bisa diisi dari 5 baterai yang tersebar). Tutup 4 cermin yang bersinar, lalu buka pintu ke lapangan.
# Kuntilanak agresif mengejar cahaya dan suara; setiap cermin yang ditutup membuatnya lebih cepat dan marah.

const JUDUL = "Toilet Lantai Dua"
const RINGKAS = "Baterai senter terbatas. Tutup semua cermin."

const Util = preload("res://scripts/util.gd")
const Toilet = preload("res://scripts/toilet.gd")
const Kuntilanak = preload("res://scripts/kuntilanak.gd")
const BateraiHud = preload("res://scripts/baterai_hud.gd")

var main
var dunia
var pemain
var hud
var bat
var baterai = 100.0
var habis = false
var cermin = 0
var selesai = false
var _kedip = false


func jalankan(lanjut: bool):
    hud = main.hud
    hud.hitamkan()
    dunia = main.buat_dunia(Toilet)
    pemain = main.pemain
    dunia.hook_aksi = Callable(self, "_aksi")
    bat = BateraiHud.new()
    bat.layer = 11
    add_child(bat)
    pemain.global_position = Toilet.TITIK_AWAL
    pemain.yaw = 0.0
    pemain.senter_ada = true
    pemain.senter.visible = true
    pemain.terkunci = true
    hud.senter_tersedia = true
    Sfx.mulai_loop("ambience_sekolah", -14.0)
    Sfx.mulai_loop("detak_jantung", -38.0)
    hud.tampil_kontrol(false)
    await hud.kartu("MISI 7: TOILET LANTAI DUA", 2.4)
    await hud.fade(0.0, 1.4)
    hud.tampil_kontrol(true)
    pemain.terkunci = false
    hud.misi("Tutup 4 cermin (0/4)")
    hud.bicara("Raka: Toilet lantai dua... bau lembap. Cermin-cermin itu bersinar sendiri.", 4.5)
    await get_tree().create_timer(5.0).timeout
    hud.bicara("Raka: Baterai senterku terbatas. Matikan saat tidak perlu, cari baterai cadangan.", 4.5)
    await get_tree().create_timer(6.0).timeout
    var mulai_di = Vector3(0.0, 0.0, -16.0)
    if pemain.global_position.z < -9.0:
        mulai_di = Vector3(0.0, 0.0, -2.5)
    dunia.munculkan_guru(mulai_di, Kuntilanak)
    Sfx.putar("kuntilanak_tawa", -6.0)
    hud.bicara("Raka: Tawa itu lagi... Kuntilanak! Dia mengejar cahaya.", 4.0)


func _process(delta):
    if dunia == null or pemain == null or hud == null:
        return
    bat.visible = hud.kontrol_tampil
    bat.set_nilai(baterai)
    if selesai or dunia.mati or dunia.sedang_adegan:
        return
    if pemain.senter.visible:
        baterai = maxf(0.0, baterai - 1.8 * delta)
        if baterai <= 0.0:
            _senter_habis()
        elif baterai < 15.0 and not _kedip and randf() < 0.03:
            _kedip_senter()


func _senter_habis():
    habis = true
    pemain.senter.visible = false
    pemain.senter_ada = false
    Sfx.putar("senter_habis", -2.0)
    hud.bicara("Baterai senter habis! Cari baterai di sekitar sini.", 4.0)


func _kedip_senter():
    _kedip = true
    pemain.senter.visible = false
    await get_tree().create_timer(0.12).timeout
    if baterai > 0.0 and not habis:
        pemain.senter.visible = true
    _kedip = false


func _aksi(id, node):
    if id.begins_with("cermin_") and id != "cermin_tutup":
        _tutup_cermin(node)
        return true
    if id.begins_with("baterai_"):
        _ambil_baterai(node)
        return true
    if id == "pintu_lapangan":
        if cermin < 4:
            Sfx.putar("pintu_terkunci", -2.0)
            hud.bicara("Terkunci. Pintu ini baru terbuka kalau semua cermin tertutup (%d/4)." % cermin, 3.8)
        else:
            _selesai_misi()
        return true
    return false


func _ambil_baterai(node):
    node.queue_free()
    baterai = minf(100.0, baterai + 45.0)
    Sfx.putar("baterai_ambil", -2.0)
    if habis:
        habis = false
        pemain.senter_ada = true
        hud.bicara("Raka: Baterai! Senter bisa dinyalakan lagi (tombol SENTER).", 3.5)
    else:
        hud.bicara("Raka: Baterai cadangan. Senter terisi.", 2.5)


func _tutup_cermin(node):
    cermin += 1
    node.set_meta("id", "cermin_tutup")
    node.set_meta("label", "")
    node.get_child(1).material_override = Util.bahan(Color(0.03, 0.03, 0.05))
    Sfx.putar("cermin_tutup", -2.0)
    if dunia.guru != null:
        dunia.guru.kec_kejar += 0.25
        dunia.guru.curiga(node.global_position)
    if cermin < 4:
        hud.misi("Tutup 4 cermin (%d/4)" % cermin)
        hud.bicara("Raka: Satu cermin tertutup... dia terasa makin marah.", 3.0)
    else:
        hud.misi("Buka pintu ke lapangan (dinding belakang)")
        hud.bicara("Raka: Semua cermin tertutup! Pintu belakang pasti terbuka sekarang.", 3.5)


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
    Sfx.putar("pintu_buka", 0.0, 0.8)
    var p = dunia.pintu["pintu_lapangan"]
    var tw = create_tween()
    tw.tween_property(p["pivot"], "rotation_degrees:y", 80.0, 1.6)
    hud.bicara("Raka: Angin malam... dan kabut tebal di lapangan.", 3.6)
    await tw.finished
    await get_tree().create_timer(1.2).timeout
    await hud.fade(1.0, 1.4)
    Sfx.matikan_semua_loop()
    GameState.tandai_selesai(7)
    hud.tampil_kontrol(false)
    var isi = "Pintu menuju lapangan terbuka. Kabut tebal menyelimuti lapangan sekolah, dan dua sosok berdiri diam di tengahnya, menunggu.\n\nDokumen ditemukan: %d dari 14\n\nMisi 8: Lapangan dan Gudang akan segera tiba." % dunia.dokumen_dibaca.size()
    await hud.layar_akhir("MISI 7 SELESAI", isi, "Sentuh layar untuk kembali ke menu")
    main.kembali_ke_menu()
