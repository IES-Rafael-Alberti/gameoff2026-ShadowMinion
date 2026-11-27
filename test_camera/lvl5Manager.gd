extends Node

@onready var platformAPlayer: AnimationPlayer = $"../plataforma en movimiento/AnimationPlayer"
#@onready var platformAPlayer: AnimationPlayer = $"../MeshInstance3D/plataforma en movimiento/AnimationPlayer"

func _ready() -> void:
	platformAPlayer.play("move")
