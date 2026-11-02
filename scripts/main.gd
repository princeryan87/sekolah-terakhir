extends Node

# Pengendali utama THE LAST. Menampilkan menu, lalu menjalankan skrip misi terpilih
# (scripts/misi/misi_NN.gd). Gambar 3D dirender kecil lalu diperbesar (efek PS1).
# Ubah PENGECIL: 2 = lebih tajam, 3 = lebih kasar/retro, 4 = sangat kasar.
const PENGECIL = 3

const HudScript = preload("res://scripts/hud.gd")
const PemainScript = preload("res://scripts/pemain.gd")
const MenuScript = preload("res://scripts/menu.gd")

var hud
var pemain = null
var dunia = null
var vp
var menu
var misi = null


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
    menu.tampil()


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


func _process(_delta):
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
