extends CanvasLayer

# Menu utama THE LAST: 10 kartu misi. Misi terkunci diberi ikon gembok.
# Misi yang filenya (scripts/misi/misi_NN.gd) belum ada tampil "SEGERA".

signal misi_dipilih(n, lanjut)

const KOLOM = 5

var kontrol
var aktif = false
var popup = 0
var _info = {}
var _rect_kartu = {}
var _rect_popup = {}
var _pesan = ""
var _pesan_t = 0.0
var _waktu_sentuh = 0


func _ready():
    var bg = ColorRect.new()
    bg.color = Color(0.02, 0.02, 0.03, 1.0)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    kontrol = Control.new()
    kontrol.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(kontrol)
    kontrol.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    kontrol.draw.connect(_gambar)
    visible = false


func tampil():
    _muat_info()
    popup = 0
    _pesan = ""
    aktif = true
    visible = true


func sembunyi():
    aktif = false
    visible = false


func _muat_info():
    _info.clear()
    for n in range(1, GameState.JUMLAH_MISI + 1):
        var d = {"ada": false, "judul": "Misi %d" % n, "ringkas": ""}
        var jalur = "res://scripts/misi/misi_%02d.gd" % n
        if ResourceLoader.exists(jalur):
            var s = load(jalur)
            if s != null:
                d["ada"] = true
                var m = s.get_script_constant_map()
                if m.has("JUDUL"):
                    d["judul"] = str(m["JUDUL"])
                if m.has("RINGKAS"):
                    d["ringkas"] = str(m["RINGKAS"])
        _info[n] = d


func _process(delta):
    if not aktif:
        return
    if _pesan_t > 0.0:
        _pesan_t -= delta
        if _pesan_t <= 0.0:
            _pesan = ""
    kontrol.queue_redraw()


func _ukuran() -> Vector2:
    return get_viewport().get_visible_rect().size


# ---------- gambar ----------

func _gambar():
    if not aktif:
        return
    var s = _ukuran()
    var font = ThemeDB.fallback_font
    _rect_kartu.clear()
    _rect_popup.clear()

    kontrol.draw_string(font, Vector2(0.0, s.y * 0.15), "THE LAST", HORIZONTAL_ALIGNMENT_CENTER, s.x, 52, Color(0.8, 0.1, 0.1))
    kontrol.draw_string(font, Vector2(0.0, s.y * 0.15 + 30.0), "pilih misi", HORIZONTAL_ALIGNMENT_CENTER, s.x, 20, Color(0.7, 0.7, 0.7))

    var mx = 40.0
    var celah = 14.0
    var lebar = (s.x - 2.0 * mx - celah * (KOLOM - 1)) / KOLOM
    var tinggi = minf(lebar * 0.95, (s.y * 0.62 - celah) / 2.0)
    var y0 = s.y * 0.27
    for i in range(GameState.JUMLAH_MISI):
        var n = i + 1
        var baris = i / KOLOM
        var kol = i % KOLOM
        var r = Rect2(mx + kol * (lebar + celah), y0 + baris * (tinggi + celah), lebar, tinggi)
        _rect_kartu[n] = r
        _gambar_kartu(n, r, font)

    if _pesan != "":
        kontrol.draw_string(font, Vector2(0.0, s.y - 22.0), _pesan, HORIZONTAL_ALIGNMENT_CENTER, s.x, 18, Color(1.0, 0.8, 0.5))

    if popup > 0:
        _gambar_popup(s, font)


func _gambar_kartu(n: int, r: Rect2, font):
    var ada = _info[n]["ada"]
    var buka = GameState.misi_terbuka(n) and ada
    var selesai = GameState.misi_selesai(n)
    var isi = Color(0.07, 0.07, 0.09)
    var garis = Color(0.3, 0.3, 0.33)
    if buka:
        isi = Color(0.16, 0.05, 0.05)
        garis = Color(0.8, 0.15, 0.15)
    kontrol.draw_rect(r, isi)
    kontrol.draw_rect(r, garis, false, 2.0)
    if buka:
        kontrol.draw_string(font, Vector2(r.position.x, r.position.y + r.size.y * 0.42), str(n), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 38, Color(1, 1, 1))
        kontrol.draw_multiline_string(font, Vector2(r.position.x + 6.0, r.position.y + r.size.y * 0.62), _info[n]["judul"], HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 12.0, 13, 2, Color(0.9, 0.85, 0.8))
        if selesai:
            kontrol.draw_string(font, Vector2(r.position.x, r.position.y + r.size.y - 8.0), "SELESAI", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 13, Color(0.4, 0.9, 0.4))
        elif GameState.ambil_cp(n) != "awal":
            kontrol.draw_string(font, Vector2(r.position.x, r.position.y + r.size.y - 8.0), "TERSIMPAN", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 13, Color(0.9, 0.8, 0.4))
    else:
        _gambar_gembok(r.get_center() + Vector2(0.0, -6.0))
        kontrol.draw_string(font, Vector2(r.position.x, r.position.y + 22.0), str(n), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 18, Color(0.5, 0.5, 0.55))
        var teks = "TERKUNCI"
        if not ada:
            teks = "SEGERA"
        kontrol.draw_string(font, Vector2(r.position.x, r.position.y + r.size.y - 8.0), teks, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 13, Color(0.55, 0.55, 0.6))


