extends Node3D

var dialogue_playing = false


@onready var player: Player = $Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Dialogic.signal_event.connect(_on_dialogic_signal)
	
	#Se conecta las señales de dialogic
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
	#Iniciamos el diálogo, solo si no se ha visto ya
	if not GlobalScript.intro_dialogue_seen:
		Dialogic.start("timeline")


func _on_timeline_started() -> void:
	dialogue_playing = true
	if player:
		player.is_in_dialogue = true
		
func _on_timeline_ended() -> void:
	dialogue_playing = false
	GlobalScript.intro_dialogue_seen = true
	if player:
		player.is_in_dialogue = false
	

func _process(delta: float) -> void:
	if dialogue_playing:
		#Si el dialogo está activo, se detiene cualquier lógica de movimiento
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _on_dialogic_signal(argument: String) -> void:
	#if argument == "its_a_signal":
		#print("Prueba de señales de dialogic")
