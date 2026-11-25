class_name InteractionArea extends Area3D

@export var actionName: String = "Interact"

var interact: Callable = func():
	pass
	
	
func _on_body_entered(body: Node3D) -> void:
	print("area entered")
	InteractorManager.registerArea(self)


func _on_body_exited(body: Node3D) -> void:
	print("area exit")
	InteractorManager.unregisterArea(self)


func _on_interaction_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
