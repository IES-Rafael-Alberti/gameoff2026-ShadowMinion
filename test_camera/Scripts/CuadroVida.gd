extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
#@onready var player: Player = $"../Player"
@onready var object: RigidBody3D = $"../OBJETO MOVIBLE PUZLE VIDA MUERTE"

var answer = false

func _ready() -> void:
	if interactionArea:
		interactionArea.interact = _on_interact
	
	Dialogic.signal_event.connect(_on_dialogic_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_interact()->void:
	if answer:
		print("return")
		return
		
	print("not return")
	await Dialogic.start("lvl5Cuadro")

func _on_dialogic_signal(arg: String)->void:
	if arg == "lvl5Cuadro" and not answer:
		print("a")
		answer = true
		object.freeze = false
	
		if interactionArea:
			interactionArea.monitoring = false
			interactionArea.queue_free()
