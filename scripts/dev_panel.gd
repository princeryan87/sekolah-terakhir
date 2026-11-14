extends CanvasLayer

# Panel developer tersembunyi. Tidak ada tombol di layar.
# Cara membuka: di menu, ketuk tulisan "THE LAST" 7 kali dalam 3 detik.
# Di dalam misi: tahan 4 jari di layar selama 2 detik.
# Saat terbuka, game dijeda (get_tree().paused).
# Matikan seluruh fitur ini di rilis dengan GameState.CHEAT_TERSEDIA = false.

signal ditutup

const KECEPATAN = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

var main
var kontrol
var aktif = false
var _rect = {}
var _konfirmasi_hapus = false
var _pesan = ""
var _waktu_sentuh = 0


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    kontrol = Control.new()
    kontrol.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(kontrol)
    kontrol.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    kontrol.draw.connect(_gambar)
    visible = false


func buka():
    aktif = true
    visible = true
    _konfirmasi_hapus = false
    _pesan = ""
    get_tree().paused = true


func tutup():
    aktif = false
    visible = false
    get_tree().paused = false
    ditutup.emit()


func _process(_delta):
    if aktif:
        kontrol.queue_redraw()


func _onoff(b: bool) -> String:
    if b:
        return "NYALA"
    return "mati"


func _daftar() -> Array:
    var hapus = "Hapus simpanan"
    if _konfirmasi_hapus:
        hapus = "YAKIN? Tekan lagi untuk menghapus"
    return [
        ["kebal", "Kebal (tidak bisa ditangkap): " + _onoff(GameState.dev_kebal)],
        ["beku", "Bekukan semua hantu: " + _onoff(GameState.dev_beku)],
        ["info", "Info debug di layar: " + _onoff(GameState.dev_info)],
        ["kecepatan", "Kecepatan hantu: x%s (ketuk untuk ganti)" % str(GameState.dev_kecepatan)],
        ["buka", "Buka semua misi"],
        ["selesai", "Selesaikan misi ini sekarang"],
        ["baterai", "Isi penuh baterai senter (Misi 7)"],
        ["hapus", hapus],
        ["tutup", "TUTUP"]
    ]


func _gambar():
    if not aktif:
        return
    var s = get_viewport().get_visible_rect().size
    var font = ThemeDB.fallback_font
    _rect.clear()
    kontrol.draw_rect(Rect2(0.0, 0.0, s.x, s.y), Color(0, 0, 0, 0.8))
    var daftar = _daftar()
    var w = minf(500.0, s.x - 30.0)
    var tinggi_baris = 38.0
    var jarak = 6.0
    var h = 50.0 + daftar.size() * (tinggi_baris + jarak) + 24.0
    var p = Rect2((s.x - w) / 2.0, maxf(8.0, (s.y - h) / 2.0), w, h)
    kontrol.draw_rect(p, Color(0.06, 0.06, 0.08))
    kontrol.draw_rect(p, Color(0.3, 0.8, 0.3), false, 2.0)
    kontrol.draw_string(font, Vector2(p.position.x, p.position.y + 32.0), "MODE DEVELOPER", HORIZONTAL_ALIGNMENT_CENTER, w, 22, Color(0.4, 1.0, 0.4))
    for i in range(daftar.size()):
        var r = Rect2(p.position.x + 16.0, p.position.y + 46.0 + i * (tinggi_baris + jarak), w - 32.0, tinggi_baris)
        _rect[daftar[i][0]] = r
        kontrol.draw_rect(r, Color(0.12, 0.16, 0.12))
        kontrol.draw_rect(r, Color(0.5, 0.6, 0.5), false, 1.5)
        kontrol.draw_string(font, Vector2(r.position.x + 10.0, r.position.y + 25.0), daftar[i][1], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 20.0, 16, Color(1, 1, 1))
    if _pesan != "":
        kontrol.draw_string(font, Vector2(p.position.x, p.position.y + h - 8.0), _pesan, HORIZONTAL_ALIGNMENT_CENTER, w, 15, Color(1.0, 0.9, 0.5))


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
    for id in _rect:
        if _rect[id].has_point(pos):
            _tekan(id)
            return


func _tekan(id: String):
    if id != "hapus":
        _konfirmasi_hapus = false
    if id == "kebal":
        GameState.dev_kebal = not GameState.dev_kebal
    elif id == "beku":
        GameState.dev_beku = not GameState.dev_beku
    elif id == "info":
        GameState.dev_info = not GameState.dev_info
    elif id == "kecepatan":
        var i = KECEPATAN.find(GameState.dev_kecepatan)
        GameState.dev_kecepatan = KECEPATAN[(i + 1) % KECEPATAN.size()]
    elif id == "buka":
        GameState.dev_buka_semua()
        _pesan = "Semua misi terbuka."
    elif id == "selesai":
        if main != null and main.dev_selesaikan_misi():
            tutup()
        else:
            _pesan = "Tidak sedang berada di dalam misi."
    elif id == "baterai":
        if main != null and main.dev_isi_baterai():
            _pesan = "Baterai terisi penuh."
        else:
            _pesan = "Hanya berlaku di Misi 7."
    elif id == "hapus":
        if _konfirmasi_hapus:
            GameState.dev_hapus()
            _konfirmasi_hapus = false
            _pesan = "Simpanan dihapus."
        else:
            _konfirmasi_hapus = true
    elif id == "tutup":
        tutup()
