extends Node

# Data bersama: input sentuh dari HUD dan penyimpanan progres.

signal interaksi_ditekan
signal senter_ditekan

var gerak = Vector2.ZERO
var lari = false
var lihat = Vector2.ZERO
var data = {"selesai": 0}


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
