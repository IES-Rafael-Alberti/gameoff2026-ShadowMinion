extends AudioStreamPlayer

@export_file("*.mp3") var music_path: String = "res://Music/Ambience.mp3"

func _ready() -> void:
	# En headless no hay dispositivo de audio: crear un playback hace que Godot
	# reporte fugas al cerrar. Cargado en runtime para no retener el resource.
	if DisplayServer.get_name() == "headless":
		return
	stream = ResourceLoader.load(music_path, "AudioStreamMP3", ResourceLoader.CACHE_MODE_IGNORE)
	play()

func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE:
		stop()
		stream = null
