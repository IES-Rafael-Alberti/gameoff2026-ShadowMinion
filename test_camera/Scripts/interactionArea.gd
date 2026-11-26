class_name InteractionArea extends Area3D

@export var actionName: String = "Interact"

var interact: Callable = func():
	pass


func _ready() -> void:
	# Si el área se libera al resolver un puzzle o al teletransportar,
	# la quitamos del manager aunque no llegue body_exited.
	tree_exiting.connect(_on_tree_exiting)


func _on_body_entered(body: Node3D) -> void:
	# IMPORTANTE: los CSGCombiner3D del nivel también son PhysicsBody3D.
	# Si no filtramos, paredes/suelos registran el área y R funciona fuera.
	if body == null or not body.is_in_group("player"):
		return

	InteractorManager.registerArea(self)


func _on_body_exited(body: Node3D) -> void:
	# Mismo filtro: ignorar todo lo que no sea el jugador.
	if body == null or not body.is_in_group("player"):
		return

	InteractorManager.unregisterArea(self)


func _on_tree_exiting() -> void:
	InteractorManager.unregisterArea(self)


func _on_interaction_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
