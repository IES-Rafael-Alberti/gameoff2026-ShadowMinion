extends CSGBox3D

@onready var interaction_area = $InteractionArea
@onready var animation_player_palanca: AnimationPlayer = $AnimationPlayerPalanca
@onready var animation_player_trampilla: AnimationPlayer = $"../../trampilla/AnimationPlayerTrampilla"

var ya_activado: bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if interaction_area:
		interaction_area.interact = _player_move_lever



func _player_move_lever() -> void:
	#Si ya se activó, o el cuerpo no es el jugador, ignoramos
	if ya_activado:
		return
	
	ya_activado = true
	
	#Reproducimos la animación
	if animation_player_palanca:
		animation_player_palanca.play("mover_palanca")
	
	if animation_player_trampilla:
		animation_player_trampilla.play("abrir_trampilla")
	
	#Desactivar detector para que no vuelva a saltar
	interaction_area.set_deferred("monitoring", false)
	interaction_area.queue_free()


func _on_interaction_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_interaction_area_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
