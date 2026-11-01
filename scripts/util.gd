extends RefCounted

# Jika tampilan 3D rusak (kotak tidak muncul / layar hitam),
# ubah baris di bawah ini menjadi: const EFEK_PS1 = false
const EFEK_PS1 = true

const SHADER_PS1 = preload("res://shaders/ps1.gdshader")

static var _cache = {}


static func bahan(warna: Color, emisi: float = 0.0):
    var kunci = warna.to_html() + "_" + str(emisi)
    if _cache.has(kunci):
        return _cache[kunci]
    var m = null
    if EFEK_PS1:
        var sm = ShaderMaterial.new()
        sm.shader = SHADER_PS1
        sm.set_shader_parameter("warna", warna)
        sm.set_shader_parameter("emisi", emisi)
        m = sm
    else:
        var sb = StandardMaterial3D.new()
        sb.albedo_color = warna
        sb.roughness = 1.0
        if emisi > 0.0:
            sb.emission_enabled = true
            sb.emission = warna
            sb.emission_energy_multiplier = emisi
        m = sb
    _cache[kunci] = m
    return m


static func kotak(induk: Node, posisi: Vector3, ukuran: Vector3, warna: Color, padat: bool = true, emisi: float = 0.0):
    var mi = MeshInstance3D.new()
    var bm = BoxMesh.new()
    bm.size = ukuran
    mi.mesh = bm
    mi.material_override = bahan(warna, emisi)
    if padat:
        var body = StaticBody3D.new()
        body.position = posisi
        var cs = CollisionShape3D.new()
        var bs = BoxShape3D.new()
        bs.size = ukuran
        cs.shape = bs
        body.add_child(cs)
        body.add_child(mi)
        induk.add_child(body)
        return body
    mi.position = posisi
    induk.add_child(mi)
    return mi
