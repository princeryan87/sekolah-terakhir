extends RefCounted

# Suara tambahan Misi 5. Dipakai hanya jika tidak ada file audio/<nama>.ogg/.wav/.mp3.

const RATE = 16000


func daftar() -> Array:
    return ["pocong_lompat", "pocong_erang", "kunci_besi", "pintu_besi"]


func resep(nama: String, sfx):
    if nama == "pocong_lompat":
        return sfx._s_langkah(0.3, 60.0, 1.6, 20.0)
    if nama == "pocong_erang":
        return _erang(sfx)
    if nama == "kunci_besi":
        return _kunci_besi(sfx)
    if nama == "pintu_besi":
        return _pintu_besi(sfx)
    return null


func _erang(sfx):
    var d = sfx._kosong(1.6)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 130.0 - 40.0 * t / 1.6 + 8.0 * sin(TAU * 5.0 * t)
        fase += TAU * f / RATE
        var n = randf() * 2.0 - 1.0
        var env = sin(PI * t / 1.6)
        d[i] = (sin(fase) * 0.5 + sin(fase * 2.0) * 0.25 + n * 0.1) * env
    return d


func _kunci_besi(sfx):
    var d = sfx._kosong(0.7)
    for i in range(d.size()):
        var t = float(i) / RATE
        var x = sin(TAU * 800.0 * t) * 0.4 + sin(TAU * 1230.0 * t) * 0.3 + sin(TAU * 1870.0 * t) * 0.2
        d[i] = x * exp(-t * 9.0) * 0.6 + sin(TAU * 70.0 * t) * exp(-t * 25.0) * 0.5
    return d


func _pintu_besi(sfx):
    var d = sfx._kosong(1.4)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        fase += TAU * (70.0 + 10.0 * sin(t * 7.0)) / RATE
        var saw = fmod(fase, TAU) / PI - 1.0
        var n = randf() * 2.0 - 1.0
        var getar = 0.6 + 0.4 * sin(TAU * 18.0 * t)
        d[i] = (saw * 0.5 + n * 0.25) * getar * sin(PI * t / 1.4)
    return d
