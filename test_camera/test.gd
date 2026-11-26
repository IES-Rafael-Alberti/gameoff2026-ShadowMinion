extends Area3D

@onready var lightPlatform: RigidBody3D = $"../LightPlatform"
@onready var farola: CSGCylinder3D = $"../farola"



func _on_body_entered(body: Node3D) -> void:
	
	var rotateTween = get_tree().create_tween()
	var positionTween = get_tree().create_tween()
	rotateTween.tween_property(farola, "rotation", Vector3(0, 0, 84.4), 1)
	positionTween.tween_property(farola, "position", Vector3(9.057, 0.787, -45.1), 1)
	lightPlatform.queue_free()
	self.queue_free()
