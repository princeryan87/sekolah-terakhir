extends RefCounted

# Suara tambahan Misi 4. Dipakai hanya jika tidak ada file audio/<nama>.ogg/.wav/.mp3.

const RATE = 16000


func daftar() -> Array:
    return ["hantu_siswi_nyanyi", "hantu_siswi_bisik", "buku_jatuh", "keypad_tekan", "keypad_salah", "keypad_benar"]


func resep(nama: String, sfx):
    if nama == "hantu_siswi_nyanyi":
        return _nyanyi(sfx)
    if nama == "hantu_siswi_bisik":
        return sfx._s_bisik()
    if nama == "buku_jatuh":
        return sfx._s_langkah(0.35, 85.0, 2.5, 18.0)
    if nama == "keypad_tekan":
        return _bip(sfx, 0.08, 1800.0, 40.0)
    if nama == "keypad_salah":
        return _salah(sfx)
    if nama == "keypad_benar":
        return _benar(sfx)
    return null


func _nyanyi(sfx):
    var nada = [392.0, 466.2, 440.0, 392.0, 349.2, 392.0, 311.1, 349.2]
    var d = sfx._kosong(3.2)
    for i in range(d.size()):
        var t = float(i) / RATE
        var k = mini(int(t / 0.4), nada.size() - 1)
        var tt = t - k * 0.4
        var f = nada[k] * (1.0 + 0.004 * sin(TAU * 5.5 * t))
        var env = exp(-tt * 3.0) * minf(tt * 40.0, 1.0)
        d[i] = (sin(TAU * f * t) * 0.6 + sin(TAU * f * 2.0 * t) * 0.15) * env * 0.5
    return d


func _bip(sfx, detik: float, f: float, peluruh: float):
    var d = sfx._kosong(detik)
    for i in range(d.size()):
        var t = float(i) / RATE
        d[i] = sin(TAU * f * t) * exp(-t * peluruh) * 0.6
    return d


func _salah(sfx):
    var d = sfx._kosong(0.4)
    for i in range(d.size()):
        var t = float(i) / RATE
        var kotak = 1.0
        if sin(TAU * 150.0 * t) < 0.0:
            kotak = -1.0
        d[i] = kotak * 0.35 * (1.0 - t / 0.4)
    return d


func _benar(sfx):
    var d = sfx._kosong(0.4)
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 1200.0
        var tt = t
        if t >= 0.2:
            f = 1600.0
            tt = t - 0.2
        d[i] = sin(TAU * f * t) * exp(-tt * 14.0) * 0.5
    return d
