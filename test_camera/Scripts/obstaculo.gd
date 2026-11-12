extends Node3D

#@onready var interactionArea: InteractionArea = $InteractionArea
#@onready var right_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/RightRayCast
#@onready var left_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/LeftRayCast
#@onready var front_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/FrontRayCast
#@onready var back_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/BackRayCast
#@onready var node_3d: Node3D = $"../Node3D"

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var right_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/RightRayCast
@onready var left_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/LeftRayCast
@onready var front_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/FrontRayCast
@onready var back_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/BackRayCast
@onready var platform: RigidBody3D = $"../Plataforma2D"

@export var pushDistance: float = 0.5

func _ready():
	interactionArea.interact = Callable(self, "_onInteract")
	
func _onInteract():
	#position = position.lerp(position + Vector3(-0.5, 0, 0), 0.5)
	var pushDirection: Vector3
	var obstacleTween = get_tree().create_tween()
	var platformTween = get_tree().create_tween()
	if right_ray_cast.is_colliding():
		pushDirection = Vector3(-pushDistance, 0, 0)
		print("right colliding")
	elif left_ray_cast.is_colliding():
		pushDirection = Vector3(pushDistance, 0, 0)
		print("left colliding")
	elif front_ray_cast.is_colliding():
		pushDirection = Vector3(0, 0, -pushDistance)
		print("front colliding")
	elif back_ray_cast.is_colliding():
		pushDirection = Vector3(0, 0, pushDistance)
		print("back colliding")
		
	if right_ray_cast.is_colliding() or left_ray_cast.is_colliding():
		obstacleTween.tween_property(self, "position", position + pushDirection, 0.5)
		platformTween.tween_property(platform, "position", platform.position + pushDirection, 0.5)
	elif front_ray_cast.is_colliding() or back_ray_cast.is_colliding():
		obstacleTween.tween_property(self, "position", position + pushDirection, 0.5)
	
