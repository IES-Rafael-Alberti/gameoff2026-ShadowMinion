extends Node3D

var player = null

var activeAreas = []
var canInteract = true


func registerArea(area: InteractionArea) -> void:
	# Evita duplicados: una misma área no debe contar dos veces.
	if area == null or activeAreas.has(area):
		return
	activeAreas.push_back(area)


func unregisterArea(area: InteractionArea) -> void:
	if area == null:
		return
	activeAreas = activeAreas.filter(func(a): return a != area)


func _find_player() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	_find_player()

	# Solo mantener áreas que sigan existiendo y cuyo CollisionShape3D
	# siga conteniendo al jugador. Esto elimina restos de otros bodies,
	# áreas liberadas y teletransportes.
	activeAreas = activeAreas.filter(func(area):
		return is_instance_valid(area) and _player_inside(area))

	if activeAreas.size() > 0 and canInteract and is_instance_valid(player):
		activeAreas.sort_custom(_sortByDistanceToPlayer)


func _player_inside(area: Area3D) -> bool:
	if not is_instance_valid(area) or not is_instance_valid(player):
		return false
	# overlaps_body comprueba las collision shapes reales del área.
	return area.monitoring and area.overlaps_body(player)


func _area_center(area: Area3D) -> Vector3:
	# Usar el centro de la CollisionShape3D, no el origen del nodo Area3D,
	# porque en lvl 3_2 los nodos están muy desplazados respecto a su shape.
	for child in area.get_children():
		if child is CollisionShape3D and child.shape != null:
			return child.global_position
	return area.global_position


func _sortByDistanceToPlayer(area1, area2):
	if not is_instance_valid(area1) or not is_instance_valid(area2) or not is_instance_valid(player):
		return false

	var p := player as Node3D
	var area1ToPlayer: float = p.global_position.distance_to(_area_center(area1))
	var area2ToPlayer: float = p.global_position.distance_to(_area_center(area2))
	return area1ToPlayer < area2ToPlayer


func _input(event):
	# is_echo evita que mantener R dispare varias veces seguidas.
	if event.is_echo() or not event.is_action_pressed("interact") or not canInteract:
		return

	_find_player()

	# Doble comprobación justo antes de interactuar: aunque quedara una
	# referencia antigua, R solo sirve si el jugador está dentro de la shape.
	activeAreas = activeAreas.filter(func(area):
		return is_instance_valid(area) and _player_inside(area))

	if activeAreas.size() == 0:
		return

	activeAreas.sort_custom(_sortByDistanceToPlayer)

	var area = activeAreas[0]
	canInteract = false

	if area.interact.is_valid():
		await area.interact.call()

	canInteract = true
