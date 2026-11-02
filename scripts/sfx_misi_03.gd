extends RefCounted

# Suara tambahan Misi 3. Dipakai hanya jika tidak ada file audio/<nama>.ogg/.wav/.mp3.

const RATE = 16000


func daftar() -> Array:
    return ["genderuwo_langkah", "genderuwo_geram", "listrik_nyala"]


func resep(nama: String, sfx):
    if nama == "genderuwo_langkah":
        return sfx._s_langkah(0.3, 48.0, 1.8, 16.0)
    if nama == "genderuwo_geram":
        return _geram(sfx)
    if nama == "listrik_nyala":
        return _listrik_nyala(sfx)
    return null


func _geram(sfx):
    var d = sfx._kosong(1.4)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 60.0 + 12.0 * sin(t * 11.0) - 15.0 * t
        fase += TAU * f / RATE
        var saw = fmod(fase, TAU) / PI - 1.0
        var n = randf() * 2.0 - 1.0
        var env = minf(t * 8.0, 1.0) * exp(-t * 1.3)
        d[i] = clampf((saw * 0.7 + n * 0.25 + sin(fase * 0.5) * 0.4) * env, -1.0, 1.0)
    return d


func _listrik_nyala(sfx):
    var d = sfx._kosong(1.0)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 40.0 + 260.0 * t
        fase += TAU * f / RATE
        var env = minf(t * 10.0, 1.0) * (1.0 - t * 0.5)
        var klik = exp(-pow((t - 0.9) * 60.0, 2.0)) * (randf() * 2.0 - 1.0)
        d[i] = (sin(fase) * 0.5 + sin(fase * 2.0) * 0.2) * env + klik * 0.6
    return d
