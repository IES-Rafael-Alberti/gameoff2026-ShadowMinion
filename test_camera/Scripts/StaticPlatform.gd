extends RigidBody3D	

@onready var player: Player = $"../Player"

# Set if the platform is monitoring or not who enter the area
func _process(delta: float) -> void:
	if player._getMovement3DActive() == true:
		get_child(1).set_deferred("monitoring", false)
	else:
		get_child(1).set_deferred("monitoring", true)

# Activate the collisiion when a character enter the area
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("enter")
	get_child(0).set_deferred("disabled", false)

# Disable the collision when the character exit the area
func _on_area_3d_body_exited(body: Node3D) -> void:
	print("exit")
	get_child(0).set_deferred("disabled", true)
