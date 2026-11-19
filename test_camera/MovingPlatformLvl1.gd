extends CSGBox3D

@onready var lvlManager: Node = $"../../LvlManager"

@export var speed: float = 5.0

@export var minHeight: float
@export var maxHeight: float = 2.1

func _physics_process(delta: float) -> void:
	
	if lvlManager.scissorPicked:
		movement()

func movement():
	var tween = get_tree().create_tween()
	if position.z <= minHeight:
		tween.tween_property(self, "position", Vector3(position.x, maxHeight, position.z), 1)
	elif position.z >= maxHeight:
		tween.tween_property(self, "position", Vector3(position.x, minHeight, position.z), 1)
	
