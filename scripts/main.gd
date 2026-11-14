extends Node

# Pengendali utama THE LAST. Menampilkan menu, lalu menjalankan skrip misi terpilih
# (scripts/misi/misi_NN.gd). Gambar 3D dirender kecil lalu diperbesar (efek PS1).
# Ubah PENGECIL: 2 = lebih tajam, 3 = lebih kasar/retro, 4 = sangat kasar.
const PENGECIL = 3

const HudScript = preload("res://scripts/hud.gd")
const PemainScript = preload("res://scripts/pemain.gd")
const MenuScript = preload("res://scripts/menu.gd")
const DevPanelScript = preload("res://scripts/dev_panel.gd")

var hud
var pemain = null
var dunia = null
var vp
var menu
var misi = null
var misi_no = 0
var dev_panel
var info_label
var _jari = {}
var _empat_t = 0.0


func _ready():
    randomize()
    GameState.muat()

    var lapis = CanvasLayer.new()
    lapis.layer = 0
    add_child(lapis)
    var wadah = SubViewportContainer.new()
    wadah.stretch = true
    wadah.stretch_shrink = PENGECIL
    wadah.mouse_filter = Control.MOUSE_FILTER_IGNORE
    wadah.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    lapis.add_child(wadah)
    wadah.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    vp = SubViewport.new()
    vp.msaa_3d = Viewport.MSAA_DISABLED
    wadah.add_child(vp)

    hud = HudScript.new()
    hud.layer = 10
    add_child(hud)
    hud.reset_total()

    menu = MenuScript.new()
    menu.layer = 20
    add_child(menu)
    menu.misi_dipilih.connect(_on_misi_dipilih)
    menu.dev_diminta.connect(buka_dev)
    menu.tampil()

    dev_panel = DevPanelScript.new()
    dev_panel.layer = 50
    dev_panel.main = self
    add_child(dev_panel)

    var lapis_info = CanvasLayer.new()
    lapis_info.layer = 45
    add_child(lapis_info)
    info_label = Label.new()
    info_label.position = Vector2(20.0, 70.0)
    info_label.add_theme_font_size_override("font_size", 14)
    info_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
    info_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
    info_label.add_theme_constant_override("outline_size", 5)
    info_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    info_label.visible = false
    lapis_info.add_child(info_label)


# Dipanggil skrip misi untuk membuat gedung/lantai dan pemain.
func buat_dunia(skrip):
    dunia = skrip.new()
    vp.add_child(dunia)
    pemain = PemainScript.new()
    vp.add_child(pemain)
    dunia.siapkan(pemain, hud)
    dunia.kembali_menu = Callable(self, "kembali_ke_menu")
    return dunia


func _on_misi_dipilih(n, lanjut):
    hud.reset_total()
    hud.hitamkan()
    if not Sfx.siap:
        hud.tampil_teks("Memuat suara...")
        await get_tree().process_frame
        await Sfx.siapkan()
        hud.sembunyi_teks()
    var jalur = "res://scripts/misi/misi_%02d.gd" % n
    if not ResourceLoader.exists(jalur):
        kembali_ke_menu()
        return
    var skrip = load(jalur)
    misi_no = n
    misi = skrip.new()
    misi.main = self
    add_child(misi)
    await misi.jalankan(lanjut)


func kembali_ke_menu():
    Sfx.matikan_semua_loop()
    if misi != null:
        misi.queue_free()
        misi = null
    for c in vp.get_children():
        c.queue_free()
    dunia = null
    pemain = null
    hud.reset_total()
    menu.tampil()


func buka_dev():
    if not GameState.CHEAT_TERSEDIA:
        return
    if dev_panel.aktif:
        return
    dev_panel.buka()


func dev_selesaikan_misi() -> bool:
    if misi == null:
        return false
    for nama in ["_selesai_misi", "_selesai", "_buka_lobi", "_buka_perpus"]:
        if misi.has_method(nama):
            misi.call(nama)
            return true
    return false


func dev_isi_baterai() -> bool:
    if misi != null and misi.get("baterai") != null:
        misi.set("baterai", 100.0)
        return true
    return false


func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            _jari[event.index] = true
        else:
            _jari.erase(event.index)


func _teks_info() -> String:
    var t = "FPS %d  Misi %d" % [Engine.get_frames_per_second(), misi_no]
    if pemain != null and is_instance_valid(pemain):
        t += "\nRaka x %.1f  z %.1f" % [pemain.global_position.x, pemain.global_position.z]
    if dunia != null and dunia.guru != null and is_instance_valid(dunia.guru):
        var jarak = dunia.guru.global_position.distance_to(pemain.global_position)
        t += "\nHantu: %s  jarak %.1f  waspada %.2f" % [dunia.guru.state, jarak, dunia.guru.waspada]
    if GameState.dev_kebal:
        t += "\n[KEBAL]"
    if GameState.dev_beku:
        t += " [HANTU BEKU]"
    return t


func _process(delta):
    # cheat tersembunyi di dalam misi: tahan 4 jari selama 2 detik
    if GameState.CHEAT_TERSEDIA and misi != null and not get_tree().paused:
        if _jari.size() >= 4:
            _empat_t += delta
            if _empat_t >= 2.0:
                _empat_t = 0.0
                _jari.clear()
                buka_dev()
        else:
            _empat_t = 0.0
    info_label.visible = GameState.dev_info and misi != null
    if info_label.visible:
        info_label.text = _teks_info()
    if pemain == null or hud == null or dunia == null:
        return
    var teks = ""
    if dunia.sembunyi_id != "":
        teks = "Keluar dari persembunyian"
    elif not pemain.terkunci and pemain.sasaran != null and is_instance_valid(pemain.sasaran):
        teks = str(pemain.sasaran.get_meta("label", ""))
    hud.set_prompt(teks)


func _unhandled_input(event):
    # papan ketik (untuk uji di komputer): E = aksi, F = senter
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_E or event.keycode == KEY_SPACE:
            GameState.interaksi_ditekan.emit()
        elif event.keycode == KEY_F:
            GameState.senter_ditekan.emit()
