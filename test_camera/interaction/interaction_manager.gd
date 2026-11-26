extends Node3D

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@onready var label = $Label

const base_text = "[R] to "

var active_areas = []
var can_interact = true

func _ready() -> void:
	if label:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(delta: float) -> void:
	#Elimina áreas que hayan sido liberadas
	active_areas = active_areas.filter(func(area): return is_instance_valid(area))
	
	#Vuelve a buscar al jugador si el anterior fue liberado
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
		if not is_instance_valid(player):
			label.hide()
			return
	
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		
		var current_area = active_areas[0]
		label.text = base_text + current_area.action_name
		
		label.global_position = current_area.global_position + Vector3(0, 1.2, 0)
		label.show()
	else:
		label.hide()
		
func _sort_by_distance_to_player(area1, area2):
	if not is_instance_valid(area1) or not is_instance_valid(area2):
		return false
	if not is_instance_valid(player):
		return false
		
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player
	
func _input(event):
	if event.is_action_pressed("interact") && can_interact:
		active_areas = active_areas.filter(func(area): return is_instance_valid(area))
		
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			
			var area = active_areas[0]
			if is_instance_valid(area):
				await area.interact.call()
			
			can_interact = true
		
