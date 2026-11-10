extends RefCounted

# Suara tambahan Misi 10. Dipakai hanya jika tidak ada file audio/<nama>.ogg/.wav/.mp3.

const RATE = 16000


func daftar() -> Array:
    return ["lonceng_besar", "kepsek_muncul", "kepsek_geram", "gerbang_buka"]


func resep(nama: String, sfx):
    if nama == "lonceng_besar":
        return _lonceng(sfx)
    if nama == "kepsek_muncul":
        return _muncul(sfx)
    if nama == "kepsek_geram":
        return _geram(sfx)
    if nama == "gerbang_buka":
        return _gerbang(sfx)
    return null


func _lonceng(sfx):
    var d = sfx._kosong(2.5)
    var rasio = [1.0, 2.0, 2.76, 5.4, 8.9]
    var amp = [0.5, 0.3, 0.25, 0.12, 0.06]
    var peluruh = [1.4, 2.0, 2.6, 4.0, 6.0]
    for i in range(d.size()):
        var t = float(i) / RATE
        var x = 0.0
        for k in range(5):
            x += sin(TAU * 220.0 * rasio[k] * t) * amp[k] * exp(-t * peluruh[k])
        d[i] = x * minf(t * 200.0, 1.0)
    return d


func _muncul(sfx):
    var d = sfx._kosong(0.8)
    for i in range(d.size()):
        var t = float(i) / RATE
        var n = randf() * 2.0 - 1.0
        var env = sin(PI * t / 0.8)
        d[i] = n * 0.3 * env + sin(TAU * 50.0 * t) * exp(-t * 5.0) * 0.8
    return d


func _geram(sfx):
    var d = sfx._kosong(1.5)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 70.0 - 15.0 * t
        fase += TAU * f / RATE
        var x = 0.0
        for k in range(1, 6):
            x += sin(fase * k) * (0.5 / k)
        var am = 0.7 + 0.3 * sin(TAU * 8.0 * t)
        var env = minf(t * 10.0, 1.0) * exp(-t * 1.2)
        d[i] = clampf(x * am * env * 1.2, -1.0, 1.0)
    return d


func _gerbang(sfx):
    var d = sfx._kosong(2.0)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 120.0 + 80.0 * t / 2.0 + 25.0 * sin(t * 6.0)
        fase += TAU * f / RATE
        var saw = fmod(fase, TAU) / PI - 1.0
        var getar = 0.6 + 0.4 * sin(TAU * 17.0 * t)
        var n = randf() * 2.0 - 1.0
        d[i] = (saw * 0.35 * getar + n * 0.08) * sin(PI * t / 2.0)
    return d
