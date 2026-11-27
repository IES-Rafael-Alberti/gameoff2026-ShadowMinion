extends Node3D

@onready var grass: CSGBox3D = $"../CSGCombiner3D2/CSGBox3D4"
@onready var interactionArea: InteractionArea = $InteractionArea
@onready var lvlManager: Node = $"../LvlManager"

func _ready():
	pass
	
func _physics_process(delta: float) -> void:
	interactionArea.interact = Callable(self, "_onInteract")
	
func _onInteract():
	if lvlManager.scissorPicked:
		print("grass eliminated")
		grass.queue_free()
	else:
		print("You need to pick the scissor first")
