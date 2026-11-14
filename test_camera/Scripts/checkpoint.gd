extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GlobalScript.checkpoint_pos = $Marker3D.global_position
	GlobalScript.previous_checkpoint_node = self
