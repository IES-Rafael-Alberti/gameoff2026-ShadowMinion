extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var object: RigidBody3D = $"../OBJETO MOVIBLE PUZLE VIDA MUERTE"
@onready var lvlManager: Node = $"../LvlManager"

var objectIn = false
var ridle = false

func _ready() -> void:
	if interactionArea:
		interactionArea.interact = _on_interact
	
	Dialogic.signal_event.connect(_on_dialogic_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_interact()->void:
	if ridle:
		print("return")
		return
		
	print("not return")
	await Dialogic.start("lvl5Arbol")

func _on_dialogic_signal(arg: String)->void:
	if arg == "lvl5Arbol":
		print("a")
		object.freeze = false
		ridle = true
		lvlManager.treeRidleResolve = true
	
		if interactionArea:
			interactionArea.monitoring = false
			interactionArea.queue_free()


func _on_detect_object_zone_body_entered(body: Node3D) -> void:
	object.freeze = true
	print("object enter")


func _on_detect_object_zone_body_exited(body: Node3D) -> void:
	print("Object exit")