func _gambar_gembok(c: Vector2):
    var warna = Color(0.6, 0.6, 0.65)
    kontrol.draw_arc(c + Vector2(0.0, -4.0), 11.0, PI, TAU, 16, warna, 4.0)
    kontrol.draw_rect(Rect2(c.x - 15.0, c.y - 4.0, 30.0, 24.0), warna)
    kontrol.draw_circle(c + Vector2(0.0, 7.0), 3.5, Color(0.1, 0.1, 0.12))
    kontrol.draw_rect(Rect2(c.x - 1.5, c.y + 7.0, 3.0, 8.0), Color(0.1, 0.1, 0.12))


func _gambar_popup(s: Vector2, font):
    kontrol.draw_rect(Rect2(0.0, 0.0, s.x, s.y), Color(0, 0, 0, 0.75))
    var w = minf(420.0, s.x - 60.0)
    var h = 250.0
    var kotak = Rect2((s.x - w) / 2.0, (s.y - h) / 2.0, w, h)
    kontrol.draw_rect(kotak, Color(0.1, 0.06, 0.06))
    kontrol.draw_rect(kotak, Color(0.8, 0.15, 0.15), false, 2.0)
    kontrol.draw_string(font, Vector2(kotak.position.x, kotak.position.y + 36.0), "Misi %d: %s" % [popup, _info[popup]["judul"]], HORIZONTAL_ALIGNMENT_CENTER, w, 20, Color(1, 1, 1))
    var nama = ["lanjut", "ulang", "batal"]
    var teks = ["LANJUTKAN", "ULANGI DARI AWAL", "BATAL"]
    for i in range(3):
        var rb = Rect2(kotak.position.x + 30.0, kotak.position.y + 62.0 + i * 58.0, w - 60.0, 46.0)
        _rect_popup[nama[i]] = rb
        kontrol.draw_rect(rb, Color(0.2, 0.1, 0.1))
        kontrol.draw_rect(rb, Color(0.6, 0.6, 0.6), false, 1.5)
        kontrol.draw_string(font, Vector2(rb.position.x, rb.position.y + 29.0), teks[i], HORIZONTAL_ALIGNMENT_CENTER, rb.size.x, 18, Color(1, 1, 1))


# ---------- input ----------

func _input(event):
    if not aktif:
        return
    if event is InputEventScreenTouch and event.pressed:
        _waktu_sentuh = Time.get_ticks_msec()
        _ketuk(event.position)
    elif event is InputEventMouseButton and event.pressed:
        if Time.get_ticks_msec() - _waktu_sentuh < 500:
            return
        _ketuk(event.position)


func _ketuk(pos: Vector2):
    if popup > 0:
        for nama in _rect_popup:
            if _rect_popup[nama].has_point(pos):
                var n = popup
                popup = 0
                if nama == "lanjut":
                    _mulai(n, true)
                elif nama == "ulang":
                    GameState.set_cp(n, "awal")
                    _mulai(n, false)
        return
    for n in _rect_kartu:
        if _rect_kartu[n].has_point(pos):
            _pilih(n)
            return


func _pilih(n: int):
    if not _info[n]["ada"]:
        _beri_pesan("Misi ini belum tersedia. Tunggu pembaruan berikutnya.")
        return
    if not GameState.misi_terbuka(n):
        _beri_pesan("Terkunci. Selesaikan misi sebelumnya untuk membukanya.")
        return
    if GameState.ambil_cp(n) != "awal":
        popup = n
    else:
        _mulai(n, false)


func _beri_pesan(t: String):
    _pesan = t
    _pesan_t = 2.5
    Sfx.putar("pintu_terkunci", -10.0)


func _mulai(n: int, lanjut: bool):
    sembunyi()
    misi_dipilih.emit(n, lanjut)
