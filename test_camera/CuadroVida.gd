extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var player: Player = $"../Player"
@onready var object: RigidBody3D = $"../OBJETO MOVIBLE PUZLE VIDA MUERTE"

var answer

func _ready() -> void:
	if interactionArea:
		interactionArea.interact = _on_interact
	
	Dialogic.signal_event.connect(_on_dialogic_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_interact()->void:
	if answer:
		return
		
	await Dialogic.start("lvl5cuadro")

func _on_dialogic_signal(arg: String)->void:
	if arg == "lvlCuadro" and not answer:
		answer = true
		object.freeze = false
	
		if interactionArea:
			interactionArea.monitoring = false
			interactionArea.queue_free()
