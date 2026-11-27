extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var lvlManager: Node = $"../LvlManager"

func _ready() -> void:
	interactionArea.interact = Callable(self, "_onInteract")
	
func _onInteract():
	if lvlManager.threeDoors:
		print("ahora a trabaja")
	else:
		print("a estudia")
