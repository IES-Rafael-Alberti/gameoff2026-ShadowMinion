extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var right_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/RightRayCast
@onready var left_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/LeftRayCast
@onready var front_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/FrontRayCast
@onready var back_ray_cast: RayCast3D = $InteractionArea/CollisionShape3D/BackRayCast

@export var pushDistance: float = 0.5

func _ready():
	interactionArea.interact = Callable(self, "_onInteract")
	
func _onInteract():
	#position = position.lerp(position + Vector3(-0.5, 0, 0), 0.5)
	print(InteractorManager.activeAreas[0])
	var pushDirection: Vector3
	var tween = get_tree().create_tween()
	if right_ray_cast.is_colliding():
		pushDirection = Vector3(-pushDistance, 0, 0)
		print("right colliding")
	elif left_ray_cast.is_colliding():
		pushDirection = Vector3(pushDistance, 0, 0)
		print("left colliding")
	elif front_ray_cast.is_colliding():
		pushDirection = Vector3(0, 0, -pushDistance)
		print("left colliding")
	elif back_ray_cast.is_colliding():
		pushDirection = Vector3(0, 0, pushDistance)
		print("left colliding")
		
	tween.tween_property(self, "position", position + pushDirection, 0.5)
