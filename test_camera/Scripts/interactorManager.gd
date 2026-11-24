extends Node3D

#@onready var player = get_tree().get_first_node_in_group("player")
var player = null

var activeAreas = []
var canInteract = true

func registerArea(area: InteractionArea):
	print(area)
	activeAreas.push_back(area)
	
func unregisterArea(area: InteractionArea):
	print(area)
	var index = activeAreas.find(area)
	if index != -1:
		activeAreas.remove_at(index)
		
func _process(delta: float) -> void:
	# Limpiamos las áreas que hayan sido destruidas al cambiar de escena
	activeAreas = activeAreas.filter(func(area): return is_instance_valid(area))
	
	# Volvemos a buscar al jugador si el anterior fue destruido
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	
	# Si hay áreas, tenemos jugador y podemos interactuar, ordenamos
	if activeAreas.size() > 0 && canInteract && is_instance_valid(player):
		activeAreas.sort_custom(_sortByDistanceToPlayer)
		
func _sortByDistanceToPlayer(area1, area2):
	if not is_instance_valid(area1) or not is_instance_valid(area2) or not is_instance_valid(player):
		return false
		
	var area1ToPlayer = player.global_position.distance_to(area1.global_position)
	var area2ToPlayer = player.global_position.distance_to(area2.global_position)
	
	return area1ToPlayer < area2ToPlayer
	
func _input(event):
	if event.is_action_pressed("interact") && canInteract:
		activeAreas = activeAreas.filter(func(area): return is_instance_valid(area))
		
		if activeAreas.size() > 0:
			canInteract = false
			
			if is_instance_valid(activeAreas[0]):
				await activeAreas[0].interact.call()
			
			canInteract = true
