extends Node3D

@onready var lvlManager: Node = $"../LvlManager"
@onready var interactionArea: InteractionArea = $InteractionArea

func _ready():
	pass
	
func _physics_process(delta: float) -> void:
	interactionArea.interact = Callable(self, "_onInteract")
	
func _onInteract():
	if lvlManager.coinPicked:
		print("load nextLevel")
		get_tree().change_scene_to_file("res://lvl_2.tscn")
	else:
		print("You need to pick the coin first")
