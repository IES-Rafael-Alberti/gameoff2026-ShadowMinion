extends Node3D

@onready var interaction_area: InteractionArea = $InteractionArea

@onready var punto_destino: Marker3D = $punto_destino



func _ready() -> void:
	if interaction_area:
		interaction_area.interact = _on_interact_entrar_cueva


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_interact_entrar_cueva()->void:
	print("¡La función de entrar a la cueva se ha activado!") # <--- AÑADE ESTO
	
	var jugador = get_tree().get_first_node_in_group("player")
	
	# Añade esto para saber si encuentra al jugador y al marcador
	if jugador == null:
		print("ERROR: No se encontró al jugador en el grupo 'Player'")
	if punto_destino == null:
		print("ERROR: El nodo 'punto_destino' no existe o está mal escrito")
		
	if jugador != null and punto_destino != null:
		jugador.global_position = punto_destino.global_position
		jugador.velocity = Vector3.ZERO
		print("¡Teletransporte realizado con éxito!")
		
		interaction_area.set_deferred("monitoring", false)
		interaction_area.queue_free()
