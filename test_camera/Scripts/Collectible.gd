extends Area3D

@onready var lvlManager: Node = $"../LevelManager"

var collectibles = Array()

var scissorPicked: bool = false
var coinPicked: bool = false

func _ready() -> void:
	for i in get_children():
		collectibles.append(i)

func _on_scissor_body_entered(body: Node3D) -> void:
	scissorPicked = true

func _on_coleccionable_dobón_puerta_body_entered(body: Node3D) -> void:
	coinPicked
