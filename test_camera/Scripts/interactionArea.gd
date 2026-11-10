class_name  InteractionArea extends Area3D

@export var actionName: String = "Interact"

var interact: Callable = func():
	pass
	
	
func _on_body_entered(body: Node3D) -> void:
	InteractorManager.registerArea(self)


func _on_body_exited(body: Node3D) -> void:
	InteractorManager.unregisterArea(self)
