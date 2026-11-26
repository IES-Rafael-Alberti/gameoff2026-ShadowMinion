extends Node3D

@onready var interaction_area: InteractionArea = $InteractionArea

@onready var punto_destino: Marker3D = $punto_destino

func _ready() -> void:
	if interaction_area:
		interaction_area.interact = _on_interact_salir_cueva


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_interact_salir_cueva()->void:
	var jugador = get_tree().get_first_node_in_group("player")
	
	if jugador != null and punto_destino != null:
		jugador.global_position = punto_destino.global_position
		
		jugador.velocity = Vector3.ZERO
		
		interaction_area.set_deferred("monitoring", false)
		interaction_area.queue_free()
