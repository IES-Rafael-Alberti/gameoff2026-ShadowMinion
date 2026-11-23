extends Node

@onready var scissor: Area3D = $Scissor
@onready var coleccionable_dobón_puerta: Area3D = $"coleccionable dobón puerta"
@onready var animationPlayer: AnimationPlayer = $"../Plataformas finales/plataforma que se desplaza/AnimationPlayer"

var scissorPicked: bool = false
var coinPicked: bool = false

func _on_scissor_body_entered(body: Node3D) -> void:
	scissorPicked = true
	scissor.queue_free()
	animationPlayer.play("move")


func _on_coleccionable_dobón_puerta_body_entered(body: Node3D) -> void:
	coinPicked = true
	coleccionable_dobón_puerta.queue_free()
