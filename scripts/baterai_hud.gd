extends CanvasLayer

# Indikator baterai senter di pojok kanan atas. Hanya menggambar, tidak menangkap sentuhan.

var kontrol
var nilai = 100.0


func _ready():
    kontrol = Control.new()
    kontrol.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(kontrol)
    kontrol.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    kontrol.draw.connect(_gambar)


func set_nilai(v: float):
    nilai = v
    kontrol.queue_redraw()


func _gambar():
    var s = get_viewport().get_visible_rect().size
    var x = s.x - 110.0
    var y = 14.0
    var warna = Color(0.4, 0.9, 0.4)
    if nilai < 35.0:
        warna = Color(0.95, 0.8, 0.2)
    if nilai < 15.0:
        warna = Color(0.95, 0.2, 0.2)
    kontrol.draw_rect(Rect2(x, y, 80.0, 22.0), Color(0, 0, 0, 0.5))
    kontrol.draw_rect(Rect2(x + 2.0, y + 2.0, 76.0 * nilai / 100.0, 18.0), warna)
    kontrol.draw_rect(Rect2(x, y, 80.0, 22.0), Color(1, 1, 1, 0.6), false, 1.5)
    kontrol.draw_rect(Rect2(x + 80.0, y + 6.0, 5.0, 10.0), Color(1, 1, 1, 0.6))
    kontrol.draw_string(ThemeDB.fallback_font, Vector2(x - 70.0, y + 17.0), "SENTER", HORIZONTAL_ALIGNMENT_RIGHT, 66.0, 14, Color(1, 1, 1, 0.8))
