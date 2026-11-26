extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var player: Player = $"../Player"

var answer: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if interactionArea:
		interactionArea.interact = _on_interact
	
	Dialogic.signal_event.connect(_on_dialogic_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_interact()->void:
	if answer:
		return
		
	await Dialogic.start("lvl5PassRiver")

func _on_dialogic_signal(arg: String)->void:
	if arg == "PassRiver" and not answer:
		answer = true
		player.position = Vector3(-19.1, 0.464, -16)
	
		if interactionArea:
			interactionArea.monitoring = false
			interactionArea.queue_free()
