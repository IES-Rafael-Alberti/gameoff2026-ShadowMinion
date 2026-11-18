extends Area3D

@onready var mesh_key: MeshInstance3D = $MeshInstance3D

var key_taken = false

func _on_body_entered(body: Node3D) -> void:
	if not is_instance_valid(body):
		return
	if not body.is_in_group("player"):
		return
	
	if key_taken == false:
		key_taken = true
		mesh_key.queue_free()
