extends Node

var checkpoint_pos: Vector3 = Vector3(-999, -999, -999)
var previous_checkpoint_node: Area3D = null
var intro_dialogue_seen: bool = false
var is_3d_mode: bool = false

func set_3d_mode(active: bool) -> void:
	is_3d_mode = active
	for nodo in get_tree().get_nodes_in_group("only_in_3d_mode"):
		if "visible" in nodo:
			nodo.visible = active
		
		#Pausa la lógica y la física si no está activo
		if active:
			nodo.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			nodo.process_mode = Node.PROCESS_MODE_DISABLED
