extends CanvasLayer

# Keypad angka 4 digit. buka() menampilkan, kode_dimasukkan(kode) terkirim saat 4 digit terisi.
# Pemanggil memakai tampil_pesan(teks) dan tutup().

signal kode_dimasukkan(kode)
signal ditutup

const PANJANG = 4
const TOMBOL = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "HAPUS", "0", "TUTUP"]

var kontrol
var aktif = false
var kode = ""
var _rect = {}
var _pesan = ""
var _waktu_sentuh = 0


func _ready():
    kontrol = Control.new()
    kontrol.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(kontrol)
    kontrol.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    kontrol.draw.connect(_gambar)
    visible = false


func buka():
    kode = ""
    _pesan = ""
    aktif = true
    visible = true


func tutup():
    aktif = false
    visible = false


func tampil_pesan(t: String):
    _pesan = t


func _process(_delta):
    if aktif:
        kontrol.queue_redraw()


func _ukuran() -> Vector2:
    return get_viewport().get_visible_rect().size


func _gambar():
    if not aktif:
        return
    var s = _ukuran()
    var font = ThemeDB.fallback_font
    _rect.clear()
    kontrol.draw_rect(Rect2(0.0, 0.0, s.x, s.y), Color(0, 0, 0, 0.7))
    var w = 300.0
    var h = minf(s.y - 20.0, 420.0)
    var p = Rect2((s.x - w) / 2.0, (s.y - h) / 2.0, w, h)
    kontrol.draw_rect(p, Color(0.08, 0.08, 0.1))
    kontrol.draw_rect(p, Color(0.7, 0.15, 0.15), false, 2.0)
    var tampil = ""
    for i in range(PANJANG):
        if i < kode.length():
            tampil += kode[i] + " "
        else:
            tampil += "_ "
    kontrol.draw_string(font, Vector2(p.position.x, p.position.y + 52.0), tampil, HORIZONTAL_ALIGNMENT_CENTER, w, 36, Color(1, 1, 1))
    kontrol.draw_string(font, Vector2(p.position.x, p.position.y + 78.0), _pesan, HORIZONTAL_ALIGNMENT_CENTER, w, 16, Color(1, 0.5, 0.4))
    var atas = p.position.y + 95.0
    var lebar_tombol = (w - 40.0 - 20.0) / 3.0
    var tinggi_tombol = (h - 110.0 - 30.0) / 4.0
    for i in range(TOMBOL.size()):
        var kol = i % 3
        var baris = int(i / 3)
        var r = Rect2(p.position.x + 20.0 + kol * (lebar_tombol + 10.0), atas + baris * (tinggi_tombol + 10.0), lebar_tombol, tinggi_tombol)
        _rect[TOMBOL[i]] = r
        kontrol.draw_rect(r, Color(0.18, 0.1, 0.1))
        kontrol.draw_rect(r, Color(0.6, 0.6, 0.6), false, 1.5)
        kontrol.draw_string(font, Vector2(r.position.x, r.position.y + tinggi_tombol * 0.62), TOMBOL[i], HORIZONTAL_ALIGNMENT_CENTER, lebar_tombol, 20, Color(1, 1, 1))


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
    for nama in _rect:
        if _rect[nama].has_point(pos):
            _tekan(nama)
            return


func _tekan(nama: String):
    if nama == "TUTUP":
        tutup()
        ditutup.emit()
        return
    if nama == "HAPUS":
        kode = kode.substr(0, kode.length() - 1)
        _pesan = ""
        Sfx.putar("keypad_tekan", -10.0)
        return
    if kode.length() < PANJANG:
        kode += nama
        _pesan = ""
        Sfx.putar("keypad_tekan", -6.0)
        if kode.length() == PANJANG:
            var k = kode
            kode = ""
            kode_dimasukkan.emit(k)
