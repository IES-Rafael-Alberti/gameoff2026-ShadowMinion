extends CSGCombiner3D

@onready var interaction_area = $InteractionArea
@onready var animation_player: AnimationPlayer = $"../../Plataformas ajedrez/plataforma1_desc/AnimationPlayer"

var puzzle_resuelto: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if interaction_area:
		interaction_area.interact = _on_interact_estanteria
	
	Dialogic.signal_event.connect(_on_dialogic_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_interact_estanteria()->void:
	if puzzle_resuelto:
		return
		
	Dialogic.start("acertijo1")

func _on_dialogic_signal(arg: String)->void:
	if arg == "next_plataform1" and not puzzle_resuelto:
		puzzle_resuelto = true
		animation_player.play("descend")
	
		if interaction_area:
			interaction_area.monitoring = false
			interaction_area.queue_free()
		


func _on_interaction_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_interaction_area_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
