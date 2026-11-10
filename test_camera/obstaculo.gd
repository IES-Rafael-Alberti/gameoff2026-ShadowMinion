extends Node3D

@onready var interactionArea: InteractionArea = $RightPush

var pushDistance: float = 0.5

func _ready():
	interactionArea.interact = Callable(self, "_onInteract")
	
func _onInteract():
	#position = position.lerp(position + Vector3(-0.5, 0, 0), 0.5)
	print(InteractorManager.activeAreas[0])
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + Vector3(-pushDistance, 0, 0), 0.5)
	
