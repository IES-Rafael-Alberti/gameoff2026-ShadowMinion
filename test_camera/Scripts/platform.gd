extends RigidBody3D	

@onready var player: CharacterBody3D = $"../../Player"
@onready var obstacleVisibility: RayCast3D = $ObstacleVisibility

# Set if the platform is monitoring or not who enter the area
func _process(delta: float) -> void:
	if player._getMovement3DActive() == true or obstacleVisibility.seeObstacle == false:
		get_child(2).set_deferred("monitoring", false)
	else:
		get_child(2).set_deferred("monitoring", true)

# Activate the collisiion when a character enter the area
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("enter")
	get_child(1).set_deferred("disabled", false)

# Disable the collision when the character exit the area
func _on_area_3d_body_exited(body: Node3D) -> void:
	print("exit")
	get_child(1).set_deferred("disabled", true)
