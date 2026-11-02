extends CanvasLayer

# Tampilan layar + kontrol sentuh multi-jari (joystick kiri, geser kanan, tombol).
# Tidak memakai Button bawaan Godot karena hanya mendukung satu jari.

signal layar_disentuh

const R_JOY = 64.0

var kontrol
var overlay
var kilat_rect
var label_prompt
var label_misi
var label_bicara
var label_kartu
var label_judul
var label_sub
var label_info

var kontrol_tampil = false
var senter_tersedia = false
var menunggu = false
var jari_gerak = -1
var jari_lihat = -1
var jari_tombol = {}
var asal_gerak = Vector2.ZERO
var pos_gerak = Vector2.ZERO
var _bicara_id = 0
var _lewati = false
var celah = false
var pilihan_menu = "kiri"
var waspada = 0.0
var kejar_tampil = false


func _ready():
    # tepi layar gelap (vinyet)
    var g = Gradient.new()
    g.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.85)])
    g.offsets = PackedFloat32Array([0.45, 1.0])
    var tex = GradientTexture2D.new()
    tex.gradient = g
    tex.fill = GradientTexture2D.FILL_RADIAL
    tex.fill_from = Vector2(0.5, 0.5)
    tex.fill_to = Vector2(1.0, 0.5)
    tex.width = 128
    tex.height = 128
    var vin = TextureRect.new()
    vin.texture = tex
    vin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    vin.stretch_mode = TextureRect.STRETCH_SCALE
    vin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(vin)
    vin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    # kontrol sentuh (digambar lewat kode)
    kontrol = Control.new()
    kontrol.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(kontrol)
    kontrol.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    kontrol.draw.connect(_gambar)

    label_prompt = _label(22, Color(1, 1, 1))
    _atur(label_prompt, 0.0, 0.58, 1.0, 0.58, 0.0, 0.0, 0.0, 40.0)
    label_misi = _label(17, Color(0.85, 0.85, 0.6))
    label_misi.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _atur(label_misi, 0.0, 0.0, 1.0, 0.0, 20.0, 14.0, -20.0, 50.0)
    label_bicara = _label(21, Color(1, 0.95, 0.85))
    _atur(label_bicara, 0.0, 1.0, 1.0, 1.0, 210.0, -175.0, -210.0, -95.0)

    overlay = ColorRect.new()
    overlay.color = Color(0, 0, 0, 1)
    overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(overlay)
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    label_kartu = _label(26, Color(0.9, 0.9, 0.9))
    label_kartu.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _atur(label_kartu, 0.0, 0.0, 1.0, 1.0, 90.0, 0.0, -90.0, 0.0)
    label_judul = _label(48, Color(0.8, 0.1, 0.1))
    _atur(label_judul, 0.0, 0.2, 1.0, 0.2, 0.0, 0.0, 0.0, 80.0)
    label_sub = _label(24, Color(0.85, 0.85, 0.85))
    _atur(label_sub, 0.0, 0.42, 1.0, 0.42, 90.0, 0.0, -90.0, 170.0)
    label_info = _label(20, Color(0.7, 0.7, 0.7))
    _atur(label_info, 0.0, 0.8, 1.0, 0.8, 0.0, 0.0, 0.0, 40.0)

    kilat_rect = ColorRect.new()
    kilat_rect.color = Color(1, 1, 1, 0)
    kilat_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(kilat_rect)
    kilat_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _label(ukuran: int, warna: Color) -> Label:
    var l = Label.new()
    l.add_theme_font_size_override("font_size", ukuran)
    l.add_theme_color_override("font_color", warna)
    l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
    l.add_theme_constant_override("outline_size", 6)
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    l.visible = false
    add_child(l)
    return l


func _atur(c, al, at, ar, ab, ol, ot, orr, ob):
    c.anchor_left = al
    c.anchor_top = at
    c.anchor_right = ar
    c.anchor_bottom = ab
    c.offset_left = ol
    c.offset_top = ot
    c.offset_right = orr
    c.offset_bottom = ob


func _ukuran() -> Vector2:
    return get_viewport().get_visible_rect().size


func _process(_delta):
    kontrol.queue_redraw()


# ---------- tampilan ----------

