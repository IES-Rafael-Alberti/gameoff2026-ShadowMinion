extends CSGBox3D

@onready var interaction_area = $InteractionArea
@onready var animation_player: AnimationPlayer = $"../../paredes techo y suelo underground/CSGBox3D12/CSGBox3D19/AnimationPlayer"

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
	
	##Reproducimos la animación
	#if animation_player_palanca:
		#animation_player_palanca.play("mover_palanca")
	
	if animation_player:
		animation_player.play("abrir_puerta")
	
	#Desactivar detector para que no vuelva a saltar
	interaction_area.set_deferred("monitoring", false)
	interaction_area.queue_free()
