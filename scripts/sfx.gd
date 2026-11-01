extends Node

# Mesin suara.
# Jika ada file audio/<nama>.ogg (atau .wav / .mp3), file itu yang dipakai.
# Jika tidak ada, suara dibuat lewat kode (sintesis).

const RATE = 16000
const LOOPS = ["ambience_sekolah", "detak_jantung"]
const DAFTAR = [
    "senter_klik", "langkah_jalan", "langkah_lari", "pintu_buka", "pintu_terkunci",
    "kunci_ambil", "sapu", "listrik_mati", "bel_sekolah", "langkah_atas", "bisik",
    "jumpscare", "kuntilanak_tawa", "detak_jantung", "ambience_sekolah"
]

var _cache = {}
var _pemutar = []
var _loop_pemutar = {}


func _ready():
    for i in range(8):
        var p = AudioStreamPlayer.new()
        add_child(p)
        _pemutar.append(p)


func siapkan():
    for nama in DAFTAR:
        _ambil(nama)
        await get_tree().process_frame


func putar(nama: String, db: float = 0.0, pitch: float = 1.0):
    var s = _ambil(nama)
    if s == null:
        return
    var p = null
    for kandidat in _pemutar:
        if not kandidat.playing:
            p = kandidat
            break
    if p == null:
        p = _pemutar[0]
    p.stream = s
    p.volume_db = db
    p.pitch_scale = pitch
    p.play()


func mulai_loop(nama: String, db: float = 0.0):
    if _loop_pemutar.has(nama):
        _loop_pemutar[nama].volume_db = db
        return
    var s = _ambil(nama)
    if s == null:
        return
    var p = AudioStreamPlayer.new()
    p.stream = s
    p.volume_db = db
    add_child(p)
    p.play()
    _loop_pemutar[nama] = p


func atur_loop(nama: String, db: float, pitch: float = 1.0):
    if _loop_pemutar.has(nama):
        _loop_pemutar[nama].volume_db = db
        _loop_pemutar[nama].pitch_scale = pitch


func henti_loop(nama: String):
    if _loop_pemutar.has(nama):
        _loop_pemutar[nama].queue_free()
        _loop_pemutar.erase(nama)


# ---------- pemuatan ----------

func _ambil(nama: String):
    if _cache.has(nama):
        return _cache[nama]
    var s = _dari_file(nama)
    if s == null:
        s = _sintesis(nama)
    _cache[nama] = s
    return s


func _dari_file(nama: String):
    for ekstensi in ["ogg", "wav", "mp3"]:
        var jalur = "res://audio/" + nama + "." + ekstensi
        if ResourceLoader.exists(jalur):
            var r = load(jalur)
            if r is AudioStream:
                if nama in LOOPS:
                    _atur_loop_file(r)
                return r
    return null


func _atur_loop_file(r):
    if r is AudioStreamOggVorbis:
        r.loop = true
    elif r is AudioStreamMP3:
        r.loop = true
    elif r is AudioStreamWAV:
        r.loop_mode = AudioStreamWAV.LOOP_FORWARD
        r.loop_begin = 0
        r.loop_end = int(r.get_length() * r.mix_rate)


func _sintesis(nama: String):
    var d = null
    match nama:
        "senter_klik":
            d = _s_klik()
        "langkah_jalan":
            d = _s_langkah(0.25, 75.0, 1.2, 22.0)
        "langkah_lari":
            d = _s_langkah(0.16, 95.0, 1.4, 34.0)
        "pintu_buka":
            d = _s_pintu_buka()
        "pintu_terkunci":
            d = _s_terkunci()
        "kunci_ambil":
            d = _s_kunci()
        "sapu":
            d = _s_sapu()
        "listrik_mati":
            d = _s_listrik_mati()
        "bel_sekolah":
            d = _s_bel()
        "langkah_atas":
            d = _s_langkah_atas()
        "bisik":
            d = _s_bisik()
        "jumpscare":
            d = _s_jumpscare()
        "kuntilanak_tawa":
            d = _s_kuntilanak()
        "detak_jantung":
            d = _s_jantung()
        "ambience_sekolah":
            d = _s_ambience()
        _:
            d = _s_klik()
    return _ke_wav(d, nama in LOOPS)


