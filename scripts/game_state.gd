extends Node

# Data bersama: input sentuh dari HUD, penyimpanan progres misi.

signal interaksi_ditekan
signal senter_ditekan

const JUMLAH_MISI = 10

var gerak = Vector2.ZERO
var lari = false
var lihat = Vector2.ZERO
var data = {"terbuka": 1, "selesai_misi": [], "cp_misi": {}, "dokumen": [], "selesai": 0}


func ambil_lihat():
    var v = lihat
    lihat = Vector2.ZERO
    return v


func simpan():
    var f = FileAccess.open("user://save.json", FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify(data))
        f.close()


func muat():
    if not FileAccess.file_exists("user://save.json"):
        return
    var f = FileAccess.open("user://save.json", FileAccess.READ)
    if f == null:
        return
    var teks = f.get_as_text()
    f.close()
    var hasil = JSON.parse_string(teks)
    if typeof(hasil) == TYPE_DICTIONARY:
        for k in hasil:
            data[k] = hasil[k]
    if typeof(data["cp_misi"]) != TYPE_DICTIONARY:
        data["cp_misi"] = {}
    if typeof(data["selesai_misi"]) != TYPE_ARRAY:
        data["selesai_misi"] = []
    if typeof(data["dokumen"]) != TYPE_ARRAY:
        data["dokumen"] = []


func misi_terbuka(n: int) -> bool:
    return n <= int(data.get("terbuka", 1))


func misi_selesai(n: int) -> bool:
    for x in data["selesai_misi"]:
        if int(x) == n:
            return true
    return false


func tandai_selesai(n: int):
    if not misi_selesai(n):
        data["selesai_misi"].append(n)
    data["terbuka"] = maxi(int(data.get("terbuka", 1)), mini(n + 1, JUMLAH_MISI))
    data["cp_misi"][str(n)] = "awal"
    data["selesai"] = int(data.get("selesai", 0)) + 1
    simpan()


func ambil_cp(n: int) -> String:
    return str(data["cp_misi"].get(str(n), "awal"))


func set_cp(n: int, nama: String):
    data["cp_misi"][str(n)] = nama
    simpan()
