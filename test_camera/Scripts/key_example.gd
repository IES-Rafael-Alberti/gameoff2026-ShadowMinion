extends Area3D

@onready var moneda: MeshInstance3D = $Moneda


var key_taken = false

func _on_body_entered(body: Node3D) -> void:
	if not is_instance_valid(body):
		return
	if not body.is_in_group("player"):
		return
	
	if key_taken == false:
		key_taken = true
		moneda.queue_free()
