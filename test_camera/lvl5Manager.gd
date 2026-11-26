extends Node

@onready var platformAPlayer: AnimationPlayer = $"../plataforma en movimiento/AnimationPlayer"

func _ready() -> void:
	platformAPlayer.play("move")