func reset_total():
    kontrol_tampil = false
    senter_tersedia = false
    menunggu = false
    celah = false
    waspada = 0.0
    kejar_tampil = false
    _bicara_id += 1
    label_prompt.visible = false
    label_misi.visible = false
    label_misi.text = ""
    label_bicara.visible = false
    label_kartu.visible = false
    label_judul.visible = false
    label_sub.visible = false
    label_info.visible = false
    kilat_rect.color = Color(1, 1, 1, 0)
    overlay.color = Color(0, 0, 0, 0)
    reset_input()


func hitamkan():
    overlay.color = Color(0, 0, 0, 1)


func fade(alpha: float, durasi: float):
    var tw = create_tween()
    tw.tween_property(overlay, "color:a", alpha, durasi)
    await tw.finished


func kilat(durasi: float):
    kilat_rect.color = Color(1, 1, 1, 1)
    var tw = create_tween()
    tw.tween_property(kilat_rect, "color:a", 0.0, durasi)


func judul_tampil(j: String, s: String, info: String):
    label_judul.text = j
    label_judul.visible = true
    label_sub.text = s
    label_sub.visible = true
    label_info.text = info
    label_info.visible = true


func judul_sembunyi():
    label_judul.visible = false
    label_sub.visible = false
    label_info.visible = false


func tampil_teks(t: String):
    label_kartu.text = t
    label_kartu.visible = true


func sembunyi_teks():
    label_kartu.visible = false


func tampil_kontrol(b: bool):
    kontrol_tampil = b
    label_misi.visible = b and label_misi.text != ""
    if not b:
        label_prompt.visible = false
        reset_input()


func reset_input():
    jari_gerak = -1
    jari_lihat = -1
    jari_tombol.clear()
    GameState.gerak = Vector2.ZERO
    GameState.lari = false
    GameState.lihat = Vector2.ZERO


func set_celah(b: bool):
    celah = b


func set_waspada(v: float, kejar: bool):
    waspada = v
    kejar_tampil = kejar


func set_prompt(t: String):
    label_prompt.text = t
    label_prompt.visible = (t != "" and kontrol_tampil)


func misi(t: String):
    label_misi.text = "MISI: " + t
    label_misi.visible = kontrol_tampil


func bicara(teks: String, durasi: float = 3.0):
    _bicara_id += 1
    var id = _bicara_id
    label_bicara.text = teks
    label_bicara.visible = true
    await get_tree().create_timer(durasi).timeout
    if id == _bicara_id:
        label_bicara.visible = false


func kartu(teks: String, durasi: float):
    label_kartu.text = teks
    label_kartu.visible = true
    _lewati = false
    var t = 0.0
    while t < durasi and not (_lewati and t > 0.5):
        await get_tree().process_frame
        t += get_process_delta_time()
    label_kartu.visible = false


func tunggu_sentuh():
    await get_tree().create_timer(0.4).timeout
    menunggu = true
    await layar_disentuh


func layar_akhir(j: String, isi: String, info: String):
    label_judul.text = j
    label_judul.visible = true
    label_sub.text = isi
    label_sub.visible = true
    label_info.text = info
    label_info.visible = true
    await get_tree().create_timer(1.0).timeout
    menunggu = true
    await layar_disentuh


# ---------- menggambar kontrol ----------

func _tombol_def(s: Vector2) -> Dictionary:
    return {
        "interaksi": [Vector2(s.x - 110.0, s.y - 110.0), 52.0, "AKSI"],
        "lari": [Vector2(s.x - 235.0, s.y - 70.0), 40.0, "LARI"],
        "senter": [Vector2(s.x - 85.0, s.y - 235.0), 38.0, "SENTER"]
    }


