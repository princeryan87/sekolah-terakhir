extends RefCounted

# Suara tambahan Misi 7. Dipakai hanya jika tidak ada file audio/<nama>.ogg/.wav/.mp3.

const RATE = 16000


func daftar() -> Array:
    return ["kuntilanak_melayang", "cermin_tutup", "baterai_ambil", "senter_habis"]


func resep(nama: String, sfx):
    if nama == "kuntilanak_melayang":
        return _melayang(sfx)
    if nama == "cermin_tutup":
        return _kain(sfx)
    if nama == "baterai_ambil":
        return _baterai(sfx)
    if nama == "senter_habis":
        return _habis(sfx)
    return null


func _melayang(sfx):
    var d = sfx._kosong(0.6)
    var lp = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var n = randf() * 2.0 - 1.0
        lp += 0.05 * (n - lp)
        var env = sin(PI * t / 0.6)
        d[i] = (lp * 3.0 + sin(TAU * 400.0 * t) * 0.05) * env * 0.5
    return d


func _kain(sfx):
    var d = sfx._kosong(0.5)
    var lp = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var n = randf() * 2.0 - 1.0
        lp += 0.2 * (n - lp)
        var env = sin(PI * t / 0.5)
        d[i] = (n - lp) * 0.5 * env
    return d


func _baterai(sfx):
    var d = sfx._kosong(0.3)
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 900.0
        var tt = t
        if t >= 0.12:
            f = 1300.0
            tt = t - 0.12
        d[i] = sin(TAU * f * t) * exp(-tt * 16.0) * 0.5
    return d


func _habis(sfx):
    var d = sfx._kosong(0.6)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 600.0 - 500.0 * (t / 0.6)
        fase += TAU * f / RATE
        d[i] = sin(fase) * exp(-t * 4.0) * 0.5
    return d
