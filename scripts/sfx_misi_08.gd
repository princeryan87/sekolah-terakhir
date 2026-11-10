extends RefCounted

# Suara tambahan Misi 8. Dipakai hanya jika tidak ada file audio/<nama>.ogg/.wav/.mp3.

const RATE = 16000


func daftar() -> Array:
    return ["angin_lapangan"]


func loops() -> Array:
    return ["angin_lapangan"]


func resep(nama: String, sfx):
    if nama == "angin_lapangan":
        return _angin(sfx)
    return null


func _angin(sfx):
    var d = sfx._kosong(4.0)
    var lp = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var n = randf() * 2.0 - 1.0
        lp += 0.06 * (n - lp)
        var swell = 0.5 - 0.5 * cos(TAU * t / 4.0)
        d[i] = lp * 4.0 * (0.4 + 0.6 * swell) * 0.5
    return d
