extends CSGBox3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_detector: Area3D = $player_detector

var ya_activado: bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player_detector:
		player_detector.body_entered.connect(_on_player_stepped_on_platform)



func _on_player_stepped_on_platform(body: Node3D) -> void:
	#Si ya se activó, o el cuerpo no es el jugador, ignoramos
	if ya_activado or not body.is_in_group("player"):
		return
	
	ya_activado = true
	
	#Reproducimos la animación
	if animation_player:
		animation_player.play("fall")
	
	#Desactivar detector para que no vuelva a saltar
	player_detector.set_deferred("monitoring", false)
