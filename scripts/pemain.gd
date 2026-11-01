extends CharacterBody3D

# Raka. Dibuat sepenuhnya lewat kode (kapsul tabrakan, kamera, senter).

const JALAN = 2.5
const LARI = 4.3
const SENS = 0.0055

var kamera
var senter
var yaw = 0.0
var pitch = 0.0
var terkunci = false
var beku = false
var senter_ada = false
var sasaran = null
var _bob = 0.0
var _jarak_langkah = 0.0


func _ready():
    var cs = CollisionShape3D.new()
    var cap = CapsuleShape3D.new()
    cap.radius = 0.3
    cap.height = 1.7
    cs.shape = cap
    cs.position = Vector3(0.0, 0.85, 0.0)
    add_child(cs)

    kamera = Camera3D.new()
    kamera.position = Vector3(0.0, 1.6, 0.0)
    kamera.fov = 75.0
    kamera.near = 0.05
    kamera.far = 45.0
    add_child(kamera)
    kamera.current = true

    senter = SpotLight3D.new()
    senter.spot_range = 16.0
    senter.spot_angle = 30.0
    senter.light_energy = 3.5
    senter.light_color = Color(1.0, 0.96, 0.82)
    senter.shadow_enabled = false
    senter.position = Vector3(0.15, -0.1, 0.0)
    senter.visible = false
    kamera.add_child(senter)

    GameState.senter_ditekan.connect(_on_senter)


func _on_senter():
    if terkunci or not senter_ada:
        return
    senter.visible = not senter.visible
    Sfx.putar("senter_klik", -4.0)


func _physics_process(delta):
    var gerak = Vector2.ZERO
    var lari = false
    var lihat = GameState.ambil_lihat()
    if not terkunci:
        gerak = GameState.gerak
        lari = GameState.lari
        # papan ketik (untuk uji di komputer)
        if Input.is_key_pressed(KEY_W):
            gerak.y -= 1.0
        if Input.is_key_pressed(KEY_S):
            gerak.y += 1.0
        if Input.is_key_pressed(KEY_A):
            gerak.x -= 1.0
        if Input.is_key_pressed(KEY_D):
            gerak.x += 1.0
        if Input.is_key_pressed(KEY_SHIFT):
            lari = true
        if Input.is_key_pressed(KEY_LEFT):
            lihat.x -= 360.0 * delta
        if Input.is_key_pressed(KEY_RIGHT):
            lihat.x += 360.0 * delta
        if Input.is_key_pressed(KEY_UP):
            lihat.y -= 240.0 * delta
        if Input.is_key_pressed(KEY_DOWN):
            lihat.y += 240.0 * delta
        gerak = gerak.limit_length(1.0)
        yaw -= lihat.x * SENS
        pitch = clampf(pitch - lihat.y * SENS, -1.2, 1.2)

    rotation.y = yaw
    kamera.rotation.x = pitch

    if beku:
        velocity = Vector3.ZERO
        sasaran = null
        return

    var kec = JALAN
    if lari:
        kec = LARI
    var arah = global_transform.basis * Vector3(gerak.x, 0.0, gerak.y)
    velocity.x = move_toward(velocity.x, arah.x * kec, 18.0 * delta)
    velocity.z = move_toward(velocity.z, arah.z * kec, 18.0 * delta)
    if is_on_floor():
        velocity.y = 0.0
    else:
        velocity.y -= 18.0 * delta
    move_and_slide()

    # ayunan kamera dan suara langkah
    var horiz = Vector2(velocity.x, velocity.z).length()
    if horiz > 0.3 and is_on_floor():
        _bob += delta * horiz * 3.0
        _jarak_langkah += horiz * delta
        var panjang = 1.2
        if lari:
            panjang = 1.5
        if _jarak_langkah >= panjang:
            _jarak_langkah = 0.0
            var nama = "langkah_jalan"
            if lari:
                nama = "langkah_lari"
            Sfx.putar(nama, -8.0, randf_range(0.85, 1.15))
        kamera.position.y = 1.6 + sin(_bob) * 0.03
    else:
        kamera.position.y = lerpf(kamera.position.y, 1.6, 0.2)

    # sinar pandang untuk interaksi
    var dari = kamera.global_position
    var ke = dari + (-kamera.global_transform.basis.z) * 2.4
    var q = PhysicsRayQueryParameters3D.create(dari, ke)
    q.exclude = [get_rid()]
    var hasil = get_world_3d().direct_space_state.intersect_ray(q)
    sasaran = null
    if not hasil.is_empty():
        var c = hasil["collider"]
        if c != null and c.has_meta("id"):
            sasaran = c


func getar(durasi: float, kekuatan: float):
    var t = 0.0
    while t < durasi:
        kamera.h_offset = randf_range(-kekuatan, kekuatan)
        kamera.v_offset = randf_range(-kekuatan, kekuatan)
        await get_tree().create_timer(0.03).timeout
        t += 0.03
    kamera.h_offset = 0.0
    kamera.v_offset = 0.0
