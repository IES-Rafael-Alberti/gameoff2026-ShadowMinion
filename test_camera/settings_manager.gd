extends Node

const SAVE_PATH := "user://settings.cfg"

var music_volume: float = 1.0
var sfx_volume: float = 1.0

var _cfg := ConfigFile.new()


func _ready() -> void:
	var err := _cfg.load(SAVE_PATH)
	if err == OK:
		music_volume = clampf(_cfg.get_value("audio", "music", 1.0), 0.0, 1.0)
		sfx_volume = clampf(_cfg.get_value("audio", "sfx", 1.0), 0.0, 1.0)
	apply()


func apply() -> void:
	music_volume = clampf(music_volume, 0.0, 1.0)
	sfx_volume = clampf(sfx_volume, 0.0, 1.0)
	_set_bus("Music", music_volume)
	_set_bus("SFX", sfx_volume)


func _set_bus(bus_name: String, value: float) -> void:
	value = clampf(value, 0.0, 1.0)
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_mute(idx, value <= 0.0)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(value, 0.0001)))


func save_settings() -> void:
	music_volume = clampf(music_volume, 0.0, 1.0)
	sfx_volume = clampf(sfx_volume, 0.0, 1.0)
	_cfg.set_value("audio", "music", music_volume)
	_cfg.set_value("audio", "sfx", sfx_volume)
	_cfg.save(SAVE_PATH)
