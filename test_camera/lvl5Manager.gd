extends Node

@onready var platformAPlayer: AnimationPlayer = $"../plataforma en movimiento/AnimationPlayer"
#@onready var platformAPlayer: AnimationPlayer = $"../MeshInstance3D/plataforma en movimiento/AnimationPlayer"

var pictureRidleResolve = false
var treeRidleResolve = false
var coffinRidleResolve = false
var threeDoors = false

func _ready() -> void:
	platformAPlayer.play("move")
