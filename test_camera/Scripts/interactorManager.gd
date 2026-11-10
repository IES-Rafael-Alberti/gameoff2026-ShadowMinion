extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")

var activeAreas = []
var canInteract = true

func registerArea(area: InteractionArea):
	activeAreas.push_back(area)
	
func unregisterArea(area: InteractionArea):
	var index = activeAreas.find(area)
	if index != -1:
		activeAreas.remove_at(index)
		
func _process(delta: float) -> void:
	if activeAreas.size() > 0 && canInteract:
		activeAreas.sort_custom(_sortByDistanceToPlayer)
		
func _sortByDistanceToPlayer(area1, area2):
	var area1ToPlayer = player.global_position.distance_to(area1.global_position)
	var area2ToPlayer = player.global_position.distance_to(area2.global_position)
	
	return area1ToPlayer < area2ToPlayer
	
func _input(event):
	if event.is_action_pressed("Interact") && canInteract:
		if activeAreas.size() > 0:
			canInteract = false
			
			await activeAreas[0].interact.call()
			
			canInteract = true