func _gambar():
    if not kontrol_tampil:
        return
    var s = _ukuran()
    var font = ThemeDB.fallback_font
    if celah:
        kontrol.draw_rect(Rect2(0.0, 0.0, s.x, s.y * 0.36), Color(0, 0, 0, 0.97))
        kontrol.draw_rect(Rect2(0.0, s.y * 0.64, s.x, s.y * 0.36), Color(0, 0, 0, 0.97))
    if waspada > 0.02:
        var lebar = 180.0
        var x0 = s.x * 0.5 - lebar * 0.5
        kontrol.draw_rect(Rect2(x0, 14.0, lebar, 10.0), Color(0, 0, 0, 0.5))
        kontrol.draw_rect(Rect2(x0, 14.0, lebar * waspada, 10.0), Color(0.9, 0.1, 0.1, 0.9))
        var label_w = "DIAWASI"
        if kejar_tampil:
            label_w = "LARI!"
        kontrol.draw_string(font, Vector2(x0, 42.0), label_w, HORIZONTAL_ALIGNMENT_CENTER, lebar, 16, Color(1, 0.4, 0.4, 0.95))
    var pusat = Vector2(120.0, s.y - 120.0)
    if jari_gerak != -1:
        pusat = asal_gerak
    kontrol.draw_circle(pusat, R_JOY, Color(1, 1, 1, 0.08))
    kontrol.draw_arc(pusat, R_JOY, 0.0, TAU, 40, Color(1, 1, 1, 0.3), 2.0)
    var knob = pusat
    if jari_gerak != -1:
        knob = pusat + (pos_gerak - asal_gerak).limit_length(R_JOY)
    kontrol.draw_circle(knob, 26.0, Color(1, 1, 1, 0.25))
    var defs = _tombol_def(s)
    for nama in defs:
        if nama == "senter" and not senter_tersedia:
            continue
        var d = defs[nama]
        var aktif = false
        for idx in jari_tombol:
            if jari_tombol[idx] == nama:
                aktif = true
        var a = 0.16
        if aktif:
            a = 0.38
        kontrol.draw_circle(d[0], d[1], Color(1, 1, 1, a))
        kontrol.draw_arc(d[0], d[1], 0.0, TAU, 32, Color(1, 1, 1, 0.4), 2.0)
        kontrol.draw_string(font, Vector2(d[0].x - d[1], d[0].y + 6.0), d[2], HORIZONTAL_ALIGNMENT_CENTER, d[1] * 2.0, 14, Color(1, 1, 1, 0.85))
    kontrol.draw_circle(s * 0.5, 2.5, Color(1, 1, 1, 0.5))


# ---------- input sentuh ----------

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            _sentuh_mulai(event.index, event.position)
        else:
            _sentuh_selesai(event.index)
    elif event is InputEventScreenDrag:
        _sentuh_geser(event.index, event.position, event.relative)
    elif event is InputEventMouseButton:
        if event.pressed and menunggu:
            pilihan_menu = "kiri"
            if event.position.x > _ukuran().x * 0.5:
                pilihan_menu = "kanan"
            menunggu = false
            layar_disentuh.emit()
    elif event is InputEventKey:
        if event.pressed and menunggu:
            menunggu = false
            layar_disentuh.emit()


func _sentuh_mulai(idx: int, pos: Vector2):
    if menunggu:
        pilihan_menu = "kiri"
        if pos.x > _ukuran().x * 0.5:
            pilihan_menu = "kanan"
        menunggu = false
        layar_disentuh.emit()
        return
    _lewati = true
    if not kontrol_tampil:
        return
    var s = _ukuran()
    var defs = _tombol_def(s)
    for nama in defs:
        if nama == "senter" and not senter_tersedia:
            continue
        var d = defs[nama]
        if pos.distance_to(d[0]) <= d[1] + 10.0:
            jari_tombol[idx] = nama
            if nama == "interaksi":
                GameState.interaksi_ditekan.emit()
            elif nama == "senter":
                GameState.senter_ditekan.emit()
            elif nama == "lari":
                GameState.lari = true
            return
    if pos.x < s.x * 0.42:
        if jari_gerak == -1:
            jari_gerak = idx
            asal_gerak = pos
            pos_gerak = pos
        return
    if jari_lihat == -1:
        jari_lihat = idx


func _sentuh_selesai(idx: int):
    if idx == jari_gerak:
        jari_gerak = -1
        GameState.gerak = Vector2.ZERO
    if idx == jari_lihat:
        jari_lihat = -1
    if jari_tombol.has(idx):
        if jari_tombol[idx] == "lari":
            GameState.lari = false
        jari_tombol.erase(idx)


func _sentuh_geser(idx: int, pos: Vector2, rel: Vector2):
    if idx == jari_gerak:
        pos_gerak = pos
        var v = ((pos - asal_gerak) / R_JOY).limit_length(1.0)
        if v.length() < 0.15:
            v = Vector2.ZERO
        GameState.gerak = v
    elif idx == jari_lihat:
        GameState.lihat += rel
