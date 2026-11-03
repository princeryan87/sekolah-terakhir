extends RefCounted

# Suara tambahan Misi 6. Dipakai hanya jika tidak ada file audio/<nama>.ogg/.wav/.mp3.

const RATE = 16000


func daftar() -> Array:
    return ["tuyul_tawa", "tuyul_langkah", "kertas_ambil", "denah_pasang"]


func resep(nama: String, sfx):
    if nama == "tuyul_tawa":
        return _tawa(sfx)
    if nama == "tuyul_langkah":
        return sfx._s_langkah(0.12, 220.0, 1.0, 50.0)
    if nama == "kertas_ambil":
        return _kertas(sfx)
    if nama == "denah_pasang":
        return _pasang(sfx)
    return null


func _tawa(sfx):
    var d = sfx._kosong(0.9)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var k = int(t / 0.2)
        var tt = t - k * 0.2
        if k < 4 and tt < 0.12:
            var f = 1100.0 + k * 120.0 + 300.0 * (tt / 0.12)
            f += 40.0 * sin(TAU * 30.0 * t)
            fase += TAU * f / RATE
            var env = sin(PI * tt / 0.12)
            d[i] = (sin(fase) * 0.4 + sin(fase * 2.0) * 0.15) * env
    return d


func _kertas(sfx):
    var d = sfx._kosong(0.35)
    var lp = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var n = randf() * 2.0 - 1.0
        lp += 0.3 * (n - lp)
        var env = sin(PI * t / 0.35) * (0.5 + 0.5 * sin(TAU * 22.0 * t))
        d[i] = (n - lp) * 0.5 * env
    return d


func _pasang(sfx):
    var d = sfx._kosong(0.9)
    var nada = [660.0, 880.0, 1100.0]
    for i in range(d.size()):
        var t = float(i) / RATE
        var x = 0.0
        for k in range(3):
            var tt = t - 0.22 * k
            if tt >= 0.0:
                x += sin(TAU * nada[k] * tt) * exp(-tt * 5.0) * 0.3
        d[i] = x
    return d