func _ke_wav(d: PackedFloat32Array, ulang: bool) -> AudioStreamWAV:
    var bytes = PackedByteArray()
    bytes.resize(d.size() * 2)
    for i in range(d.size()):
        var v = int(clampf(d[i], -1.0, 1.0) * 30000.0)
        bytes.encode_s16(i * 2, v)
    var w = AudioStreamWAV.new()
    w.format = AudioStreamWAV.FORMAT_16_BITS
    w.mix_rate = RATE
    w.stereo = false
    w.data = bytes
    if ulang:
        w.loop_mode = AudioStreamWAV.LOOP_FORWARD
        w.loop_begin = 0
        w.loop_end = d.size()
    return w


func _kosong(detik: float) -> PackedFloat32Array:
    var d = PackedFloat32Array()
    d.resize(int(RATE * detik))
    return d


# ---------- resep suara ----------

func _s_klik():
    var d = _kosong(0.08)
    for i in range(d.size()):
        var t = float(i) / RATE
        var env = exp(-t * 90.0)
        var n = randf() * 2.0 - 1.0
        d[i] = (n * 0.5 + sin(TAU * 1500.0 * t) * 0.5) * env * 0.8
    return d


func _s_langkah(durasi: float, nada: float, kasar: float, peluruh: float):
    var d = _kosong(durasi)
    var lp = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var env = exp(-t * peluruh)
        var n = randf() * 2.0 - 1.0
        lp += 0.2 * (n - lp)
        d[i] = (sin(TAU * nada * t) * 0.8 + lp * kasar) * env * 0.9
    return d


func _s_pintu_buka():
    var d = _kosong(1.0)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 150.0 + 90.0 * sin(t * 5.0) + 140.0 * t
        fase += TAU * f / RATE
        var saw = fmod(fase, TAU) / PI - 1.0
        var env = sin(PI * t)
        var getar = 0.6 + 0.4 * sin(TAU * 23.0 * t)
        var n = randf() * 2.0 - 1.0
        d[i] = (saw * 0.35 * getar + n * 0.08) * env
    return d


func _s_terkunci():
    var d = _kosong(0.6)
    for i in range(d.size()):
        var t = float(i) / RATE
        var x = 0.0
        for k in range(3):
            var tt = t - 0.17 * k
            if tt >= 0.0:
                var n = randf() * 2.0 - 1.0
                x += (sin(TAU * 110.0 * tt) * 0.6 + n * 0.5) * exp(-tt * 40.0)
        d[i] = x * 0.6
    return d


func _s_kunci():
    var d = _kosong(0.7)
    var nada = [2200.0, 3100.0, 2650.0, 3500.0]
    for i in range(d.size()):
        var t = float(i) / RATE
        var x = 0.0
        for k in range(4):
            var tt = t - 0.07 * k
            if tt >= 0.0:
                x += sin(TAU * nada[k] * tt) * exp(-tt * 9.0) * 0.3
        d[i] = x
    return d


func _s_sapu():
    var d = _kosong(0.8)
    var lp = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var env = sin(PI * t / 0.8)
        var n = randf() * 2.0 - 1.0
        lp += 0.25 * (n - lp)
        d[i] = (n - lp) * 0.45 * env * (0.6 + 0.4 * sin(TAU * 9.0 * t))
    return d


func _s_listrik_mati():
    var d = _kosong(1.4)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 100.0 * (1.0 - 0.7 * t / 1.4)
        fase += TAU * f / RATE
        var env = pow(maxf(1.0 - t / 1.4, 0.0), 2.0)
        var pop = exp(-t * 60.0) * (randf() * 2.0 - 1.0)
        d[i] = (sin(fase) * 0.5 + sin(fase * 2.0) * 0.25) * env + pop * 0.8
    return d


