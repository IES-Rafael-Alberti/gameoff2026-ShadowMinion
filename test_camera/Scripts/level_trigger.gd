extends Area3D

@export_group("Configuración del nivel")
# Arrastra aquí el archivo .tscn del nivel al que quieres ir
@export_file("*.tscn") var target_level_path: String = ""
# Posición exacta donde aparecerá el jugador en el nuevo nivel
@export var target_spawn_position: Vector3 = Vector3(0, 2, 0) 
var transitioning: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# level_trigger.tscn ya trae la conexión guardada; no duplicarla
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if transitioning or not body.is_in_group("player"):
		return
	if target_level_path == "":
		return
	transitioning = true
	
	# Se guarda la posición en el GlobalScript
	GlobalScript.next_spawn_pos = target_spawn_position
	GlobalScript.use_next_spawn = true 
	
	# Se limpia el checkpoint anterior para que no interfiera
	GlobalScript.checkpoint_pos = Vector3(-999, -999, -999) 
	
	get_tree().change_scene_to_file(target_level_path)
