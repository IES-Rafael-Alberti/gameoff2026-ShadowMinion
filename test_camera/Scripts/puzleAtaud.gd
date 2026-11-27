extends Node3D

@onready var object: RigidBody3D = $"../OBJETO MOVIBLE PUZLE VIDA MUERTE"
@onready var lvlManager: Node = $"../LvlManager"


func _on_detect_object_zone_body_entered(body: Node3D) -> void:
	lvlManager.coffinRidleResolve = true
	object.freeze = true
	print("object enter")


func _on_detect_object_zone_body_exited(body: Node3D) -> void:
	print("Object exit")