func _s_bel():
    var d = _kosong(1.8)
    for i in range(d.size()):
        var t = float(i) / RATE
        var mod = 0.35
        if sin(TAU * 16.0 * t) > 0.0:
            mod = 1.0
        var env = 1.0
        if t > 1.4:
            env = maxf(0.0, 1.0 - (t - 1.4) / 0.4)
        var x = sin(TAU * 1900.0 * t) * 0.35 + sin(TAU * 2350.0 * t) * 0.2 + sin(TAU * 950.0 * t) * 0.15
        d[i] = x * mod * env * 0.8
    return d


func _s_langkah_atas():
    var d = _kosong(2.6)
    var lp = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var n = randf() * 2.0 - 1.0
        lp += 0.12 * (n - lp)
        var x = 0.0
        for k in range(3):
            var tt = t - 0.2 - 0.75 * k
            if tt >= 0.0:
                x += (sin(TAU * 52.0 * tt) * 0.8 + lp * 3.0) * exp(-tt * 12.0)
        d[i] = x * 0.9
    return d


func _s_bisik():
    var d = _kosong(1.4)
    var lp1 = 0.0
    var lp2 = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var n = randf() * 2.0 - 1.0
        lp1 += 0.35 * (n - lp1)
        lp2 += 0.08 * (n - lp2)
        var env = sin(PI * t / 1.4) * (0.55 + 0.45 * sin(TAU * 5.0 * t + 1.0))
        d[i] = (lp1 - lp2) * env * 1.8
    return d


func _s_jumpscare():
    var d = _kosong(1.2)
    var f1 = 0.0
    var f2 = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        f1 += TAU * (220.0 + 40.0 * sin(t * 30.0)) / RATE
        f2 += TAU * 233.0 / RATE
        var saw1 = fmod(f1, TAU) / PI - 1.0
        var saw2 = fmod(f2, TAU) / PI - 1.0
        var n = randf() * 2.0 - 1.0
        var boom = sin(TAU * 45.0 * t) * exp(-t * 5.0)
        var x = n * 0.7 * exp(-t * 3.5) + (saw1 + saw2) * 0.3 * exp(-t * 2.0) + boom * 0.9
        d[i] = clampf(x * 1.2, -1.0, 1.0)
    return d


func _s_kuntilanak():
    var d = _kosong(2.4)
    var fase = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var f = 0.0
        var env = 0.0
        if t < 1.4:
            var k = int(t / 0.22)
            var tk = t - k * 0.22
            if tk < 0.17:
                f = 620.0 + k * 55.0 + 420.0 * (tk / 0.17)
                env = sin(PI * tk / 0.17)
        else:
            var tw = t - 1.4
            f = 900.0 - 380.0 * tw + 18.0 * sin(TAU * 7.0 * tw)
            env = sin(PI * clampf(tw, 0.0, 1.0))
        if env > 0.0:
            fase += TAU * f / RATE
            var napas = (randf() * 2.0 - 1.0) * 0.12
            d[i] = (sin(fase) * 0.45 + sin(fase * 2.0) * 0.22 + sin(fase * 3.0) * 0.08 + napas) * env * 0.9
    return d


func _s_jantung():
    var d = _kosong(1.0)
    for i in range(d.size()):
        var t = float(i) / RATE
        var x = 0.0
        for k in range(2):
            var tt = t - 0.28 * k
            if tt >= 0.0:
                x += sin(TAU * 55.0 * tt) * exp(-tt * 16.0) * (1.0 - 0.3 * k)
        d[i] = x * 0.9
    return d


func _s_ambience():
    var d = _kosong(4.0)
    var lp = 0.0
    for i in range(d.size()):
        var t = float(i) / RATE
        var angin = 0.5 - 0.5 * cos(TAU * t / 4.0)
        var n = randf() * 2.0 - 1.0
        lp += 0.02 * (n - lp)
        var dengung = sin(TAU * 55.0 * t) * 0.18 + sin(TAU * 82.5 * t) * 0.1 * (0.6 + 0.4 * sin(TAU * t / 4.0))
        d[i] = dengung * 0.8 + lp * 2.5 * angin
    return d
