extends Node

# Penyusun utama. Gambar 3D dirender kecil lalu diperbesar (efek pixel ala PS1).
# Ubah PENGECIL: 2 = lebih tajam, 3 = lebih kasar/retro, 4 = sangat kasar.
const PENGECIL = 3

const HudScript = preload("res://scripts/hud.gd")
const PemainScript = preload("res://scripts/pemain.gd")
const DuniaScript = preload("res://scripts/dunia.gd")

var hud
var pemain
var dunia


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
    var vp = SubViewport.new()
    vp.msaa_3d = Viewport.MSAA_DISABLED
    wadah.add_child(vp)

    hud = HudScript.new()
    hud.layer = 10
    add_child(hud)
    hud.hitamkan()
    hud.judul_tampil("SEKOLAH TERAKHIR", "jam 00:00", "Sentuh layar untuk mulai")

    dunia = DuniaScript.new()
    vp.add_child(dunia)
    pemain = PemainScript.new()
    vp.add_child(pemain)
    dunia.siapkan(pemain, hud)

    await hud.tunggu_sentuh()
    hud.judul_sembunyi()
    hud.tampil_teks("Memuat suara...")
    await get_tree().process_frame
    await Sfx.siapkan()
    hud.sembunyi_teks()
    await dunia.mulai()


func _process(_delta):
    if pemain == null or hud == null:
        return
    var teks = ""
    if not pemain.terkunci and pemain.sasaran != null and is_instance_valid(pemain.sasaran):
        teks = str(pemain.sasaran.get_meta("label", ""))
    hud.set_prompt(teks)


func _unhandled_input(event):
    # papan ketik (untuk uji di komputer): E = aksi, F = senter
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_E or event.keycode == KEY_SPACE:
            GameState.interaksi_ditekan.emit()
        elif event.keycode == KEY_F:
            GameState.senter_ditekan.emit()
