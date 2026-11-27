extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var lvlManager: Node = $"../LvlManager"

var ridle = false

func _ready() -> void:
	if interactionArea:
		interactionArea.interact = _on_interact
	
	Dialogic.signal_event.connect(_on_dialogic_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_interact()->void:
	#if ridle:
		
	if lvlManager.coffinRidleResolve == true:
		print("not return")
		await Dialogic.start("lvl5ThreeDoors")
	else: 
		print("return")
		return

func _on_dialogic_signal(arg: String)->void:
	if arg == "lvl5ThreeDoors":
		print("a")
		lvlManager.threeDoors = true
		ridle = true
	
		if interactionArea:
			interactionArea.monitoring = false
			interactionArea.queue_free()
